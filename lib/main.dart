import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var ready = false;
  final url = const String.fromEnvironment('SUPABASE_URL').trim();
  final key = const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY').trim();
  if (url.isNotEmpty && key.isNotEmpty) {
    try { await Supabase.initialize(url: url, publishableKey: key); ready = true; }
    catch (error) { debugPrint('Supabase initialization failed: $error'); }
  }
  runApp(NexPeerApp(supabaseReady: ready));
}

class NexPeerApp extends StatelessWidget {
  final bool supabaseReady;
  const NexPeerApp({super.key, this.supabaseReady = false});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'NexPeer',
    theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, colorSchemeSeed: const Color(0xFF2563EB), scaffoldBackgroundColor: const Color(0xFF0B1020)),
    home: SplashScreen(supabaseReady: supabaseReady),
  );
}
