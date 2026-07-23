import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_status.dart';

class DeviceModel {
  final String id;
  final String name;
  final String? description;
  final DeviceStatus status;
  final int currentUsage;
  final int usageAtLastMaintenance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeviceModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.currentUsage,
    required this.usageAtLastMaintenance,
    required this.createdAt,
    required this.updatedAt,
  });

  Device toEntity() {
    return Device(
      id: id,
      name: name,
      description: description,
      status: status,
      currentUsage: currentUsage,
      usageAtLastMaintenance: usageAtLastMaintenance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory DeviceModel.fromEntity(Device device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      description: device.description,
      status: device.status,
      currentUsage: device.currentUsage,
      usageAtLastMaintenance: device.usageAtLastMaintenance,
      createdAt: device.createdAt,
      updatedAt: device.updatedAt,
    );
  }

  factory DeviceModel.fromTableData(DevicesTableData device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      description: device.description,
      status: DeviceStatusX.fromStorage(device.status),
      currentUsage: device.currentUsage,
      usageAtLastMaintenance: device.usageAtLastMaintenance,
      createdAt: device.createdAt,
      updatedAt: device.updatedAt,
    );
  }

  DevicesTableData toTableData() {
    return DevicesTableData(
      id: id,
      name: name,
      description: description,
      status: status.storageValue,
      currentUsage: currentUsage,
      usageAtLastMaintenance: usageAtLastMaintenance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DevicesTableCompanion toCompanion() {
    return DevicesTableCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      status: Value(status.storageValue),
      currentUsage: Value(currentUsage),
      usageAtLastMaintenance: Value(usageAtLastMaintenance),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
