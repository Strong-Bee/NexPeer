import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ContactService {
  ContactService._();
  static final ContactService instance = ContactService._();

  static const _apiBase = String.fromEnvironment('NEXPEER_API_URL');
  Database? _database;

  User get _user {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Silakan login terlebih dahulu.');
    return user;
  }

  String normalizeUsername(String value) =>
      value.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();

  String userId(String uid) => 'np_$uid';

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      p.join(root, 'nexpeer.sqlite'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE profiles (uid TEXT PRIMARY KEY, username TEXT NOT NULL, displayName TEXT NOT NULL, photoUrl TEXT, updatedAt TEXT NOT NULL)');
        await db.execute('CREATE TABLE contacts (uid TEXT PRIMARY KEY, username TEXT NOT NULL, displayName TEXT NOT NULL, photoUrl TEXT, addedAt TEXT NOT NULL)');
      },
    );
    return _database!;
  }

  Future<String> _token() async {
    final token = await _user.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi login tidak valid. Silakan login ulang.');
    }
    return token;
  }

  Uri _uri(String path) {
    if (_apiBase.isEmpty) {
      throw StateError('API belum dikonfigurasi. Tambahkan --dart-define=NEXPEER_API_URL=https://alamat-api.');
    }
    return Uri.parse(_apiBase).resolve(path);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = {
      'Authorization': 'Bearer ${await _token()}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final uri = _uri(path);
    late http.Response response;
    if (method == 'GET') {
      response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
    } else if (method == 'POST') {
      response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 15));
    } else if (method == 'PATCH') {
      response = await http.patch(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 15));
    } else {
      throw UnsupportedError('HTTP method tidak didukung.');
    }
    final dynamic decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map ? decoded['error'] : null;
      throw StateError(message?.toString() ?? 'API NexPeer gagal (${response.statusCode}).');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Respons API NexPeer tidak valid.');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> ensureProfile({String? requestedUsername}) async {
    final user = _user;
    final result = await _request('POST', '/v1/me', body: {
      if (requestedUsername != null && requestedUsername.trim().isNotEmpty)
        'username': normalizeUsername(requestedUsername),
      'displayName': user.displayName ?? user.email?.split('@').first ?? 'NexPeer User',
      'photoUrl': user.photoURL,
    });
    final profile = Map<String, dynamic>.from(result['profile'] as Map);
    await _cacheProfile(profile);
    return profile;
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final result = await _request('GET', '/v1/me');
      final profile = Map<String, dynamic>.from(result['profile'] as Map);
      await _cacheProfile(profile);
      return profile;
    } catch (_) {
      final rows = await (await _db).query('profiles',
          where: 'uid = ?', whereArgs: [_user.uid], limit: 1);
      if (rows.isNotEmpty) return rows.first;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> findUser(String value) async {
    final input = value.trim();
    if (input.isEmpty) return null;
    final identifier = input.startsWith('np_') ? input : normalizeUsername(input);
    final result = await _request('GET', '/v1/users/${Uri.encodeComponent(identifier)}');
    final profile = result['profile'];
    return profile == null ? null : Map<String, dynamic>.from(profile as Map);
  }

  Future<void> addContact(Map<String, dynamic> peer) async {
    final uid = peer['uid']?.toString();
    if (uid == null || uid.isEmpty || uid == _user.uid) {
      throw StateError('ID NexPeer tidak valid atau merupakan akun sendiri.');
    }
    final result = await _request('POST', '/v1/contacts', body: {'contactUid': uid});
    await _cacheContact(Map<String, dynamic>.from(result['contact'] as Map));
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final result = await _request('GET', '/v1/contacts');
      final contacts = (result['contacts'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map)).toList();
      final db = await _db;
      final batch = db.batch();
      for (final contact in contacts) {
        batch.insert('contacts', _contactRow(contact),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
      return contacts;
    } catch (_) {
      final rows = await (await _db).query('contacts',
          orderBy: 'displayName COLLATE NOCASE');
      if (rows.isNotEmpty) return rows;
      rethrow;
    }
  }

  Future<void> _cacheProfile(Map<String, dynamic> profile) async {
    await (await _db).insert('profiles', {
      'uid': profile['uid'],
      'username': profile['username'],
      'displayName': profile['displayName'],
      'photoUrl': profile['photoUrl'],
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _cacheContact(Map<String, dynamic> contact) async {
    await (await _db).insert('contacts', _contactRow(contact),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Map<String, Object?> _contactRow(Map<String, dynamic> contact) => {
    'uid': contact['uid'],
    'username': contact['username'],
    'displayName': contact['displayName'],
    'photoUrl': contact['photoUrl'],
    'addedAt': contact['addedAt'] ?? DateTime.now().toUtc().toIso8601String(),
  };
}
