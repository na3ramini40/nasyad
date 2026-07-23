import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';

class DeviceLogRepositoryImpl extends DeviceLogRepository {
  final AppDatabase _db;
  final DeviceLogLocalDataSource _logs;
  final DeviceLocalDataSource _devices;

  DeviceLogRepositoryImpl({
    required AppDatabase db,
    required DeviceLogLocalDataSource logs,
    required DeviceLocalDataSource devices,
  })  : _db = db,
        _logs = logs,
        _devices = devices;

  @override
  Future<List<DeviceLog>> getLogsForDevice(String deviceId) async {
    final models = await _logs.getLogsForDevice(deviceId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<DeviceLog>> watchLogsForDevice(String deviceId) {
    return _logs.watchLogsForDevice(deviceId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<void> createLog(DeviceLog log) async {
    await _db.transaction(() async {
      final device = await _devices.getDevice(log.deviceId);
      if (device == null) {
        throw StateError('Device not found: ${log.deviceId}');
      }

      final nextUsage = device.currentUsage + (log.usageDelta ?? 0);
      final updated = DeviceModel(
        id: device.id,
        name: device.name,
        description: device.description,
        status: device.status,
        currentUsage: nextUsage,
        usageAtLastMaintenance: nextUsage,
        createdAt: device.createdAt,
        updatedAt: DateTime.now(),
      );

      await _logs.insertDeviceLog(DeviceLogModel.fromEntity(log));
      await _devices.updateDevice(updated);
    });
  }

  @override
  Future<void> deleteLog(String id) async {
    await _logs.deleteDeviceLog(id);
  }
}
