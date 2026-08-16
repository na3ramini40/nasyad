import 'package:nasyad/domain/repositories/tag_repository.dart';

class DeleteTagUsecase {
  DeleteTagUsecase(this._repository);

  final TagRepository _repository;

  Future<void> call(String id) => _repository.deleteTag(id);
}
