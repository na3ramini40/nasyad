import 'package:equatable/equatable.dart';

class OtpRequestResult extends Equatable {
  const OtpRequestResult({
    required this.phone,
    required this.cooldownSeconds,
    required this.expiresInSeconds,
  });

  final String phone;
  final int cooldownSeconds;
  final int expiresInSeconds;

  @override
  List<Object?> get props => [phone, cooldownSeconds, expiresInSeconds];
}
