import 'package:nasyad/domain/repositories/tag_repository.dart';

class SetDeviceTagsUsecase {
  SetDeviceTagsUsecase(this._repository);

  final TagRepository _repository;

  Future<void> call(String deviceId, List<String> tagIds) {
    return _repository.setDeviceTags(deviceId, tagIds);
  }
}
