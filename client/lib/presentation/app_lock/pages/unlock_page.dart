import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/lock_method.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';

/// Full-screen unlock gate. Main UI underneath is not interactable.
class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final _controller = TextEditingController();
  var _obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AppLockCubit>();
      if (cubit.state.method == LockMethod.biometric) {
        _tryBiometric();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final l10n = AppLocalizations.of(context);
    await context.read<AppLockCubit>().unlockWithBiometric(
      localizedReason: l10n.appLockBiometricPrompt,
    );
  }

  String? _errorText(AppLocalizations l10n, AppLockState state) {
    return switch (state.error) {
      AppLockError.wrongSecret => l10n.appLockWrongSecret,
      AppLockError.biometricFailed => l10n.appLockBiometricFailed,
      AppLockError.biometricUnavailable => l10n.appLockBiometricUnavailable,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: AppContent(
          child: BlocBuilder<AppLockCubit, AppLockState>(
            builder: (context, state) {
              final method = state.method;
              final busy = state.authenticating;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.appLockUnlockTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (method == LockMethod.biometric) ...[
                    AppButton(
                      label: l10n.appLockUseBiometric,
                      icon: Icons.fingerprint,
                      isLoading: busy,
                      onPressed: busy ? null : _tryBiometric,
                    ),
                    if (_errorText(l10n, state) != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _errorText(l10n, state)!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ] else ...[
                    AppTextField(
                      controller: _controller,
                      label: method == LockMethod.pin
                          ? l10n.appLockPinLabel
                          : l10n.appLockPasswordLabel,
                      hintText: method == LockMethod.pin
                          ? l10n.appLockPinHint
                          : l10n.appLockPasswordHint,
                      obscureText: _obscure,
                      keyboardType: method == LockMethod.pin
                          ? TextInputType.number
                          : TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !busy,
                      errorText: _errorText(l10n, state),
                      inputFormatters: method == LockMethod.pin
                          ? [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ]
                          : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l10n.appLockUnlock,
                      isLoading: busy,
                      onPressed: busy ? null : _submit,
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.push('/auth/phone?purpose=reset_lock');
                    },
                    child: Text(l10n.appLockForgot),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await context.read<AppLockCubit>().unlockWithSecret(_controller.text);
  }
}
