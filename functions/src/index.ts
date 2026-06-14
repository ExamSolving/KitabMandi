import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

// ── Haversine great-circle distance in km ────────────────────────────────────
function haversineKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

interface NearbyUser {
  uid: string;
  token: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// onListingCreated
// Fires when a new listing document is created.
// Queries all Firestore users who have a location within 5 km of the listing,
// writes an in-app notification, and sends an FCM push with the cover image.
// ─────────────────────────────────────────────────────────────────────────────
export const onListingCreated = functions.firestore
  .document("listings/{listingId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const listingId = context.params.listingId as string;

    // Only fire for active listings (edits use update(), not create())
    if (data.status !== "active") return;

    const sellerUid = (data.seller?.uid as string) || "";
    const listingLat = data.location?.lat as number | undefined;
    const listingLong = data.location?.long as number | undefined;
    const title = (data.title as string) || "A Book";
    const price = (data.price as number) || 0;
    const sellerName = (data.seller?.name as string) || "A Seller";

    // First image is the listing cover — shown in the notification
    const images: string[] = Array.isArray(data.images) ? data.images : [];
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
    const nearbyUsers: NearbyUser[] = [];

    for (const userDoc of usersSnap.docs) {
      if (userDoc.id === sellerUid) continue; // never notify the seller
      const user = userDoc.data();
      const token = user.fcmToken as string | undefined;
      const userLat = user.location?.lat as number | undefined;
      const userLong = user.location?.long as number | undefined;
      if (!token || userLat === undefined || userLong === undefined) continue;
      const dist = haversineKm(listingLat, listingLong, userLat, userLong);
      if (dist <= 5) nearbyUsers.push({ uid: userDoc.id, token });
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
    const payload: Record<string, string> = {
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
        notification: {
          title: notifTitle,
          body: notifBody,
          ...(coverImage ? { imageUrl: coverImage } : {}),
        },
        data: payload,
        // Android: show big-image style + correct channel
        android: {
          priority: "high",
          notification: {
            channelId: "kitabmandi_high",
            sound: "default",
            ...(coverImage ? { imageUrl: coverImage } : {}),
          },
        },
        // iOS: mutable-content = 1 lets the Notification Service Extension
        // download and attach the image before it is displayed.
        apns: {
          ...(coverImage ? { fcm_options: { image: coverImage } } : {}),
          payload: {
            aps: {
              sound: "default",
              badge: 1,
              "mutable-content": 1,
            },
          },
        },
      });

      // Remove stale / unregistered tokens so future sends stay clean
      for (let j = 0; j < res.responses.length; j++) {
        const r = res.responses[j];
        if (
          !r.success &&
          r.error?.code === "messaging/registration-token-not-registered"
        ) {
          const uid = nearbyUsers[i + j]?.uid;
          if (uid) {
            await db
              .collection("users")
              .doc(uid)
              .update({ fcmToken: admin.firestore.FieldValue.delete() });
          }
        }
      }
    }

    functions.logger.info(
      `[onListingCreated] Sent to ${nearbyUsers.length} users for listing ${listingId}`
    );
  });

// ─────────────────────────────────────────────────────────────────────────────
// onChatMessageCreated
// Fires when any new message is added to a chat room.
// Notifies the receiver via FCM push + writes an in-app notification.
// ─────────────────────────────────────────────────────────────────────────────
export const onChatMessageCreated = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const msg = snap.data();
    const chatId = context.params.chatId as string;

    const senderId = msg.senderId as string | undefined;
    if (!senderId) return;

    // Fetch the parent chat for participants + metadata
    const chatDoc = await db.collection("chats").doc(chatId).get();
    if (!chatDoc.exists) return;
    const chatData = chatDoc.data()!;

    // Resolve receiverId from message field, falling back to participants array
    let receiverId = msg.receiverId as string | undefined;
    if (!receiverId) {
      const participants = (chatData.participants as string[]) || [];
      receiverId = participants.find((p) => p !== senderId);
    }
    if (!receiverId || receiverId === senderId) return;

    // Fetch sender and receiver concurrently
    const [receiverDoc, senderDoc] = await Promise.all([
      db.collection("users").doc(receiverId).get(),
      db.collection("users").doc(senderId).get(),
    ]);

    const receiverToken = receiverDoc.data()?.fcmToken as string | undefined;
    const senderName = (senderDoc.data()?.name as string) || "Someone";
    const listingTitle = (chatData.listingTitle as string) || "";
    const listingId = (chatData.listingId as string) || "";
    const listingImage = (chatData.listingImage as string) || "";

    // Build body based on message type
    const msgType = (msg.type as string) || "text";
    const notifTitle = senderName;
    let notifBody: string;
    if (msgType === "image") {
      const caption = (msg.caption as string) || "";
      notifBody = caption ? `📷 ${caption}` : "📷 Photo";
    } else {
      const text = (msg.message as string) || "";
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

    const fcmPayload: Record<string, string> = {
      ...storedPayload,
      notif_saved: "true",
    };

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
      functions.logger.info(
        `[onChatMessageCreated] No FCM token for receiver ${receiverId}`
      );
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
      functions.logger.info(
        `[onChatMessageCreated] Notified ${receiverId} in chat ${chatId}`
      );
    } catch (err: unknown) {
      const e = err as { code?: string; message?: string };
      if (e.code === "messaging/registration-token-not-registered") {
        await db
          .collection("users")
          .doc(receiverId)
          .update({ fcmToken: admin.firestore.FieldValue.delete() });
        functions.logger.warn(
          `[onChatMessageCreated] Stale token cleaned for ${receiverId}`
        );
      } else {
        functions.logger.error(
          "[onChatMessageCreated] FCM send error:",
          e.message
        );
      }
    }
  });
