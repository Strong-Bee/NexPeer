import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } on FirebaseException {
    // Firebase is optional during local UI development. AuthGate displays
    // setup instructions instead of crashing when native Firebase config
    // (google-services.json / GoogleService-Info.plist) is missing.
  } catch (_) {
    // Keep the app launchable and surface the configuration state in the UI.
  }

  runApp(NexPeerApp(firebaseReady: firebaseReady));
}

class NexPeerApp extends StatelessWidget {
  final bool firebaseReady;

  const NexPeerApp({super.key, this.firebaseReady = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexPeer',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFF0B1020),
      ),
      home: SplashScreen(firebaseReady: firebaseReady),
    );
  }
}
