import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/app_button.dart';
import 'package:nasyad/domain/entities/app_release.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_update/bloc/app_update_bloc.dart';

Future<void> showAppUpdateDialog(
  BuildContext context, {
  required AppRelease release,
  bool downloading = false,
  double? progress,
  bool readyToInstall = false,
  String? errorMessage,
}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: !downloading,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<AppUpdateBloc>(),
        child: BlocConsumer<AppUpdateBloc, AppUpdateState>(
          listener: (context, state) {
            if (state is AppUpdateUpToDate ||
                state is AppUpdateUnsupported ||
                (state is AppUpdateError && state.manual)) {
              // Keep dialog open for manual flows; caller handles snackbars.
            }
          },
          builder: (context, state) {
            final activeRelease = switch (state) {
              AppUpdateAvailable(:final release) => release,
              AppUpdateDownloading(:final release) => release,
              AppUpdateReadyToInstall(:final release) => release,
              AppUpdateError(:final release) when release != null => release,
              _ => release,
            };

            final isDownloading = state is AppUpdateDownloading;
            final fraction = state is AppUpdateDownloading
                ? state.progress.fraction
                : progress;
            final isReady = state is AppUpdateReadyToInstall || readyToInstall;
            final error = state is AppUpdateError
                ? state.message
                : errorMessage;

            return AlertDialog(
              title: Text(l10n.updateAvailableTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.updateAvailableBody(
                        activeRelease.version.name,
                        _formatSize(l10n, activeRelease.sizeBytes),
                      ),
                    ),
                    if (activeRelease.releaseNotes?.trim().isNotEmpty ??
                        false) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.updateReleaseNotes,
                        style: Theme.of(dialogContext).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        activeRelease.releaseNotes!.trim(),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isDownloading && fraction != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      LinearProgressIndicator(value: fraction),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.updateDownloadProgress((fraction * 100).round()),
                      ),
                    ],
                    if (isReady) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.updateReadyToInstall),
                    ],
                    if (error != null && error.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (!isDownloading)
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.cancel),
                  ),
                if (isReady)
                  AppButton(
                    label: l10n.updateInstall,
                    expand: false,
                    onPressed: () {
                      context.read<AppUpdateBloc>().add(
                        const AppUpdateInstallRequested(),
                      );
                    },
                  )
                else if (!isDownloading)
                  AppButton(
                    label: l10n.updateDownload,
                    expand: false,
                    onPressed: () {
                      context.read<AppUpdateBloc>().add(
                        const AppUpdateDownloadRequested(),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      );
    },
  );
}

String _formatSize(AppLocalizations l10n, int bytes) {
  if (bytes < 1024 * 1024) {
    return l10n.updateSizeKb((bytes / 1024).ceil());
  }
  return l10n.updateSizeMb((bytes / (1024 * 1024)).toStringAsFixed(1));
}
