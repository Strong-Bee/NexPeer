import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/auth_service.dart';
import '../../services/contact_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Silakan login.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ContactService.instance.getMyProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Profil belum tersedia: ${snapshot.error ?? ''}'));
          }
          final profile = snapshot.data!;
          final username = profile['username']?.toString() ?? 'unknown';
          final displayName = profile['displayName']?.toString() ?? user.displayName ?? 'NexPeer User';
          final payload = jsonEncode({
            'type': 'nexpeer-user',
            'version': 1,
            'uid': user.uid,
            'username': username,
            'displayName': displayName,
            'photoUrl': user.photoURL,
          });
          final id = ContactService.instance.userId(user.uid);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 42,
                backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null ? const Icon(Icons.person, size: 42) : null,
              ),
              const SizedBox(height: 12),
              Text(displayName, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('@$username', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('QR CODE NEXPEER', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(12),
                        child: QrImageView(data: payload, size: 220),
                      ),
                      const SizedBox(height: 14),
                      const Text('Minta teman memindai QR ini untuk menambahkan Anda.'),
                      const SizedBox(height: 16),
                      SelectableText(id, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: id));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID NexPeer disalin.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Salin ID NexPeer'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(leading: const Icon(Icons.person_outline), title: const Text('Edit Profile'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
              ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notifications'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
              ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Privacy'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
              ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
              ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
            ],
          );
        },
      ),
    );
  }
}
