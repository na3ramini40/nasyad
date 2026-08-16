import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/repositories/tag_repository.dart';

class WatchTagsForDeviceUsecase {
  WatchTagsForDeviceUsecase(this._repository);

  final TagRepository _repository;

  Stream<List<Tag>> call(String deviceId) {
    return _repository.watchTagsForDevice(deviceId);
  }
}
