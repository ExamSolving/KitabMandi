import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';

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

      final currentData = _authCtrl.userData.value ?? {};
      String photoUrl = currentData['photoUrl'] as String? ?? '';

      // Upload new photo if user picked one
      if (pickedImage.value != null) {
        photoUrl = await _uploadPhoto(user.uid) ?? photoUrl;
      }

      await _authRepo.saveUserProfile(
        uid: user.uid,
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
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
