import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:nasyad/data/datasources/app_config_remote_datasource.dart';
import 'package:nasyad/domain/app_config_keys.dart';

void main() {
  group('HttpAppConfigRemoteDataSource.parseBody', () {
    test('parses features and updated_at', () {
      final snapshot = HttpAppConfigRemoteDataSource.parseBody('''
{
  "updated_at": "2026-08-08T12:00:00Z",
  "features": { "example_remote_flag": true },
  "extra_top_level": "ignored"
}
''');
      expect(snapshot.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      expect(snapshot.isEnabled('unknown'), isFalse);
      expect(snapshot.updatedAt, DateTime.utc(2026, 8, 8, 12));
    });

    test('ignores non-bool feature values', () {
      final snapshot = HttpAppConfigRemoteDataSource.parseBody('''
{
  "features": {
    "example_remote_flag": true,
    "bad": "yes",
    "also_bad": 1
  }
}
''');
      expect(snapshot.features, {AppConfigKeys.exampleRemoteFlag: true});
    });
  });

  group('HttpAppConfigRemoteDataSource.fetch', () {
    test('GETs /api/app_config/ with optional token', () async {
      String? authHeader;
      final client = MockClient((request) async {
        authHeader = request.headers['Authorization'];
        expect(request.method, 'GET');
        expect(request.url.path, '/api/app_config/');
        return http.Response(
          '{"updated_at":"2026-08-08T12:00:00Z","features":{"example_remote_flag":false}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final remote = HttpAppConfigRemoteDataSource(
        client: client,
        baseUrl: 'http://example.test',
      );
      final snapshot = await remote.fetch(token: 'tok');
      expect(authHeader, 'Token tok');
      expect(snapshot.isEnabled(AppConfigKeys.exampleRemoteFlag), isFalse);
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('nope', 500));
      final remote = HttpAppConfigRemoteDataSource(
        client: client,
        baseUrl: 'http://example.test',
      );
      expect(() => remote.fetch(), throwsA(isA<AppConfigRemoteException>()));
    });
  });
}
