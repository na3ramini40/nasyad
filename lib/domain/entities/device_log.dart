import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';

class DeviceLog extends Equatable {
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

  /// Base64-encoded photo for export/import transit only — not persisted in DB.
  final String? photoBase64;
  final DateTime createdAt;

  const DeviceLog({
    required this.id,
    required this.deviceId,
    required this.date,
    this.notes,
    this.kind = DeviceLogKind.maintenanceDone,
    this.usageValue,
    this.usageUnit,
    this.cost,
    this.costCurrency,
    this.vendor,
    this.photoPath,
    this.photoBase64,
    required this.createdAt,
  });

  DeviceLog copyWith({
    String? id,
    String? deviceId,
    DateTime? date,
    String? notes,
    DeviceLogKind? kind,
    int? usageValue,
    UsageIntervalUnit? usageUnit,
    double? cost,
    String? costCurrency,
    String? vendor,
    String? photoPath,
    String? photoBase64,
    DateTime? createdAt,
    bool clearNotes = false,
    bool clearCost = false,
    bool clearCostCurrency = false,
    bool clearVendor = false,
    bool clearPhotoPath = false,
    bool clearPhotoBase64 = false,
  }) {
    return DeviceLog(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      notes: clearNotes ? null : (notes ?? this.notes),
      kind: kind ?? this.kind,
      usageValue: usageValue ?? this.usageValue,
      usageUnit: usageUnit ?? this.usageUnit,
      cost: clearCost ? null : (cost ?? this.cost),
      costCurrency: clearCostCurrency
          ? null
          : (costCurrency ?? this.costCurrency),
      vendor: clearVendor ? null : (vendor ?? this.vendor),
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
      photoBase64: clearPhotoBase64 ? null : (photoBase64 ?? this.photoBase64),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    date,
    notes,
    kind,
    usageValue,
    usageUnit,
    cost,
    costCurrency,
    vendor,
    photoPath,
    photoBase64,
    createdAt,
  ];
}
