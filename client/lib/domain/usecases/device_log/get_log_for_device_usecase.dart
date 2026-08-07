import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';

class GetLogsForDeviceUsecase {
  final DeviceLogRepository _repository;

  GetLogsForDeviceUsecase(this._repository);

  Future<List<DeviceLog>> call(String deviceId) {
    return _repository.getLogsForDevice(deviceId);
  }
}
