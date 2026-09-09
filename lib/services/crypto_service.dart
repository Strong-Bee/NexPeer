import 'dart:convert';

import 'package:crypto/crypto.dart';

class CryptoService {
  /// Membuat SHA-256 hash dari sebuah string.
  static String sha256Hash(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Membuat SHA-1 hash.
  static String sha1Hash(String text) {
    final bytes = utf8.encode(text);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  /// Membuat MD5 hash.
  static String md5Hash(String text) {
    final bytes = utf8.encode(text);
    final digest = md5.convert(bytes);

    return digest.toString();
  }

  /// Mengubah string menjadi Base64.
  static String encodeBase64(String text) {
    return base64Encode(utf8.encode(text));
  }

  /// Mengubah Base64 kembali menjadi string.
  static String decodeBase64(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }
}
