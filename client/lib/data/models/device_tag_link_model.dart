import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/device_tag_link.dart';

class DeviceTagLinkModel {
  const DeviceTagLinkModel({
    required this.deviceId,
    required this.tagId,
    required this.createdAt,
  });

  final String deviceId;
  final String tagId;
  final DateTime createdAt;

  DeviceTagLink toEntity() {
    return DeviceTagLink(
      deviceId: deviceId,
      tagId: tagId,
      createdAt: createdAt,
    );
  }

  factory DeviceTagLinkModel.fromEntity(DeviceTagLink link) {
    return DeviceTagLinkModel(
      deviceId: link.deviceId,
      tagId: link.tagId,
      createdAt: link.createdAt,
    );
  }

  factory DeviceTagLinkModel.fromRow(DeviceTagsTableData row) {
    return DeviceTagLinkModel(
      deviceId: row.deviceId,
      tagId: row.tagId,
      createdAt: row.createdAt,
    );
  }

  DeviceTagsTableCompanion toInsertCompanion() {
    return DeviceTagsTableCompanion.insert(
      deviceId: deviceId,
      tagId: tagId,
      createdAt: createdAt,
    );
  }

  /// Snake_case wire shape matching server [DeviceTagLinkSerializer].
  Map<String, dynamic> toSyncJson() => {
    'device_id': deviceId,
    'tag_id': tagId,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  factory DeviceTagLinkModel.fromSyncJson(Map<String, dynamic> json) {
    return DeviceTagLinkModel(
      deviceId: json['device_id'] as String,
      tagId: json['tag_id'] as String,
      createdAt: _parseLinkIso(json['created_at']) ?? DateTime.now().toUtc(),
    );
  }
}

DateTime? _parseLinkIso(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}
