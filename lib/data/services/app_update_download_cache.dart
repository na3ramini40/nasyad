import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AppUpdateDownloadCache {
  AppUpdateDownloadCache({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<Directory> cacheDirectory() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/app_updates');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> assetFile(String assetName) async {
    final dir = await cacheDirectory();
    return File('${dir.path}/$assetName');
  }

  Future<File> metaFile(String assetName) async {
    final dir = await cacheDirectory();
    return File('${dir.path}/$assetName.meta.json');
  }

  Future<bool> hasValidCachedAsset({
    required String assetName,
    required int expectedSizeBytes,
  }) async {
    final file = await assetFile(assetName);
    if (!await file.exists()) return false;
    if (await file.length() != expectedSizeBytes) return false;

    final meta = await _readMeta(assetName);
    if (meta == null) return false;
    if (meta['size'] != expectedSizeBytes) return false;

    final digest = meta['sha256'] as String?;
    if (digest == null || digest.isEmpty) return false;

    final actual = await _sha256OfFile(file);
    return actual == digest;
  }

  Stream<DownloadProgressEvent> downloadResumable({
    required Uri url,
    required String assetName,
    required int expectedSizeBytes,
  }) async* {
    final file = await assetFile(assetName);
    var received = 0;
    if (await file.exists()) {
      received = await file.length();
      if (received > expectedSizeBytes) {
        await file.delete();
        received = 0;
      }
      if (received == expectedSizeBytes) {
        final valid = await hasValidCachedAsset(
          assetName: assetName,
          expectedSizeBytes: expectedSizeBytes,
        );
        if (valid) {
          yield DownloadProgressEvent(
            receivedBytes: received,
            totalBytes: expectedSizeBytes,
          );
          return;
        }
        await file.delete();
        received = 0;
      }
    }

    final request = http.Request('GET', url);
    if (received > 0) {
      request.headers['Range'] = 'bytes=$received-';
    }
    request.headers['User-Agent'] = 'nasyad-app-update';

    final response = await _client.send(request);
    if (response.statusCode == 416 && received > 0) {
      if (received == expectedSizeBytes) {
        yield DownloadProgressEvent(
          receivedBytes: received,
          totalBytes: expectedSizeBytes,
        );
        await _writeMeta(assetName, expectedSizeBytes, file);
        return;
      }
      await file.delete();
      yield* downloadResumable(
        url: url,
        assetName: assetName,
        expectedSizeBytes: expectedSizeBytes,
      );
      return;
    }

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw HttpException('Download failed: HTTP ${response.statusCode}');
    }

    final total = _resolveTotalBytes(
      response: response,
      received: received,
      expected: expectedSizeBytes,
    );

    final sink = received == 0 || response.statusCode == 200
        ? file.openWrite(mode: FileMode.writeOnly)
        : file.openWrite(mode: FileMode.append);

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        yield DownloadProgressEvent(receivedBytes: received, totalBytes: total);
      }
    } finally {
      await sink.close();
    }

    if (await file.length() != expectedSizeBytes) {
      throw HttpException(
        'Download size mismatch: expected $expectedSizeBytes, got ${await file.length()}',
      );
    }

    await _writeMeta(assetName, expectedSizeBytes, file);
  }

  int _resolveTotalBytes({
    required http.StreamedResponse response,
    required int received,
    required int expected,
  }) {
    final contentRange = response.headers['content-range'];
    if (contentRange != null) {
      final match = RegExp(r'/(\d+)\s*$').firstMatch(contentRange);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }
    final contentLength = response.contentLength;
    if (contentLength != null && contentLength > 0) {
      return response.statusCode == 206
          ? received + contentLength
          : contentLength;
    }
    return expected;
  }

  Future<void> _writeMeta(String assetName, int size, File file) async {
    final digest = await _sha256OfFile(file);
    final meta = await metaFile(assetName);
    await meta.writeAsString(jsonEncode({'size': size, 'sha256': digest}));
  }

  Future<Map<String, dynamic>?> _readMeta(String assetName) async {
    final meta = await metaFile(assetName);
    if (!await meta.exists()) return null;
    try {
      return jsonDecode(await meta.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<String> _sha256OfFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  void close() => _client.close();
}

class DownloadProgressEvent {
  const DownloadProgressEvent({
    required this.receivedBytes,
    required this.totalBytes,
  });

  final int receivedBytes;
  final int totalBytes;
}
