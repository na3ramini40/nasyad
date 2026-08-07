import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class UpdateDeviceUsecase {
  final DeviceRepository _repository;

  UpdateDeviceUsecase(this._repository);

  Future<void> call(Device device) {
    if (device.name.trim().isEmpty) {
      throw ArgumentError('Device name is required');
    }
    if (device.hasSchedule) {
      final amount = device.intervalValue;
      if (amount == null || amount <= 0) {
        throw ArgumentError('Interval must be greater than 0');
      }
      if (device.intervalUnit == null || device.intervalUnit!.isEmpty) {
        throw ArgumentError('Interval unit is required');
      }
    }
    return _repository.updateDevice(device);
  }
}
