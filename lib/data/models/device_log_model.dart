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
  final double? cost;
  final String? costCurrency;
  final String? vendor;
  final String? photoPath;
  final DateTime createdAt;

  const DeviceLogModel({
    required this.id,
    required this.deviceId,
    required this.date,
    this.notes,
    required this.kind,
    this.usageValue,
    this.usageUnit,
    this.cost,
    this.costCurrency,
    this.vendor,
    this.photoPath,
    required this.createdAt,
  });

  DeviceLog toEntity({String? photoBase64}) {
    return DeviceLog(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: notes,
      kind: kind,
      usageValue: usageValue,
      usageUnit: usageUnit,
      cost: cost,
      costCurrency: costCurrency,
      vendor: vendor,
      photoPath: photoPath,
      photoBase64: photoBase64,
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
      cost: log.cost,
      costCurrency: log.costCurrency,
      vendor: log.vendor,
      photoPath: log.photoPath,
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
      cost: log.cost,
      costCurrency: log.costCurrency,
      vendor: log.vendor,
      photoPath: log.photoPath,
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
      cost: Value(cost),
      costCurrency: Value(costCurrency),
      vendor: Value(vendor),
      photoPath: Value(photoPath),
      createdAt: createdAt,
    );
  }
}
