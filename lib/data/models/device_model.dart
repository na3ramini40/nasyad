import 'package:nasyad/data/local/db/app_database.dart';

import '../../domain/entities/device.dart';

class DeviceModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const DeviceModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  Device toEntity() {
    return Device(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
    );
  }

  factory DeviceModel.fromEntity(Device device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      description: device.description,
      createdAt: device.createdAt,
    );
  }

  factory DeviceModel.fromTableData(DevicesTableData device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      description: device.description,
      createdAt: device.createdAt,
    );
  }

  DevicesTableData toTableData() {
    return DevicesTableData(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
    );
  }
}
