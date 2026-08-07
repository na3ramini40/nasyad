import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/data/local/auth_session_store.dart';
import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/domain/services/auth_phone.dart';

void main() {
  group('AuthPhone.normalize', () {
    test('accepts E.164 and local IR forms', () {
      expect(AuthPhone.normalize('+989121234567'), '+989121234567');
      expect(AuthPhone.normalize('09121234567'), '+989121234567');
      expect(AuthPhone.normalize('989121234567'), '+989121234567');
      expect(AuthPhone.normalize('00989121234567'), '+989121234567');
    });

    test('rejects empty or too-short values', () {
      expect(AuthPhone.normalize(''), isNull);
      expect(AuthPhone.normalize('123'), isNull);
      expect(AuthPhone.normalize('abc'), isNull);
    });
  });

  group('OtpCooldownTicker', () {
    test('disables resend until countdown reaches zero', () {
      final ticker = OtpCooldownTicker(initialSeconds: 3);
      expect(ticker.canResend, isFalse);
      expect(ticker.tick(), 2);
      expect(ticker.tick(), 1);
      expect(ticker.tick(), 0);
      expect(ticker.canResend, isTrue);
      expect(ticker.tick(), 0);
    });

    test('start resets remaining seconds', () {
      final ticker = OtpCooldownTicker();
      expect(ticker.canResend, isTrue);
      ticker.start(120);
      expect(ticker.remainingSeconds, 120);
      expect(ticker.canResend, isFalse);
    });
  });

  group('AuthSessionStore', () {
    test('persists token, profile, and intro flag in memory', () async {
      final store = AuthSessionStore.memory();
      expect(await store.hasCompletedIntro(), isFalse);
      expect(await store.readToken(), isNull);

      final profile = UserProfile(
        id: 'abc123',
        phone: '+989121234567',
        name: 'Ada',
        imageUrl: null,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      );

      await store.writeSession(token: 'tok', profile: profile);
      await store.setIntroCompleted();

      expect(await store.readToken(), 'tok');
      expect(await store.readCachedProfile(), profile);
      expect(await store.hasCompletedIntro(), isTrue);

      final session = await store.readSession();
      expect(session.isSignedIn, isTrue);

      await store.clearSession();
      expect(await store.readToken(), isNull);
      expect((await store.readSession()).isSignedIn, isFalse);
      expect(await store.hasCompletedIntro(), isTrue);

      store.dispose();
    });

    test('introCompleted initial true is respected', () async {
      final store = AuthSessionStore.memory(introCompleted: true);
      expect(await store.hasCompletedIntro(), isTrue);
      store.dispose();
    });
  });
}
