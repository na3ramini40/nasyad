import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';

class DeviceLogModel {
  final String id;
  final String deviceId;
  final DateTime date;
  final String? notes;
  final DeviceLogKind kind;
  final int? usageValue;
  final UsageIntervalUnit? usageUnit;
  final DateTime createdAt;

  const DeviceLogModel({
    required this.id,
    required this.deviceId,
    required this.date,
    this.notes,
    required this.kind,
    this.usageValue,
    this.usageUnit,
    required this.createdAt,
  });

  DeviceLog toEntity() {
    return DeviceLog(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: notes,
      kind: kind,
      usageValue: usageValue,
      usageUnit: usageUnit,
      createdAt: createdAt,
    );
  }

  factory DeviceLogModel.fromEntity(DeviceLog log) {
    return DeviceLogModel(
      id: log.id,
      deviceId: log.deviceId,
      date: log.date,
      notes: log.notes,
      kind: log.kind,
      usageValue: log.usageValue,
      usageUnit: log.usageUnit,
      createdAt: log.createdAt,
    );
  }

  factory DeviceLogModel.fromTableData(DeviceLogsTableData log) {
    return DeviceLogModel(
      id: log.id,
      deviceId: log.deviceId,
      date: log.date,
      notes: log.notes,
      kind: DeviceLogKindX.fromStorage(log.kind),
      usageValue: log.usageValue,
      usageUnit: log.usageUnit == null
          ? null
          : UsageIntervalUnitX.fromStorage(log.usageUnit!),
      createdAt: log.createdAt,
    );
  }

  DeviceLogsTableCompanion toCompanion() {
    return DeviceLogsTableCompanion.insert(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: Value(notes),
      kind: Value(kind.storageValue),
      usageValue: Value(usageValue),
      usageUnit: Value(usageUnit?.storageValue),
      createdAt: createdAt,
    );
  }
}
