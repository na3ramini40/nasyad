import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';

class CreateDeviceLogUsecase {
  final DeviceLogRepository _repository;

  CreateDeviceLogUsecase(this._repository);

  Future<void> call(DeviceLog log) => _repository.createLog(log);
}
