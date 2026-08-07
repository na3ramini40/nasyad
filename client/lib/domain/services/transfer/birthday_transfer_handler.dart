import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/services/transfer/transfer_data_handler.dart';

class BirthdayTransferHandler implements TransferDataHandler {
  BirthdayTransferHandler(this._birthdays);

  final BirthdayRepository _birthdays;

  @override
  String get key => TransferSectionKey.birthdays;

  @override
  Future<void> collectInto(
    ExportBundleDraft draft, {
    required ExportScopeKind scope,
    required List<String> deviceIds,
  }) async {
    // Global kind — always export all birthdays regardless of device scope.
    draft.birthdays = await _birthdays.getAllBirthdays();
  }

  @override
  bool hasDataIn(ExportBundle bundle) => bundle.birthdays.isNotEmpty;

  @override
  Future<void> applyFrom(ExportBundle bundle) async {
    for (final birthday in bundle.birthdays) {
      await _birthdays.upsertBirthday(birthday);
    }
  }
}
