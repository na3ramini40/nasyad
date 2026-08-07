import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/sync/local_first_sync_coordinator.dart';

class LocalFirstDeviceLogRepository implements DeviceLogRepository {
  LocalFirstDeviceLogRepository({
    required DeviceLogRepository local,
    required DeviceRepository devices,
    required LocalFirstSyncCoordinator syncCoordinator,
  }) : _local = local,
       _devices = devices,
       _syncCoordinator = syncCoordinator;

  final DeviceLogRepository _local;
  final DeviceRepository _devices;
  final LocalFirstSyncCoordinator _syncCoordinator;

  @override
  Future<List<DeviceLog>> getLogsForDevice(String deviceId) =>
      _local.getLogsForDevice(deviceId);

  @override
  Stream<List<DeviceLog>> watchLogsForDevice(String deviceId) =>
      _local.watchLogsForDevice(deviceId);

  @override
  Future<void> createLog(DeviceLog log) async {
    await _local.createLog(log);
    await _syncCoordinator.recordDeviceLogUpsert(log);
    final device = await _devices.getDevice(log.deviceId);
    if (device != null) {
      await _syncCoordinator.recordDeviceUpsert(device);
    }
  }

  @override
  Future<void> deleteLog(String id) async {
    await _local.deleteLog(id);
    await _syncCoordinator.recordDeviceLogDelete(id);
  }
}
