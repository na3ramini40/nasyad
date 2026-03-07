import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';

class GetLogForDeviceUsecase {
  final DeviceLogRepository repository;

  GetLogForDeviceUsecase(this.repository);

  Future<List<DeviceLog>> call(String deviceId) {
    return repository.getLogsForDevice(deviceId);
  }
}
