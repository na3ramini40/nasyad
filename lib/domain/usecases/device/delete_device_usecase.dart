import 'package:nasyad/domain/repositories/device_repository.dart';

class DeleteDeviceUsecase{
  final DeviceRepository deviceRepository;
  DeleteDeviceUsecase(this.deviceRepository);

  Future<void> call(String id){
    return deviceRepository.deleteDevice(id);
  }
}