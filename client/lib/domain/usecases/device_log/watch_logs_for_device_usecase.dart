import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';

class WatchLogsForDeviceUsecase {
  final DeviceLogRepository _repository;

  WatchLogsForDeviceUsecase(this._repository);

  Stream<List<DeviceLog>> call(String deviceId) {
    return _repository.watchLogsForDevice(deviceId);
  }
}
