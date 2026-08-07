import 'package:nasyad/domain/repositories/auth_repository.dart';

class SignOutUsecase {
  SignOutUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
