import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/domain/entities/lock_idle_timeout.dart';
import 'package:nasyad/domain/entities/lock_method.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';
import 'package:nasyad/presentation/app_lock/widgets/confirm_app_lock_unlock.dart';

String appLockMethodLabel(AppLocalizations l10n, LockMethod? method) {
  return switch (method) {
    null => l10n.appLockMethodOff,
    LockMethod.password => l10n.appLockMethodPassword,
    LockMethod.pin => l10n.appLockMethodPin,
    LockMethod.biometric => l10n.appLockMethodBiometric,
  };
}

String appLockTimeoutLabel(AppLocalizations l10n, LockIdleTimeout timeout) {
  return switch (timeout) {
    LockIdleTimeout.immediate => l10n.appLockTimeoutImmediate,
    LockIdleTimeout.oneMinute => l10n.appLockTimeoutOneMinute,
    LockIdleTimeout.fiveMinutes => l10n.appLockTimeoutFiveMinutes,
    LockIdleTimeout.fifteenMinutes => l10n.appLockTimeoutFifteenMinutes,
    LockIdleTimeout.thirtyMinutes => l10n.appLockTimeoutThirtyMinutes,
    LockIdleTimeout.oneHour => l10n.appLockTimeoutOneHour,
  };
}

/// App lock controls for the Preferences expandable section.
class AppLockPreferencesSection extends StatelessWidget {
  const AppLockPreferencesSection({super.key});

  Future<void> _selectMethod(BuildContext context, LockMethod? next) async {
    final cubit = context.read<AppLockCubit>();
    final current = cubit.state.method;
    final l10n = AppLocalizations.of(context);

    if (next == current) return;

    if (current != null) {
      final verified = await confirmAppLockUnlock(context);
      if (!verified || !context.mounted) return;
    }

    if (next == null) {
      await cubit.disable(alreadyVerified: true);
      return;
    }

    if (next == LockMethod.biometric) {
      await cubit.enableBiometric(localizedReason: l10n.appLockBiometricPrompt);
      return;
    }

    if (!context.mounted) return;
    await context.push<bool>(
      '/preferences/app-lock/setup?method=${next.storageValue}',
    );
  }

  Future<void> _selectTimeout(
    BuildContext context,
    LockIdleTimeout timeout,
  ) async {
    await context.read<AppLockCubit>().setTimeout(timeout);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        final method = state.method;
        return Column(
          children: [
            RadioGroup<LockMethod?>(
              groupValue: method,
              onChanged: (value) => _selectMethod(context, value),
              child: Column(
                children: [
                  RadioListTile<LockMethod?>(
                    value: null,
                    title: Text(l10n.appLockMethodOff),
                    secondary: const Icon(Icons.lock_open_outlined),
                  ),
                  const Divider(height: 1),
                  RadioListTile<LockMethod?>(
                    value: LockMethod.password,
                    title: Text(l10n.appLockMethodPassword),
                    secondary: const Icon(Icons.password_outlined),
                  ),
                  const Divider(height: 1),
                  RadioListTile<LockMethod?>(
                    value: LockMethod.pin,
                    title: Text(l10n.appLockMethodPin),
                    secondary: const Icon(Icons.pin_outlined),
                  ),
                  if (state.biometricAvailable) ...[
                    const Divider(height: 1),
                    RadioListTile<LockMethod?>(
                      value: LockMethod.biometric,
                      title: Text(l10n.appLockMethodBiometric),
                      secondary: const Icon(Icons.fingerprint),
                    ),
                  ],
                ],
              ),
            ),
            if (method != null) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.appLockTimeout),
                subtitle: Text(appLockTimeoutLabel(l10n, state.timeout)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickTimeout(context, state.timeout),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: Text(l10n.appLockForgot),
                onTap: () => context.push('/auth/phone?purpose=reset_lock'),
              ),
            ],
            if (state.error == AppLockError.biometricUnavailable ||
                state.error == AppLockError.biometricFailed)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.error == AppLockError.biometricUnavailable
                      ? l10n.appLockBiometricUnavailable
                      : l10n.appLockBiometricFailed,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickTimeout(
    BuildContext context,
    LockIdleTimeout current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<LockIdleTimeout>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final timeout in LockIdleTimeout.values)
                ListTile(
                  title: Text(appLockTimeoutLabel(l10n, timeout)),
                  trailing: timeout == current ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(sheetContext, timeout),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null && context.mounted) {
      await _selectTimeout(context, picked);
    }
  }
}
