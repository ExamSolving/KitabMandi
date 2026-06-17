import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Contract between the auth presentation layer and the data layer.
/// Controllers depend only on this interface — never on concrete Firebase classes.
abstract class IAuthRepository {
  // ── Streams / current state ─────────────────────────────────────────────
  Stream<User?> get authStateChanges;
  User? get currentUser;

  // ── Email / password ─────────────────────────────────────────────────────
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> createAccount({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();
  Future<void> reloadUser();
  bool get isEmailVerified;
  Future<void> deleteCurrentUser();

  // ── Google ────────────────────────────────────────────────────────────────
  Future<GoogleSignInAccount?> initiateGoogleSignIn();

  Future<void> signInWithGoogleCredential({
    required String? idToken,
    required String? accessToken,
  });

  Future<bool> isGoogleSignedIn();
  Future<void> googleSignOut();

  // ── Session ───────────────────────────────────────────────────────────────
  Future<void> signOut();

  // ── Firestore user profile ────────────────────────────────────────────────
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String photoUrl,
    required bool isGoogleUser,
  });

  Future<Map<String, dynamic>?> getUserProfile(String uid);

  /// Returns true when a Firestore user document exists AND has a phone number.
  Future<bool> isUserProfileComplete(String uid);

  /// Stamps the user's Firestore doc with the time of their latest listing so
  /// the dashboard can enforce the 24-hour limit without a network call.
  Future<void> updateLastListingAt(String uid);

  /// Returns true if [phone] is already registered to a different account.
  /// Pass [excludeUid] (current user's UID) on profile-edit checks so the
  /// user can save without changing their own number.
  Future<bool> isPhoneTaken(String phone, {String? excludeUid});
}
