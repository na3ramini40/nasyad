import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

final DateTime t0 = DateTime.utc(2024, 1, 1);
final DateTime t1 = DateTime.utc(2024, 2, 1);
final DateTime tNow = DateTime.utc(2024, 6, 1);

Device sampleDevice({
  String id = 'device-1',
  String? parentId,
  String name = 'Pump',
  String? description = 'Main pump',
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
    createdAt: createdAt ?? t1,
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
}) {
  return ExportBundle(
    exportedAt: exportedAt ?? tNow,
    devices:
        devices ??
        [
          ExportDeviceBundle(
            device: sampleDevice(),
            logs: [sampleLog()],
          ),
        ],
  );
}
