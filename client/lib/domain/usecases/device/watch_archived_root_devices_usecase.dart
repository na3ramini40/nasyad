import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class WatchArchivedRootDevicesUsecase {
  final DeviceRepository _repository;

  WatchArchivedRootDevicesUsecase(this._repository);

  Stream<List<Device>> call() => _repository.watchArchivedRootDevices();
}
