import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Register
  Future<UserCredential> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final normalized = username.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();
    if (!RegExp(r'^[a-z0-9_]{3,24}

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.reload();
      final normalized = username.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();
      if (!RegExp(r'^[a-z0-9_]{3,24}
    }

    return credential;
  }

  // Google Login
  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();

    final googleAuthentication = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    await _ensureSocialProfile(result.user);
    return result;
  }

  // Apple Login
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final credential = await _auth.signInWithCredential(oauthCredential);

    final user = credential.user;

    final name = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().join(' ').trim();

    if (user != null &&
        name.isNotEmpty &&
        (user.displayName == null || user.displayName!.isEmpty)) {
      await user.updateDisplayName(name);
    }

    await _ensureSocialProfile(user);
    return credential;
  }

  Future<void> _ensureSocialProfile(User? user) async {
    if (user == null) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    if (snapshot.exists) return;
    final base = 'user_${user.uid.substring(0, 8)}';
    final usernameRef = FirebaseFirestore.instance.collection('usernames').doc(base);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final existing = await transaction.get(usernameRef);
      if (existing.exists && existing.data()?['uid'] != user.uid) {
        throw FirebaseAuthException(code: 'username-reservation-conflict');
      }
      transaction.set(usernameRef, {'uid': user.uid});
      transaction.set(userRef, {
        'uid': user.uid,
        'username': base,
        'displayName': user.displayName ?? base,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Logout
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    await _auth.signOut();
  }
}
).hasMatch(normalized)) {
        throw FirebaseAuthException(code: 'invalid-username', message: 'Username harus 3-24 karakter, huruf kecil, angka, atau garis bawah.');
      }
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final usernameRef = FirebaseFirestore.instance.collection('usernames').doc(normalized);
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final existing = await transaction.get(usernameRef);
          if (existing.exists) {
            throw FirebaseAuthException(code: 'username-already-in-use');
          }
          transaction.set(usernameRef, {'uid': user.uid});
          transaction.set(userRef, {
            'uid': user.uid,
            'username': normalized,
            'displayName': name.trim(),
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
      } catch (_) {
        await user.delete();
        rethrow;
      }
    }

    return credential;
  }

  // Google Login
  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();

    final googleAuthentication = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  // Apple Login
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final credential = await _auth.signInWithCredential(oauthCredential);

    final user = credential.user;

    final name = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().join(' ').trim();

    if (user != null &&
        name.isNotEmpty &&
        (user.displayName == null || user.displayName!.isEmpty)) {
      await user.updateDisplayName(name);
    }

    return credential;
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Logout
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    await _auth.signOut();
  }
}
).hasMatch(normalized)) {
      throw FirebaseAuthException(code: 'invalid-username', message: 'Username harus 3-24 karakter, huruf kecil, angka, atau garis bawah.');
    }
    final usernameRef = FirebaseFirestore.instance.collection('usernames').doc(normalized);
    final usernameSnapshot = await usernameRef.get();
    if (usernameSnapshot.exists) {
      throw FirebaseAuthException(code: 'username-already-in-use');
    }
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.reload();
      final normalized = username.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();
      if (!RegExp(r'^[a-z0-9_]{3,24}
    }

    return credential;
  }

  // Google Login
  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();

    final googleAuthentication = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    await _ensureSocialProfile(result.user);
    return result;
  }

  // Apple Login
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final credential = await _auth.signInWithCredential(oauthCredential);

    final user = credential.user;

    final name = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().join(' ').trim();

    if (user != null &&
        name.isNotEmpty &&
        (user.displayName == null || user.displayName!.isEmpty)) {
      await user.updateDisplayName(name);
    }

    await _ensureSocialProfile(user);
    return credential;
  }

  Future<void> _ensureSocialProfile(User? user) async {
    if (user == null) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    if (snapshot.exists) return;
    final base = 'user_${user.uid.substring(0, 8)}';
    final usernameRef = FirebaseFirestore.instance.collection('usernames').doc(base);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final existing = await transaction.get(usernameRef);
      if (existing.exists && existing.data()?['uid'] != user.uid) {
        throw FirebaseAuthException(code: 'username-reservation-conflict');
      }
      transaction.set(usernameRef, {'uid': user.uid});
      transaction.set(userRef, {
        'uid': user.uid,
        'username': base,
        'displayName': user.displayName ?? base,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Logout
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    await _auth.signOut();
  }
}
).hasMatch(normalized)) {
        throw FirebaseAuthException(code: 'invalid-username', message: 'Username harus 3-24 karakter, huruf kecil, angka, atau garis bawah.');
      }
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final usernameRef = FirebaseFirestore.instance.collection('usernames').doc(normalized);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final existing = await transaction.get(usernameRef);
        if (existing.exists && existing.data()?['uid'] != user.uid) {
          throw FirebaseAuthException(code: 'username-already-in-use');
        }
        transaction.set(usernameRef, {'uid': user.uid});
        transaction.set(userRef, {
          'uid': user.uid,
          'username': normalized,
          'displayName': name.trim(),
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    }

    return credential;
  }

  // Google Login
  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();

    final googleAuthentication = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  // Apple Login
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final credential = await _auth.signInWithCredential(oauthCredential);

    final user = credential.user;

    final name = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().join(' ').trim();

    if (user != null &&
        name.isNotEmpty &&
        (user.displayName == null || user.displayName!.isEmpty)) {
      await user.updateDisplayName(name);
    }

    return credential;
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Logout
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    await _auth.signOut();
  }
}
