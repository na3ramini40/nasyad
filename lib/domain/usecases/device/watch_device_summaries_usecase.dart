import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class WatchDeviceSummariesUsecase {
  final DeviceRepository _repository;

  WatchDeviceSummariesUsecase(this._repository);

  Stream<List<DeviceSummary>> call() => _repository.watchDeviceSummaries();
}
