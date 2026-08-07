part of 'auth_flow_bloc.dart';

enum AuthFlowStep { phone, otp }

enum AuthFlowStatus {
  ready,
  submitting,
  syncing,
  awaitingSyncConfirm,
  success,
  failure,
}

final class AuthFlowState extends Equatable {
  const AuthFlowState({
    this.step = AuthFlowStep.phone,
    this.status = AuthFlowStatus.ready,
    this.phone = '',
    this.normalizedPhone,
    this.code = '',
    this.cooldownSeconds = 0,
    this.errorMessage,
    this.syncFailed = false,
    this.syncCancelled = false,
    this.syncConflictDeviceCount = 0,
    this.syncConflictBirthdayCount = 0,
  });

  final AuthFlowStep step;
  final AuthFlowStatus status;
  final String phone;
  final String? normalizedPhone;
  final String code;
  final int cooldownSeconds;
  final String? errorMessage;
  final bool syncFailed;
  final bool syncCancelled;
  final int syncConflictDeviceCount;
  final int syncConflictBirthdayCount;

  int get syncConflictTotal =>
      syncConflictDeviceCount + syncConflictBirthdayCount;

  bool get canResend => cooldownSeconds <= 0;

  AuthFlowState copyWith({
    AuthFlowStep? step,
    AuthFlowStatus? status,
    String? phone,
    String? normalizedPhone,
    String? code,
    int? cooldownSeconds,
    String? errorMessage,
    bool? syncFailed,
    bool? syncCancelled,
    int? syncConflictDeviceCount,
    int? syncConflictBirthdayCount,
    bool clearError = false,
    bool clearNormalizedPhone = false,
  }) {
    return AuthFlowState(
      step: step ?? this.step,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      normalizedPhone: clearNormalizedPhone
          ? null
          : (normalizedPhone ?? this.normalizedPhone),
      code: code ?? this.code,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      syncFailed: syncFailed ?? this.syncFailed,
      syncCancelled: syncCancelled ?? this.syncCancelled,
      syncConflictDeviceCount:
          syncConflictDeviceCount ?? this.syncConflictDeviceCount,
      syncConflictBirthdayCount:
          syncConflictBirthdayCount ?? this.syncConflictBirthdayCount,
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
    phone,
    normalizedPhone,
    code,
    cooldownSeconds,
    errorMessage,
    syncFailed,
    syncCancelled,
    syncConflictDeviceCount,
    syncConflictBirthdayCount,
  ];
}
