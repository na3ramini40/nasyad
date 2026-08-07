import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  Future<void> _continueOffline(BuildContext context) async {
    final services = AppServicesScope.of(context);
    await services.completeIntro();
    if (context.mounted) context.go('/');
  }

  Future<void> _signIn(BuildContext context) async {
    final services = AppServicesScope.of(context);
    await services.completeIntro();
    if (context.mounted) context.go('/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: AppContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const AppLogo(height: 64, variant: AppLogoVariant.wordmark),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.introTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.introBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: l10n.introSignInWithPhone,
                icon: Icons.phone_android_outlined,
                onPressed: () => _signIn(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.introContinueOffline,
                variant: AppButtonVariant.secondary,
                onPressed: () => _continueOffline(context),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
