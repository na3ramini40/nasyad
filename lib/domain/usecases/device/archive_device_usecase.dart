import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class ArchiveDeviceUsecase {
  final DeviceRepository _repository;

  ArchiveDeviceUsecase(this._repository);

  Future<void> call(String id) {
    return _repository.setDeviceStatus(id, DeviceStatus.archived);
  }
}
