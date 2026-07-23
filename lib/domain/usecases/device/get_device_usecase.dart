import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class GetDeviceUsecase {
  final DeviceRepository _repository;

  GetDeviceUsecase(this._repository);

  Future<Device?> call(String id) => _repository.getDevice(id);
}
