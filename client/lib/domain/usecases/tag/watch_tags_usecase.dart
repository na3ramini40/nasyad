import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/repositories/tag_repository.dart';

class WatchTagsUsecase {
  WatchTagsUsecase(this._repository);

  final TagRepository _repository;

  Stream<List<Tag>> call() => _repository.watchTags();
}
