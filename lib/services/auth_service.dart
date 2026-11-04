import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'contact_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(), password: password);
    await ContactService.instance.ensureProfile();
    return credential;
  }

  Future<UserCredential> register({
    required String name, required String username,
    required String email, required String password,
  }) async {
    final normalized = username.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();
    if (!RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(normalized)) {
      throw FirebaseAuthException(code: 'invalid-username',
        message: 'Username harus 3-24 karakter, huruf kecil, angka, atau garis bawah.');
    }
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(), password: password);
    final user = credential.user;
    if (user == null) return credential;
    try {
      await user.updateDisplayName(name.trim());
      await ContactService.instance.ensureProfile(requestedUsername: normalized);
    } catch (_) {
      await user.delete();
      rethrow;
    }
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final googleUser = await googleSignIn.authenticate();
    final googleAuthentication = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(idToken: googleAuthentication.idToken);
    final result = await _auth.signInWithCredential(credential);
    await ContactService.instance.ensureProfile();
    return result;
  }

  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode);
    final credential = await _auth.signInWithCredential(oauthCredential);
    final user = credential.user;
    final name = [appleCredential.givenName, appleCredential.familyName]
        .whereType<String>().join(' ').trim();
    if (user != null && name.isNotEmpty &&
        (user.displayName == null || user.displayName!.isEmpty)) {
      await user.updateDisplayName(name);
    }
    await ContactService.instance.ensureProfile();
    return credential;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    try { await GoogleSignIn.instance.signOut(); } catch (_) {}
    await _auth.signOut();
  }
}
