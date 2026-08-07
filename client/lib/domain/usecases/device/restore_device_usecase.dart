import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class RestoreDeviceUsecase {
  final DeviceRepository _repository;

  RestoreDeviceUsecase(this._repository);

  Future<void> call(String id) {
    return _repository.setDeviceStatus(id, DeviceStatus.active);
  }
}
