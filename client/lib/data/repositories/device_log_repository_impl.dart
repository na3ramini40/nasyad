import 'dart:typed_data';

import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/services/log_photo_storage.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/services/maintenance_status_calculator.dart';

class DeviceLogRepositoryImpl extends DeviceLogRepository {
  final AppDatabase _db;
  final DeviceLogLocalDataSource _logs;
  final DeviceLocalDataSource _devices;
  final LogPhotoStorage _photos;
  final MaintenanceStatusCalculator _calculator;

  DeviceLogRepositoryImpl({
    required AppDatabase db,
    required DeviceLogLocalDataSource logs,
    required DeviceLocalDataSource devices,
    required LogPhotoStorage photos,
    MaintenanceStatusCalculator? calculator,
  }) : _db = db,
       _logs = logs,
       _devices = devices,
       _photos = photos,
       _calculator = calculator ?? MaintenanceStatusCalculator();

  @override
  Future<List<DeviceLog>> getLogsForDevice(String deviceId) async {
    final models = await _logs.getLogsForDevice(deviceId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<DeviceLog>> watchLogsForDevice(String deviceId) {
    return _logs
        .watchLogsForDevice(deviceId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> createLog(DeviceLog log, {Uint8List? photoBytes}) async {
    var persisted = log;
    if (photoBytes != null) {
      final path = await _photos.savePhoto(log.id, photoBytes);
      persisted = log.copyWith(photoPath: path);
    }

    await _db.transaction(() async {
      final deviceModel = await _devices.getDevice(persisted.deviceId);
      if (deviceModel == null) {
        throw StateError('Device not found: ${persisted.deviceId}');
      }
      final device = deviceModel.toEntity();
      final all = (await _devices.getAllDevices())
          .map((m) => m.toEntity())
          .toList();
      final byId = {for (final d in all) d.id: d};

      await _logs.insertDeviceLog(DeviceLogModel.fromEntity(persisted));

      switch (persisted.kind) {
        case DeviceLogKind.usageUpdate:
          await _applyUsageUpdate(device: device, log: persisted, byId: byId);
        case DeviceLogKind.maintenanceDone:
          await _applyMaintenanceDone(
            device: device,
            log: persisted,
            byId: byId,
          );
      }
    });
  }

  Future<void> _applyUsageUpdate({
    required Device device,
    required DeviceLog log,
    required Map<String, Device> byId,
  }) async {
    final owner =
        _calculator.resolveUsageOwner(device, byId) ??
        (device.isUsageOwner ? device : null);
    if (owner == null) {
      throw StateError('No usage owner found for device ${device.id}');
    }
    final value = _requireAbsoluteUsage(log.usageValue, owner.currentUsage);

    final updated = owner.copyWith(
      currentUsage: value,
      updatedAt: DateTime.now(),
    );
    await _devices.updateDevice(DeviceModel.fromEntity(updated));
  }

  Future<void> _applyMaintenanceDone({
    required Device device,
    required DeviceLog log,
    required Map<String, Device> byId,
  }) async {
    final now = DateTime.now();
    final owner = _calculator.resolveUsageOwner(device, byId);

    if (owner == null) {
      final updated = device.copyWith(
        lastMaintainedAt: now,
        usageAtLastMaintenance: device.currentUsage,
        updatedAt: now,
      );
      await _devices.updateDevice(DeviceModel.fromEntity(updated));
      return;
    }

    final value = _requireAbsoluteUsage(log.usageValue, owner.currentUsage);

    if (owner.id == device.id) {
      final updated = device.copyWith(
        currentUsage: value,
        lastMaintainedAt: now,
        usageAtLastMaintenance: value,
        updatedAt: now,
      );
      await _devices.updateDevice(DeviceModel.fromEntity(updated));
      return;
    }

    final updatedOwner = owner.copyWith(currentUsage: value, updatedAt: now);
    await _devices.updateDevice(DeviceModel.fromEntity(updatedOwner));

    final updatedDevice = device.copyWith(
      lastMaintainedAt: now,
      usageAtLastMaintenance: value,
      updatedAt: now,
    );
    await _devices.updateDevice(DeviceModel.fromEntity(updatedDevice));
  }

  int _requireAbsoluteUsage(int? value, int currentUsage) {
    if (value == null || value < 0) {
      throw ArgumentError('Usage value is required');
    }
    if (value < currentUsage) {
      throw ArgumentError('Usage value cannot be less than current usage');
    }
    return value;
  }

  @override
  Future<void> deleteLog(String id) async {
    final existing = await _logs.getLogById(id);
    await _logs.deleteDeviceLog(id);
    await _photos.deletePhoto(existing?.photoPath);
  }
}
