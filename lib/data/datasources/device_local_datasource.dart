import 'package:nasyad/data/models/device_model.dart';

abstract class DeviceLocalDataSource {
  Future<List<DeviceModel>> getActiveDevices();

  Future<List<DeviceModel>> getAllDevices();

  Future<List<DeviceModel>> getDevicesByIds(List<String> ids);

  Stream<List<DeviceModel>> watchActiveDevices();

  Future<DeviceModel?> getDevice(String id);

  Future<void> insertDevice(DeviceModel device);

  Future<void> upsertDevice(DeviceModel device);

  Future<void> updateDevice(DeviceModel device);

  Future<void> setDeviceStatus(String id, String status, DateTime updatedAt);
}
