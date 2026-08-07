import 'package:nasyad/domain/repositories/auth_repository.dart';

class HasCompletedIntroUsecase {
  HasCompletedIntroUsecase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.hasCompletedIntro();
}
