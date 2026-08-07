import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';
import 'package:nasyad/presentation/auth/auth_purpose.dart';
import 'package:nasyad/presentation/auth/bloc/auth_flow_bloc.dart';

class AuthOtpPage extends StatelessWidget {
  const AuthOtpPage({super.key});

  bool _isResetLock(BuildContext context) {
    return AuthPurpose.isResetLock(
      GoRouterState.of(context).uri.queryParameters['purpose'],
    );
  }

  String? _errorText(AppLocalizations l10n, AuthFlowState state) {
    if (state.status != AuthFlowStatus.failure) return null;
    return switch (state.errorMessage) {
      'invalid_code' => l10n.authInvalidCode,
      'invalid_phone' => l10n.authInvalidPhone,
      final msg? => msg,
      null => l10n.authGenericError,
    };
  }

  Future<void> _showConflictDialog(
    BuildContext context,
    AuthFlowState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.authSyncConflictTitle),
          content: Text(l10n.authSyncConflictBody(state.syncConflictTotal)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.authSyncConflictCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.authSyncConflictConfirm),
            ),
          ],
        );
      },
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      context.read<AuthFlowBloc>().add(const AuthSyncOverrideConfirmed());
    } else {
      context.read<AuthFlowBloc>().add(const AuthSyncOverrideCancelled());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authOtpTitle)),
      body: AppContent(
        child: BlocConsumer<AuthFlowBloc, AuthFlowState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) async {
            if (state.status == AuthFlowStatus.awaitingSyncConfirm) {
              await _showConflictDialog(context, state);
              return;
            }
            if (state.status != AuthFlowStatus.success) return;
            if (_isResetLock(context)) {
              await context.read<AppLockCubit>().clearAfterForgot();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.appLockResetSuccess)));
              context.go('/');
              return;
            }
            if (state.syncFailed) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.authSyncFailed)));
            } else if (state.syncCancelled) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.authSyncCancelled)));
            }
            context.go('/');
          },
          builder: (context, state) {
            final busy =
                state.status == AuthFlowStatus.submitting ||
                state.status == AuthFlowStatus.syncing ||
                state.status == AuthFlowStatus.awaitingSyncConfirm;
            final phone = state.normalizedPhone ?? state.phone;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.authOtpBody(phone),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (state.status == AuthFlowStatus.syncing) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.authSyncing,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (state.status == AuthFlowStatus.awaitingSyncConfirm) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.authSyncConflictBody(state.syncConflictTotal),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: l10n.authOtpLabel,
                  hintText: l10n.authOtpHint,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 8,
                  errorText: _errorText(l10n, state),
                  enabled: !busy,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    context.read<AuthFlowBloc>().add(AuthCodeChanged(value));
                  },
                  onSubmitted: (_) {
                    context.read<AuthFlowBloc>().add(
                      const AuthVerifyRequested(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.authVerify,
                  isLoading: busy,
                  onPressed: busy
                      ? null
                      : () {
                          context.read<AuthFlowBloc>().add(
                            const AuthVerifyRequested(),
                          );
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: state.canResend
                      ? l10n.authResendCode
                      : l10n.authResendCooldown(state.cooldownSeconds),
                  variant: AppButtonVariant.secondary,
                  onPressed: !state.canResend || busy
                      ? null
                      : () {
                          context.read<AuthFlowBloc>().add(
                            const AuthResendRequested(),
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
