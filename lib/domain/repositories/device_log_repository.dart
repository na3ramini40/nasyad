import 'package:nasyad/domain/entities/device_log.dart';

abstract class DeviceLogRepository {
  Future<List<DeviceLog>> getLogsForDevice(String deviceId);

  Stream<List<DeviceLog>> watchLogsForDevice(String deviceId);

  Future<void> createLog(DeviceLog log);

  Future<void> deleteLog(String id);
}
