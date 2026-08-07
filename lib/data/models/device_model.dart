import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_category_preset.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class DeviceModel {
  final String id;
  final String? parentId;
  final String name;
  final String? description;
  final DeviceCategoryPreset? categoryPreset;
  final String? locationLabel;
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

  const DeviceModel({
    required this.id,
    this.parentId,
    required this.name,
    this.description,
    this.categoryPreset,
    this.locationLabel,
    required this.status,
    this.usageUnit,
    required this.currentUsage,
    this.scheduleType,
    this.intervalValue,
    this.intervalUnit,
    this.fixedDueAt,
    this.lastMaintainedAt,
    required this.usageAtLastMaintenance,
    required this.createdAt,
    required this.updatedAt,
  });

  Device toEntity() {
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
      lastMaintainedAt: lastMaintainedAt,
      usageAtLastMaintenance: usageAtLastMaintenance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory DeviceModel.fromEntity(Device device) {
    return DeviceModel(
      id: device.id,
      parentId: device.parentId,
      name: device.name,
      description: device.description,
      categoryPreset: device.categoryPreset,
      locationLabel: device.locationLabel,
      status: device.status,
      usageUnit: device.usageUnit,
      currentUsage: device.currentUsage,
      scheduleType: device.scheduleType,
      intervalValue: device.intervalValue,
      intervalUnit: device.intervalUnit,
      fixedDueAt: device.fixedDueAt,
      lastMaintainedAt: device.lastMaintainedAt,
      usageAtLastMaintenance: device.usageAtLastMaintenance,
      createdAt: device.createdAt,
      updatedAt: device.updatedAt,
    );
  }

  factory DeviceModel.fromTableData(DevicesTableData device) {
    return DeviceModel(
      id: device.id,
      parentId: device.parentId,
      name: device.name,
      description: device.description,
      categoryPreset: DeviceCategoryPresetX.fromStorage(device.categoryPreset),
      locationLabel: device.locationLabel,
      status: DeviceStatusX.fromStorage(device.status),
      usageUnit: device.usageUnit == null
          ? null
          : UsageIntervalUnitX.fromStorage(device.usageUnit!),
      currentUsage: device.currentUsage,
      scheduleType: device.scheduleType == null
          ? null
          : ScheduleTypeX.fromStorage(device.scheduleType!),
      intervalValue: device.intervalValue,
      intervalUnit: device.intervalUnit,
      fixedDueAt: device.fixedDueAt,
      lastMaintainedAt: device.lastMaintainedAt,
      usageAtLastMaintenance: device.usageAtLastMaintenance,
      createdAt: device.createdAt,
      updatedAt: device.updatedAt,
    );
  }

  DevicesTableData toTableData() {
    return DevicesTableData(
      id: id,
      parentId: parentId,
      name: name,
      description: description,
      categoryPreset: categoryPreset?.storageValue,
      locationLabel: locationLabel,
      status: status.storageValue,
      usageUnit: usageUnit?.storageValue,
      currentUsage: currentUsage,
      scheduleType: scheduleType?.storageValue,
      intervalValue: intervalValue,
      intervalUnit: intervalUnit,
      fixedDueAt: fixedDueAt,
      lastMaintainedAt: lastMaintainedAt,
      usageAtLastMaintenance: usageAtLastMaintenance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DevicesTableCompanion toCompanion() {
    return DevicesTableCompanion.insert(
      id: id,
      parentId: Value(parentId),
      name: name,
      description: Value(description),
      categoryPreset: Value(categoryPreset?.storageValue),
      locationLabel: Value(locationLabel),
      status: Value(status.storageValue),
      usageUnit: Value(usageUnit?.storageValue),
      currentUsage: Value(currentUsage),
      scheduleType: Value(scheduleType?.storageValue),
      intervalValue: Value(intervalValue),
      intervalUnit: Value(intervalUnit),
      fixedDueAt: Value(fixedDueAt),
      lastMaintainedAt: Value(lastMaintainedAt),
      usageAtLastMaintenance: Value(usageAtLastMaintenance),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
