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
  final DateTime createdAt;

  const DeviceLog({
    required this.id,
    required this.deviceId,
    required this.date,
    this.notes,
    this.kind = DeviceLogKind.maintenanceDone,
    this.usageValue,
    this.usageUnit,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    deviceId,
    date,
    notes,
    kind,
    usageValue,
    usageUnit,
    createdAt,
  ];
}
