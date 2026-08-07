import 'dart:io';
import 'dart:typed_data';

import 'package:nasyad/data/services/log_photo_storage.dart';

class FakeLogPhotoStorage implements LogPhotoStorage {
  final Map<String, Uint8List> files = {};

  @override
  Future<void> deletePhoto(String? relativePath) async {
    if (relativePath == null) return;
    files.remove(relativePath);
  }

  @override
  Future<File?> getFile(String? relativePath) async => null;

  @override
  Future<Uint8List?> readBytes(String? relativePath) async {
    if (relativePath == null) return null;
    return files[relativePath];
  }

  @override
  Future<String> savePhoto(
    String logId,
    Uint8List bytes, {
    String extension = 'jpg',
  }) async {
    final path = '${LogPhotoStorageImpl.photosSubdir}/$logId.$extension';
    files[path] = bytes;
    return path;
  }
}
