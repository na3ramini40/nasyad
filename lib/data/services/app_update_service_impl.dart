import 'package:nasyad/data/datasources/github_release_datasource.dart';
import 'package:nasyad/data/services/app_update_download_cache.dart';
import 'package:nasyad/data/services/app_update_installer_stub.dart'
    if (dart.library.io) 'package:nasyad/data/services/app_update_installer.dart';
import 'package:nasyad/domain/entities/app_release.dart';
import 'package:nasyad/domain/services/app_update_service.dart';

class AppUpdateServiceImpl implements AppUpdateService {
  AppUpdateServiceImpl({
    GitHubReleaseDataSource? releaseDataSource,
    AppUpdateDownloadCache? downloadCache,
    AppUpdateInstaller? installer,
  }) : _releaseDataSource = releaseDataSource ?? GitHubReleaseDataSource(),
       _downloadCache = downloadCache ?? AppUpdateDownloadCache(),
       _installer = installer ?? createAppUpdateInstaller();

  final GitHubReleaseDataSource _releaseDataSource;
  final AppUpdateDownloadCache _downloadCache;
  final AppUpdateInstaller _installer;

  @override
  Future<AppUpdateCheckResult> checkForUpdate() {
    return _releaseDataSource.fetchLatestRelease();
  }

  @override
  Stream<DownloadProgress> downloadUpdate(AppRelease release) async* {
    await for (final event in _downloadCache.downloadResumable(
      url: Uri.parse(release.downloadUrl),
      assetName: release.assetName,
      expectedSizeBytes: release.sizeBytes,
    )) {
      yield DownloadProgress(
        receivedBytes: event.receivedBytes,
        totalBytes: event.totalBytes,
      );
    }
  }

  @override
  Future<String> installUpdate(AppRelease release, String localPath) async {
    await _installer.install(release, localPath);
    return localPath;
  }

  @override
  Future<String> localPathFor(AppRelease release) async {
    final file = await _downloadCache.assetFile(release.assetName);
    return file.path;
  }

  Future<String> localPathForRelease(AppRelease release) =>
      localPathFor(release);
}
