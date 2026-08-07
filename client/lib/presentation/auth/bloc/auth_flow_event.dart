part of 'auth_flow_bloc.dart';

sealed class AuthFlowEvent extends Equatable {
  const AuthFlowEvent();

  @override
  List<Object?> get props => [];
}

final class AuthPhoneChanged extends AuthFlowEvent {
  const AuthPhoneChanged(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class AuthSendCodeRequested extends AuthFlowEvent {
  const AuthSendCodeRequested();
}

final class AuthCodeChanged extends AuthFlowEvent {
  const AuthCodeChanged(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class AuthVerifyRequested extends AuthFlowEvent {
  const AuthVerifyRequested();
}

final class AuthResendRequested extends AuthFlowEvent {
  const AuthResendRequested();
}

final class AuthCooldownTicked extends AuthFlowEvent {
  const AuthCooldownTicked();
}

/// User confirmed local-wins override after conflict preview.
final class AuthSyncOverrideConfirmed extends AuthFlowEvent {
  const AuthSyncOverrideConfirmed();
}

/// User skipped sync after conflict preview — stay signed in, no overrides.
final class AuthSyncOverrideCancelled extends AuthFlowEvent {
  const AuthSyncOverrideCancelled();
}
