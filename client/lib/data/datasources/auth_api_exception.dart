class AuthApiException implements Exception {
  const AuthApiException({
    required this.message,
    this.statusCode,
    this.retryAfterSeconds,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;
  final int? retryAfterSeconds;
  final Map<String, List<String>> fieldErrors;

  bool get isCooldown => statusCode == 429;

  @override
  String toString() => message;
}
