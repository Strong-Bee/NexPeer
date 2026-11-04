import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/contact_service.dart';
import 'add_contact_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontak'),
        actions: [
          IconButton(
            tooltip: 'Tambah kontak',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddContactScreen()),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ContactService.instance.contacts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat kontak: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snapshot.data?.docs ?? [];
          if (contacts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 58, color: Colors.white38),
                    const SizedBox(height: 14),
                    const Text('Belum ada kontak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Tambahkan teman menggunakan QR Code, username, atau ID NexPeer.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddContactScreen()),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Tambah kontak'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: contacts.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final data = contacts[index].data();
              final name = data['displayName']?.toString() ?? 'NexPeer User';
              final username = data['username']?.toString() ?? '';
              final photo = data['photoUrl']?.toString();
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: photo != null && photo.isNotEmpty ? NetworkImage(photo) : null,
                  child: photo == null || photo.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(name),
                subtitle: Text('@$username'),
                trailing: const Icon(Icons.chevron_right_rounded),
              );
            },
          );
        },
      ),
    );
  }
}
