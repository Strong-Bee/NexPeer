import 'dart:async';

class P2PService {
  P2PService._();

  static final P2PService instance = P2PService._();

  bool _isConnected = false;
  String? _connectedPeerId;

  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  /// Stream pesan yang diterima.
  Stream<String> get messages => _messageController.stream;

  /// Stream status koneksi.
  Stream<bool> get connectionStatus => _connectionController.stream;

  /// Status koneksi saat ini.
  bool get isConnected => _isConnected;

  /// ID peer yang sedang terhubung.
  String? get connectedPeerId => _connectedPeerId;

  /// Inisialisasi service.
  Future<void> initialize() async {
    _isConnected = false;
    _connectedPeerId = null;

    _connectionController.add(false);
  }

  /// Dipanggil ketika berhasil terhubung ke peer.
  void setConnected(String peerId) {
    _isConnected = true;
    _connectedPeerId = peerId;

    _connectionController.add(true);
  }

  /// Dipanggil ketika koneksi terputus.
  void setDisconnected() {
    _isConnected = false;
    _connectedPeerId = null;

    _connectionController.add(false);
  }

  /// Mengirim pesan.
  ///
  /// Implementasi pengiriman sebenarnya akan dihubungkan
  /// dengan flutter_p2p_connection.
  Future<void> sendMessage(String message) async {
    if (!_isConnected) {
      throw StateError('Tidak ada peer yang terhubung.');
    }

    if (message.trim().isEmpty) {
      return;
    }

    // TODO:
    // Hubungkan bagian ini dengan socket/channel
    // dari flutter_p2p_connection.
    //
    // Contoh alurnya:
    //
    // final payload = jsonEncode({
    //   'type': 'message',
    //   'data': message,
    // });
    //
    // lalu kirim payload melalui koneksi P2P.

    print('P2P SEND: $message');
  }

  /// Dipanggil ketika data diterima dari peer.
  void handleIncomingMessage(String message) {
    if (message.trim().isEmpty) {
      return;
    }

    _messageController.add(message);
  }

  /// Disconnect dari peer.
  Future<void> disconnect() async {
    // TODO:
    // Tambahkan disconnect dari flutter_p2p_connection.

    setDisconnected();
  }

  /// Membersihkan resources.
  void dispose() {
    _messageController.close();
    _connectionController.close();
  }
}
