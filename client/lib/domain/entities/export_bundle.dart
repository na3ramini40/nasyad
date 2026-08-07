import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/place.dart';

class ExportDeviceBundle extends Equatable {
  final Device device;
  final List<DeviceLog> logs;

  const ExportDeviceBundle({required this.device, this.logs = const []});

  @override
  List<Object?> get props => [device, logs];
}

/// Versioned backup container. Typed section fields stay for BundleCodec /
/// back-compat; [TransferService] fills them via registered handlers.
class ExportBundle extends Equatable {
  static const formatName = 'nasyad';

  /// v1: devices + legacy rules; v2: schedule on device; v3: + birthdays/places.
  static const currentVersion = 3;

  final String format;
  final int version;
  final DateTime exportedAt;
  final List<ExportDeviceBundle> devices;
  final List<Birthday> birthdays;
  final List<Place> places;

  const ExportBundle({
    this.format = formatName,
    this.version = currentVersion,
    required this.exportedAt,
    this.devices = const [],
    this.birthdays = const [],
    this.places = const [],
  });

  int get deviceCount => devices.length;

  int get logCount => devices.fold(0, (sum, d) => sum + d.logs.length);

  int get birthdayCount => birthdays.length;

  int get placeCount => places.length;

  bool get isEmpty => devices.isEmpty && birthdays.isEmpty && places.isEmpty;

  ExportBundle copyWith({
    String? format,
    int? version,
    DateTime? exportedAt,
    List<ExportDeviceBundle>? devices,
    List<Birthday>? birthdays,
    List<Place>? places,
  }) {
    return ExportBundle(
      format: format ?? this.format,
      version: version ?? this.version,
      exportedAt: exportedAt ?? this.exportedAt,
      devices: devices ?? this.devices,
      birthdays: birthdays ?? this.birthdays,
      places: places ?? this.places,
    );
  }

  @override
  List<Object?> get props => [
    format,
    version,
    exportedAt,
    devices,
    birthdays,
    places,
  ];
}

enum ExportScopeKind { all, one, selected }
