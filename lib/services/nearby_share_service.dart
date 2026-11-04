import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

class NearbyShareService {
  NearbyShareService._();
  static final NearbyShareService instance = NearbyShareService._();

  HttpServer? _server;
  String? _token;
  String? _address;
  final StreamController<String> _receivedController =
      StreamController<String>.broadcast();

  Stream<String> get receivedFiles => _receivedController.stream;
  bool get isReceiving => _server != null;
  String? get shareCode {
    final address = _address;
    final token = _token;
    if (address == null || token == null || _server == null) return null;
    return jsonEncode({
      'type': 'nexpeer-share',
      'version': 1,
      'host': address,
      'port': _server!.port,
      'token': token,
    });
  }

  Future<void> startReceiving() async {
    if (_server != null) return;
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    InternetAddress? localAddress;
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback && !address.isLinkLocal) {
          localAddress = address;
          break;
        }
      }
      if (localAddress != null) break;
    }
    if (localAddress == null) {
      throw StateError('Tidak menemukan alamat IPv4 jaringan lokal. Pastikan Wi-Fi aktif.');
    }

    final random = Random.secure();
    _token = List<int>.generate(32, (_) => random.nextInt(256))
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    _address = localAddress.address;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0, shared: true);
    _server!.listen(_handleRequest, onError: (_) {});
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.method != 'POST' || request.uri.path != '/upload') {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not found');
      await request.response.close();
      return;
    }
    if (request.uri.queryParameters['token'] != _token ||
        _token == null) {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('Invalid share session');
      await request.response.close();
      return;
    }

    final encodedName = request.headers.value('x-file-name');
    final declaredLength = request.contentLength;
    if (encodedName == null || declaredLength < 0 ||
        declaredLength > 1024 * 1024 * 1024) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid file metadata or file exceeds 1 GB');
      await request.response.close();
      return;
    }

    String fileName;
    try {
      fileName = utf8.decode(base64Url.decode(encodedName));
    } catch (_) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid file name');
      await request.response.close();
      return;
    }
    fileName = fileName.split(RegExp(r'[/\\\\]')).last.trim();
    if (fileName.isEmpty || fileName == '.' || fileName == '..') {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid file name');
      await request.response.close();
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final receiveDirectory = Directory('${directory.path}/NexPeer Received');
      await receiveDirectory.create(recursive: true);
      final safeName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final output = File('${receiveDirectory.path}/$safeName');
      final sink = output.openWrite();
      await request.pipe(sink);
      await sink.flush();
      await sink.close();
      _receivedController.add(output.path);
      request.response
        ..statusCode = HttpStatus.created
        ..write('Received');
      await request.response.close();
    } catch (_) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Could not save file');
      await request.response.close();
    }
  }

  Future<void> sendFile({
    required String host,
    required int port,
    required String token,
    required File file,
  }) async {
    final length = await file.length();
    if (length > 1024 * 1024 * 1024) {
      throw StateError('Ukuran file maksimal 1 GB.');
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final uri = Uri(
        scheme: 'http',
        host: host,
        port: port,
        path: '/upload',
        queryParameters: {'token': token},
      );
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.binary;
      request.headers.contentLength = length;
      request.headers.set(
        'x-file-name',
        base64Url.encode(utf8.encode(file.uri.pathSegments.last)),
      );
      await request.addStream(file.openRead());
      final response = await request.close().timeout(const Duration(minutes: 30));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode != HttpStatus.created) {
        throw HttpException('Penerima menolak file: $body');
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<void> stopReceiving() async {
    final server = _server;
    _server = null;
    _token = null;
    _address = null;
    await server?.close(force: true);
  }

  Future<void> dispose() async {
    await stopReceiving();
    await _receivedController.close();
  }
}
