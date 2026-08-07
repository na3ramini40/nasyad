import 'package:nasyad/domain/repositories/auth_repository.dart';

class CompleteIntroUsecase {
  CompleteIntroUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.completeIntro();
}
