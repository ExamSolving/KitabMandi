import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/resume/model/cover_letter_model.dart';

class CoverLetterController extends GetxController {
  static CoverLetterController get to => Get.find();

  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final isGenerating = false.obs;
  final isLoading = false.obs;
  final coverLetters = <CoverLetterRecord>[].obs;
  final generatedLetter = Rxn<CoverLetterRecord>();

  // Subscription + usage
  final sub = Rxn<Map<String, dynamic>>();
  final clUsage = Rxn<CoverLetterUsage>();

  // Form fields
  final jobTitleCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final jdCtrl = TextEditingController();
  final selectedResumeId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCoverLetters();
  }

  @override
  void onClose() {
    jobTitleCtrl.dispose();
    companyCtrl.dispose();
    jdCtrl.dispose();
    super.onClose();
  }

  Future<void> loadCoverLetters() async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await _fs.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      sub.value = userData['subscription'] as Map<String, dynamic>?;
      _computeUsage(userData);

      final snap = await _fs
          .collection('users')
          .doc(uid)
          .collection('coverLetters')
          .orderBy('createdAt', descending: true)
          .get();
      coverLetters.value = snap.docs
          .map((d) => CoverLetterRecord.fromDoc(
              Map<String, dynamic>.from(d.data()), d.id))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  void _computeUsage(Map<String, dynamic> userData) {
    final plan = SubscriptionService.getPlan(sub.value);
    final isActive = SubscriptionService.isActive(sub.value);
    final isFreePlan = !isActive || plan == RazorpayConfig.planFree;
    final isPlus = isActive &&
        (plan == RazorpayConfig.planPlusMonthly ||
            plan == RazorpayConfig.planPlusAnnual);

    final rawUsage =
        (userData['coverLetterUsage'] as Map<String, dynamic>?) ?? {};
    final used = (rawUsage['countLifetime'] as int?) ?? 0;
    // Free=1, Plus=3, Pro=5
    final max = isFreePlan ? 1 : (isPlus ? 3 : 5);

    clUsage.value = CoverLetterUsage(usedCount: used, maxCount: max);
  }

  Future<void> generate() async {
    // Client-side limit guard
    final usage = clUsage.value;
    if (usage != null && !usage.canGenerate) {
      Get.snackbar(
        'Limit Reached',
        _limitMessage(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final resumeId = selectedResumeId.value;
    final jobTitle = jobTitleCtrl.text.trim();
    final company = companyCtrl.text.trim();

    if (resumeId.isEmpty) {
      Get.snackbar('Select a resume', 'Please choose which resume to use',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (jobTitle.isEmpty || company.isEmpty) {
      Get.snackbar(
          'Missing fields', 'Job title and company name are required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isGenerating.value = true;
      generatedLetter.value = null;

      final callable =
          FirebaseFunctions.instance.httpsCallable('generateCoverLetter');
      final result = await callable.call({
        'resumeId': resumeId,
        'jobTitle': jobTitle,
        'companyName': company,
        if (jdCtrl.text.trim().isNotEmpty)
          'jobDescription': jdCtrl.text.trim(),
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final record = CoverLetterRecord(
        id: data['coverLetterId'] as String,
        resumeId: resumeId,
        jobTitle: jobTitle,
        companyName: company,
        letterText: data['letterText'] as String,
        createdAt: DateTime.now(),
        aiModel: data['aiModel'] as String?,
      );

      generatedLetter.value = record;
      coverLetters.insert(0, record);

      // Increment usage counter in Firestore and update local state
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _fs.collection('users').doc(uid).update({
          'coverLetterUsage.countLifetime': FieldValue.increment(1),
        });
        final current = clUsage.value;
        if (current != null) {
          clUsage.value = CoverLetterUsage(
            usedCount: current.usedCount + 1,
            maxCount: current.maxCount,
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      Get.snackbar('Error', e.message ?? 'Generation failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isGenerating.value = false;
    }
  }

  String _limitMessage() {
    final plan = SubscriptionService.getPlan(sub.value);
    final isActive = SubscriptionService.isActive(sub.value);
    if (!isActive || plan == RazorpayConfig.planFree) {
      return 'Free plan allows 1 cover letter. Upgrade to Plus for 3.';
    }
    final isPlus = plan == RazorpayConfig.planPlusMonthly ||
        plan == RazorpayConfig.planPlusAnnual;
    if (isPlus) return 'Plus plan allows 3 cover letters. Upgrade to Pro for 5.';
    return 'Pro plan allows 5 cover letters. You have used all of them.';
  }

  Future<void> delete(String id) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _fs
          .collection('users')
          .doc(uid)
          .collection('coverLetters')
          .doc(id)
          .delete();
      coverLetters.removeWhere((c) => c.id == id);
      if (generatedLetter.value?.id == id) generatedLetter.value = null;
    } catch (_) {}
  }

  void resetForm() {
    jobTitleCtrl.clear();
    companyCtrl.clear();
    jdCtrl.clear();
    selectedResumeId.value = '';
    generatedLetter.value = null;
  }
}
