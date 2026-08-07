import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/data/local/device_registration_store.dart';
import 'package:nasyad/data/services/fcm_registration_sync.dart';
import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/entities/user_profile.dart';
import '../helpers/fake_auth_repository.dart';

UserProfile _profile() => UserProfile(
  id: 'u1',
  phone: '+989121234567',
  name: 'Ada',
  imageUrl: null,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  group('FcmRegistrationSync', () {
    late FakeAuthRepository auth;
    late DeviceRegistrationStore store;
    late StreamController<String> tokenRefresh;
    late String? currentToken;
    late FcmRegistrationSync sync;

    setUp(() {
      auth = FakeAuthRepository();
      store = DeviceRegistrationStore.memory(deviceId: 'install-1');
      tokenRefresh = StreamController<String>.broadcast();
      currentToken = 'fcm-current';
      sync = FcmRegistrationSync(
        authRepository: auth,
        store: store,
        supported: true,
        getToken: () async => currentToken,
        tokenRefresh: tokenRefresh.stream,
      );
    });

    tearDown(() async {
      await sync.dispose();
      await tokenRefresh.close();
      auth.dispose();
    });

    Future<void> pump() => Future<void>.delayed(Duration.zero);

    test('upserts when signed in with a token', () async {
      auth.emitSession(AuthSession(token: 'tok', profile: _profile()));

      await sync.start();
      await pump();

      expect(auth.upsertRegistrationCalls, 1);
      expect(auth.lastUpsertDeviceId, 'install-1');
      expect(auth.lastUpsertFcmToken, 'fcm-current');
      expect(await store.readLastSyncedFcmToken(), 'fcm-current');
    });

    test('skips guest sessions', () async {
      await sync.start();
      await pump();

      expect(auth.upsertRegistrationCalls, 0);
      expect(await store.readLastSyncedFcmToken(), isNull);
    });

    test('syncs when session flips to signed in', () async {
      await sync.start();
      await pump();
      expect(auth.upsertRegistrationCalls, 0);

      auth.emitSession(AuthSession(token: 'tok', profile: _profile()));
      await pump();

      expect(auth.upsertRegistrationCalls, 1);
      expect(auth.lastUpsertFcmToken, 'fcm-current');
    });

    test('skips PUT when fcm token unchanged', () async {
      auth.emitSession(AuthSession(token: 'tok', profile: _profile()));
      await store.writeLastSyncedFcmToken('fcm-current');

      await sync.start();
      await pump();

      expect(auth.upsertRegistrationCalls, 0);
    });

    test('token refresh triggers upsert while signed in', () async {
      auth.emitSession(AuthSession(token: 'tok', profile: _profile()));
      await sync.start();
      await pump();
      expect(auth.upsertRegistrationCalls, 1);

      tokenRefresh.add('fcm-refreshed');
      await pump();

      expect(auth.upsertRegistrationCalls, 2);
      expect(auth.lastUpsertFcmToken, 'fcm-refreshed');
      expect(await store.readLastSyncedFcmToken(), 'fcm-refreshed');
    });

    test('swallows remote errors without throwing', () async {
      auth.emitSession(AuthSession(token: 'tok', profile: _profile()));
      auth.upsertError = StateError('network down');

      await expectLater(sync.start(), completes);
      await pump();

      expect(auth.upsertRegistrationCalls, 0);
      expect(await store.readLastSyncedFcmToken(), isNull);
    });

    test('no-ops when push unsupported', () async {
      await sync.dispose();
      sync = FcmRegistrationSync(
        authRepository: auth,
        store: store,
        supported: false,
        getToken: () async => 'fcm',
        tokenRefresh: tokenRefresh.stream,
      );
      auth.emitSession(AuthSession(token: 'tok', profile: _profile()));

      await sync.start();
      await sync.syncNow();
      await pump();

      expect(auth.upsertRegistrationCalls, 0);
    });
  });
}
