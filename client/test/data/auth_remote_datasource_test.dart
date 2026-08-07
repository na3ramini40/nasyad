import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:nasyad/data/datasources/auth_api_exception.dart';
import 'package:nasyad/data/datasources/auth_remote_datasource.dart';

void main() {
  group('AuthRemoteDataSource.upsertDeviceRegistration', () {
    test('PUTs /api/accounts/registrations/ with token and body', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'device_id': 'install-1',
            'fcm_token': 'fcm-abc',
            'created_at': '2026-08-08T12:00:00Z',
            'updated_at': '2026-08-08T12:05:00Z',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final remote = AuthRemoteDataSource(
        client: client,
        baseUrl: 'http://example.test',
      );
      final body = await remote.upsertDeviceRegistration(
        token: 'auth-tok',
        deviceId: 'install-1',
        fcmToken: 'fcm-abc',
      );

      expect(captured.method, 'PUT');
      expect(captured.url.path, '/api/accounts/registrations/');
      expect(captured.headers['Authorization'], 'Token auth-tok');
      expect(captured.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(captured.body), {
        'device_id': 'install-1',
        'fcm_token': 'fcm-abc',
      });
      expect(body['device_id'], 'install-1');
      expect(body['fcm_token'], 'fcm-abc');
    });

    test('throws AuthApiException on non-200', () async {
      final client = MockClient(
        (_) async => http.Response('{"detail":"nope"}', 401),
      );
      final remote = AuthRemoteDataSource(
        client: client,
        baseUrl: 'http://example.test',
      );
      expect(
        () => remote.upsertDeviceRegistration(
          token: 'tok',
          deviceId: 'd',
          fcmToken: 'f',
        ),
        throwsA(
          isA<AuthApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });
  });
}
