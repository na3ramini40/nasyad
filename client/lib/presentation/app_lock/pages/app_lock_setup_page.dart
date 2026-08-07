import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/lock_method.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';

/// Create or change password/PIN. [method] must be password or pin.
class AppLockSetupPage extends StatefulWidget {
  const AppLockSetupPage({super.key, required this.method});

  final LockMethod method;

  @override
  State<AppLockSetupPage> createState() => _AppLockSetupPageState();
}

class _AppLockSetupPageState extends State<AppLockSetupPage> {
  final _secret = TextEditingController();
  final _confirm = TextEditingController();
  var _obscure = true;

  @override
  void dispose() {
    _secret.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _isPin => widget.method == LockMethod.pin;

  String? _errorText(AppLocalizations l10n, AppLockState state) {
    return switch (state.error) {
      AppLockError.mismatch => l10n.appLockMismatch,
      AppLockError.tooShort =>
        _isPin ? l10n.appLockPinTooShort : l10n.appLockPasswordTooShort,
      AppLockError.wrongSecret => l10n.appLockWrongSecret,
      _ => null,
    };
  }

  Future<void> _submit() async {
    final cubit = context.read<AppLockCubit>();
    final ok = _isPin
        ? await cubit.enablePin(pin: _secret.text, confirm: _confirm.text)
        : await cubit.enablePassword(
            password: _secret.text,
            confirm: _confirm.text,
          );
    if (ok && mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isPin ? l10n.appLockCreatePin : l10n.appLockCreatePassword,
        ),
      ),
      body: AppContent(
        child: BlocBuilder<AppLockCubit, AppLockState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _secret,
                  label: _isPin
                      ? l10n.appLockPinLabel
                      : l10n.appLockPasswordLabel,
                  hintText: _isPin
                      ? l10n.appLockPinHint
                      : l10n.appLockPasswordHint,
                  obscureText: _obscure,
                  keyboardType: _isPin
                      ? TextInputType.number
                      : TextInputType.visiblePassword,
                  inputFormatters: _isPin
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
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirm,
                  label: l10n.appLockConfirmLabel,
                  hintText: l10n.appLockConfirmHint,
                  obscureText: _obscure,
                  keyboardType: _isPin
                      ? TextInputType.number
                      : TextInputType.visiblePassword,
                  inputFormatters: _isPin
                      ? [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ]
                      : null,
                  errorText: _errorText(l10n, state),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: l10n.save, onPressed: _submit),
              ],
            );
          },
        ),
      ),
    );
  }
}
