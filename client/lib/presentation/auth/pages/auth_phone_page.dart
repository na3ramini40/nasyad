import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/presentation/auth/auth_purpose.dart';
import 'package:nasyad/presentation/auth/bloc/auth_flow_bloc.dart';

class AuthPhonePage extends StatelessWidget {
  const AuthPhonePage({super.key});

  String _otpLocation(BuildContext context) {
    final purpose = GoRouterState.of(context).uri.queryParameters['purpose'];
    if (AuthPurpose.isResetLock(purpose)) {
      return '/auth/otp?purpose=${AuthPurpose.resetLock}';
    }
    return '/auth/otp';
  }

  String? _errorText(AppLocalizations l10n, AuthFlowState state) {
    if (state.status != AuthFlowStatus.failure) return null;
    return switch (state.errorMessage) {
      'invalid_phone' => l10n.authInvalidPhone,
      final msg? => msg,
      null => l10n.authGenericError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authSignInTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.dismiss,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: AppContent(
        child: BlocConsumer<AuthFlowBloc, AuthFlowState>(
          listenWhen: (previous, current) =>
              previous.step != current.step && current.step == AuthFlowStep.otp,
          listener: (context, state) {
            context.go(_otpLocation(context));
          },
          builder: (context, state) {
            final submitting = state.status == AuthFlowStatus.submitting;
            final resetLock = AuthPurpose.isResetLock(
              GoRouterState.of(context).uri.queryParameters['purpose'],
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  resetLock ? l10n.appLockForgotPhoneBody : l10n.authPhoneBody,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: l10n.authPhoneLabel,
                  hintText: l10n.authPhoneHint,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  errorText: _errorText(l10n, state),
                  enabled: !submitting,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+\s\-]')),
                  ],
                  onChanged: (value) {
                    context.read<AuthFlowBloc>().add(AuthPhoneChanged(value));
                  },
                  onSubmitted: (_) {
                    context.read<AuthFlowBloc>().add(
                      const AuthSendCodeRequested(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.authSendCode,
                  isLoading: submitting,
                  onPressed: submitting
                      ? null
                      : () {
                          context.read<AuthFlowBloc>().add(
                            const AuthSendCodeRequested(),
                          );
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
