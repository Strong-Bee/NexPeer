import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/nearby_share_service.dart';
import '../chat/qr_scan_screen.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _service = NearbyShareService.instance;
  bool _starting = false;
  bool _sending = false;
  String? _status;
  Stream<String>? _receivedStream;

  @override
  void initState() {
    super.initState();
    _receivedStream = _service.receivedFiles;
  }

  @override
  void dispose() {
    _service.stopReceiving();
    super.dispose();
  }

  Future<void> _startReceiving() async {
    setState(() {
      _starting = true;
      _status = null;
    });
    try {
      await _service.startReceiving();
      if (!mounted) return;
      setState(() => _status = 'Siap menerima file. Bagikan QR ini ke pengirim.');
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _stopReceiving() async {
    await _service.stopReceiving();
    if (mounted) setState(() => _status = 'Sesi penerimaan dihentikan.');
  }

  Future<void> _sendFiles() async {
    final raw = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (!mounted || raw == null) return;

    Map<String, dynamic> session;
    try {
      session = jsonDecode(raw) as Map<String, dynamic>;
      if (session['type'] != 'nexpeer-share' ||
          session['version'] != 1 ||
          session['host'] is! String ||
          session['port'] is! int ||
          session['token'] is! String) {
        throw const FormatException('QR bukan sesi NexPeer Share.');
      }
    } catch (error) {
      _showMessage('QR tidak valid: $error');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: false,
    );
    if (!mounted || result == null) return;

    final files = result.files.where((item) => item.path != null).toList();
    if (files.isEmpty) {
      _showMessage('File tidak dapat dibaca dari perangkat ini.');
      return;
    }

    setState(() {
      _sending = true;
      _status = 'Mengirim 0 dari ${files.length} file...';
    });
    var sent = 0;
    try {
      for (final item in files) {
        await _service.sendFile(
          host: session['host'] as String,
          port: session['port'] as int,
          token: session['token'] as String,
          file: File(item.path!),
        );
        sent++;
        if (mounted) {
          setState(() => _status = 'Mengirim $sent dari ${files.length} file...');
        }
      }
      if (mounted) _showMessage('$sent file berhasil dikirim.');
    } catch (error) {
      if (mounted) _showMessage('Pengiriman gagal: $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = _service.shareCode;
    return Scaffold(
      appBar: AppBar(title: const Text('NexPeer Share')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.devices_rounded, size: 54, color: Colors.blueAccent),
            const SizedBox(height: 12),
            const Text(
              'Kirim file antar Android dan iPhone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Transfer langsung melalui Wi-Fi lokal. Kedua perangkat harus terhubung ke jaringan Wi-Fi yang sama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text('TERIMA FILE', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (code != null) ...[
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(12),
                        child: QrImageView(data: code, size: 220),
                      ),
                      const SizedBox(height: 12),
                      const Text('Pindai QR ini dari perangkat pengirim.'),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _stopReceiving,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Hentikan sesi'),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _starting ? null : _startReceiving,
                          icon: _starting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.qr_code_2_rounded),
                          label: Text(_starting ? 'Menyiapkan...' : 'Tampilkan QR penerimaan'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text('KIRIM FILE', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Pindai QR dari perangkat penerima, lalu pilih satu atau beberapa file.'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _sending ? null : _sendFiles,
                        icon: _sending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.qr_code_scanner_rounded),
                        label: Text(_sending ? 'Mengirim...' : 'Pindai QR & pilih file'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 14),
              Text(_status!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 18),
            const Text(
              'File yang diterima disimpan di folder dokumen aplikasi: NexPeer Received. Ukuran maksimum per file 1 GB.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            StreamBuilder<String>(
              stream: _receivedStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('File diterima'),
                  subtitle: Text(snapshot.data!.split(Platform.pathSeparator).last),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
