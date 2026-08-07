import 'package:nasyad/domain/entities/otp_request_result.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

class ResendOtpUsecase {
  ResendOtpUsecase(this._repository);

  final AuthRepository _repository;

  Future<OtpRequestResult> call(String phone) => _repository.resendOtp(phone);
}
