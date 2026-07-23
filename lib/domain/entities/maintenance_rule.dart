import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class MaintenanceRule extends Equatable {
  final String id;
  final String deviceId;
  final String name;
  final ScheduleType scheduleType;
  final int? intervalValue;
  final String? intervalUnit;
  final DateTime? fixedDueAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaintenanceRule({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.scheduleType,
    this.intervalValue,
    this.intervalUnit,
    this.fixedDueAt,
    required this.createdAt,
    required this.updatedAt,
  });

  MaintenanceRule copyWith({
    String? id,
    String? deviceId,
    String? name,
    ScheduleType? scheduleType,
    int? intervalValue,
    String? intervalUnit,
    DateTime? fixedDueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceRule(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      scheduleType: scheduleType ?? this.scheduleType,
      intervalValue: intervalValue ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      fixedDueAt: fixedDueAt ?? this.fixedDueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    name,
    scheduleType,
    intervalValue,
    intervalUnit,
    fixedDueAt,
    createdAt,
    updatedAt,
  ];
}
