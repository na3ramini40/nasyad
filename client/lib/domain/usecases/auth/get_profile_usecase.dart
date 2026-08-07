import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

class GetProfileUsecase {
  GetProfileUsecase(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call() => _repository.getProfile();
}
