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
        releaseAssetName(UpdatePlatform.android, '1.3.0'),
        'nasyad-v1.3.0.apk',
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
    test('selects platform asset and detects update', () async {
      const body = '''
{
  "tag_name": "v1.3.0",
  "body": "Bug fixes",
  "assets": [
    {"name": "nasyad-v1.3.0.apk", "browser_download_url": "https://example/apk", "size": 1234},
    {"name": "nasyad-v1.3.0-linux-x64.tar.gz", "browser_download_url": "https://example/linux", "size": 5678}
  ]
}
''';
      final client = MockClient((_) async => http.Response(body, 200));
      final source = GitHubReleaseDataSource(client: client);
      final result = await source.fetchLatestRelease(
        platform: UpdatePlatform.android,
        currentVersionName: '1.2.0',
      );

      expect(result.status, AppUpdateCheckStatus.updateAvailable);
      expect(result.release?.assetName, 'nasyad-v1.3.0.apk');
      expect(result.release?.sizeBytes, 1234);
      expect(result.release?.version.name, '1.3.0');
    });

    test('returns up to date when remote is not newer', () async {
      const body = '''
{
  "tag_name": "v1.2.0",
  "assets": [
    {"name": "nasyad-v1.2.0.apk", "browser_download_url": "https://example/apk", "size": 100}
  ]
}
''';
      final client = MockClient((_) async => http.Response(body, 200));
      final source = GitHubReleaseDataSource(client: client);
      final result = await source.fetchLatestRelease(
        platform: UpdatePlatform.android,
        currentVersionName: '1.2.0',
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
      );

      expect(result.status, AppUpdateCheckStatus.failed);
      expect(result.errorMessage, contains('nasyad-v9.0.0.apk'));
    });
  });
}
