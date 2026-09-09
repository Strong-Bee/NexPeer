import 'package:flutter/material.dart';
import '../models/peer.dart';

/// Menampilkan satu peer dalam daftar perangkat, lengkap dengan status
/// koneksi dan tombol aksi (connect / chat / disconnect).
class PeerCard extends StatelessWidget {
  final Peer peer;
  final VoidCallback? onConnect;
  final VoidCallback? onOpenChat;
  final VoidCallback? onDisconnect;

  const PeerCard({
    super.key,
    required this.peer,
    this.onConnect,
    this.onOpenChat,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _statusColor(peer.status).withOpacity(0.15),
          child: Icon(Icons.smartphone, color: _statusColor(peer.status)),
        ),
        title: Text(
          peer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _statusColor(peer.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(_statusLabel(peer.status)),
          ],
        ),
        trailing: _buildAction(context),
        onTap: peer.status == PeerStatus.connected ? onOpenChat : null,
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    switch (peer.status) {
      case PeerStatus.discovered:
        return FilledButton.tonal(
          onPressed: onConnect,
          child: const Text('Hubungkan'),
        );
      case PeerStatus.connecting:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        );
      case PeerStatus.connected:
        return IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: onOpenChat,
          tooltip: 'Buka chat',
        );
      case PeerStatus.disconnected:
        return TextButton(
          onPressed: onConnect,
          child: const Text('Sambungkan lagi'),
        );
    }
  }

  Color _statusColor(PeerStatus status) {
    switch (status) {
      case PeerStatus.discovered:
        return Colors.blueGrey;
      case PeerStatus.connecting:
        return Colors.orange;
      case PeerStatus.connected:
        return Colors.green;
      case PeerStatus.disconnected:
        return Colors.redAccent;
    }
  }

  String _statusLabel(PeerStatus status) {
    switch (status) {
      case PeerStatus.discovered:
        return 'Ditemukan';
      case PeerStatus.connecting:
        return 'Menghubungkan...';
      case PeerStatus.connected:
        return 'Terhubung';
      case PeerStatus.disconnected:
        return 'Terputus';
    }
  }
}
