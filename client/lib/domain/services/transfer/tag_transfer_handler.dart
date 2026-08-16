import 'package:nasyad/domain/entities/device_tag_link.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/repositories/tag_repository.dart';
import 'package:nasyad/domain/services/transfer/transfer_data_handler.dart';

class TagTransferHandler implements TransferDataHandler {
  TagTransferHandler(this._tags);

  final TagRepository _tags;

  @override
  String get key => TransferSectionKey.tags;

  @override
  Future<void> collectInto(
    ExportBundleDraft draft, {
    required ExportScopeKind scope,
    required List<String> deviceIds,
  }) async {
    draft.tags = await _tags.getAllTags();
    draft.deviceTags = await _tags.getDeviceTagLinks();
  }

  @override
  bool hasDataIn(ExportBundle bundle) =>
      bundle.tags.isNotEmpty || bundle.deviceTags.isNotEmpty;

  @override
  Future<void> applyFrom(ExportBundle bundle) async {
    for (final tag in bundle.tags) {
      await _tags.upsertTag(tag);
    }
    for (final link in bundle.deviceTags) {
      await _tags.upsertDeviceTagLink(
        DeviceTagLink(deviceId: link.deviceId, tagId: link.tagId),
      );
    }
  }
}
