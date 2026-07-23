import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class GetAllDevicesUsecase {
  GetAllDevicesUsecase(this._repository);

  final DeviceRepository _repository;

  Future<List<Device>> call() => _repository.getAllDevices();
}
