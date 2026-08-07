import 'dart:convert';
import 'dart:typed_data';

import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/services/log_photo_storage.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/services/device_schedule_baseline.dart';
import 'package:nasyad/domain/services/maintenance_status_calculator.dart';

class DeviceRepositoryImpl extends DeviceRepository {
  final AppDatabase _db;
  final DeviceLocalDataSource _devices;
  final DeviceLogLocalDataSource _logs;
  final LogPhotoStorage _photos;
  final MaintenanceStatusCalculator _calculator;

  DeviceRepositoryImpl({
    required AppDatabase db,
    required DeviceLocalDataSource devices,
    required DeviceLogLocalDataSource logs,
    required LogPhotoStorage photos,
    MaintenanceStatusCalculator? calculator,
  }) : _db = db,
       _devices = devices,
       _logs = logs,
       _photos = photos,
       _calculator = calculator ?? MaintenanceStatusCalculator();

  @override
  Future<List<Device>> getDevices() async {
    final models = await _devices.getActiveDevices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Device>> getAllDevices() async {
    final models = await _devices.getAllDevices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Device>> getDevicesByIds(List<String> ids) async {
    final models = await _devices.getDevicesByIds(ids);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Device>> getChildren(String parentId) async {
    final models = await _devices.getChildren(parentId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<DeviceSummary>> watchRootDeviceSummaries() {
    return _devices.watchActiveDevices().asyncMap((deviceModels) async {
      final devices = deviceModels.map((m) => m.toEntity()).toList();
      final byId = {for (final d in devices) d.id: d};
      final roots = devices.where((d) => d.parentId == null).toList();
      final summaries = <DeviceSummary>[];

      for (final root in roots) {
        summaries.add(await _buildSummaryTree(root, devices, byId));
      }

      summaries.sort((a, b) {
        final byStatus = b.status.severity.compareTo(a.status.severity);
        if (byStatus != 0) return byStatus;
        return a.device.name.toLowerCase().compareTo(
          b.device.name.toLowerCase(),
        );
      });
      return summaries;
    });
  }

  @override
  Stream<DeviceSummary?> watchDeviceSummary(String deviceId) {
    return _devices.watchActiveDevices().asyncMap((deviceModels) async {
      final devices = deviceModels.map((m) => m.toEntity()).toList();
      final byId = {for (final d in devices) d.id: d};
      final device = byId[deviceId];
      if (device == null) return null;
      return _buildSummaryTree(device, devices, byId);
    });
  }

  Future<DeviceSummary> _buildSummaryTree(
    Device device,
    List<Device> all,
    Map<String, Device> byId,
  ) async {
    final children = all.where((d) => d.parentId == device.id).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final childSummaries = <DeviceSummary>[];
    for (final child in children) {
      childSummaries.add(await _buildSummaryTree(child, all, byId));
    }

    final own = _ownResult(device, byId);
    final aggregate = _calculator.aggregate([
      if (device.hasSchedule) own,
      ...childSummaries.map(
        (c) => RuleStatusResult(status: c.status, progress: c.progress),
      ),
    ]);

    final latestLog = (await _logs.getLatestLogForDevice(
      device.id,
    ))?.toEntity();

    return DeviceSummary(
      device: device,
      latestLog: latestLog,
      status: device.hasSchedule || childSummaries.isNotEmpty
          ? aggregate.status
          : MaintenanceStatus.upToDate,
      progress: device.hasSchedule || childSummaries.isNotEmpty
          ? aggregate.progress
          : 0,
      children: childSummaries,
    );
  }

  RuleStatusResult _ownResult(Device device, Map<String, Device> byId) {
    if (!device.hasSchedule) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }
    final usageOwner = _calculator.resolveUsageOwner(device, byId);
    return _calculator.evaluateDevice(device: device, usageOwner: usageOwner);
  }

  @override
  Future<Device?> getDevice(String id) async {
    final model = await _devices.getDevice(id);
    return model?.toEntity();
  }

  @override
  Future<void> createDevice(Device device, {int initialElapsed = 0}) async {
    await _db.transaction(() async {
      final all = (await _devices.getAllDevices())
          .map((m) => m.toEntity())
          .toList();
      final byId = {for (final d in all) d.id: d};
      if (device.parentId != null) {
        byId[device.parentId!] = byId[device.parentId!] ?? device;
      }
      byId[device.id] = device;
      final usageOwner = _calculator.resolveUsageOwner(device, byId);
      final prepared = DeviceScheduleBaseline.applyInitialElapsed(
        device: device.copyWith(
          lastMaintainedAt: device.lastMaintainedAt ?? device.createdAt,
        ),
        initialElapsed: initialElapsed,
        usageOwner: usageOwner,
      );
      await _devices.insertDevice(DeviceModel.fromEntity(prepared));
    });
  }

  @override
  Future<void> updateDevice(Device device) async {
    await _devices.updateDevice(DeviceModel.fromEntity(device));
  }

  @override
  Future<void> setDeviceStatus(String id, DeviceStatus status) async {
    final all = (await _devices.getAllDevices())
        .map((m) => m.toEntity())
        .toList();
    final descendants = _calculator.descendantsOf(id, all);
    final ids = [id, ...descendants.map((d) => d.id)];
    await _devices.setDeviceStatusForIds(
      ids,
      status.storageValue,
      DateTime.now(),
    );
  }

  @override
  Future<void> importBundle(ExportBundle bundle) async {
    await _db.transaction(() async {
      for (final item in bundle.devices) {
        await _devices.upsertDevice(DeviceModel.fromEntity(item.device));
        for (final log in item.logs) {
          final imported = await _persistImportedPhoto(log);
          await _logs.upsertDeviceLog(DeviceLogModel.fromEntity(imported));
        }
      }
    });
  }

  Future<DeviceLog> _persistImportedPhoto(DeviceLog log) async {
    final encoded = log.photoBase64;
    if (encoded == null || encoded.trim().isEmpty) {
      return log.copyWith(clearPhotoBase64: true);
    }
    Uint8List bytes;
    try {
      bytes = base64Decode(encoded.trim());
    } on FormatException {
      return log.copyWith(clearPhotoBase64: true);
    }
    final path = await _photos.savePhoto(log.id, bytes);
    return log.copyWith(photoPath: path, clearPhotoBase64: true);
  }
}
