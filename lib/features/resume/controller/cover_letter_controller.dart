import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/resume/model/cover_letter_model.dart';

class CoverLetterController extends GetxController {
  static CoverLetterController get to => Get.find();

  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final isGenerating = false.obs;
  final isLoading = false.obs;
  final coverLetters = <CoverLetterRecord>[].obs;
  final generatedLetter = Rxn<CoverLetterRecord>();

  // Form fields
  final jobTitleCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final jdCtrl = TextEditingController();
  final selectedResumeId = ''.obs;

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

  Future<void> generate() async {
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
      );

      generatedLetter.value = record;
      coverLetters.insert(0, record);
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
