import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';

class DeviceLog extends Equatable {
  final String id;
  final String deviceId;
  final DateTime date;
  final String? notes;
  final int? usageDelta;
  final UsageIntervalUnit? usageUnit;
  final DateTime createdAt;

  const DeviceLog({
    required this.id,
    required this.deviceId,
    required this.date,
    this.notes,
    this.usageDelta,
    this.usageUnit,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    deviceId,
    date,
    notes,
    usageDelta,
    usageUnit,
    createdAt,
  ];
}
