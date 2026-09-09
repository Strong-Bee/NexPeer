/// Merepresentasikan satu perangkat (peer) yang ditemukan atau terhubung
/// dalam jaringan peer-to-peer.
class Peer {
  /// ID unik endpoint, biasanya diberikan oleh layer P2P (mis. Nearby Connections).
  final String id;

  /// Nama yang ditampilkan untuk perangkat ini (nama device / username).
  final String name;

  /// Status koneksi saat ini terhadap peer ini.
  PeerStatus status;

  /// Waktu terakhir peer ini terlihat / terhubung.
  DateTime lastSeen;

  Peer({
    required this.id,
    required this.name,
    this.status = PeerStatus.discovered,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Peer copyWith({
    String? id,
    String? name,
    PeerStatus? status,
    DateTime? lastSeen,
  }) {
    return Peer(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status.name,
    'lastSeen': lastSeen.toIso8601String(),
  };

  factory Peer.fromJson(Map<String, dynamic> json) => Peer(
    id: json['id'] as String,
    name: json['name'] as String,
    status: PeerStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => PeerStatus.discovered,
    ),
    lastSeen:
        DateTime.tryParse(json['lastSeen'] as String? ?? '') ?? DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Peer && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Peer(id: $id, name: $name, status: $status)';
}

/// Status hubungan Peer dengan perangkat lokal.
enum PeerStatus {
  /// Ditemukan lewat discovery, tapi belum diminta koneksi.
  discovered,

  /// Permintaan koneksi sedang berlangsung (menunggu diterima).
  connecting,

  /// Sudah terhubung dan siap bertukar pesan.
  connected,

  /// Koneksi terputus / gagal.
  disconnected,
}
