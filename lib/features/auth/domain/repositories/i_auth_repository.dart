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
}
