import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';

class DeviceLogModel {
  final String id;
  final String deviceId;
  final DateTime date;
  final String? notes;
  final int? usageDelta;
  final UsageIntervalUnit? usageUnit;
  final DateTime createdAt;

  const DeviceLogModel({
    required this.id,
    required this.deviceId,
    required this.date,
    this.notes,
    this.usageDelta,
    this.usageUnit,
    required this.createdAt,
  });

  DeviceLog toEntity() {
    return DeviceLog(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: notes,
      usageDelta: usageDelta,
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
      usageDelta: log.usageDelta,
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
      usageDelta: log.usageDelta,
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
      usageDelta: Value(usageDelta),
      usageUnit: Value(usageUnit?.storageValue),
      createdAt: createdAt,
    );
  }
}
