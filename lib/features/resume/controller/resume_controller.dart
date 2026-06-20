import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/resume/model/resume_model.dart';
import 'package:kitab_mandi/features/resume/service/resume_pdf_service.dart';

class ResumeController extends GetxController {
  static ResumeController get to => Get.find();

  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Observable state ───────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isGenerating = false.obs;
  final resumes = <ResumeRecord>[].obs;
  final usage = Rxn<ResumeUsage>();
  final sub = Rxn<Map<String, dynamic>>();

  // ── Multi-step form state ──────────────────────────────────────────────────
  final currentStep = 0.obs;

  // Step 1 – Personal
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final githubCtrl = TextEditingController();

  // Step 2 – Education
  final degreeCtrl = TextEditingController();
  final institutionCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final gpaCtrl = TextEditingController();

  // Step 3 – Skills
  final techSkillCtrl = TextEditingController();
  final softSkillCtrl = TextEditingController();
  final techSkills = <String>[].obs;
  final softSkills = <String>[].obs;

  // Step 4 – Experience
  final experiences = <Map<String, TextEditingController>>[].obs;

  // Step 5 – Projects
  final projects = <Map<String, TextEditingController>>[].obs;

  // Step 6 – JD + Template
  final jdCtrl = TextEditingController();
  final selectedTemplate = 'classic'.obs;
  final certCtrl = TextEditingController();
  final certs = <String>[].obs;

  // Last generated result (to open preview immediately)
  final lastGenerated = Rxn<ResumeRecord>();

  // Template preview state
  final isPreviewLoading = false.obs;

  // ── Validation errors — key → error message ────────────────────────────────
  final fieldErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _addExperienceEntry();
    _addProjectEntry();
    _loadAll();
  }

  @override
  void onClose() {
    for (final c in [
      nameCtrl, emailCtrl, phoneCtrl, locationCtrl, linkedinCtrl, githubCtrl,
      degreeCtrl, institutionCtrl, yearCtrl, gpaCtrl,
      techSkillCtrl, softSkillCtrl,
      jdCtrl, certCtrl,
    ]) {
      c.dispose();
    }
    for (final e in experiences) {
      for (final c in e.values) { c.dispose(); }
    }
    for (final p in projects) {
      for (final c in p.values) { c.dispose(); }
    }
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  /// Call after subscription changes so usage limits and plan-gating
  /// update immediately without restarting the app.
  Future<void> reloadAll() => _loadAll();

  Future<void> _loadAll() async {
    isLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Fetch user doc and resumes in parallel — resumes must be available
      // before _computeUsage() so Plus plan can count actual documents.
      final results = await Future.wait([
        _fs.collection('users').doc(uid).get(),
        _fs
            .collection('users')
            .doc(uid)
            .collection('resumes')
            .orderBy('createdAt', descending: true)
            .get(),
      ]);

      final userData =
          ((results[0] as DocumentSnapshot).data() as Map<String, dynamic>?) ??
              {};
      sub.value = userData['subscription'] as Map<String, dynamic>?;

      final loaded = (results[1] as QuerySnapshot).docs
          .map((d) => ResumeRecord.fromDoc(
              Map<String, dynamic>.from(d.data() as Map), d.id))
          .toList();
      resumes.value = loaded;

      _computeUsage(userData, loaded);
    } finally {
      isLoading.value = false;
    }
  }

  void _computeUsage(
      Map<String, dynamic> userData, List<ResumeRecord> loadedResumes) {
    final plan = SubscriptionService.getPlan(sub.value);
    final isActive = SubscriptionService.isActive(sub.value);

    final isFreePlan = !isActive || plan == RazorpayConfig.planFree;
    final isPro = isActive &&
        (plan == RazorpayConfig.planProMonthly ||
            plan == RazorpayConfig.planProAnnual);

    final rawUsage = (userData['resumeUsage'] as Map<String, dynamic>?) ?? {};

    int used;
    int max;
    bool unlimited;

    if (isPro) {
      // Pro: 50 resumes per calendar month (counts actual docs, same as Plus)
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      used = loadedResumes
          .where((r) => !r.createdAt.isBefore(monthStart))
          .length;
      max = 50;
      unlimited = false;
    } else if (isFreePlan) {
      used = (rawUsage['countLifetime'] as int?) ?? 0;
      max = 1;
      unlimited = false;
    } else {
      // Plus plan: count actual resume documents created this calendar month.
      // Using real doc count (not a counter field) means Free-plan generations
      // this month are automatically included after an upgrade.
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      used = loadedResumes
          .where((r) => !r.createdAt.isBefore(monthStart))
          .length;
      max = 10;
      unlimited = false;
    }

    usage.value = ResumeUsage(
      usedCount: used,
      maxCount: max,
      isUnlimited: unlimited,
    );
  }

  // ── Preview ───────────────────────────────────────────────────────────────

  Future<Uint8List?> generatePreview(String templateId) async {
    isPreviewLoading.value = true;
    try {
      final sample = ResumePdfService.sampleResume();
      return await ResumePdfService.generateFrom(sample, templateId);
    } catch (e) {
      Get.snackbar('preview_error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isPreviewLoading.value = false;
    }
  }

  // ── Generate ──────────────────────────────────────────────────────────────

  Future<void> generate() async {
    if (!(usage.value?.canGenerate ?? false)) {
      Get.snackbar(
        'limit_reached'.tr,
        _limitMessage(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isGenerating.value = true;
    try {
      final payload = _buildPayload();
      final callable = FirebaseFunctions.instance.httpsCallable('generateResume');
      final result = await callable.call(payload);
      final data = Map<String, dynamic>.from(result.data as Map);

      final resumeId = data['resumeId'] as String;
      final aiModel = data['aiModel'] as String?;
      final generated = GeneratedResume.fromMap(
          Map<String, dynamic>.from(data['generatedData'] as Map));

      final record = ResumeRecord(
        id: resumeId,
        createdAt: DateTime.now(),
        templateId: selectedTemplate.value,
        data: generated,
        aiModel: aiModel,
      );

      resumes.insert(0, record);
      lastGenerated.value = record;

      // Refresh usage
      await _loadAll();
      Get.back(); // Close form
      Get.toNamed('/resumePreview', arguments: record);
    } on FirebaseFunctionsException catch (e) {
      final msg = e.message ?? 'Generation failed';
      if (msg.startsWith('limit_reached')) {
        Get.snackbar('limit_reached'.tr, _limitMessage(),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGenerating.value = false;
    }
  }

  String _limitMessage() {
    final plan = SubscriptionService.getPlan(sub.value);
    final isActive = SubscriptionService.isActive(sub.value);
    if (!isActive || plan == RazorpayConfig.planFree) {
      return 'Free plan allows 1 resume lifetime. Upgrade to Plus for 10/month.';
    }
    final isPro = plan == RazorpayConfig.planProMonthly ||
        plan == RazorpayConfig.planProAnnual;
    if (isPro) return 'Pro plan allows 50 resumes/month. Limit reached.';
    return 'Plus plan allows 10 resumes/month. Upgrade to Pro for 50/month.';
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'personalInfo': {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        if (linkedinCtrl.text.trim().isNotEmpty)
          'linkedin': linkedinCtrl.text.trim(),
        if (githubCtrl.text.trim().isNotEmpty) 'github': githubCtrl.text.trim(),
      },
      'education': {
        'degree': degreeCtrl.text.trim(),
        'institution': institutionCtrl.text.trim(),
        'year': yearCtrl.text.trim(),
        if (gpaCtrl.text.trim().isNotEmpty) 'gpa': gpaCtrl.text.trim(),
      },
      'skills': techSkills.toList(),
      'softSkills': softSkills.toList(),
      'experience': experiences
          .map((e) => {
                'title': e['title']!.text.trim(),
                'company': e['company']!.text.trim(),
                'duration': e['duration']!.text.trim(),
                'description': e['description']!.text.trim(),
              })
          .where((e) => (e['title'] as String).isNotEmpty)
          .toList(),
      'projects': projects
          .map((p) => {
                'title': p['title']!.text.trim(),
                'tech': p['tech']!.text.trim(),
                'link': p['link']!.text.trim(),
                'description': p['description']!.text.trim(),
              })
          .where((p) => (p['title'] as String).isNotEmpty)
          .toList(),
      if (certs.isNotEmpty) 'certifications': certs.toList(),
      'targetJd': jdCtrl.text.trim(),
      'templateId': selectedTemplate.value,
    };
  }

  // ── Form helpers ──────────────────────────────────────────────────────────

  // ── Validation ────────────────────────────────────────────────────────────

  void clearFieldError(String key) => fieldErrors.remove(key);

  /// Returns true if the step is valid. Sets [fieldErrors] for any failures.
  bool validateStep(int step) {
    fieldErrors.clear();
    switch (step) {
      case 0: return _validatePersonal();
      case 1: return _validateEducation();
      case 2: return _validateSkills();
      case 3: return _validateExperience();
      case 4: return _validateProjects();
      default: return true;
    }
  }

  bool _validatePersonal() {
    var ok = true;
    if (nameCtrl.text.trim().isEmpty) {
      fieldErrors['name'] = 'Full name is required';
      ok = false;
    }
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      fieldErrors['email'] = 'Email is required';
      ok = false;
    } else if (!GetUtils.isEmail(email)) {
      fieldErrors['email'] = 'Enter a valid email address';
      ok = false;
    }
    if (phoneCtrl.text.trim().isEmpty) {
      fieldErrors['phone'] = 'Phone number is required';
      ok = false;
    }
    if (locationCtrl.text.trim().isEmpty) {
      fieldErrors['location'] = 'Location is required';
      ok = false;
    }
    return ok;
  }

  bool _validateEducation() {
    var ok = true;
    if (degreeCtrl.text.trim().isEmpty) {
      fieldErrors['degree'] = 'Degree / course is required';
      ok = false;
    }
    if (institutionCtrl.text.trim().isEmpty) {
      fieldErrors['institution'] = 'College / university is required';
      ok = false;
    }
    final yearText = yearCtrl.text.trim();
    if (yearText.isEmpty) {
      fieldErrors['year'] = 'Graduation year is required';
      ok = false;
    } else {
      final y = int.tryParse(yearText);
      if (y == null || y < 1970 || y > 2035) {
        fieldErrors['year'] = 'Enter a valid year (e.g. 2024)';
        ok = false;
      }
    }
    return ok;
  }

  bool _validateSkills() {
    if (techSkills.isEmpty) {
      fieldErrors['techSkills'] = 'Add at least one technical skill';
      return false;
    }
    return true;
  }

  bool _validateExperience() {
    var ok = true;
    for (var i = 0; i < experiences.length; i++) {
      final e = experiences[i];
      // Only validate entries where the user has typed something
      final hasData = e.values.any((c) => c.text.trim().isNotEmpty);
      if (hasData && e['title']!.text.trim().isEmpty) {
        fieldErrors['exp_title_$i'] = 'Job title is required';
        ok = false;
      }
    }
    return ok;
  }

  bool _validateProjects() {
    var ok = true;
    for (var i = 0; i < projects.length; i++) {
      final p = projects[i];
      final hasData = p.values.any((c) => c.text.trim().isNotEmpty);
      if (hasData && p['title']!.text.trim().isEmpty) {
        fieldErrors['proj_title_$i'] = 'Project title is required';
        ok = false;
      }
    }
    return ok;
  }

  void addTechSkill(String skill) {
    final s = skill.trim();
    if (s.isNotEmpty && !techSkills.contains(s)) {
      techSkills.add(s);
      techSkillCtrl.clear();
      fieldErrors.remove('techSkills');
    }
  }

  void removeTechSkill(String skill) => techSkills.remove(skill);

  void addSoftSkill(String skill) {
    final s = skill.trim();
    if (s.isNotEmpty && !softSkills.contains(s)) {
      softSkills.add(s);
      softSkillCtrl.clear();
    }
  }

  void removeSoftSkill(String skill) => softSkills.remove(skill);

  void addCert(String cert) {
    final c = cert.trim();
    if (c.isNotEmpty && !certs.contains(c)) {
      certs.add(c);
      certCtrl.clear();
    }
  }

  void removeCert(String cert) => certs.remove(cert);

  void _addExperienceEntry() {
    experiences.add({
      'title': TextEditingController(),
      'company': TextEditingController(),
      'duration': TextEditingController(),
      'description': TextEditingController(),
    });
  }

  void addExperience() => _addExperienceEntry();

  void removeExperience(int index) {
    if (experiences.length <= 1) return;
    for (final c in experiences[index].values) { c.dispose(); }
    experiences.removeAt(index);
  }

  void _addProjectEntry() {
    projects.add({
      'title': TextEditingController(),
      'tech': TextEditingController(),
      'link': TextEditingController(),
      'description': TextEditingController(),
    });
  }

  void addProject() => _addProjectEntry();

  void removeProject(int index) {
    if (projects.length <= 1) return;
    for (final c in projects[index].values) { c.dispose(); }
    projects.removeAt(index);
  }

  void resetForm() {
    currentStep.value = 0;
    fieldErrors.clear();
    for (final c in [
      nameCtrl, emailCtrl, phoneCtrl, locationCtrl, linkedinCtrl, githubCtrl,
      degreeCtrl, institutionCtrl, yearCtrl, gpaCtrl,
      jdCtrl, certCtrl,
    ]) {
      c.clear();
    }
    techSkills.clear();
    softSkills.clear();
    certs.clear();
    for (final e in experiences) {
      for (final c in e.values) { c.dispose(); }
    }
    experiences.clear();
    for (final p in projects) {
      for (final c in p.values) { c.dispose(); }
    }
    projects.clear();
    _addExperienceEntry();
    _addProjectEntry();
    selectedTemplate.value = 'classic';
  }
}
