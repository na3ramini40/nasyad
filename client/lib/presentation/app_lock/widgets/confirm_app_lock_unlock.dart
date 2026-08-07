import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/lock_method.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';

/// Prompts for the current unlock before change/disable.
Future<bool> confirmAppLockUnlock(BuildContext context) async {
  final cubit = context.read<AppLockCubit>();
  final method = cubit.state.method;
  if (method == null) return true;

  if (method == LockMethod.biometric) {
    final l10n = AppLocalizations.of(context);
    return cubit.verifyCurrent(biometricReason: l10n.appLockBiometricPrompt);
  }

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: const _VerifySecretSheet(),
        ),
      );
    },
  );
  return result ?? false;
}

class _VerifySecretSheet extends StatefulWidget {
  const _VerifySecretSheet();

  @override
  State<_VerifySecretSheet> createState() => _VerifySecretSheetState();
}

class _VerifySecretSheetState extends State<_VerifySecretSheet> {
  final _controller = TextEditingController();
  var _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final method = context.read<AppLockCubit>().state.method;
    final isPin = method == LockMethod.pin;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: BlocBuilder<AppLockCubit, AppLockState>(
          builder: (context, state) {
            final error = switch (state.error) {
              AppLockError.wrongSecret => l10n.appLockWrongSecret,
              _ => null,
            };
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.appLockVerifyToContinue,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _controller,
                  label: isPin
                      ? l10n.appLockPinLabel
                      : l10n.appLockPasswordLabel,
                  obscureText: _obscure,
                  keyboardType: isPin
                      ? TextInputType.number
                      : TextInputType.visiblePassword,
                  inputFormatters: isPin
                      ? [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ]
                      : null,
                  errorText: error,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(label: l10n.appLockUnlock, onPressed: _submit),
                const SizedBox(height: AppSpacing.sm),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final ok = await context.read<AppLockCubit>().verifyCurrent(
      secret: _controller.text,
    );
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
