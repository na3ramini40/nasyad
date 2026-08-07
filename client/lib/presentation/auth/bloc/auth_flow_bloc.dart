import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/data/datasources/auth_api_exception.dart';
import 'package:nasyad/data/services/fcm_registration_sync.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';
import 'package:nasyad/domain/services/auth_phone.dart';
import 'package:nasyad/domain/services/local_sync_coordinator.dart';
import 'package:nasyad/domain/usecases/auth/request_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/resend_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/verify_otp_usecase.dart';

part 'auth_flow_event.dart';
part 'auth_flow_state.dart';

class AuthFlowBloc extends Bloc<AuthFlowEvent, AuthFlowState> {
  AuthFlowBloc({
    required RequestOtpUsecase requestOtp,
    required ResendOtpUsecase resendOtp,
    required VerifyOtpUsecase verifyOtp,
    required AuthRepository authRepository,
    LocalSyncCoordinator? syncCoordinator,
    FcmRegistrationSync? fcmRegistrationSync,
    this.tickInterval = const Duration(seconds: 1),
  }) : _requestOtp = requestOtp,
       _resendOtp = resendOtp,
       _verifyOtp = verifyOtp,
       _authRepository = authRepository,
       _syncCoordinator = syncCoordinator,
       _fcmRegistrationSync = fcmRegistrationSync,
       super(const AuthFlowState()) {
    on<AuthPhoneChanged>(_onPhoneChanged);
    on<AuthSendCodeRequested>(_onSendCode);
    on<AuthCodeChanged>(_onCodeChanged);
    on<AuthVerifyRequested>(_onVerify);
    on<AuthResendRequested>(_onResend);
    on<AuthCooldownTicked>(_onCooldownTicked);
    on<AuthSyncOverrideConfirmed>(_onSyncOverrideConfirmed);
    on<AuthSyncOverrideCancelled>(_onSyncOverrideCancelled);
  }

  final RequestOtpUsecase _requestOtp;
  final ResendOtpUsecase _resendOtp;
  final VerifyOtpUsecase _verifyOtp;
  final AuthRepository _authRepository;
  final LocalSyncCoordinator? _syncCoordinator;
  final FcmRegistrationSync? _fcmRegistrationSync;
  final Duration tickInterval;
  final OtpCooldownTicker _cooldown = OtpCooldownTicker();
  Timer? _timer;

  void _onPhoneChanged(AuthPhoneChanged event, Emitter<AuthFlowState> emit) {
    emit(
      state.copyWith(
        phone: event.phone,
        clearError: true,
        status: AuthFlowStatus.ready,
      ),
    );
  }

  Future<void> _onSendCode(
    AuthSendCodeRequested event,
    Emitter<AuthFlowState> emit,
  ) async {
    final normalized = AuthPhone.normalize(state.phone);
    if (normalized == null) {
      emit(
        state.copyWith(
          status: AuthFlowStatus.failure,
          errorMessage: 'invalid_phone',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthFlowStatus.submitting,
        normalizedPhone: normalized,
        clearError: true,
      ),
    );

    try {
      final result = await _requestOtp(normalized);
      _startCooldown(result.cooldownSeconds);
      emit(
        state.copyWith(
          step: AuthFlowStep.otp,
          status: AuthFlowStatus.ready,
          normalizedPhone: result.phone,
          cooldownSeconds: result.cooldownSeconds,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthFlowStatus.failure,
          errorMessage: _messageOf(error),
        ),
      );
    }
  }

  void _onCodeChanged(AuthCodeChanged event, Emitter<AuthFlowState> emit) {
    emit(
      state.copyWith(
        code: event.code,
        clearError: true,
        status: AuthFlowStatus.ready,
      ),
    );
  }

  Future<void> _onVerify(
    AuthVerifyRequested event,
    Emitter<AuthFlowState> emit,
  ) async {
    final phone = state.normalizedPhone ?? AuthPhone.normalize(state.phone);
    final code = state.code.trim();
    if (phone == null) {
      emit(
        state.copyWith(
          status: AuthFlowStatus.failure,
          errorMessage: 'invalid_phone',
        ),
      );
      return;
    }
    if (!AuthPhone.isValidOtpCode(code)) {
      emit(
        state.copyWith(
          status: AuthFlowStatus.failure,
          errorMessage: 'invalid_code',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthFlowStatus.submitting, clearError: true));
    try {
      await _verifyOtp(phone: phone, code: code);
      _stopCooldown();
      final token = _authRepository.currentSession.token;
      final coordinator = _syncCoordinator;
      if (coordinator != null && token != null && token.isNotEmpty) {
        emit(state.copyWith(status: AuthFlowStatus.syncing, clearError: true));
        final preview = await coordinator.previewSync(token: token);
        if (preview is SyncPreviewConflicts) {
          emit(
            state.copyWith(
              status: AuthFlowStatus.awaitingSyncConfirm,
              syncConflictDeviceCount: preview.summary.deviceCount,
              syncConflictBirthdayCount: preview.summary.birthdayCount,
              clearError: true,
            ),
          );
          return;
        }
        await _finishAfterSync(emit, token: token, overrideConfirmed: false);
        return;
      }
      // Silent FCM registration — never blocks or fails the auth flow.
      unawaited(_fcmRegistrationSync?.syncNow() ?? Future<void>.value());
      await _emitAuthSuccess(emit, syncFailed: false, syncCancelled: false);
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthFlowStatus.failure,
          errorMessage: _messageOf(error),
        ),
      );
    }
  }

  Future<void> _onSyncOverrideConfirmed(
    AuthSyncOverrideConfirmed event,
    Emitter<AuthFlowState> emit,
  ) async {
    if (state.status != AuthFlowStatus.awaitingSyncConfirm) return;
    final token = _authRepository.currentSession.token;
    if (token == null || token.isEmpty || _syncCoordinator == null) {
      await _emitAuthSuccess(emit, syncFailed: false, syncCancelled: false);
      return;
    }
    emit(state.copyWith(status: AuthFlowStatus.syncing, clearError: true));
    await _finishAfterSync(emit, token: token, overrideConfirmed: true);
  }

  Future<void> _onSyncOverrideCancelled(
    AuthSyncOverrideCancelled event,
    Emitter<AuthFlowState> emit,
  ) async {
    if (state.status != AuthFlowStatus.awaitingSyncConfirm) return;
    // Signed in; abort sync writes — local and remote stay as-is.
    unawaited(_fcmRegistrationSync?.syncNow() ?? Future<void>.value());
    await _emitAuthSuccess(emit, syncFailed: false, syncCancelled: true);
  }

  Future<void> _finishAfterSync(
    Emitter<AuthFlowState> emit, {
    required String token,
    required bool overrideConfirmed,
  }) async {
    final coordinator = _syncCoordinator!;
    final outcome = await coordinator.syncNow(
      token: token,
      overrideConfirmed: overrideConfirmed,
    );
    if (outcome == SyncNowOutcome.needsConfirmation) {
      // Defensive: preview should have caught this; surface confirm again.
      final preview = await coordinator.previewSync(token: token);
      if (preview is SyncPreviewConflicts) {
        emit(
          state.copyWith(
            status: AuthFlowStatus.awaitingSyncConfirm,
            syncConflictDeviceCount: preview.summary.deviceCount,
            syncConflictBirthdayCount: preview.summary.birthdayCount,
            clearError: true,
          ),
        );
        return;
      }
    }
    unawaited(_fcmRegistrationSync?.syncNow() ?? Future<void>.value());
    await _emitAuthSuccess(
      emit,
      syncFailed: outcome == SyncNowOutcome.failed,
      syncCancelled: false,
    );
  }

  Future<void> _emitAuthSuccess(
    Emitter<AuthFlowState> emit, {
    required bool syncFailed,
    required bool syncCancelled,
  }) async {
    emit(
      state.copyWith(
        status: AuthFlowStatus.success,
        syncFailed: syncFailed,
        syncCancelled: syncCancelled,
        clearError: true,
      ),
    );
  }

  Future<void> _onResend(
    AuthResendRequested event,
    Emitter<AuthFlowState> emit,
  ) async {
    if (!state.canResend) return;
    final phone = state.normalizedPhone ?? AuthPhone.normalize(state.phone);
    if (phone == null) {
      emit(
        state.copyWith(
          status: AuthFlowStatus.failure,
          errorMessage: 'invalid_phone',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthFlowStatus.submitting, clearError: true));
    try {
      final result = await _resendOtp(phone);
      _startCooldown(result.cooldownSeconds);
      emit(
        state.copyWith(
          status: AuthFlowStatus.ready,
          cooldownSeconds: result.cooldownSeconds,
          clearError: true,
        ),
      );
    } catch (error) {
      if (error is AuthApiException && error.isCooldown) {
        final retry = error.retryAfterSeconds ?? 120;
        _startCooldown(retry);
        emit(
          state.copyWith(
            status: AuthFlowStatus.failure,
            cooldownSeconds: retry,
            errorMessage: error.message,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AuthFlowStatus.failure,
          errorMessage: _messageOf(error),
        ),
      );
    }
  }

  void _onCooldownTicked(
    AuthCooldownTicked event,
    Emitter<AuthFlowState> emit,
  ) {
    final remaining = _cooldown.tick();
    emit(state.copyWith(cooldownSeconds: remaining));
    if (remaining <= 0) {
      _stopCooldown();
    }
  }

  void _startCooldown(int seconds) {
    _cooldown.start(seconds);
    _timer?.cancel();
    if (seconds <= 0) return;
    _timer = Timer.periodic(tickInterval, (_) {
      if (!isClosed) add(const AuthCooldownTicked());
    });
  }

  void _stopCooldown() {
    _timer?.cancel();
    _timer = null;
  }

  String _messageOf(Object error) {
    if (error is AuthApiException) return error.message;
    return error.toString();
  }

  @override
  Future<void> close() {
    _stopCooldown();
    return super.close();
  }
}
