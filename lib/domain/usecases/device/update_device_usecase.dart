import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class UpdateDeviceUsecase {
  final DeviceRepository deviceRepository;

  UpdateDeviceUsecase(this.deviceRepository);

  Future<void> call(Device device) {
    return deviceRepository.updateDevice(device);
  }
}
