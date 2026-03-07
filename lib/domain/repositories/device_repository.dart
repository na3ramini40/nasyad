import 'package:nasyad/domain/entities/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getDevices();

  Future<Device?> getDevice(String id);

  Future<void> createDevice(Device device);

  Future<void> updateDevice(Device device);

  Future<void> deleteDevice(String id);
}
