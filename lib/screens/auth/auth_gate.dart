import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  final bool supabaseReady;
  const AuthGate({super.key, this.supabaseReady = false});
  @override
  Widget build(BuildContext context) {
    if (!supabaseReady) return const _SupabaseSetupScreen();
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(backgroundColor: Color(0xFF0B1020), body: Center(child: CircularProgressIndicator()));
        return Supabase.instance.client.auth.currentSession != null ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}

class _SupabaseSetupScreen extends StatelessWidget {
  const _SupabaseSetupScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0B1020),
    body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_outlined, size: 56, color: Color(0xFF38BDF8)), const SizedBox(height: 20),
      const Text('Supabase belum dikonfigurasi', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
      Text('Atur SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY, lalu jalankan ulang aplikasi. Jangan pernah memasukkan service_role key ke aplikasi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, height: 1.5)),
    ]))))),
  );
}
