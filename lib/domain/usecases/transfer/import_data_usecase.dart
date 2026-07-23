import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';

class ImportDataResult {
  const ImportDataResult({required this.bundle, required this.format});

  final ExportBundle bundle;
  final ExportFormat format;
}

class ImportDataUsecase {
  ImportDataUsecase(this._devices);

  final DeviceRepository _devices;

  ExportBundle preview(
    String content, {
    ExportFormat? format,
    String? fileName,
  }) {
    final detected =
        format ??
        BundleCodec.formatFromExtension(fileName) ??
        BundleCodec.detectFormat(content);
    return BundleCodec.decode(content, format: detected);
  }

  Future<ImportDataResult> call(
    String content, {
    ExportFormat? format,
    String? fileName,
  }) async {
    final detected =
        format ??
        BundleCodec.formatFromExtension(fileName) ??
        BundleCodec.detectFormat(content);
    final bundle = BundleCodec.decode(content, format: detected);
    if (bundle.devices.isEmpty) {
      throw StateError('Import file contains no devices');
    }
    await _devices.importBundle(bundle);
    return ImportDataResult(bundle: bundle, format: detected);
  }
}
