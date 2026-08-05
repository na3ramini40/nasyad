import 'package:nasyad/domain/entities/app_release.dart';

enum AppUpdateCheckStatus {
  upToDate,
  updateAvailable,
  unsupportedPlatform,
  failed,
}

class AppUpdateCheckResult {
  const AppUpdateCheckResult({
    required this.status,
    this.release,
    this.errorMessage,
  });

  final AppUpdateCheckStatus status;
  final AppRelease? release;
  final String? errorMessage;
}

class DownloadProgress {
  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
  });

  final int receivedBytes;
  final int totalBytes;

  double get fraction =>
      totalBytes <= 0 ? 0 : (receivedBytes / totalBytes).clamp(0.0, 1.0);
}

abstract class AppUpdateService {
  Future<AppUpdateCheckResult> checkForUpdate();

  Stream<DownloadProgress> downloadUpdate(AppRelease release);

  /// Returns the local path of the downloaded asset when complete.
  Future<String> installUpdate(AppRelease release, String localPath);

  Future<String> localPathFor(AppRelease release);
}
