import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/validators.dart';

class AuthController extends GetxController {
  final IAuthRepository _authRepo;
  AuthController(this._authRepo);

  final locationController = Get.find<LocationController>();

  // ── UI state ─────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isLogin = true.obs;
  final obscurePassword = true.obs;
  final isGoogleUser = false.obs;
  // True until the first Firebase auth event resolves on app start
  final isCheckingAuth = true.obs;

  final formKey = GlobalKey<FormState>();

  // ── Form controllers ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final forgotEmailController = TextEditingController();
  final passwordController = TextEditingController();

  Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    bool firstEvent = true;
    _authRepo.authStateChanges.listen((user) async {
      if (user != null) {
        await fetchUserData();
      } else {
        userData.value = null;
      }
      // Reveal the wrapper UI after the very first auth event resolves
      if (firstEvent) {
        firstEvent = false;
        isCheckingAuth.value = false;
      }
    });
  }

  // ── User data ─────────────────────────────────────────────────────────────
  Future<void> fetchUserData() async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) return;
      userData.value = await _authRepo.getUserProfile(user.uid);
    } catch (e) {
      debugPrint('Fetch user error: $e');
    }
  }

  // ── Field helpers ─────────────────────────────────────────────────────────
  void clearAllFields() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    forgotEmailController.clear();
    passwordController.clear();
    update();
  }

  void clearLoginFields() {
    emailController.clear();
    passwordController.clear();
  }

  void clearSignupFields() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    forgotEmailController.clear();
    passwordController.clear();
  }

  void clearForgotFields() => forgotEmailController.clear();

  void toggleMode() {
    isLogin.toggle();
    isGoogleUser.value = false;
    clearAllFields();
    formKey.currentState?.reset();
  }

  void togglePassword() => obscurePassword.toggle();

  // ── Validators ────────────────────────────────────────────────────────────
  String? validateName(String? v) => Validators.validateName(v ?? '');
  String? validateEmail(String? v) => Validators.validateEmail(v ?? '');
  String? validatePassword(String? v) =>
      isGoogleUser.value ? null : Validators.validatePassword(v ?? '');

  String? validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'validate_phone_required'.tr;
    if (v.length != 10) return 'validate_phone_invalid'.tr;
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!formKey.currentState!.validate()) return;
    if (isLogin.value) {
      await login();
    } else {
      await signUp();
    }
  }

  // ── Sign-up ───────────────────────────────────────────────────────────────
  Future<void> signUp() async {
    try {
      isLoading.value = true;

      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (!isGoogleUser.value) {
        await _authRepo.createAccount(email: email, password: password);
      }

      final user = _authRepo.currentUser;
      if (user == null) {
        AppSnackbar.error('user_creation_failed'.tr);
        return;
      }

      await _authRepo.saveUserProfile(
        uid: user.uid,
        name: name,
        phone: phone,
        email: user.email ?? email,
        photoUrl: user.photoURL ?? '',
        isGoogleUser: isGoogleUser.value,
      );
      await fetchUserData();
      clearAllFields();
      isLogin.value = true;
      await locationController.initLocation(isNewUser: true);
      isGoogleUser.value = false;
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error('signup_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<void> forgotPassword() async {
    try {
      isLoading.value = true;
      final email = forgotEmailController.text.trim();
      if (email.isEmpty) {
        AppSnackbar.error('email_required_snack'.tr);
        return;
      }
      if (!GetUtils.isEmail(email)) {
        AppSnackbar.error('enter_valid_email_snack'.tr);
        return;
      }
      await _authRepo.sendPasswordResetEmail(email);
      clearAllFields();
      Get.back(result: true);
      AppSnackbar.success('reset_link_sent'.tr);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error('error_generic'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login() async {
    try {
      isLoading.value = true;
      await _authRepo.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Explicitly fetch user data here rather than relying solely on the
      // authStateChanges listener.  If the user already had a persisted
      // Firebase session the listener may not re-fire, leaving userData null.
      await fetchUserData();
      final uid = _authRepo.currentUser?.uid ?? '';
      final isComplete =
          uid.isNotEmpty ? await _authRepo.isUserProfileComplete(uid) : true;
      await locationController.initLocation(isNewUser: !isComplete);
      clearAllFields();
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error('login_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Google sign-in ────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final googleUser = await _authRepo.initiateGoogleSignIn();
      if (googleUser == null) {
        AppSnackbar.error('cancelled'.tr);
        return;
      }
      final googleAuth = await googleUser.authentication;
      await _authRepo.signInWithGoogleCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final user = _authRepo.currentUser;
      if (user == null) throw Exception('Google login failed');

      final isComplete = await _authRepo.isUserProfileComplete(user.uid);
      if (isComplete) {
        await locationController.initLocation(isNewUser: false);
        clearAllFields();
        return;
      }
      // New Google user — show sign-up form with pre-filled data
      isGoogleUser.value = true;
      isLogin.value = false;
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
      AppSnackbar.success('complete_profile'.tr);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error('google_login_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _authRepo.signOut();
      if (await _authRepo.isGoogleSignedIn()) {
        await _authRepo.googleSignOut();
      }
      clearAllFields();
      Get.deleteAll();
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
  }

  void showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'logout_title'.tr,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'logout_confirm'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      backgroundColor: AppColors.primaryDark,
                      onPressed: () => Get.back(),
                      text: 'cancel'.tr,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      backgroundColor: AppColors.secondaryDark,
                      onPressed: () async {
                        Get.back();
                        await logout();
                      },
                      text: 'logout'.tr,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error mapping ─────────────────────────────────────────────────────────
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'error_user_not_found'.tr;
      case 'wrong-password':
        return 'error_wrong_password'.tr;
      case 'invalid-credential':
        return 'error_invalid_credential'.tr;
      case 'user-disabled':
        return 'error_user_disabled'.tr;
      case 'email-already-in-use':
        return 'error_email_in_use'.tr;
      case 'invalid-email':
        return 'error_invalid_email'.tr;
      case 'weak-password':
        return 'error_weak_password'.tr;
      case 'network-request-failed':
        return 'error_network'.tr;
      case 'too-many-requests':
        return 'error_too_many_requests'.tr;
      default:
        return e.message ?? 'error_generic'.tr;
    }
  }
}
