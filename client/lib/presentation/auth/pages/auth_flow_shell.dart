import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/presentation/auth/bloc/auth_flow_bloc.dart';

/// Keeps [AuthFlowBloc] alive while switching between phone and OTP routes.
class AuthFlowShell extends StatefulWidget {
  const AuthFlowShell({super.key, required this.services, required this.child});

  final AppServices services;
  final Widget child;

  @override
  State<AuthFlowShell> createState() => _AuthFlowShellState();
}

class _AuthFlowShellState extends State<AuthFlowShell> {
  late final AuthFlowBloc _bloc = AuthFlowBloc(
    requestOtp: widget.services.requestOtp,
    resendOtp: widget.services.resendOtp,
    verifyOtp: widget.services.verifyOtp,
    authRepository: widget.services.authRepository,
    syncCoordinator: widget.services.localSyncCoordinator,
    fcmRegistrationSync: widget.services.fcmRegistrationSync,
  );

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthFlowBloc>.value(value: _bloc, child: widget.child);
  }
}
