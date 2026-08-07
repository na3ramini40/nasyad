import 'dart:io';

import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

class UpdateProfileUsecase {
  UpdateProfileUsecase(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call({String? name, File? imageFile}) {
    return _repository.updateProfile(name: name, imageFile: imageFile);
  }
}
