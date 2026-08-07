import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

class VerifyOtpUsecase {
  VerifyOtpUsecase(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call({required String phone, required String code}) {
    return _repository.verifyOtp(phone: phone, code: code);
  }
}
