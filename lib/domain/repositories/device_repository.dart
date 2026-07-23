import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';

abstract class DeviceRepository {
  Future<List<Device>> getDevices();

  Future<List<Device>> getAllDevices();

  Future<List<Device>> getDevicesByIds(List<String> ids);

  Stream<List<DeviceSummary>> watchDeviceSummaries();

  Future<Device?> getDevice(String id);

  Future<List<MaintenanceRule>> getRulesForDevice(String deviceId);

  Stream<List<MaintenanceRule>> watchRulesForDevice(String deviceId);

  Future<void> createDevice(Device device, MaintenanceRule rule);

  Future<void> updateDevice(Device device, MaintenanceRule rule);

  Future<void> setDeviceStatus(String id, DeviceStatus status);

  Future<void> importBundle(ExportBundle bundle);
}
