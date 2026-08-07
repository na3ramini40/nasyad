import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/app_lock/biometric_authenticator.dart';
import 'package:nasyad/core/preferences/app_lock_store.dart';
import 'package:nasyad/domain/entities/app_lock_config.dart';
import 'package:nasyad/domain/entities/lock_idle_timeout.dart';
import 'package:nasyad/domain/entities/lock_method.dart';

enum AppLockError {
  wrongSecret,
  mismatch,
  tooShort,
  biometricUnavailable,
  biometricFailed,
  unlockRequired,
}

final class AppLockState extends Equatable {
  const AppLockState({
    this.hydrated = false,
    this.config = AppLockConfig.unset,
    this.isLocked = false,
    this.biometricAvailable = false,
    this.authenticating = false,
    this.error,
  });

  final bool hydrated;
  final AppLockConfig config;
  final bool isLocked;
  final bool biometricAvailable;
  final bool authenticating;
  final AppLockError? error;

  bool get isEnabled => config.isEnabled;
  LockMethod? get method => config.method;
  LockIdleTimeout get timeout => config.timeout;

  AppLockState copyWith({
    bool? hydrated,
    AppLockConfig? config,
    bool? isLocked,
    bool? biometricAvailable,
    bool? authenticating,
    AppLockError? error,
    bool clearError = false,
  }) {
    return AppLockState(
      hydrated: hydrated ?? this.hydrated,
      config: config ?? this.config,
      isLocked: isLocked ?? this.isLocked,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      authenticating: authenticating ?? this.authenticating,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    hydrated,
    config,
    isLocked,
    biometricAvailable,
    authenticating,
    error,
  ];
}

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required AppLockStore store,
    BiometricAuthenticator? biometric,
    this.now = DateTime.now,
  }) : _store = store,
       _biometric = biometric ?? const UnavailableBiometricAuthenticator(),
       super(const AppLockState()) {
    _hydrating = _hydrate();
  }

  final AppLockStore _store;
  final BiometricAuthenticator _biometric;
  final DateTime Function() now;

  Future<void>? _hydrating;
  Timer? _idleTimer;
  DateTime? _pausedAt;
  DateTime? _lastInteractionAt;

  Future<void> get ready => _hydrating ?? Future<void>.value();

  Future<void> _hydrate() async {
    final config = await _store.readConfig();
    final biometricAvailable = await _biometric.isAvailable();
    if (isClosed) return;
    emit(
      AppLockState(
        hydrated: true,
        config: config,
        // Cold start: lock when enabled.
        isLocked: config.isEnabled,
        biometricAvailable: biometricAvailable,
      ),
    );
    if (config.isEnabled) {
      _lastInteractionAt = now();
    }
  }

  Future<void> refreshBiometricAvailability() async {
    final available = await _biometric.isAvailable();
    if (!isClosed) {
      emit(state.copyWith(biometricAvailable: available));
    }
  }

  void onUserInteraction() {
    if (!state.isEnabled || state.isLocked) return;
    _lastInteractionAt = now();
    _restartIdleTimer();
  }

  void onAppPaused() {
    if (!state.isEnabled || state.isLocked) return;
    _idleTimer?.cancel();
    _pausedAt = now();
    if (state.timeout.isImmediate) {
      emit(state.copyWith(isLocked: true, clearError: true));
    }
  }

  void onAppResumed() {
    if (!state.isEnabled) return;
    if (state.isLocked) {
      _pausedAt = null;
      return;
    }
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt != null) {
      final elapsed = now().difference(pausedAt);
      if (state.timeout.isImmediate || elapsed >= state.timeout.duration) {
        emit(state.copyWith(isLocked: true, clearError: true));
        return;
      }
    }
    _restartIdleTimer();
  }

  void lockNow() {
    if (!state.isEnabled) return;
    _idleTimer?.cancel();
    emit(state.copyWith(isLocked: true, clearError: true));
  }

  void _restartIdleTimer() {
    _idleTimer?.cancel();
    if (!state.isEnabled || state.isLocked || state.timeout.isImmediate) {
      return;
    }
    final last = _lastInteractionAt ?? now();
    final remaining = state.timeout.duration - now().difference(last);
    if (remaining <= Duration.zero) {
      emit(state.copyWith(isLocked: true, clearError: true));
      return;
    }
    _idleTimer = Timer(remaining, () {
      if (!isClosed && state.isEnabled && !state.isLocked) {
        emit(state.copyWith(isLocked: true, clearError: true));
      }
    });
  }

  Future<bool> unlockWithSecret(String secret) async {
    await _hydrating;
    final method = state.method;
    if (method != LockMethod.password && method != LockMethod.pin) {
      return false;
    }
    emit(state.copyWith(authenticating: true, clearError: true));
    final ok = await _store.verifySecret(secret);
    if (isClosed) return false;
    if (!ok) {
      emit(
        state.copyWith(authenticating: false, error: AppLockError.wrongSecret),
      );
      return false;
    }
    _lastInteractionAt = now();
    emit(
      state.copyWith(authenticating: false, isLocked: false, clearError: true),
    );
    _restartIdleTimer();
    return true;
  }

  Future<bool> unlockWithBiometric({required String localizedReason}) async {
    await _hydrating;
    if (state.method != LockMethod.biometric) return false;
    if (!state.biometricAvailable) {
      emit(state.copyWith(error: AppLockError.biometricUnavailable));
      return false;
    }
    emit(state.copyWith(authenticating: true, clearError: true));
    final ok = await _biometric.authenticate(localizedReason: localizedReason);
    if (isClosed) return false;
    if (!ok) {
      emit(
        state.copyWith(
          authenticating: false,
          error: AppLockError.biometricFailed,
        ),
      );
      return false;
    }
    _lastInteractionAt = now();
    emit(
      state.copyWith(authenticating: false, isLocked: false, clearError: true),
    );
    _restartIdleTimer();
    return true;
  }

  /// Re-verify current unlock for change/disable flows while unlocked.
  Future<bool> verifyCurrent({String? secret, String? biometricReason}) async {
    await _hydrating;
    final method = state.method;
    if (method == null) return true;
    if (method == LockMethod.biometric) {
      if (!state.biometricAvailable) {
        emit(state.copyWith(error: AppLockError.biometricUnavailable));
        return false;
      }
      final reason = biometricReason ?? 'Authenticate';
      emit(state.copyWith(authenticating: true, clearError: true));
      final ok = await _biometric.authenticate(localizedReason: reason);
      if (isClosed) return false;
      emit(
        state.copyWith(
          authenticating: false,
          error: ok ? null : AppLockError.biometricFailed,
          clearError: ok,
        ),
      );
      return ok;
    }
    if (secret == null) {
      emit(state.copyWith(error: AppLockError.unlockRequired));
      return false;
    }
    final ok = await _store.verifySecret(secret);
    if (!ok) {
      emit(state.copyWith(error: AppLockError.wrongSecret));
    } else {
      emit(state.copyWith(clearError: true));
    }
    return ok;
  }

  Future<bool> enablePassword({
    required String password,
    required String confirm,
    LockIdleTimeout? timeout,
  }) async {
    await _hydrating;
    if (!AppLockStore.isValidPassword(password)) {
      emit(state.copyWith(error: AppLockError.tooShort));
      return false;
    }
    if (password != confirm) {
      emit(state.copyWith(error: AppLockError.mismatch));
      return false;
    }
    await _store.setSecret(password);
    final config = AppLockConfig(
      method: LockMethod.password,
      timeout: timeout ?? state.timeout,
    );
    await _store.writeConfig(config);
    _lastInteractionAt = now();
    emit(state.copyWith(config: config, isLocked: false, clearError: true));
    _restartIdleTimer();
    return true;
  }

  Future<bool> enablePin({
    required String pin,
    required String confirm,
    LockIdleTimeout? timeout,
  }) async {
    await _hydrating;
    if (!AppLockStore.isValidPin(pin)) {
      emit(state.copyWith(error: AppLockError.tooShort));
      return false;
    }
    if (pin != confirm) {
      emit(state.copyWith(error: AppLockError.mismatch));
      return false;
    }
    await _store.setSecret(pin);
    final config = AppLockConfig(
      method: LockMethod.pin,
      timeout: timeout ?? state.timeout,
    );
    await _store.writeConfig(config);
    _lastInteractionAt = now();
    emit(state.copyWith(config: config, isLocked: false, clearError: true));
    _restartIdleTimer();
    return true;
  }

  Future<bool> enableBiometric({
    required String localizedReason,
    LockIdleTimeout? timeout,
  }) async {
    await _hydrating;
    final available = await _biometric.isAvailable();
    if (!available) {
      emit(
        state.copyWith(
          biometricAvailable: false,
          error: AppLockError.biometricUnavailable,
        ),
      );
      return false;
    }
    emit(state.copyWith(authenticating: true, clearError: true));
    final ok = await _biometric.authenticate(localizedReason: localizedReason);
    if (isClosed) return false;
    if (!ok) {
      emit(
        state.copyWith(
          authenticating: false,
          biometricAvailable: true,
          error: AppLockError.biometricFailed,
        ),
      );
      return false;
    }
    final config = AppLockConfig(
      method: LockMethod.biometric,
      timeout: timeout ?? state.timeout,
    );
    // Biometric has no local secret; wipe any leftover password/PIN hash.
    await _store.clearSecret();
    await _store.writeConfig(config);
    _lastInteractionAt = now();
    emit(
      state.copyWith(
        authenticating: false,
        config: config,
        biometricAvailable: true,
        isLocked: false,
        clearError: true,
      ),
    );
    _restartIdleTimer();
    return true;
  }

  Future<void> setTimeout(LockIdleTimeout timeout) async {
    await _hydrating;
    final config = state.config.copyWith(timeout: timeout);
    await _store.writeConfig(config);
    emit(state.copyWith(config: config, clearError: true));
    if (state.isEnabled && !state.isLocked) {
      _lastInteractionAt = now();
      _restartIdleTimer();
    }
  }

  Future<bool> disable({
    String? secret,
    String? biometricReason,
    bool alreadyVerified = false,
  }) async {
    await _hydrating;
    if (!state.isEnabled) return true;
    if (!alreadyVerified) {
      final verified = await verifyCurrent(
        secret: secret,
        biometricReason: biometricReason,
      );
      if (!verified) return false;
    }
    await _store.clear();
    _idleTimer?.cancel();
    emit(
      state.copyWith(
        config: AppLockConfig.unset,
        isLocked: false,
        clearError: true,
      ),
    );
    return true;
  }

  /// Forgot-lock OTP success: reset to unset. Does not touch Drift.
  Future<void> clearAfterForgot() async {
    await _hydrating;
    await _store.clear();
    _idleTimer?.cancel();
    emit(
      state.copyWith(
        config: AppLockConfig.unset,
        isLocked: false,
        clearError: true,
      ),
    );
  }

  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  @override
  Future<void> close() {
    _idleTimer?.cancel();
    return super.close();
  }
}
