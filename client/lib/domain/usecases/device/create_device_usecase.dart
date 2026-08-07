import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class CreateDeviceUsecase {
  final DeviceRepository _repository;

  CreateDeviceUsecase(this._repository);

  Future<void> call(Device device, {int initialElapsed = 0}) {
    if (device.name.trim().isEmpty) {
      throw ArgumentError('Device name is required');
    }
    if (initialElapsed < 0) {
      throw ArgumentError('Initial elapsed cannot be negative');
    }
    if (device.hasSchedule) {
      final amount = device.intervalValue;
      if (amount == null || amount <= 0) {
        throw ArgumentError('Interval must be greater than 0');
      }
      if (device.intervalUnit == null || device.intervalUnit!.isEmpty) {
        throw ArgumentError('Interval unit is required');
      }
      if (initialElapsed > amount) {
        throw ArgumentError('Initial elapsed cannot exceed the interval');
      }
    }
    return _repository.createDevice(device, initialElapsed: initialElapsed);
  }
}
