import 'package:nasyad/domain/entities/app_release.dart';

/// Installs a downloaded update for the current platform.
abstract class AppUpdateInstaller {
  Future<void> install(AppRelease release, String localPath);
}

class UnsupportedAppUpdateInstaller implements AppUpdateInstaller {
  @override
  Future<void> install(AppRelease release, String localPath) {
    throw UnsupportedError('In-app updates are not available on this platform');
  }
}

AppUpdateInstaller createAppUpdateInstaller() =>
    UnsupportedAppUpdateInstaller();
