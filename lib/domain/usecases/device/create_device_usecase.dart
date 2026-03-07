import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class CreateDeviceUsecase {
  final DeviceRepository deviceRepository;

  CreateDeviceUsecase(this.deviceRepository);

  Future<void> call(Device device) {
    return deviceRepository.createDevice(device);
  }
}
