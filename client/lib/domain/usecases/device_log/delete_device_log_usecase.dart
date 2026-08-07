import 'package:nasyad/domain/repositories/device_log_repository.dart';

class DeleteDeviceLogUsecase {
  final DeviceLogRepository _repository;

  DeleteDeviceLogUsecase(this._repository);

  Future<void> call(String id) => _repository.deleteLog(id);
}
