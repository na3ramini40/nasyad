import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class WatchDeviceSummaryUsecase {
  final DeviceRepository _repository;

  WatchDeviceSummaryUsecase(this._repository);

  Stream<DeviceSummary?> call(String deviceId) =>
      _repository.watchDeviceSummary(deviceId);
}
