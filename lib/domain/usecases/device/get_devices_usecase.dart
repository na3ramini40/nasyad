import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class GetDevicesUsecase {
  final DeviceRepository deviceRepository;

  GetDevicesUsecase(this.deviceRepository);

  Future<List<Device>> call() {
    return deviceRepository.getDevices();
  }
}
