import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kitab_mandi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _ds;
  const AuthRepositoryImpl(this._ds);

  @override
  Stream<User?> get authStateChanges => _ds.authStateChanges;

  @override
  User? get currentUser => _ds.currentUser;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _ds.signInWithEmail(email: email, password: password);

  @override
  Future<void> createAccount({
    required String email,
    required String password,
  }) =>
      _ds.createAccount(email: email, password: password);

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _ds.sendPasswordResetEmail(email);

  @override
  Future<void> sendEmailVerification() => _ds.sendEmailVerification();

  @override
  Future<void> reloadUser() => _ds.reloadUser();

  @override
  bool get isEmailVerified => _ds.isEmailVerified;

  @override
  Future<void> deleteCurrentUser() => _ds.deleteCurrentUser();

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  Future<GoogleSignInAccount?> initiateGoogleSignIn() =>
      _ds.initiateGoogleSignIn();

  @override
  Future<void> signInWithGoogleCredential({
    required String? idToken,
    required String? accessToken,
  }) =>
      _ds.signInWithGoogleCredential(
        idToken: idToken,
        accessToken: accessToken,
      );

  @override
  Future<bool> isGoogleSignedIn() => _ds.isGoogleSignedIn();

  @override
  Future<void> googleSignOut() => _ds.googleSignOut();

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String photoUrl,
    required bool isGoogleUser,
  }) =>
      _ds.saveUserProfile(
        uid: uid,
        name: name,
        phone: phone,
        email: email,
        photoUrl: photoUrl,
        isGoogleUser: isGoogleUser,
      );

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) =>
      _ds.getUserProfile(uid);

  @override
  Future<bool> isUserProfileComplete(String uid) =>
      _ds.isUserProfileComplete(uid);

  @override
  Future<bool> isPhoneTaken(String phone, {String? excludeUid}) =>
      _ds.isPhoneTaken(phone, excludeUid: excludeUid);
}
