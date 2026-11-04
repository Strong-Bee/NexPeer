import 'package:flutter/material.dart';

import '../../services/contact_service.dart';
import 'add_contact_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late Future<List<Map<String, dynamic>>> _contacts;
  @override
  void initState() {
    super.initState();
    _contacts = ContactService.instance.getContacts();
  }

  Future<void> _refresh() async {
    final request = ContactService.instance.getContacts();
    setState(() => _contacts = request);
    await request;
  }

  Future<void> _addContact() async {
    await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => const AddContactScreen()));
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kontak'), actions: [
      IconButton(tooltip: 'Tambah kontak', onPressed: _addContact,
        icon: const Icon(Icons.person_add_alt_1_rounded)),
    ]),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _contacts,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Gagal memuat kontak: ${snapshot.error}', textAlign: TextAlign.center)));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final contacts = snapshot.data ?? [];
        if (contacts.isEmpty) return Center(child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.people_outline_rounded, size: 58, color: Colors.white38),
            const SizedBox(height: 14),
            const Text('Belum ada kontak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tambahkan teman menggunakan QR Code, username, atau ID NexPeer.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _addContact,
              icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('Tambah kontak')),
          ])));
        return RefreshIndicator(onRefresh: _refresh, child: ListView.separated(
          itemCount: contacts.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 76),
          itemBuilder: (context, index) {
            final data = contacts[index];
            final photo = data['photoUrl']?.toString();
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: photo != null && photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo == null || photo.isEmpty ? const Icon(Icons.person) : null),
              title: Text(data['displayName']?.toString() ?? 'NexPeer User'),
              subtitle: Text('@${data['username'] ?? ''}'),
              trailing: const Icon(Icons.chevron_right_rounded));
          },
        ));
      },
    ),
  );
}
