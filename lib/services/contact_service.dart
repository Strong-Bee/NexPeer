import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactService {
  ContactService._();
  static final ContactService instance = ContactService._();
  SupabaseClient get _client => Supabase.instance.client;
  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Silakan login terlebih dahulu.');
    return id;
  }

  Database? _database;
  RealtimeChannel? _channel;
  final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();
  final Set<String> _subscribedUsers = {};

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(p.join(root, 'nexpeer_cache.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE contacts (owner_id TEXT NOT NULL, contact_id TEXT NOT NULL, username TEXT NOT NULL, display_name TEXT NOT NULL, avatar_url TEXT, added_at TEXT NOT NULL, PRIMARY KEY(owner_id, contact_id))');
      });
    return _database!;
  }

  String normalizeUsername(String value) => value.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();

  Future<void> ensureProfile({String? requestedUsername}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Silakan login terlebih dahulu.');
    final existing = await _client.from('profiles').select('id').eq('id', user.id).maybeSingle();
    if (existing != null) return;
    final metadata = user.userMetadata ?? {};
    final requested = normalizeUsername(requestedUsername ?? (metadata['username'] as String?) ?? 'user_${user.id.substring(0, 8)}');
    if (!RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(requested)) {
      throw StateError('Username harus 3-24 karakter: huruf kecil, angka, atau garis bawah.');
    }
    await _client.from('profiles').insert({
      'id': user.id, 'username': requested,
      'display_name': metadata['display_name'] ?? metadata['full_name'] ?? requested,
      'avatar_url': metadata['avatar_url'] ?? metadata['picture'],
    });
  }

  Future<Map<String, dynamic>?> findUser(String value) async {
    final input = value.trim();
    if (input.isEmpty) return null;
    final query = _client.from('profiles').select('id, username, display_name, avatar_url');
    if (input.startsWith('np_')) return query.eq('id', input.substring(3)).maybeSingle();
    if (input.contains('@')) return null;
    return query.ilike('username', normalizeUsername(input)).maybeSingle();
  }

  Future<void> addContact(Map<String, dynamic> peer) async {
    final owner = _uid;
    final id = peer['id']?.toString() ?? peer['uid']?.toString();
    if (id == null || id.isEmpty) throw StateError('ID NexPeer tidak valid.');
    if (id == owner) throw StateError('Anda tidak dapat menambahkan akun sendiri.');
    await _client.from('contacts').upsert({'owner_id': owner, 'contact_id': id},
      onConflict: 'owner_id,contact_id', ignoreDuplicates: true);
    await _refreshContacts();
  }

  Stream<List<Map<String, dynamic>>> get contacts async* {
    final owner = _uid;
    yield await _readCached(owner);
    await _refreshContacts();
    _subscribe(owner);
    yield await _readCached(owner);
    yield* _controller.stream;
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    await ensureProfile();
    final user = _client.auth.currentUser!;
    final row = await _client.from('profiles').select('id, username, display_name, avatar_url').eq('id', user.id).single();
    return {'uid': row['id'], 'username': row['username'], 'displayName': row['display_name'], 'photoUrl': row['avatar_url']};
  }

  String userId(String uid) => 'np_$uid';

  Future<List<Map<String, dynamic>>> _readCached(String owner) async {
    final rows = await (await _db).query('contacts', where: 'owner_id = ?', whereArgs: [owner], orderBy: 'display_name COLLATE NOCASE');
    return rows.map((row) => {'uid': row['contact_id'], 'id': row['contact_id'], 'username': row['username'], 'displayName': row['display_name'], 'photoUrl': row['avatar_url']}).toList();
  }

  Future<void> _refreshContacts() async {
    final owner = _uid;
    final rows = await _client.from('contacts')
      .select('contact_id, created_at, profiles!contacts_contact_id_fkey(id, username, display_name, avatar_url)')
      .eq('owner_id', owner);
    final db = await _db;
    final batch = db.batch();
    batch.delete('contacts', where: 'owner_id = ?', whereArgs: [owner]);
    for (final item in rows) {
      final profile = item['profiles'] as Map<String, dynamic>?;
      if (profile == null) continue;
      batch.insert('contacts', {
        'owner_id': owner, 'contact_id': profile['id'], 'username': profile['username'],
        'display_name': profile['display_name'], 'avatar_url': profile['avatar_url'],
        'added_at': item['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    _controller.add(await _readCached(owner));
  }

  void _subscribe(String owner) {
    if (!_subscribedUsers.add(owner)) return;
    _channel = _client.channel('contacts-$owner')
      ..onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: 'contacts',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'owner_id', value: owner),
        callback: (_) { _refreshContacts(); })
      ..subscribe();
  }
}
