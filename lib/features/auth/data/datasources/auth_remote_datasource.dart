import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
                  '136794753205-210rggct227ahdu5t70ckn30rejonctk.apps.googleusercontent.com',
            );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> createAccount({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();

  Future<GoogleSignInAccount?> initiateGoogleSignIn() async {
    await _googleSignIn.signOut();
    return _googleSignIn.signIn();
  }

  Future<void> signInWithGoogleCredential({
    required String? idToken,
    required String? accessToken,
  }) async {
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<bool> isGoogleSignedIn() => _googleSignIn.isSignedIn();
  Future<void> googleSignOut() => _googleSignIn.signOut();

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String photoUrl,
    required bool isGoogleUser,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final exists = (await docRef.get()).exists;
    await docRef.set({
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'provider': isGoogleUser ? 'google' : 'email',
      // Only stamp createdAt on initial creation — re-login must not overwrite it
      if (!exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<bool> isUserProfileComplete(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    return (doc.data()?['phone'] ?? '').toString().isNotEmpty;
  }
}
