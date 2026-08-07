import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/sync/local_first_sync_coordinator.dart';

/// Local-first decorator: reads/writes Drift first, records remote sync after
/// successful local mutations.
class LocalFirstDeviceRepository implements DeviceRepository {
  LocalFirstDeviceRepository({
    required DeviceRepository local,
    required LocalFirstSyncCoordinator syncCoordinator,
  }) : _local = local,
       _syncCoordinator = syncCoordinator;

  final DeviceRepository _local;
  final LocalFirstSyncCoordinator _syncCoordinator;

  @override
  Future<List<Device>> getDevices() => _local.getDevices();

  @override
  Future<List<Device>> getAllDevices() => _local.getAllDevices();

  @override
  Future<List<Device>> getDevicesByIds(List<String> ids) =>
      _local.getDevicesByIds(ids);

  @override
  Future<List<Device>> getChildren(String parentId) =>
      _local.getChildren(parentId);

  @override
  Stream<List<DeviceSummary>> watchRootDeviceSummaries() =>
      _local.watchRootDeviceSummaries();

  @override
  Stream<List<Device>> watchArchivedRootDevices() =>
      _local.watchArchivedRootDevices();

  @override
  Stream<DeviceSummary?> watchDeviceSummary(String deviceId) =>
      _local.watchDeviceSummary(deviceId);

  @override
  Future<Device?> getDevice(String id) => _local.getDevice(id);

  @override
  Future<void> createDevice(Device device, {int initialElapsed = 0}) async {
    await _local.createDevice(device, initialElapsed: initialElapsed);
    final stored = await _local.getDevice(device.id);
    if (stored != null) {
      await _syncCoordinator.recordDeviceUpsert(stored);
    }
  }

  @override
  Future<void> updateDevice(Device device) async {
    await _local.updateDevice(device);
    await _syncCoordinator.recordDeviceUpsert(device);
  }

  @override
  Future<void> setDeviceStatus(String id, DeviceStatus status) async {
    final before = await _local.getAllDevices();
    await _local.setDeviceStatus(id, status);
    final after = await _local.getAllDevices();
    final beforeById = {for (final device in before) device.id: device};
    final changed = after.where((device) {
      final previous = beforeById[device.id];
      return previous == null ||
          previous.status != device.status ||
          previous.updatedAt != device.updatedAt;
    });
    await _syncCoordinator.recordDeviceUpserts(changed);
  }

  @override
  Future<void> importBundle(ExportBundle bundle) async {
    await _local.importBundle(bundle);
    for (final item in bundle.devices) {
      await _syncCoordinator.recordDeviceUpsert(item.device);
      for (final log in item.logs) {
        await _syncCoordinator.recordDeviceLogUpsert(log);
      }
    }
  }

  @override
  Future<List<Device>> searchActiveDevicesByName(String query) =>
      _local.searchActiveDevicesByName(query);
}
