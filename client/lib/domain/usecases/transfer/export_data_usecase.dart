import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';
import 'package:nasyad/domain/services/transfer/transfer_service.dart';

class ExportDataResult {
  const ExportDataResult({
    required this.bundle,
    required this.content,
    required this.format,
    required this.fileName,
  });

  final ExportBundle bundle;
  final String content;
  final ExportFormat format;
  final String fileName;
}

class ExportDataUsecase {
  ExportDataUsecase(this._transfer);

  final TransferService _transfer;

  Future<ExportDataResult> call({
    required ExportScopeKind scope,
    required ExportFormat format,
    List<String> deviceIds = const [],
  }) async {
    final bundle = await _transfer.export(scope: scope, deviceIds: deviceIds);
    final content = BundleCodec.encode(bundle, format);
    final stamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = 'nasyad-export-$stamp.${format.fileExtension}';

    return ExportDataResult(
      bundle: bundle,
      content: content,
      format: format,
      fileName: fileName,
    );
  }
}
