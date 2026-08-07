import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';
import 'package:nasyad/domain/services/transfer/transfer_service.dart';

class ImportDataResult {
  const ImportDataResult({required this.bundle, required this.format});

  final ExportBundle bundle;
  final ExportFormat format;
}

class ImportDataUsecase {
  ImportDataUsecase(this._transfer);

  final TransferService _transfer;

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
    await _transfer.import(bundle);
    return ImportDataResult(bundle: bundle, format: detected);
  }
}
