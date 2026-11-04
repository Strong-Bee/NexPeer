import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactService {
  ContactService._();
  static final ContactService instance = ContactService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  User get _user {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Silakan login terlebih dahulu.');
    return user;
  }

  String normalizeUsername(String value) =>
      value.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();

  Future<void> ensureProfile({String? requestedUsername}) async {
    final user = _user;
    final userRef = _db.collection('users').doc(user.uid);
    final existing = await userRef.get();
    if (existing.exists) return;

    final base = normalizeUsername(
      requestedUsername?.isNotEmpty == true
          ? requestedUsername!
          : 'user_${user.uid.substring(0, 8)}',
    );
    if (!RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(base)) {
      throw StateError('Username harus 3-24 karakter: huruf kecil, angka, atau garis bawah.');
    }

    final usernameRef = _db.collection('usernames').doc(base);
    await _db.runTransaction((transaction) async {
      final reservation = await transaction.get(usernameRef);
      if (reservation.exists && reservation.data()?['uid'] != user.uid) {
        throw StateError('Username sudah digunakan. Silakan pilih username lain.');
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

  Future<Map<String, dynamic>?> findUser(String value) async {
    final input = value.trim();
    if (input.isEmpty) return null;
    final users = _db.collection('users');
    if (input.startsWith('np_')) {
      final byId = await users.doc(input.substring(3)).get();
      return byId.exists ? byId.data() : null;
    }
    if (input.contains('@')) return null;
    final username = normalizeUsername(input);
    final reservation = await _db.collection('usernames').doc(username).get();
    final uid = reservation.data()?['uid'] as String?;
    if (uid == null) return null;
    final result = await users.doc(uid).get();
    return result.data();
  }

  Future<void> addContact(Map<String, dynamic> peer) async {
    final user = _user;
    final uid = peer['uid'] as String?;
    if (uid == null || uid.isEmpty) throw StateError('ID NexPeer tidak valid.');
    if (uid == user.uid) throw StateError('Anda tidak dapat menambahkan akun sendiri.');
    await _db.collection('users').doc(user.uid).collection('contacts').doc(uid).set({
      'uid': uid,
      'username': peer['username'],
      'displayName': peer['displayName'],
      'photoUrl': peer['photoUrl'],
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get contacts =>
      _db.collection('users').doc(_user.uid).collection('contacts')
          .orderBy('displayName').snapshots();

  Future<Map<String, dynamic>> getMyProfile() async {
    final user = _user;
    await ensureProfile();
    final snapshot = await _db.collection('users').doc(user.uid).get();
    return snapshot.data()!;
  }

  String userId(String uid) => 'np_$uid';
}
