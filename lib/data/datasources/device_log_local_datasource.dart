import 'package:nasyad/data/models/device_log_model.dart';

abstract class DeviceLogLocalDataSource {
  Future<List<DeviceLogModel>> getLogsForDevice(String deviceId);

  Stream<List<DeviceLogModel>> watchLogsForDevice(String deviceId);

  Future<DeviceLogModel?> getLatestLogForDevice(String deviceId);

  Future<void> insertDeviceLog(DeviceLogModel log);

  Future<void> upsertDeviceLog(DeviceLogModel log);

  Future<void> deleteDeviceLog(String id);
}
