import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class ProfileEditController extends GetxController {
  final IAuthRepository _authRepo;
  ProfileEditController(this._authRepo);

  final _picker = ImagePicker();
  final _authCtrl = Get.find<AuthController>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final Rxn<File> pickedImage = Rxn<File>();
  final isSaving = false.obs;
  final isPickingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    final data = _authCtrl.userData.value;
    nameCtrl.text = data?['name'] as String? ?? '';
    phoneCtrl.text = data?['phone'] as String? ?? '';
    emailCtrl.text = data?['email'] as String? ?? '';
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.onClose();
  }

  void showPhotoOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1D23) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Change Profile Photo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _PhotoOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                color: const Color(0xFF1B5E20),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _PhotoOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                color: const Color(0xFF1976D2),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (pickedImage.value != null ||
                  (_authCtrl.userData.value?['photoUrl'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 10),
                _PhotoOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    pickedImage.value = null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      isPickingImage.value = true;
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (file != null) pickedImage.value = File(file.path);
    } catch (e) {
      Get.snackbar('Error', 'Could not pick image');
    } finally {
      isPickingImage.value = false;
    }
  }

  Future<String?> _uploadPhoto(String uid) async {
    final file = pickedImage.value;
    if (file == null) return null;
    final ref = FirebaseStorage.instance
        .ref()
        .child('users/$uid/avatar.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isSaving.value = true;
      final user = _authRepo.currentUser;
      if (user == null) return;

      final newPhone = phoneCtrl.text.trim();

      // Check phone uniqueness, excluding the current user so they can save
      // without changing their own number.
      if (await _authRepo.isPhoneTaken(newPhone, excludeUid: user.uid)) {
        Get.snackbar(
          'Error',
          'This phone number is already registered with another account.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final currentData = _authCtrl.userData.value ?? {};
      String photoUrl = currentData['photoUrl'] as String? ?? '';

      // Upload new photo if user picked one
      if (pickedImage.value != null) {
        photoUrl = await _uploadPhoto(user.uid) ?? photoUrl;
      }

      await _authRepo.saveUserProfile(
        uid: user.uid,
        name: nameCtrl.text.trim(),
        phone: newPhone,
        email: user.email ?? '',
        photoUrl: photoUrl,
        isGoogleUser: currentData['provider'] == 'google',
      );

      // Refresh userData so profile view and hero update immediately
      await _authCtrl.fetchUserData();

      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (v.trim().length != 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  // ── Delete account ────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    final user = _authRepo.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final fs = FirebaseFirestore.instance;

    // Show non-dismissible progress dialog.
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Deleting account…'),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    final storage = FirebaseStorage.instance;

    Future<void> safeDeleteStorageUrl(String url) async {
      if (url.isEmpty) return;
      try {
        await storage.refFromURL(url).delete();
      } catch (_) {}
    }

    try {
      // 1. Delete all listings posted by this user + their Storage images.
      final listingsSnap = await fs
          .collection('listings')
          .where('seller.uid', isEqualTo: uid)
          .get();
      for (final doc in listingsSnap.docs) {
        final images =
            List<String>.from(doc.data()['images'] as List? ?? []);
        for (final url in images) {
          await safeDeleteStorageUrl(url);
        }
        await doc.reference.delete();
      }

      // 2. Delete all chats where user is a participant, their messages, and
      //    any images those messages reference in Storage.
      final chatsSnap = await fs
          .collection('chats')
          .where('participants', arrayContains: uid)
          .get();
      for (final chatDoc in chatsSnap.docs) {
        final msgsSnap =
            await chatDoc.reference.collection('messages').get();
        for (final msg in msgsSnap.docs) {
          final data = msg.data();
          if (data['type'] == 'image') {
            await safeDeleteStorageUrl(
                data['imageUrl'] as String? ?? '');
          }
          await msg.reference.delete();
        }
        await chatDoc.reference.delete();
      }

      // 3. Delete all subcollections under the user document so the parent doc
      //    is fully removed (Firestore ghost-documents appear when subcollections
      //    survive after the parent is deleted).
      for (final sub in ['resumes', 'wishlist', 'notifications', 'coverLetters']) {
        final snap =
            await fs.collection('users').doc(uid).collection(sub).get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }

      // 4. Delete Firestore user document — now safe since all subcollections
      //    are gone, so no ghost document remains in the console.
      await fs.collection('users').doc(uid).delete();

      // 5. Delete avatar from Storage.
      try {
        await storage.ref().child('users/$uid/avatar.jpg').delete();
      } catch (_) {}

      // 6. Delete Firebase Auth account — must be last authenticated call.
      await _authRepo.deleteCurrentUser();

      // Close the loading dialog then navigate; the auth-state listener in
      // WrapperView will redirect to login automatically.
      Get.close(1);
      Get.offAllNamed(AppRoutes.wrapper);
    } on FirebaseAuthException catch (e) {
      Get.close(1);
      if (e.code == 'requires-recent-login') {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Sign In Again',
                style: TextStyle(fontWeight: FontWeight.w700)),
            content: const Text(
              'For security, please sign out and sign back in before deleting your account.',
              style: TextStyle(fontSize: 13.5, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: const Text('OK',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar('Error', e.message ?? 'Failed to delete account.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (_) {
      Get.close(1);
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
