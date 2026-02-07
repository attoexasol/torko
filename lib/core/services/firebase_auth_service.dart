import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth service.
/// Signs in with custom token, signs out, exposes authStateChanges.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Firebase custom token.
  /// Token is from Laravel create_users response (do NOT persist).
  Future<UserCredential> signInWithCustomToken(String token) async {
    return _auth.signInWithCustomToken(token);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
