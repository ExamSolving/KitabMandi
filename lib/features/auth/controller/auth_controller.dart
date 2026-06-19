import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import '../../../core/services/fcm_service.dart';
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

  // ── Email verification state ──────────────────────────────────────────────
  final isCheckingVerification = false.obs;
  final resendCooldown = 0.obs; // seconds remaining before resend is allowed
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  // Pending signup data held in memory between createAccount and profile save
  String _pendingName = '';
  String _pendingPhone = '';
  String _pendingEmail = '';
  String _pendingPassword = '';

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

  @override
  void onClose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.onClose();
  }

  void _listenAuthChanges() {
    bool firstEvent = true;
    _authRepo.authStateChanges.listen((user) async {
      if (user != null) {
        await fetchUserData();
        // Firebase persists auth locally even after the account is deleted from
        // the console. If we have a Firebase user but no Firestore profile, and
        // we're not actively creating one, it's a stale session — sign out so
        // background services (FCM, location) can't re-create the document.
        if (userData.value == null &&
            !isGoogleUser.value &&
            _pendingEmail.isEmpty) {
          if (firstEvent) {
            firstEvent = false;
            isCheckingAuth.value = false;
          }
          await _authRepo.signOut();
          return;
        }
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

      // Reject duplicate phone numbers before touching Firebase Auth
      if (await _authRepo.isPhoneTaken(phone)) {
        AppSnackbar.error('error_phone_in_use'.tr);
        return;
      }

      // Google users are already verified — skip email verification step
      if (isGoogleUser.value) {
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
          isGoogleUser: true,
        );
        await fetchUserData();
        // Profile document now exists — safe to update() the FCM token fields.
        // The auth-state listener fired before this point and update() threw
        // NOT_FOUND because the document didn't exist yet.
        await FCMService.instance.refreshToken(user.uid);
        clearAllFields();
        isLogin.value = true;
        await locationController.initLocation(isNewUser: true);
        isGoogleUser.value = false;
        return;
      }

      // Email/password signup → create account, send verification, sign out
      await _authRepo.createAccount(email: email, password: password);

      final user = _authRepo.currentUser;
      if (user == null) {
        AppSnackbar.error('user_creation_failed'.tr);
        return;
      }

      // Store pending data — needed to save profile after verification
      _pendingName = name;
      _pendingPhone = phone;
      _pendingEmail = email;
      _pendingPassword = password;

      await _authRepo.sendEmailVerification();

      // Sign out so the auth listener doesn't navigate to dashboard yet
      await _authRepo.signOut();

      // Don't clear form — fields are needed if user returns to change email
      Get.toNamed(AppRoutes.emailVerification, arguments: email);
      _startResendCooldown();
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error('signup_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Email verification polling ────────────────────────────────────────────

  /// Called by EmailVerificationView on mount.
  /// Checks immediately, then polls every 3 s as a background safety net.
  void startVerificationPolling() {
    _pollTimer?.cancel();
    _checkVerified(); // instant first check — no need to wait 3 s
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerified();
    });
  }

  void stopVerificationPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Triggered when the app returns to the foreground while the verification
  /// screen is visible — gives near-instant detection after the user taps the
  /// link in their email client and switches back to the app.
  void checkVerifiedOnResume() => _checkVerified();

  Future<void> _checkVerified() async {
    if (isCheckingVerification.value) return;
    try {
      isCheckingVerification.value = true;
      // Sign in temporarily to reload the user object from Firebase
      await _authRepo.signInWithEmail(
        email: _pendingEmail,
        password: _pendingPassword,
      );
      await _authRepo.reloadUser();
      if (_authRepo.isEmailVerified) {
        stopVerificationPolling();
        await _completeRegistration();
      } else {
        // Not verified yet — sign out and keep waiting
        await _authRepo.signOut();
      }
    } catch (_) {
      // Silently ignore transient network errors during polling
    } finally {
      isCheckingVerification.value = false;
    }
  }

  Future<void> _completeRegistration() async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) return;
      await _authRepo.saveUserProfile(
        uid: user.uid,
        name: _pendingName,
        phone: _pendingPhone,
        email: user.email ?? _pendingEmail,
        photoUrl: user.photoURL ?? '',
        isGoogleUser: false,
      );
      await fetchUserData();
      await FCMService.instance.refreshToken(user.uid);
      _clearPendingData();
      clearAllFields();
      isLogin.value = true;
      await locationController.initLocation(isNewUser: true);
      // WrapperView shows DashboardView inline when userData is set, but it's
      // hidden under /emailVerification. Clear the stack to surface it.
      Get.offAllNamed(AppRoutes.wrapper);
    } catch (e) {
      AppSnackbar.error('signup_failed'.tr);
    }
  }

  void _clearPendingData() {
    _pendingName = '';
    _pendingPhone = '';
    _pendingEmail = '';
    _pendingPassword = '';
  }

  Future<void> resendVerificationEmail() async {
    if (resendCooldown.value > 0) return;
    try {
      isLoading.value = true;
      // Sign in temporarily to send the verification email
      await _authRepo.signInWithEmail(
        email: _pendingEmail,
        password: _pendingPassword,
      );
      await _authRepo.sendEmailVerification();
      await _authRepo.signOut();
      AppSnackbar.success('verify_email_resent'.tr);
      _startResendCooldown();
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error('error_generic'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendCooldown([int seconds = 60]) {
    resendCooldown.value = seconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCooldown.value <= 0) {
        t.cancel();
      } else {
        resendCooldown.value--;
      }
    });
  }

  /// Called when user presses "Wrong email? Change it"
  Future<void> cancelVerification() async {
    stopVerificationPolling();
    _cooldownTimer?.cancel();
    resendCooldown.value = 0;

    // Delete the unverified account so the email can be reused
    try {
      await _authRepo.signInWithEmail(
        email: _pendingEmail,
        password: _pendingPassword,
      );
      await _authRepo.deleteCurrentUser();
    } catch (_) {}

    // Restore form with the data the user already entered so they only
    // need to fix the email — don't make them retype everything.
    nameController.text = _pendingName;
    phoneController.text = _pendingPhone;
    emailController.text = _pendingEmail;
    passwordController.text = _pendingPassword;
    isLogin.value = false; // stay on signup tab

    _clearPendingData();
    Get.back();
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
      clearForgotFields();
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
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await _authRepo.signInWithEmail(email: email, password: password);
      await _authRepo.reloadUser();

      // Block login for unverified email accounts
      if (!_authRepo.isEmailVerified) {
        await _authRepo.signOut();
        // Store credentials so the verification screen can poll/resend
        _pendingEmail = email;
        _pendingPassword = password;
        AppSnackbar.error('verify_email_first'.tr);
        Get.toNamed(AppRoutes.emailVerification, arguments: email);
        _startResendCooldown();
        return;
      }

      // Explicitly fetch user data here rather than relying solely on the
      // authStateChanges listener. If the user already had a persisted
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

      // Mark as Google sign-in BEFORE the credential call so the auth-state
      // listener's stale-session guard doesn't fire on the new user who has
      // no Firestore profile yet — without this flag, the listener would see
      // userData==null and immediately sign them out.
      isGoogleUser.value = true;

      await _authRepo.signInWithGoogleCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final user = _authRepo.currentUser;
      if (user == null) throw Exception('Google login failed');

      final isComplete = await _authRepo.isUserProfileComplete(user.uid);
      if (isComplete) {
        // Existing Google user — reset flag and go to dashboard
        isGoogleUser.value = false;
        await locationController.initLocation(isNewUser: false);
        clearAllFields();
        return;
      }
      // New Google user — keep flag true and show complete-profile form
      isLogin.value = false;
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
      AppSnackbar.success('complete_profile'.tr);
    } on FirebaseAuthException catch (e) {
      isGoogleUser.value = false;
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      isGoogleUser.value = false;
      AppSnackbar.error('google_login_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _authRepo.signOut();
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }
    try {
      if (await _authRepo.isGoogleSignedIn()) {
        await _authRepo.googleSignOut();
      }
    } catch (_) {}
    clearAllFields();
    // Clear the entire route stack — WrapperView will show AuthView because
    // userData is now null. Route disposal handles non-permanent controllers.
    Get.offAllNamed(AppRoutes.wrapper);
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
