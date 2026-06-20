"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateCoverLetter = exports.generateResume = exports.onChatMessageCreated = exports.onListingCreated = void 0;
const functions = require("firebase-functions");
const params_1 = require("firebase-functions/params");
const admin = require("firebase-admin");
const sdk_1 = require("@anthropic-ai/sdk");
const anthropicKey = (0, params_1.defineSecret)("ANTHROPIC_KEY");
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();
// ── Haversine great-circle distance in km ────────────────────────────────────
function haversineKm(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a = Math.sin(dLat / 2) ** 2 +
        Math.cos((lat1 * Math.PI) / 180) *
            Math.cos((lat2 * Math.PI) / 180) *
            Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
// ─────────────────────────────────────────────────────────────────────────────
// onListingCreated
// Fires when a new listing document is created.
// Queries all Firestore users who have a location within 5 km of the listing,
// writes an in-app notification, and sends an FCM push with the cover image.
// ─────────────────────────────────────────────────────────────────────────────
exports.onListingCreated = functions.firestore
    .document("listings/{listingId}")
    .onCreate(async (snap, context) => {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    const data = snap.data();
    const listingId = context.params.listingId;
    // Only fire for active listings (edits use update(), not create())
    if (data.status !== "active")
        return;
    const sellerUid = ((_a = data.seller) === null || _a === void 0 ? void 0 : _a.uid) || "";
    const listingLat = (_b = data.location) === null || _b === void 0 ? void 0 : _b.lat;
    const listingLong = (_c = data.location) === null || _c === void 0 ? void 0 : _c.long;
    const title = data.title || "A Book";
    const price = data.price || 0;
    const sellerName = ((_d = data.seller) === null || _d === void 0 ? void 0 : _d.name) || "A Seller";
    // First image is the listing cover — shown in the notification
    const images = Array.isArray(data.images) ? data.images : [];
    const coverImage = images.length > 0 ? images[0] : "";
    if (!listingLat || !listingLong || !sellerUid) {
        functions.logger.warn("[onListingCreated] Missing lat/long or seller", {
            listingId,
        });
        return;
    }
    // Fetch every user and filter by Haversine distance ≤ 5 km.
    // Firestore doesn't support native geo-queries without geohash, so we
    // scan all users and filter in JS. Fine for typical user counts.
    const usersSnap = await db.collection("users").get();
    const nearbyUsers = [];
    for (const userDoc of usersSnap.docs) {
        if (userDoc.id === sellerUid)
            continue; // never notify the seller
        const user = userDoc.data();
        const token = user.fcmToken;
        const userLat = (_e = user.location) === null || _e === void 0 ? void 0 : _e.lat;
        const userLong = (_f = user.location) === null || _f === void 0 ? void 0 : _f.long;
        if (!token || userLat === undefined || userLong === undefined)
            continue;
        const dist = haversineKm(listingLat, listingLong, userLat, userLong);
        if (dist <= 5)
            nearbyUsers.push({ uid: userDoc.id, token });
    }
    if (nearbyUsers.length === 0) {
        functions.logger.info("[onListingCreated] No nearby users found", {
            listingId,
        });
        return;
    }
    const notifTitle = "📚 New Book Near You!";
    const notifBody = `"${title}" by ${sellerName} – ₹${price}`;
    // FCM data payload — all values must be strings
    const payload = {
        type: "listing",
        listing_id: listingId,
        listing_title: title,
        listing_image: coverImage,
        seller_name: sellerName,
        // Marker: Cloud Function already wrote the Firestore notif doc,
        // so FCMService.addFromFCM() can skip its own write to avoid duplicates.
        notif_saved: "true",
    };
    // ── 1. Write in-app notification docs to Firestore BEFORE sending FCM ──
    // Writing first means the real-time stream updates the badge count
    // before the push even arrives. Batch in groups of 500 (Firestore limit).
    for (let i = 0; i < nearbyUsers.length; i += 500) {
        const chunk = nearbyUsers.slice(i, i + 500);
        const batch = db.batch();
        for (const u of chunk) {
            const ref = db
                .collection("users")
                .doc(u.uid)
                .collection("notifications")
                .doc();
            batch.set(ref, {
                title: notifTitle,
                body: notifBody,
                type: "listing",
                isRead: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                // Store payload without the internal notif_saved marker
                payload: {
                    type: "listing",
                    listing_id: listingId,
                    listing_title: title,
                    listing_image: coverImage,
                    seller_name: sellerName,
                },
            });
        }
        await batch.commit();
    }
    // ── 2. Send FCM push in batches of 500 (multicast limit) ───────────────
    const tokens = nearbyUsers.map((u) => u.token);
    for (let i = 0; i < tokens.length; i += 500) {
        const chunk = tokens.slice(i, i + 500);
        const res = await fcm.sendEachForMulticast({
            tokens: chunk,
            // Top-level notification: shown by the OS on Android & iOS
            notification: Object.assign({ title: notifTitle, body: notifBody }, (coverImage ? { imageUrl: coverImage } : {})),
            data: payload,
            // Android: show big-image style + correct channel
            android: {
                priority: "high",
                notification: Object.assign({ channelId: "kitabmandi_high", sound: "default" }, (coverImage ? { imageUrl: coverImage } : {})),
            },
            // iOS: mutable-content = 1 lets the Notification Service Extension
            // download and attach the image before it is displayed.
            apns: Object.assign(Object.assign({}, (coverImage ? { fcm_options: { image: coverImage } } : {})), { payload: {
                    aps: {
                        sound: "default",
                        badge: 1,
                        "mutable-content": 1,
                    },
                } }),
        });
        // Remove stale / unregistered tokens so future sends stay clean
        for (let j = 0; j < res.responses.length; j++) {
            const r = res.responses[j];
            if (!r.success &&
                ((_g = r.error) === null || _g === void 0 ? void 0 : _g.code) === "messaging/registration-token-not-registered") {
                const uid = (_h = nearbyUsers[i + j]) === null || _h === void 0 ? void 0 : _h.uid;
                if (uid) {
                    await db
                        .collection("users")
                        .doc(uid)
                        .update({ fcmToken: admin.firestore.FieldValue.delete() });
                }
            }
        }
    }
    functions.logger.info(`[onListingCreated] Sent to ${nearbyUsers.length} users for listing ${listingId}`);
});
// ─────────────────────────────────────────────────────────────────────────────
// onChatMessageCreated
// Fires when any new message is added to a chat room.
// Notifies the receiver via FCM push + writes an in-app notification.
// ─────────────────────────────────────────────────────────────────────────────
exports.onChatMessageCreated = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
    var _a, _b;
    const msg = snap.data();
    const chatId = context.params.chatId;
    const senderId = msg.senderId;
    if (!senderId)
        return;
    // Fetch the parent chat for participants + metadata
    const chatDoc = await db.collection("chats").doc(chatId).get();
    if (!chatDoc.exists)
        return;
    const chatData = chatDoc.data();
    // Resolve receiverId from message field, falling back to participants array
    let receiverId = msg.receiverId;
    if (!receiverId) {
        const participants = chatData.participants || [];
        receiverId = participants.find((p) => p !== senderId);
    }
    if (!receiverId || receiverId === senderId)
        return;
    // Fetch sender and receiver concurrently
    const [receiverDoc, senderDoc] = await Promise.all([
        db.collection("users").doc(receiverId).get(),
        db.collection("users").doc(senderId).get(),
    ]);
    const receiverToken = (_a = receiverDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
    const senderName = ((_b = senderDoc.data()) === null || _b === void 0 ? void 0 : _b.name) || "Someone";
    const listingTitle = chatData.listingTitle || "";
    const listingId = chatData.listingId || "";
    const listingImage = chatData.listingImage || "";
    // Build body based on message type
    const msgType = msg.type || "text";
    const notifTitle = senderName;
    let notifBody;
    if (msgType === "image") {
        const caption = msg.caption || "";
        notifBody = caption ? `📷 ${caption}` : "📷 Photo";
    }
    else {
        const text = msg.message || "";
        notifBody = text.length > 100 ? `${text.substring(0, 97)}…` : text;
    }
    const storedPayload = {
        type: "chat",
        chat_id: chatId,
        listing_id: listingId,
        listing_title: listingTitle,
        listing_image: listingImage,
        sender_id: senderId,
        sender_name: senderName,
        receiver_id: receiverId,
    };
    const fcmPayload = Object.assign(Object.assign({}, storedPayload), { notif_saved: "true" });
    // ── 1. Write in-app notification to Firestore FIRST ────────────────────
    await db
        .collection("users")
        .doc(receiverId)
        .collection("notifications")
        .add({
        title: notifTitle,
        body: notifBody,
        type: "chat",
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        payload: storedPayload,
    });
    // ── 2. Send FCM push (only if receiver has a registered token) ──────────
    if (!receiverToken) {
        functions.logger.info(`[onChatMessageCreated] No FCM token for receiver ${receiverId}`);
        return;
    }
    try {
        await fcm.send({
            token: receiverToken,
            notification: { title: notifTitle, body: notifBody },
            data: fcmPayload,
            android: {
                priority: "high",
                notification: {
                    channelId: "kitabmandi_high",
                    sound: "default",
                },
            },
            apns: {
                payload: {
                    aps: { sound: "default", badge: 1 },
                },
            },
        });
        functions.logger.info(`[onChatMessageCreated] Notified ${receiverId} in chat ${chatId}`);
    }
    catch (err) {
        const e = err;
        if (e.code === "messaging/registration-token-not-registered") {
            await db
                .collection("users")
                .doc(receiverId)
                .update({ fcmToken: admin.firestore.FieldValue.delete() });
            functions.logger.warn(`[onChatMessageCreated] Stale token cleaned for ${receiverId}`);
        }
        else {
            functions.logger.error("[onChatMessageCreated] FCM send error:", e.message);
        }
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// generateResume — Callable Function
// Validates subscription, calls Claude Haiku to build an ATS resume JSON,
// saves to Firestore, and returns the structured data to the Flutter app.
//
// Deploy: firebase deploy --only functions
// Set API key: firebase functions:config:set anthropic.key="sk-ant-..."
// ─────────────────────────────────────────────────────────────────────────────
const RESUME_SYSTEM_PROMPT = `You are an expert ATS (Applicant Tracking System) resume writer and career coach.
Your job is to generate a highly optimized, keyword-rich resume in structured JSON format.

Rules:
- Use STAR format for experience bullets (Situation, Task, Action, Result with metrics)
- Inject relevant keywords from the target JD throughout the resume
- Write a compelling 3-sentence professional summary
- Quantify achievements wherever possible (%, numbers, scale)
- Make every bullet point action-verb-first
- Return ONLY valid JSON — no markdown fences, no explanation text

JSON Schema:
{
  "contact": { "name": string, "email": string, "phone": string, "location": string, "linkedin"?: string, "github"?: string },
  "summary": string,
  "education": [{ "degree": string, "institution": string, "year": string, "gpa"?: string }],
  "skills": { "technical": string[], "soft": string[] },
  "experience": [{ "title": string, "company": string, "duration": string, "bullets": string[] }],
  "projects": [{ "title": string, "tech": string, "link"?: string, "bullets": string[] }],
  "certifications": string[],
  "keywords_matched": string[]
}`;
function buildResumePrompt(data) {
    const { personalInfo, education, skills, softSkills, experience, projects, certifications, targetJd } = data;
    let prompt = `Generate an ATS-optimized resume for:

PERSONAL: ${personalInfo.name} | ${personalInfo.email} | ${personalInfo.phone} | ${personalInfo.location}
${personalInfo.linkedin ? `LinkedIn: ${personalInfo.linkedin}` : ""}
${personalInfo.github ? `GitHub: ${personalInfo.github}` : ""}

EDUCATION: ${education.degree} from ${education.institution} (${education.year})${education.gpa ? ` | GPA: ${education.gpa}` : ""}

TECHNICAL SKILLS: ${skills.join(", ")}
SOFT SKILLS: ${softSkills.join(", ")}`;
    if (experience.length > 0) {
        prompt += "\n\nEXPERIENCE:\n";
        experience.forEach((e) => {
            prompt += `- ${e.title} at ${e.company} (${e.duration}): ${e.description}\n`;
        });
    }
    if (projects.length > 0) {
        prompt += "\n\nPROJECTS:\n";
        projects.forEach((p) => {
            prompt += `- ${p.title} [${p.tech}]${p.link ? ` (${p.link})` : ""}: ${p.description}\n`;
        });
    }
    if (certifications && certifications.length > 0) {
        prompt += `\n\nCERTIFICATIONS: ${certifications.join(", ")}`;
    }
    if (targetJd && targetJd.trim()) {
        prompt += `\n\nTARGET JOB DESCRIPTION (tailor resume keywords to this):\n${targetJd.trim()}`;
    }
    prompt += "\n\nReturn ONLY the JSON object. No extra text.";
    return prompt;
}
exports.generateResume = functions
    .runWith({ secrets: [anthropicKey] })
    .https.onCall(async (data, context) => {
    var _a, _b, _c;
    // 1. Auth
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Sign in required");
    }
    const uid = context.auth.uid;
    // 2. Load user + subscription
    const userDoc = await db.collection("users").doc(uid).get();
    const userData = userDoc.data() || {};
    const sub = (userData.subscription || {});
    const plan = sub.plan || "free";
    // Subscription limits
    const monthLimits = {
        free: 0, // tracked by countLifetime, not monthly
        plus_monthly: 10, plus_annual: 10,
        pro_monthly: 9999, pro_annual: 9999,
    };
    const isFreePlan = plan === "free";
    const maxCount = isFreePlan ? 1 : ((_a = monthLimits[plan]) !== null && _a !== void 0 ? _a : 1);
    // 3. Check usage
    const now = new Date();
    const monthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;
    const usageRaw = (userData.resumeUsage || {});
    let currentCount;
    if (isFreePlan) {
        currentCount = usageRaw.countLifetime || 0;
    }
    else {
        currentCount =
            usageRaw.monthKey === monthKey ? (usageRaw.count || 0) : 0;
    }
    if (currentCount >= maxCount) {
        throw new functions.https.HttpsError("resource-exhausted", `limit_reached:${plan}:${maxCount}`);
    }
    // 4. Call Claude
    const apiKey = (_b = anthropicKey.value()) === null || _b === void 0 ? void 0 : _b.trim();
    if (!apiKey) {
        throw new functions.https.HttpsError("internal", "Anthropic API key not configured");
    }
    let generatedData;
    try {
        const anthropic = new sdk_1.default({ apiKey });
        const message = await anthropic.messages.create({
            model: "claude-haiku-4-5-20251001",
            max_tokens: 4096,
            system: RESUME_SYSTEM_PROMPT,
            messages: [{ role: "user", content: buildResumePrompt(data) }],
        });
        const rawText = message.content[0].type === "text" ? message.content[0].text : "";
        const cleanJson = rawText
            .replace(/^```(?:json)?\s*/m, "")
            .replace(/\s*```\s*$/m, "")
            .trim();
        try {
            generatedData = JSON.parse(cleanJson);
        }
        catch (_d) {
            functions.logger.error("[generateResume] JSON parse failed:", rawText);
            throw new functions.https.HttpsError("internal", "Failed to parse AI response");
        }
    }
    catch (err) {
        if (err instanceof functions.https.HttpsError)
            throw err;
        const e = err;
        functions.logger.error("[generateResume] Anthropic error:", e.message);
        if (e.status === 401) {
            throw new functions.https.HttpsError("internal", "Invalid Anthropic API key — please reset ANTHROPIC_KEY secret");
        }
        throw new functions.https.HttpsError("internal", `AI call failed: ${(_c = e.message) !== null && _c !== void 0 ? _c : "unknown error"}`);
    }
    // 5. Save resume to Firestore
    const resumeRef = db.collection("users").doc(uid).collection("resumes").doc();
    await resumeRef.set({
        id: resumeRef.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        templateId: data.templateId || "classic",
        inputData: data,
        generatedData,
        status: "completed",
    });
    // 6. Update usage counter
    if (isFreePlan) {
        await db.collection("users").doc(uid).update({
            "resumeUsage.countLifetime": admin.firestore.FieldValue.increment(1),
        });
    }
    else {
        await db.collection("users").doc(uid).update({
            resumeUsage: { count: currentCount + 1, monthKey },
        });
    }
    functions.logger.info(`[generateResume] uid=${uid} plan=${plan} count=${currentCount + 1}`);
    return { resumeId: resumeRef.id, generatedData };
});
// ─────────────────────────────────────────────────────────────────────────────
// generateCoverLetter — Callable Function
// Reads the user's existing resume from Firestore, calls Claude to write a
// personalised cover letter, saves it, and returns the text to the app.
// ─────────────────────────────────────────────────────────────────────────────
const COVER_LETTER_SYSTEM_PROMPT = `You are an expert career coach and professional writer specialising in cover letters.
Write a compelling, personalised cover letter that:
- Is exactly 3 paragraphs long
- Paragraph 1: A strong opening hook naming the role and company, and why the applicant is excited about it
- Paragraph 2: 2-3 specific achievements or skills from the resume that directly match the role
- Paragraph 3: A confident, action-oriented closing with a call to action
- Tone: Professional yet warm and personal
- Length: 230-300 words
- Do NOT include date, postal address headers, salutation, or sign-off — output only the three body paragraphs
Return ONLY the cover letter body text. No JSON, no markdown, no labels.`;
exports.generateCoverLetter = functions
    .runWith({ secrets: [anthropicKey] })
    .https.onCall(async (data, context) => {
    var _a, _b, _c;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Sign in required");
    }
    const uid = context.auth.uid;
    const { resumeId, jobTitle, companyName, jobDescription } = data;
    if (!resumeId || !jobTitle || !companyName) {
        throw new functions.https.HttpsError("invalid-argument", "resumeId, jobTitle and companyName are required");
    }
    // Load the resume the user selected
    const resumeDoc = await db
        .collection("users")
        .doc(uid)
        .collection("resumes")
        .doc(resumeId)
        .get();
    if (!resumeDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Resume not found");
    }
    const gd = resumeDoc.data().generatedData;
    const contact = gd.contact || {};
    const skills = (((_a = gd.skills) === null || _a === void 0 ? void 0 : _a.technical) || []).slice(0, 8);
    const experience = gd.experience || [];
    const projects = gd.projects || [];
    const summary = gd.summary || "";
    const userPrompt = `Write a cover letter for ${contact.name || "the applicant"} applying for the role of ${jobTitle} at ${companyName}.

Professional summary: ${summary}
Technical skills: ${skills.join(", ")}
Experience: ${experience.map((e) => `${e.title} at ${e.company} (${e.duration})`).join("; ") || "None listed"}
Projects: ${projects.map((p) => `${p.title} [${p.tech}]`).join("; ") || "None listed"}
${jobDescription ? `\nJob description to tailor towards:\n${jobDescription.slice(0, 1000)}` : ""}

Return only the three body paragraphs. No headers, no sign-off.`;
    const apiKey = (_b = anthropicKey.value()) === null || _b === void 0 ? void 0 : _b.trim();
    if (!apiKey) {
        throw new functions.https.HttpsError("internal", "Anthropic API key not configured");
    }
    let letterText;
    try {
        const anthropic = new sdk_1.default({ apiKey });
        const message = await anthropic.messages.create({
            model: "claude-haiku-4-5-20251001",
            max_tokens: 1024,
            system: COVER_LETTER_SYSTEM_PROMPT,
            messages: [{ role: "user", content: userPrompt }],
        });
        letterText = message.content[0].type === "text" ? message.content[0].text.trim() : "";
    }
    catch (err) {
        const e = err;
        functions.logger.error("[generateCoverLetter] Anthropic error:", e.message);
        if (e.status === 401) {
            throw new functions.https.HttpsError("internal", "Invalid Anthropic API key — please reset ANTHROPIC_KEY secret");
        }
        throw new functions.https.HttpsError("internal", `AI call failed: ${(_c = e.message) !== null && _c !== void 0 ? _c : "unknown error"}`);
    }
    // Persist
    const clRef = db
        .collection("users")
        .doc(uid)
        .collection("coverLetters")
        .doc();
    await clRef.set({
        resumeId,
        jobTitle,
        companyName,
        letterText,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    functions.logger.info(`[generateCoverLetter] uid=${uid} job=${jobTitle} company=${companyName}`);
    return { coverLetterId: clRef.id, letterText };
});
//# sourceMappingURL=index.js.map