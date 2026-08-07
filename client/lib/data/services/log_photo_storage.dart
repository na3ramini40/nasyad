import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Stores maintenance log photos under the app documents directory.
abstract class LogPhotoStorage {
  Future<String> savePhoto(
    String logId,
    Uint8List bytes, {
    String extension = 'jpg',
  });

  Future<void> deletePhoto(String? relativePath);

  Future<Uint8List?> readBytes(String? relativePath);

  Future<File?> getFile(String? relativePath);
}

class LogPhotoStorageImpl implements LogPhotoStorage {
  static const photosSubdir = 'log_photos';

  @override
  Future<String> savePhoto(
    String logId,
    Uint8List bytes, {
    String extension = 'jpg',
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/$photosSubdir');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final relativePath = '$photosSubdir/$logId.$extension';
    final file = File('${appDir.path}/$relativePath');
    await file.writeAsBytes(bytes, flush: true);
    return relativePath;
  }

  @override
  Future<void> deletePhoto(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) return;
    final file = await _resolveFile(relativePath);
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<Uint8List?> readBytes(String? relativePath) async {
    final file = await getFile(relativePath);
    if (file == null) return null;
    return file.readAsBytes();
  }

  @override
  Future<File?> getFile(String? relativePath) async {
    return _resolveFile(relativePath);
  }

  Future<File?> _resolveFile(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) return null;
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$relativePath');
    if (!await file.exists()) return null;
    return file;
  }
}
