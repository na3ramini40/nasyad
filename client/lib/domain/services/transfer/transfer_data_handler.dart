import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device_tag_link.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/tag.dart';

/// Section identity keys used in backup files and [TransferDataHandler]s.
abstract final class TransferSectionKey {
  static const devices = 'devices';
  static const birthdays = 'birthdays';
  static const places = 'places';
  static const tags = 'tags';
  static const deviceTags = 'device_tags';
}

/// Mutable collect target used while handlers populate an export.
class ExportBundleDraft {
  List<ExportDeviceBundle> devices = const [];
  List<Birthday> birthdays = const [];
  List<Place> places = const [];
  List<Tag> tags = const [];
  List<DeviceTagLink> deviceTags = const [];

  bool get isEmpty =>
      devices.isEmpty &&
      birthdays.isEmpty &&
      places.isEmpty &&
      tags.isEmpty &&
      deviceTags.isEmpty;

  ExportBundle toBundle({DateTime? exportedAt}) {
    return ExportBundle(
      exportedAt: exportedAt ?? DateTime.now().toUtc(),
      devices: List.unmodifiable(devices),
      birthdays: List.unmodifiable(birthdays),
      places: List.unmodifiable(places),
      tags: List.unmodifiable(tags),
      deviceTags: List.unmodifiable(deviceTags),
    );
  }
}

/// One local data kind that can participate in export/import.
abstract class TransferDataHandler {
  String get key;

  /// Collect this kind into [draft]. Device-scoped kinds honor [scope];
  /// global kinds ignore device ids and dump all.
  Future<void> collectInto(
    ExportBundleDraft draft, {
    required ExportScopeKind scope,
    required List<String> deviceIds,
  });

  /// Whether [bundle] has user data for this section.
  bool hasDataIn(ExportBundle bundle);

  /// Apply this section from a validated [bundle] (idempotent upserts).
  Future<void> applyFrom(ExportBundle bundle);
}
