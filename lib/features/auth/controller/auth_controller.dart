import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/validators.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "136794753205-210rggct227ahdu5t70ckn30rejonctk.apps.googleusercontent.com",
  );

  /// UI STATE
  var isLoading = false.obs;
  var isLogin = true.obs;
  var obscurePassword = true.obs;
  var isGoogleUser = false.obs;

  final formKey = GlobalKey<FormState>();

  /// CONTROLLERS
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final forgotEmailController = TextEditingController();
  final passwordController = TextEditingController();

  Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();

  bool _isManualLogin = false;

  @override
  void onInit() {
    super.onInit();
    _listenAuthChanges();
  }

  /// ================= AUTH LISTENER =================
  void _listenAuthChanges() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await fetchUserData();

        if (_isManualLogin) {
          AppSnackbar.success("Login successful 🎉");
          _isManualLogin = false;
        }
      } else {
        userData.value = null;
      }
    });
  }

  /// ================= FETCH USER =================
  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        userData.value = doc.data();
      }
    } catch (e) {
      debugPrint("Fetch user error: $e");
    }
  }

  /// ================= CLEAR HELPERS =================
  void clearAllFields() {
    nameController.text = "";
    phoneController.text = "";
    emailController.text = "";
    forgotEmailController.text = "";
    passwordController.text = "";
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

  void clearForgotFields() {
    emailController.clear();
  }

  /// ================= TOGGLE =================
  void toggleMode() {
    isLogin.toggle();
    isGoogleUser.value = false;
    clearAllFields();
    formKey.currentState?.reset();
  }

  void togglePassword() => obscurePassword.toggle();

  /// ================= VALIDATORS =================
  String? validateName(String? v) => Validators.validateName(v ?? "");
  String? validateEmail(String? v) => Validators.validateEmail(v ?? "");
  String? validatePassword(String? v) =>
      isGoogleUser.value ? null : Validators.validatePassword(v ?? "");

  String? validatePhone(String? v) {
    if (v == null || v.isEmpty) return "Enter phone number";
    if (v.length != 10) return "Enter valid 10-digit number";
    return null;
  }

  /// ================= SUBMIT =================
  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    if (isLogin.value) {
      await login();
    } else {
      await signUp();
    }
  }

  /// ================= SIGNUP =================
  Future<void> signUp() async {
    try {
      isLoading.value = true;

      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      User? user = _auth.currentUser;

      if (!isGoogleUser.value) {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = cred.user;
      }

      if (user == null) {
        AppSnackbar.error("User creation failed");
        return;
      }

      /// 📍 GET LOCATION CONTROLLER
      final locationController = Get.put(LocationController());

      /// 📍 DETECT LOCATION ONLY IF NOT ALREADY SELECTED
      if (locationController.selectedLocations.isEmpty) {
        await locationController.detectCurrentLocation();
      }

      // /// 📍 GET FINAL LOCATION VALUE
      // final location = locationController.selectedLocations.isNotEmpty
      //     ? locationController.selectedLocations.first
      //     : "";

      /// 💾 SAVE USER DATA + LOCATION
      await _firestore.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "phone": phone,
        "email": user.email,
        "photoUrl": user.photoURL ?? "",
        "provider": isGoogleUser.value ? "google" : "email",
        "createdAt": FieldValue.serverTimestamp(),
      });

      /// OPTIONAL: refresh user data
      await fetchUserData();

      AppSnackbar.success("Signup successful 🚀");

      clearAllFields();

      isLogin.value = true;

      /// 🚀 NAVIGATE AFTER EVERYTHING DONE
      Get.offAllNamed(AppRoutes.wrapper);

      isGoogleUser.value = false;
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Signup failed");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= FORGOT PASSWORD =================
  Future<void> forgotPassword() async {
    try {
      isLoading.value = true;

      final email = forgotEmailController.text.trim();

      if (email.isEmpty) {
        isLoading.value = false; // ✅ FIX
        AppSnackbar.error("Email is required");
        return;
      }

      if (!GetUtils.isEmail(email)) {
        isLoading.value = false; // ✅ FIX
        AppSnackbar.error("Enter a valid email");
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);

      //  SUCCESS FLOW

      clearAllFields();
      Get.back(result: true); // ✅ go back
      AppSnackbar.success("Password reset link sent 📩");
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Something went wrong");
    } finally {
      isLoading.value = false; // ✅ always reset
    }
  }

  /// ================= LOGIN =================
  Future<void> login() async {
    try {
      isLoading.value = true;
      _isManualLogin = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Get.offAllNamed(AppRoutes.wrapper);
      clearAllFields();
    } on FirebaseAuthException catch (e) {
      _isManualLogin = false;
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      _isManualLogin = false;
      AppSnackbar.error("Login failed");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= GOOGLE LOGIN =================
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        AppSnackbar.error("Cancelled");
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user == null) throw Exception("Google login failed");

      final doc = await _firestore.collection("users").doc(user.uid).get();

      // ✅ EXISTING USER
      if (doc.exists && (doc.data()?["phone"] ?? "").toString().isNotEmpty) {
        clearAllFields();

        AppSnackbar.success("Login successful ✅"); //  ONLY HERE

        Get.offAllNamed(AppRoutes.wrapper);
        return;
      }

      //  NEW USER FLOW
      isGoogleUser.value = true;
      isLogin.value = false;

      nameController.text = user.displayName ?? "";
      emailController.text = user.email ?? "";

      AppSnackbar.success("Complete your profile ✍️"); // ✅ ONLY THIS
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Google login failed");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await _auth.signOut();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      ///  Clear only your data (NOT close Hive)
      await Hive.box('locationBox').clear();
      clearAllFields();
      Get.deleteAll();
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }

  //===================LOGOUT DIALOG==============
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
              /// 🔴 ICON
              Icon(Icons.logout, size: 32, color: theme.colorScheme.primary),

              const SizedBox(height: 12),

              /// TITLE
              Text(
                "Logout?",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: AppButton(
                      backgroundColor: AppColors.primaryDark,
                      onPressed: () => Get.back(),
                      text: "Cancel",
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// LOGOUT
                  Expanded(
                    child: AppButton(
                      backgroundColor: AppColors.secondaryDark,
                      onPressed: () async {
                        Get.back();
                        await logout();
                      },
                      text: "Logout",
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

  /// ================= ERROR HANDLER =================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No account found with this email";
      case 'wrong-password':
        return "Incorrect password";
      case 'invalid-credential':
        return "Invalid email or password";
      case 'user-disabled':
        return "This account has been disabled";
      case 'email-already-in-use':
        return "Email is already registered";
      case 'invalid-email':
        return "Invalid email format";
      case 'weak-password':
        return "Password must be at least 6 characters";
      case 'network-request-failed':
        return "No internet connection";
      case 'too-many-requests':
        return "Too many attempts. Try again later";
      default:
        return e.message ?? "Something went wrong";
    }
  }
}
