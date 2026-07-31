import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class Device extends Equatable {
  final String id;
  final String? parentId;
  final String name;
  final String? description;
  final DeviceStatus status;
  final UsageIntervalUnit? usageUnit;
  final int currentUsage;
  final ScheduleType? scheduleType;
  final int? intervalValue;
  final String? intervalUnit;
  final DateTime? fixedDueAt;
  final DateTime? lastMaintainedAt;
  final int usageAtLastMaintenance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Device({
    required this.id,
    this.parentId,
    required this.name,
    this.description,
    this.status = DeviceStatus.active,
    this.usageUnit,
    this.currentUsage = 0,
    this.scheduleType,
    this.intervalValue,
    this.intervalUnit,
    this.fixedDueAt,
    this.lastMaintainedAt,
    this.usageAtLastMaintenance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasSchedule => scheduleType != null;

  bool get isUsageOwner => usageUnit != null;

  Device copyWith({
    String? id,
    String? parentId,
    bool clearParentId = false,
    String? name,
    String? description,
    DeviceStatus? status,
    UsageIntervalUnit? usageUnit,
    bool clearUsageUnit = false,
    int? currentUsage,
    ScheduleType? scheduleType,
    bool clearSchedule = false,
    int? intervalValue,
    String? intervalUnit,
    DateTime? fixedDueAt,
    DateTime? lastMaintainedAt,
    bool clearLastMaintainedAt = false,
    int? usageAtLastMaintenance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      id: id ?? this.id,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      usageUnit: clearUsageUnit ? null : (usageUnit ?? this.usageUnit),
      currentUsage: currentUsage ?? this.currentUsage,
      scheduleType: clearSchedule ? null : (scheduleType ?? this.scheduleType),
      intervalValue: clearSchedule ? null : (intervalValue ?? this.intervalValue),
      intervalUnit: clearSchedule ? null : (intervalUnit ?? this.intervalUnit),
      fixedDueAt: clearSchedule ? null : (fixedDueAt ?? this.fixedDueAt),
      lastMaintainedAt: clearLastMaintainedAt
          ? null
          : (lastMaintainedAt ?? this.lastMaintainedAt),
      usageAtLastMaintenance:
          usageAtLastMaintenance ?? this.usageAtLastMaintenance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    parentId,
    name,
    description,
    status,
    usageUnit,
    currentUsage,
    scheduleType,
    intervalValue,
    intervalUnit,
    fixedDueAt,
    lastMaintainedAt,
    usageAtLastMaintenance,
    createdAt,
    updatedAt,
  ];
}
