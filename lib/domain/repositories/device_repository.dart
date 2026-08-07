import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';

abstract class DeviceRepository {
  Future<List<Device>> getDevices();

  Future<List<Device>> getAllDevices();

  Future<List<Device>> getDevicesByIds(List<String> ids);

  Future<List<Device>> getChildren(String parentId);

  Stream<List<DeviceSummary>> watchRootDeviceSummaries();

  Stream<List<Device>> watchArchivedRootDevices();

  Stream<DeviceSummary?> watchDeviceSummary(String deviceId);

  Future<Device?> getDevice(String id);

  Future<void> createDevice(Device device, {int initialElapsed = 0});

  Future<void> updateDevice(Device device);

  Future<void> setDeviceStatus(String id, DeviceStatus status);

  Future<void> importBundle(ExportBundle bundle);
}
