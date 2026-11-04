import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/contact_service.dart';
import '../chat/qr_scan_screen.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _candidate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final value = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (!mounted || value == null) return;
    try {
      final payload = jsonDecode(value);
      if (payload is! Map<String, dynamic> ||
          payload['type'] != 'nexpeer-user' ||
          payload['version'] != 1 ||
          payload['uid'] is! String) {
        throw const FormatException('QR bukan QR identitas NexPeer.');
      }
      final verified = await ContactService.instance.findUser('np_${payload['uid']}');
      if (verified == null) throw const FormatException('Akun NexPeer tidak ditemukan.');
      if (!mounted) return;
      setState(() => _candidate = verified);
    } catch (error) {
      _message('QR tidak valid: $error');
    }
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _candidate = null;
    });
    try {
      final result = await ContactService.instance.findUser(_controller.text);
      if (!mounted) return;
      setState(() => _candidate = result);
      if (result == null) _message('Akun NexPeer tidak ditemukan.');
    } catch (error) {
      if (mounted) _message('Pencarian gagal: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final candidate = _candidate;
    if (candidate == null) return;
    setState(() => _loading = true);
    try {
      await ContactService.instance.addContact(candidate);
      if (!mounted) return;
      _message('Kontak berhasil ditambahkan.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidate = _candidate;
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kontak')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.person_add_alt_1_rounded, size: 54, color: Colors.blueAccent),
          const SizedBox(height: 12),
          const Text('Temukan teman di NexPeer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pindai QR identitas atau cari menggunakan username / ID NexPeer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400)),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _loading ? null : _scan,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Pindai QR Code'),
          ),
          const SizedBox(height: 24),
          const Center(child: Text('ATAU')),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Username atau ID NexPeer',
              hintText: '@username atau np_ID',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : _search,
            child: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Cari akun'),
          ),
          if (candidate != null) ...[
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: candidate['photoUrl'] is String
                      ? NetworkImage(candidate['photoUrl'] as String)
                      : null,
                  child: candidate['photoUrl'] is String
                      ? null
                      : const Icon(Icons.person),
                ),
                title: Text(candidate['displayName']?.toString() ?? 'NexPeer User'),
                subtitle: Text('@${candidate['username'] ?? 'unknown'}'),
                trailing: IconButton(
                  tooltip: 'Tambah kontak',
                  onPressed: _loading ? null : _add,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
