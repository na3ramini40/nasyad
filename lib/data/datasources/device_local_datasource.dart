import 'package:nasyad/data/models/device_model.dart';

abstract class DeviceLocalDataSource {
  Future<List<DeviceModel>> getDevices();

  Future<DeviceModel?> getDevice(String id);

  Future<void> insertDevice(DeviceModel device);

  Future<void> updateDevice(DeviceModel device);

  Future<void> deleteDevice(String id);
}
