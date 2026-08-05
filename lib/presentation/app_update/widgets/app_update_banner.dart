import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_update/bloc/app_update_bloc.dart';
import 'package:nasyad/presentation/app_update/widgets/app_update_dialog.dart';

class AppUpdateBanner extends StatelessWidget {
  const AppUpdateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<AppUpdateBloc, AppUpdateState>(
      buildWhen: (previous, current) =>
          current is AppUpdateAvailable && current.showBanner,
      builder: (context, state) {
        if (state is! AppUpdateAvailable || !state.showBanner) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Material(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
            borderRadius: AppRadius.borderMd,
            child: InkWell(
              borderRadius: AppRadius.borderMd,
              onTap: () => showAppUpdateDialog(context, release: state.release),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.system_update_alt_outlined,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.updateBannerMessage(state.release.version.name),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: l10n.dismiss,
                      onPressed: () => context.read<AppUpdateBloc>().add(
                        const AppUpdateBannerDismissed(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
