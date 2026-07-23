import 'package:nasyad/domain/entities/maintenance_rule.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class GetRulesForDeviceUsecase {
  final DeviceRepository _repository;

  GetRulesForDeviceUsecase(this._repository);

  Future<List<MaintenanceRule>> call(String deviceId) {
    return _repository.getRulesForDevice(deviceId);
  }
}
