import 'package:nasyad/domain/entities/device_tag_link.dart';
import 'package:nasyad/domain/repositories/tag_repository.dart';

class WatchDeviceTagLinksUsecase {
  WatchDeviceTagLinksUsecase(this._repository);

  final TagRepository _repository;

  Stream<List<DeviceTagLink>> call() => _repository.watchDeviceTagLinks();
}
