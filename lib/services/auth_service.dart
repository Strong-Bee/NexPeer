import 'package:supabase_flutter/supabase_flutter.dart';

class NexPeerUser {
  const NexPeerUser(this.raw);
  final User raw;
  String get uid => raw.id;
  String? get displayName => raw.userMetadata?['display_name'] as String? ?? raw.userMetadata?['full_name'] as String?;
  String? get photoURL => raw.userMetadata?['avatar_url'] as String? ?? raw.userMetadata?['picture'] as String?;
  String? get email => raw.email;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  SupabaseClient get _client => Supabase.instance.client;
  NexPeerUser? get currentUser { final user = _client.auth.currentUser; return user == null ? null : NexPeerUser(user); }
  bool get isLoggedIn => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  String _normalize(String value) => value.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();

  Future<AuthResponse> login({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(email: email.trim(), password: password);
    await _ensureProfile();
    return response;
  }

  Future<AuthResponse> register({required String name, required String username, required String email, required String password}) async {
    final normalized = _normalize(username);
    if (!RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(normalized)) {
      throw const AuthException('Username harus 3-24 karakter, huruf kecil, angka, atau garis bawah.', statusCode: 'invalid_username');
    }
    final existing = await _client.from('profiles').select('id').ilike('username', normalized).maybeSingle();
    if (existing != null) throw const AuthException('Username sudah digunakan.', statusCode: 'username_already_exists');
    final response = await _client.auth.signUp(email: email.trim(), password: password, data: {'display_name': name.trim(), 'username': normalized});
    if (response.user != null && response.session != null) {
      await _upsertProfile(response.user!, username: normalized, displayName: name.trim());
    }
    return response;
  }

  Future<void> signInWithGoogle() async { await _client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'nexpeer://login-callback'); }
  Future<void> signInWithApple() async { await _client.auth.signInWithOAuth(OAuthProvider.apple, redirectTo: 'nexpeer://login-callback'); }
  Future<void> resetPassword(String email) async { await _client.auth.resetPasswordForEmail(email.trim(), redirectTo: 'nexpeer://reset-password'); }

  Future<void> _ensureProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final existing = await _client.from('profiles').select('id').eq('id', user.id).maybeSingle();
    if (existing != null) return;
    final metadata = user.userMetadata ?? {};
    final rawName = metadata['username'] as String? ?? 'user_\${user.id.substring(0, 8)}';
    final normalized = _normalize(rawName);
    final username = RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(normalized) ? normalized : 'user_\${user.id.substring(0, 8)}';
    await _upsertProfile(user, username: username, displayName: metadata['display_name'] as String? ?? metadata['full_name'] as String? ?? username);
  }

  Future<void> _upsertProfile(User user, {required String username, required String displayName}) async {
    await _client.from('profiles').upsert({'id': user.id, 'username': username, 'display_name': displayName, 'avatar_url': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'], 'updated_at': DateTime.now().toUtc().toIso8601String()});
  }
  Future<void> logout() => _client.auth.signOut();
}
