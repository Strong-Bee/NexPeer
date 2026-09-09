import 'dart:convert';

/// Jenis payload yang dikirim lewat koneksi P2P.
enum MessageType { text, system, file }

/// Merepresentasikan satu pesan chat, baik yang dikirim maupun diterima.
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;

  /// True jika pesan ini dikirim oleh perangkat lokal (bukan diterima).
  final bool isMe;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.isMe = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json, {bool isMe = false}) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isMe: isMe,
    );
  }

  /// Encode pesan ini menjadi String JSON, siap dikirim lewat payload P2P.
  String encode() => jsonEncode(toJson());

  /// Decode String JSON (hasil kiriman peer lain) menjadi objek [Message].
  factory Message.decode(String raw, {bool isMe = false}) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Message.fromJson(map, isMe: isMe);
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isMe,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
    );
  }
}
