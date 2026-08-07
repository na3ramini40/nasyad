import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

class WatchAuthSessionUsecase {
  WatchAuthSessionUsecase(this._repository);

  final AuthRepository _repository;

  Stream<AuthSession> call() => _repository.watchSession();
}
