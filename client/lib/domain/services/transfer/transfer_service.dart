import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/services/transfer/transfer_data_handler.dart';

/// Registry-based export/import orchestration over [TransferDataHandler]s.
class TransferService {
  TransferService(this._handlers);

  final List<TransferDataHandler> _handlers;

  Future<ExportBundle> export({
    required ExportScopeKind scope,
    List<String> deviceIds = const [],
  }) async {
    if (scope == ExportScopeKind.one && deviceIds.length != 1) {
      throw ArgumentError('One-device export requires exactly one device id');
    }
    if (scope == ExportScopeKind.selected && deviceIds.isEmpty) {
      throw ArgumentError('Selected export requires at least one device id');
    }

    final draft = ExportBundleDraft();
    for (final handler in _handlers) {
      await handler.collectInto(draft, scope: scope, deviceIds: deviceIds);
    }

    if (draft.isEmpty) {
      throw StateError('No data to export');
    }
    if (scope != ExportScopeKind.all && draft.devices.isEmpty) {
      throw StateError('No devices to export');
    }

    return draft.toBundle();
  }

  Future<void> import(ExportBundle bundle) async {
    if (bundle.isEmpty) {
      throw StateError('Import file contains no data');
    }
    for (final handler in _handlers) {
      if (handler.hasDataIn(bundle)) {
        await handler.applyFrom(bundle);
      }
    }
  }
}
