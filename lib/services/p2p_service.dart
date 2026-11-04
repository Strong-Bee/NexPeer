import 'dart:async';

class P2PService {
  P2PService._();
  static final P2PService instance = P2PService._();

  bool _isConnected = false;
  String? _connectedPeerId;
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  Stream<String> get messages => _messageController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;
  bool get isConnected => _isConnected;
  String? get connectedPeerId => _connectedPeerId;

  /// Native P2P transport is not integrated in this release.
  bool get isTransportReady => false;

  Future<void> initialize() async {
    _isConnected = false;
    _connectedPeerId = null;
    _connectionController.add(false);
  }

  /// Called only by a real transport adapter after connection succeeds.
  void setConnected(String peerId) {
    if (peerId.trim().isEmpty) {
      throw ArgumentError.value(peerId, 'peerId', 'Tidak boleh kosong.');
    }
    _isConnected = true;
    _connectedPeerId = peerId;
    _connectionController.add(true);
  }

  void setDisconnected() {
    _isConnected = false;
    _connectedPeerId = null;
    _connectionController.add(false);
  }

  /// Fail explicitly instead of pretending a message was delivered.
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (!_isConnected) {
      throw StateError('Tidak ada peer yang terhubung.');
    }
    throw UnsupportedError(
      'Transport P2P belum diintegrasikan. Pesan tidak dikirim.',
    );
  }

  void handleIncomingMessage(String message) {
    if (message.trim().isEmpty || _messageController.isClosed) return;
    _messageController.add(message);
  }

  Future<void> disconnect() async => setDisconnected();

  Future<void> dispose() async {
    await _messageController.close();
    await _connectionController.close();
  }
}
