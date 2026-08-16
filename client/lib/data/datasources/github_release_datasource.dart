import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nasyad/core/config/github_config.dart';
import 'package:nasyad/core/platform/update_platform.dart';
import 'package:nasyad/core/version/app_version.dart';
import 'package:nasyad/core/version/semver.dart';
import 'package:nasyad/data/services/android_device_abis.dart';
import 'package:nasyad/domain/entities/app_release.dart';
import 'package:nasyad/domain/services/app_update_service.dart';

class GitHubReleaseDataSource {
  GitHubReleaseDataSource({
    http.Client? client,
    Future<List<String>> Function()? androidSupportedAbis,
  }) : _client = client ?? http.Client(),
       _androidSupportedAbis = androidSupportedAbis;

  final http.Client _client;
  final Future<List<String>> Function()? _androidSupportedAbis;

  Future<AppUpdateCheckResult> fetchLatestRelease({
    UpdatePlatform? platform,
    String currentVersionName = AppVersion.name,
    String? androidAbi,
    List<String>? androidAbis,
  }) async {
    final resolvedPlatform = platform ?? currentUpdatePlatform();
    if (resolvedPlatform == UpdatePlatform.unsupported) {
      return const AppUpdateCheckResult(
        status: AppUpdateCheckStatus.unsupportedPlatform,
      );
    }

    try {
      if (!GitHubConfig.isConfigured) {
        return const AppUpdateCheckResult(
          status: AppUpdateCheckStatus.unsupportedPlatform,
          errorMessage: 'Update channel not configured',
        );
      }

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

      final assets = json['assets'] as List<dynamic>? ?? [];
      final assetByName = <String, Map<String, dynamic>>{};
      for (final item in assets) {
        final map = item as Map<String, dynamic>;
        final name = map['name'] as String?;
        if (name != null) assetByName[name] = map;
      }

      final expectedAsset = await _resolveExpectedAssetName(
        platform: resolvedPlatform,
        versionName: versionName,
        availableNames: assetByName.keys,
        androidAbi: androidAbi,
        androidAbis: androidAbis,
      );

      final asset = assetByName[expectedAsset];
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

  Future<String> _resolveExpectedAssetName({
    required UpdatePlatform platform,
    required String versionName,
    required Iterable<String> availableNames,
    String? androidAbi,
    List<String>? androidAbis,
  }) async {
    if (platform != UpdatePlatform.android) {
      return releaseAssetName(platform, versionName);
    }

    final deviceAbis = await _resolveAndroidAbis(
      androidAbi: androidAbi,
      androidAbis: androidAbis,
    );
    final picked = pickAndroidReleaseAssetName(
      versionName: versionName,
      deviceAbis: deviceAbis,
      availableNames: availableNames,
    );
    if (picked != null) return picked;

    final candidates = androidAbiCandidates(deviceAbis);
    final preferredAbi = candidates.isNotEmpty
        ? candidates.first
        : (androidAbi ?? kShippedAndroidAbis.first);
    return releaseAssetName(
      UpdatePlatform.android,
      versionName,
      androidAbi: preferredAbi,
    );
  }

  Future<List<String>> _resolveAndroidAbis({
    String? androidAbi,
    List<String>? androidAbis,
  }) async {
    if (androidAbis != null && androidAbis.isNotEmpty) return androidAbis;
    if (androidAbi != null && androidAbi.isNotEmpty) return [androidAbi];
    final reader = _androidSupportedAbis ?? readAndroidSupportedAbis;
    return reader();
  }

  void close() => _client.close();
}

/// Select asset name for tests and datasource.
String selectReleaseAssetName(
  UpdatePlatform platform,
  String versionName, {
  String? androidAbi,
}) {
  return releaseAssetName(platform, versionName, androidAbi: androidAbi);
}

/// Whether [remote] is newer than [current] by semver name.
bool isRemoteVersionNewer(String remote, String current) {
  return SemVer.parse(remote).compareName(SemVer.parse(current)) > 0;
}
