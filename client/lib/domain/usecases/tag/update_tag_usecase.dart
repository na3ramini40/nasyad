import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/repositories/tag_repository.dart';

class UpdateTagUsecase {
  UpdateTagUsecase(this._repository);

  final TagRepository _repository;

  Future<void> call(Tag tag) => _repository.updateTag(tag);
}
