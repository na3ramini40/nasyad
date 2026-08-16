import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nasyad/core/platform/update_platform.dart';
import 'package:nasyad/data/datasources/github_release_datasource.dart';
import 'package:nasyad/domain/services/app_update_service.dart';

void main() {
  group('releaseAssetName', () {
    test('maps CI asset names per platform', () {
      expect(
        releaseAssetName(
          UpdatePlatform.android,
          '1.3.0',
          androidAbi: 'arm64-v8a',
        ),
        'nasyad-v1.3.0-arm64-v8a.apk',
      );
      expect(
        releaseAssetName(
          UpdatePlatform.android,
          '1.3.0',
          androidAbi: 'armeabi-v7a',
        ),
        'nasyad-v1.3.0-armeabi-v7a.apk',
      );
      expect(
        releaseAssetName(UpdatePlatform.linux, '1.3.0'),
        'nasyad-v1.3.0-linux-x64.tar.gz',
      );
      expect(
        releaseAssetName(UpdatePlatform.windows, '1.3.0'),
        'nasyad-v1.3.0-windows-x64.zip',
      );
    });

    test('requires androidAbi for Android', () {
      expect(
        () => releaseAssetName(UpdatePlatform.android, '1.3.0'),
        throwsArgumentError,
      );
    });
  });

  group('androidAbiCandidates', () {
    test('orders by shipped preference among device ABIs', () {
      expect(androidAbiCandidates(['armeabi-v7a', 'arm64-v8a', 'x86']), [
        'arm64-v8a',
        'armeabi-v7a',
      ]);
      expect(androidAbiCandidates(['x86_64']), ['x86_64']);
      expect(androidAbiCandidates(['x86']), isEmpty);
    });
  });

  group('pickAndroidReleaseAssetName', () {
    test('prefers primary shipped ABI when present', () {
      expect(
        pickAndroidReleaseAssetName(
          versionName: '1.3.0',
          deviceAbis: ['arm64-v8a', 'armeabi-v7a'],
          availableNames: const [
            'nasyad-v1.3.0-armeabi-v7a.apk',
            'nasyad-v1.3.0-arm64-v8a.apk',
          ],
        ),
        'nasyad-v1.3.0-arm64-v8a.apk',
      );
    });

    test('falls back when preferred ABI asset is missing', () {
      expect(
        pickAndroidReleaseAssetName(
          versionName: '1.3.0',
          deviceAbis: ['arm64-v8a', 'armeabi-v7a'],
          availableNames: const ['nasyad-v1.3.0-armeabi-v7a.apk'],
        ),
        'nasyad-v1.3.0-armeabi-v7a.apk',
      );
    });

    test('returns null when no matching ABI asset exists', () {
      expect(
        pickAndroidReleaseAssetName(
          versionName: '1.3.0',
          deviceAbis: ['arm64-v8a'],
          availableNames: const ['nasyad-v1.3.0-x86_64.apk'],
        ),
        isNull,
      );
    });
  });

  group('parseReleaseTagName', () {
    test('accepts v-prefixed semver tags', () {
      expect(parseReleaseTagName('v1.2.3'), '1.2.3');
    });

    test('rejects invalid tags', () {
      expect(parseReleaseTagName('release-1'), isNull);
      expect(parseReleaseTagName('1.2.3'), isNull);
    });
  });

  group('isRemoteVersionNewer', () {
    test('compares semver names', () {
      expect(isRemoteVersionNewer('1.3.0', '1.2.0'), isTrue);
      expect(isRemoteVersionNewer('1.2.0', '1.2.0'), isFalse);
      expect(isRemoteVersionNewer('1.1.9', '1.2.0'), isFalse);
    });
  });

  group('GitHubReleaseDataSource', () {
    test('selects ABI-specific Android asset and detects update', () async {
      const body = '''
{
  "tag_name": "v1.3.0",
  "body": "Bug fixes",
  "assets": [
    {"name": "nasyad-v1.3.0-armeabi-v7a.apk", "browser_download_url": "https://example/apk32", "size": 1111},
    {"name": "nasyad-v1.3.0-arm64-v8a.apk", "browser_download_url": "https://example/apk", "size": 1234},
    {"name": "nasyad-v1.3.0-linux-x64.tar.gz", "browser_download_url": "https://example/linux", "size": 5678}
  ]
}
''';
      final client = MockClient((_) async => http.Response(body, 200));
      final source = GitHubReleaseDataSource(client: client);
      final result = await source.fetchLatestRelease(
        platform: UpdatePlatform.android,
        currentVersionName: '1.2.0',
        androidAbi: 'arm64-v8a',
      );

      expect(result.status, AppUpdateCheckStatus.updateAvailable);
      expect(result.release?.assetName, 'nasyad-v1.3.0-arm64-v8a.apk');
      expect(result.release?.sizeBytes, 1234);
      expect(result.release?.version.name, '1.3.0');
    });

    test(
      'falls back across device ABIs when preferred asset missing',
      () async {
        const body = '''
{
  "tag_name": "v1.3.0",
  "assets": [
    {"name": "nasyad-v1.3.0-armeabi-v7a.apk", "browser_download_url": "https://example/apk32", "size": 1111}
  ]
}
''';
        final client = MockClient((_) async => http.Response(body, 200));
        final source = GitHubReleaseDataSource(client: client);
        final result = await source.fetchLatestRelease(
          platform: UpdatePlatform.android,
          currentVersionName: '1.2.0',
          androidAbis: const ['arm64-v8a', 'armeabi-v7a'],
        );

        expect(result.status, AppUpdateCheckStatus.updateAvailable);
        expect(result.release?.assetName, 'nasyad-v1.3.0-armeabi-v7a.apk');
      },
    );

    test('returns up to date when remote is not newer', () async {
      const body = '''
{
  "tag_name": "v1.2.0",
  "assets": [
    {"name": "nasyad-v1.2.0-arm64-v8a.apk", "browser_download_url": "https://example/apk", "size": 100}
  ]
}
''';
      final client = MockClient((_) async => http.Response(body, 200));
      final source = GitHubReleaseDataSource(client: client);
      final result = await source.fetchLatestRelease(
        platform: UpdatePlatform.android,
        currentVersionName: '1.2.0',
        androidAbi: 'arm64-v8a',
      );

      expect(result.status, AppUpdateCheckStatus.upToDate);
      expect(result.release, isNull);
    });

    test('fails when platform asset missing', () async {
      const body = '''
{
  "tag_name": "v9.0.0",
  "assets": [
    {"name": "nasyad-v9.0.0-linux-x64.tar.gz", "browser_download_url": "https://example/linux", "size": 100}
  ]
}
''';
      final client = MockClient((_) async => http.Response(body, 200));
      final source = GitHubReleaseDataSource(client: client);
      final result = await source.fetchLatestRelease(
        platform: UpdatePlatform.android,
        currentVersionName: '1.0.0',
        androidAbi: 'arm64-v8a',
      );

      expect(result.status, AppUpdateCheckStatus.failed);
      expect(result.errorMessage, contains('nasyad-v9.0.0-arm64-v8a.apk'));
    });

    test('keeps Linux asset naming unchanged', () async {
      const body = '''
{
  "tag_name": "v1.3.0",
  "assets": [
    {"name": "nasyad-v1.3.0-linux-x64.tar.gz", "browser_download_url": "https://example/linux", "size": 5678}
  ]
}
''';
      final client = MockClient((_) async => http.Response(body, 200));
      final source = GitHubReleaseDataSource(client: client);
      final result = await source.fetchLatestRelease(
        platform: UpdatePlatform.linux,
        currentVersionName: '1.2.0',
      );

      expect(result.status, AppUpdateCheckStatus.updateAvailable);
      expect(result.release?.assetName, 'nasyad-v1.3.0-linux-x64.tar.gz');
    });
  });
}
