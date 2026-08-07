/// Thrown when a sync HTTP call fails.
class SyncApiException implements Exception {
  const SyncApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
