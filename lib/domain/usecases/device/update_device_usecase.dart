import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class UpdateDeviceUsecase {
  final DeviceRepository _repository;

  UpdateDeviceUsecase(this._repository);

  Future<void> call(Device device, MaintenanceRule rule) {
    if (device.name.trim().isEmpty) {
      throw ArgumentError('Device name is required');
    }
    return _repository.updateDevice(device, rule);
  }
}
