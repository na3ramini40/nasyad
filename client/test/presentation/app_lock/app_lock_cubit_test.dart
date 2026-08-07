import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/app_lock/biometric_authenticator.dart';
import 'package:nasyad/core/preferences/app_lock_store.dart';
import 'package:nasyad/domain/entities/lock_idle_timeout.dart';
import 'package:nasyad/domain/entities/lock_method.dart';
import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';

class _FakeBiometric implements BiometricAuthenticator {
  bool available = true;
  bool succeed = true;
  int authCalls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authCalls += 1;
    return succeed;
  }
}

void main() {
  late AppLockStore store;
  late _FakeBiometric biometric;
  late DateTime clock;
  late AppLockCubit cubit;

  setUp(() async {
    store = AppLockStore.memory();
    biometric = _FakeBiometric();
    clock = DateTime.utc(2024, 1, 1, 12);
    cubit = AppLockCubit(store: store, biometric: biometric, now: () => clock);
    await cubit.ready;
  });

  tearDown(() async {
    await cubit.close();
  });

  test('enable PIN then unlock; wrong PIN fails', () async {
    expect(cubit.state.isEnabled, isFalse);

    final enabled = await cubit.enablePin(
      pin: '2468',
      confirm: '2468',
      timeout: LockIdleTimeout.fiveMinutes,
    );
    expect(enabled, isTrue);
    expect(cubit.state.method, LockMethod.pin);
    expect(cubit.state.isLocked, isFalse);

    cubit.lockNow();
    expect(cubit.state.isLocked, isTrue);

    expect(await cubit.unlockWithSecret('0000'), isFalse);
    expect(cubit.state.error, AppLockError.wrongSecret);
    expect(cubit.state.isLocked, isTrue);

    expect(await cubit.unlockWithSecret('2468'), isTrue);
    expect(cubit.state.isLocked, isFalse);
  });

  test('PIN confirm mismatch and too short', () async {
    expect(await cubit.enablePin(pin: '12', confirm: '12'), isFalse);
    expect(cubit.state.error, AppLockError.tooShort);

    expect(await cubit.enablePin(pin: '1234', confirm: '9999'), isFalse);
    expect(cubit.state.error, AppLockError.mismatch);
    expect(cubit.state.isEnabled, isFalse);
  });

  test('idle timeout locks after elapsed interaction gap', () async {
    await cubit.enablePin(
      pin: '1357',
      confirm: '1357',
      timeout: LockIdleTimeout.oneMinute,
    );
    expect(cubit.state.isLocked, isFalse);

    cubit.onUserInteraction();
    clock = clock.add(const Duration(minutes: 2));
    // Force timer path by restarting with elapsed time.
    cubit.onUserInteraction();
    // lastInteraction was reset by onUserInteraction — advance again without reset:
    clock = clock.add(const Duration(minutes: 2));
    cubit.onAppPaused();
    cubit.onAppResumed();
    expect(cubit.state.isLocked, isTrue);
  });

  test('immediate timeout locks on pause', () async {
    await cubit.enablePin(
      pin: '1357',
      confirm: '1357',
      timeout: LockIdleTimeout.immediate,
    );
    cubit.onAppPaused();
    expect(cubit.state.isLocked, isTrue);
  });

  test('clearAfterForgot resets to unset without requiring unlock', () async {
    await cubit.enablePin(pin: '1111', confirm: '1111');
    cubit.lockNow();
    await cubit.clearAfterForgot();
    expect(cubit.state.isEnabled, isFalse);
    expect(cubit.state.isLocked, isFalse);
    expect(await store.hasSecret(), isFalse);
  });

  test('biometric enable and unlock', () async {
    final ok = await cubit.enableBiometric(
      localizedReason: 'test',
      timeout: LockIdleTimeout.fiveMinutes,
    );
    expect(ok, isTrue);
    expect(cubit.state.method, LockMethod.biometric);
    cubit.lockNow();
    expect(await cubit.unlockWithBiometric(localizedReason: 'test'), isTrue);
    expect(cubit.state.isLocked, isFalse);
    expect(biometric.authCalls, greaterThanOrEqualTo(2));
  });

  test('biometric unavailable is reported', () async {
    biometric.available = false;
    final ok = await cubit.enableBiometric(localizedReason: 'test');
    expect(ok, isFalse);
    expect(cubit.state.error, AppLockError.biometricUnavailable);
  });
}
