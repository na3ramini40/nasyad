import 'package:nasyad/core/utils/transfer_file_actions.dart';
import 'package:nasyad/domain/entities/export_format.dart';

class FakeTransferFileActions extends TransferFileActions {
  FakeTransferFileActions();

  TransferShareOutcome shareOutcome = TransferShareOutcome.shared;
  String? savePath = '/tmp/export.json';
  ({String content, String name})? pickedFile;
  Object? shareError;
  Object? saveError;
  Object? pickError;

  String? lastSharedContent;
  String? lastSavedContent;
  String? lastFileName;

  @override
  Future<TransferShareOutcome> share({
    required String content,
    required String fileName,
    required ExportFormat format,
  }) async {
    if (shareError != null) throw shareError!;
    lastSharedContent = content;
    lastFileName = fileName;
    return shareOutcome;
  }

  @override
  Future<String?> save({
    required String content,
    required String fileName,
    required ExportFormat format,
  }) async {
    if (saveError != null) throw saveError!;
    lastSavedContent = content;
    lastFileName = fileName;
    return savePath;
  }

  @override
  Future<({String content, String name})?> pickImportFile() async {
    if (pickError != null) throw pickError!;
    return pickedFile;
  }
}
