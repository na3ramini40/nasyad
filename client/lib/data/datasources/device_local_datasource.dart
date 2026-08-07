import 'package:nasyad/data/models/device_model.dart';

abstract class DeviceLocalDataSource {
  Future<List<DeviceModel>> getActiveDevices();

  Future<List<DeviceModel>> getActiveRootDevices();

  Future<List<DeviceModel>> getAllDevices();

  Future<List<DeviceModel>> getDevicesByIds(List<String> ids);

  Future<List<DeviceModel>> getChildren(String parentId);

  Stream<List<DeviceModel>> watchActiveDevices();

  Stream<List<DeviceModel>> watchAllDevices();

  Future<DeviceModel?> getDevice(String id);

  Future<void> insertDevice(DeviceModel device);

  Future<void> upsertDevice(DeviceModel device);

  Future<void> updateDevice(DeviceModel device);

  Future<void> setDeviceStatus(String id, String status, DateTime updatedAt);

  Future<void> setDeviceStatusForIds(
    List<String> ids,
    String status,
    DateTime updatedAt,
  );

  Future<List<DeviceModel>> searchActiveDevicesByName(String query);
}
