import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/app_lock_store.dart';
import 'package:nasyad/domain/entities/app_lock_config.dart';
import 'package:nasyad/domain/entities/lock_idle_timeout.dart';
import 'package:nasyad/domain/entities/lock_method.dart';

void main() {
  group('AppLockStore', () {
    test('starts unset and clear leaves no secret', () async {
      final store = AppLockStore.memory();
      final config = await store.readConfig();
      expect(config.isEnabled, isFalse);
      expect(config.method, isNull);
      expect(await store.hasSecret(), isFalse);

      await store.setSecret('1234');
      await store.writeConfig(
        const AppLockConfig(
          method: LockMethod.pin,
          timeout: LockIdleTimeout.oneMinute,
        ),
      );
      expect(await store.verifySecret('1234'), isTrue);
      expect(await store.verifySecret('9999'), isFalse);

      await store.clear();
      final cleared = await store.readConfig();
      expect(cleared, AppLockConfig.unset);
      expect(await store.hasSecret(), isFalse);
      expect(await store.verifySecret('1234'), isFalse);
    });

    test('validates pin and password lengths', () {
      expect(AppLockStore.isValidPin('12'), isFalse);
      expect(AppLockStore.isValidPin('1234'), isTrue);
      expect(AppLockStore.isValidPin('12345678'), isTrue);
      expect(AppLockStore.isValidPin('123456789'), isFalse);
      expect(AppLockStore.isValidPin('12ab'), isFalse);
      expect(AppLockStore.isValidPassword('abc'), isFalse);
      expect(AppLockStore.isValidPassword('abcd'), isTrue);
    });
  });
}
