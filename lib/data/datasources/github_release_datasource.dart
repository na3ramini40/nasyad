import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nasyad/core/config/github_config.dart';
import 'package:nasyad/core/platform/update_platform.dart';
import 'package:nasyad/core/version/app_version.dart';
import 'package:nasyad/core/version/semver.dart';
import 'package:nasyad/domain/entities/app_release.dart';
import 'package:nasyad/domain/services/app_update_service.dart';

class GitHubReleaseDataSource {
  GitHubReleaseDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<AppUpdateCheckResult> fetchLatestRelease({
    UpdatePlatform? platform,
    String currentVersionName = AppVersion.name,
  }) async {
    final resolvedPlatform = platform ?? currentUpdatePlatform();
    if (resolvedPlatform == UpdatePlatform.unsupported) {
      return const AppUpdateCheckResult(
        status: AppUpdateCheckStatus.unsupportedPlatform,
      );
    }

    try {
      final response = await _client.get(
        GitHubConfig.latestReleaseUri(),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'nasyad-app-update',
        },
      );

      if (response.statusCode != 200) {
        return AppUpdateCheckResult(
          status: AppUpdateCheckStatus.failed,
          errorMessage: 'GitHub API ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = json['tag_name'] as String? ?? '';
      final versionName = parseReleaseTagName(tagName);
      if (versionName == null) {
        return const AppUpdateCheckResult(
          status: AppUpdateCheckStatus.failed,
          errorMessage: 'Invalid release tag',
        );
      }

      final remoteVersion = SemVer.parse(versionName);
      final currentVersion = SemVer.parse(currentVersionName);
      if (remoteVersion.compareName(currentVersion) <= 0) {
        return const AppUpdateCheckResult(
          status: AppUpdateCheckStatus.upToDate,
        );
      }

      final expectedAsset = releaseAssetName(resolvedPlatform, versionName);
      final assets = json['assets'] as List<dynamic>? ?? [];
      Map<String, dynamic>? asset;
      for (final item in assets) {
        final map = item as Map<String, dynamic>;
        if (map['name'] == expectedAsset) {
          asset = map;
          break;
        }
      }

      if (asset == null) {
        return AppUpdateCheckResult(
          status: AppUpdateCheckStatus.failed,
          errorMessage: 'No asset: $expectedAsset',
        );
      }

      final downloadUrl = asset['browser_download_url'] as String?;
      final size = asset['size'] as int? ?? 0;
      if (downloadUrl == null || downloadUrl.isEmpty || size <= 0) {
        return const AppUpdateCheckResult(
          status: AppUpdateCheckStatus.failed,
          errorMessage: 'Invalid release asset',
        );
      }

      return AppUpdateCheckResult(
        status: AppUpdateCheckStatus.updateAvailable,
        release: AppRelease(
          version: remoteVersion,
          tagName: tagName,
          assetName: expectedAsset,
          downloadUrl: downloadUrl,
          sizeBytes: size,
          releaseNotes: json['body'] as String?,
        ),
      );
    } catch (error) {
      return AppUpdateCheckResult(
        status: AppUpdateCheckStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  void close() => _client.close();
}

/// Select asset name for tests and datasource.
String selectReleaseAssetName(UpdatePlatform platform, String versionName) {
  return releaseAssetName(platform, versionName);
}

/// Whether [remote] is newer than [current] by semver name.
bool isRemoteVersionNewer(String remote, String current) {
  return SemVer.parse(remote).compareName(SemVer.parse(current)) > 0;
}
