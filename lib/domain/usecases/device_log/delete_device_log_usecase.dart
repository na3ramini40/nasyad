import 'package:nasyad/domain/repositories/device_log_repository.dart';

class DeleteDeviceLogUsecase {
  final DeviceLogRepository repository;

  DeleteDeviceLogUsecase(this.repository);

  Future<void> call(String id) {
    return repository.deleteLog(id);
  }
}
