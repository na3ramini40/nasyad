import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/device_log.dart';

class DeviceLogModel {
  final String id;
  final String deviceId;
  final DateTime date;
  final int? usage;
  final String? notes;

  const DeviceLogModel({
    required this.id,
    required this.deviceId,
    required this.date,
    this.usage,
    this.notes,
  });

  DeviceLog toEntity() {
    return DeviceLog(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: notes,
      usage: usage,
    );
  }

  factory DeviceLogModel.fromEntity(DeviceLog log) {
    return DeviceLogModel(
      id: log.id,
      deviceId: log.deviceId,
      date: log.date,
      notes: log.notes,
      usage: log.usage,
    );
  }

  factory DeviceLogModel.fromTableData(DeviceLogsTableData log) {
    return DeviceLogModel(
      id: log.id,
      deviceId: log.deviceId,
      date: log.date,
      notes: log.notes,
      usage: log.usage,
    );
  }

  DeviceLogsTableData toTableData() {
    return DeviceLogsTableData(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: notes,
      usage: usage,
    );
  }
}
