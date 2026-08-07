import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_category_preset.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

final DateTime t0 = DateTime.utc(2024, 1, 1);
final DateTime t1 = DateTime.utc(2024, 2, 1);
final DateTime tNow = DateTime.utc(2024, 6, 1);

Device sampleDevice({
  String id = 'device-1',
  String? parentId,
  String name = 'Pump',
  String? description = 'Main pump',
  DeviceCategoryPreset? categoryPreset = DeviceCategoryPreset.generic,
  String? locationLabel = 'Basement',
  DeviceStatus status = DeviceStatus.active,
  UsageIntervalUnit? usageUnit,
  int currentUsage = 100,
  ScheduleType? scheduleType = ScheduleType.calendarInterval,
  int? intervalValue = 3,
  String? intervalUnit = 'months',
  DateTime? fixedDueAt,
  DateTime? lastMaintainedAt,
  int usageAtLastMaintenance = 50,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Device(
    id: id,
    parentId: parentId,
    name: name,
    description: description,
    categoryPreset: categoryPreset,
    locationLabel: locationLabel,
    status: status,
    usageUnit: usageUnit,
    currentUsage: currentUsage,
    scheduleType: scheduleType,
    intervalValue: intervalValue,
    intervalUnit: intervalUnit,
    fixedDueAt: fixedDueAt,
    lastMaintainedAt: lastMaintainedAt ?? createdAt ?? t0,
    usageAtLastMaintenance: usageAtLastMaintenance,
    createdAt: createdAt ?? t0,
    updatedAt: updatedAt ?? t1,
  );
}

DeviceLog sampleLog({
  String id = 'log-1',
  String deviceId = 'device-1',
  DateTime? date,
  String? notes = 'Serviced',
  DeviceLogKind kind = DeviceLogKind.maintenanceDone,
  int? usageValue,
  UsageIntervalUnit? usageUnit = UsageIntervalUnit.hours,
  double? cost,
  String? costCurrency,
  String? vendor,
  String? photoPath,
  String? photoBase64,
  DateTime? createdAt,
}) {
  return DeviceLog(
    id: id,
    deviceId: deviceId,
    date: date ?? t1,
    notes: notes,
    kind: kind,
    usageValue: usageValue,
    usageUnit: usageUnit,
    cost: cost,
    costCurrency: costCurrency,
    vendor: vendor,
    photoPath: photoPath,
    photoBase64: photoBase64,
    createdAt: createdAt ?? t1,
  );
}

Birthday sampleBirthday({
  String id = 'birthday-1',
  String name = 'Ali',
  int birthMonth = 6,
  int birthDay = 15,
  CalendarSystem calendarSystem = CalendarSystem.gregorian,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Birthday(
    id: id,
    name: name,
    birthMonth: birthMonth,
    birthDay: birthDay,
    calendarSystem: calendarSystem,
    createdAt: createdAt ?? t0,
    updatedAt: updatedAt ?? t0,
  );
}

DeviceSummary sampleSummary({
  Device? device,
  DeviceLog? latestLog,
  MaintenanceStatus status = MaintenanceStatus.upToDate,
  double progress = 0.2,
  List<DeviceSummary> children = const [],
}) {
  return DeviceSummary(
    device: device ?? sampleDevice(),
    latestLog: latestLog,
    status: status,
    progress: progress,
    children: children,
  );
}

ExportBundle sampleBundle({
  DateTime? exportedAt,
  List<ExportDeviceBundle>? devices,
  List<Birthday>? birthdays,
  List<Place>? places,
}) {
  return ExportBundle(
    exportedAt: exportedAt ?? tNow,
    devices:
        devices ??
        [
          ExportDeviceBundle(device: sampleDevice(), logs: [sampleLog()]),
        ],
    birthdays: birthdays ?? const [],
    places: places ?? const [],
  );
}

Place samplePlace({
  String id = 'place-1',
  String name = 'Office',
  PlaceGeometryKind kind = PlaceGeometryKind.point,
  List<GeoPoint>? points,
  String? notes,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Place(
    id: id,
    name: name,
    kind: kind,
    points: points ?? const [GeoPoint(latitude: 35.7, longitude: 51.4)],
    notes: notes,
    createdAt: createdAt ?? t0,
    updatedAt: updatedAt ?? t0,
  );
}
