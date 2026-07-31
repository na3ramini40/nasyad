import 'package:flutter/material.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/app_button.dart';
import 'package:nasyad/core/ui/app_logo.dart';
import 'package:nasyad/core/version/app_changelog.dart';
import 'package:nasyad/core/version/app_version.dart';
import 'package:nasyad/core/version/semver.dart';
import 'package:nasyad/l10n/app_localizations.dart';

Future<void> showWhatsNewDialog(
  BuildContext context, {
  List<ChangelogEntry>? entries,
}) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).languageCode;
  final toShow = entries ?? AppChangelog.forPreferences();

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: const AppLogo.mark(height: 40),
        title: Text(l10n.whatsNew),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < toShow.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.appVersionLabel(toShow[i].version),
                    style: Theme.of(dialogContext).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final note in toShow[i].notesFor(locale))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•  ',
                            style: Theme.of(dialogContext).textTheme.bodyMedium,
                          ),
                          Expanded(
                            child: Text(
                              note,
                              style: Theme.of(
                                dialogContext,
                              ).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          AppButton(
            label: l10n.gotIt,
            expand: false,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      );
    },
  );
}

Future<bool> maybeShowWhatsNewOnLaunch(
  BuildContext context, {
  required Future<String?> Function() readLastSeen,
  required Future<void> Function(String version) writeLastSeen,
  String currentVersion = AppVersion.name,
}) async {
  final lastSeen = await readLastSeen();
  final decision = decideWhatsNew(lastSeen: lastSeen, current: currentVersion);

  switch (decision) {
    case WhatsNewDecision.skipFirstInstall:
      await writeLastSeen(currentVersion);
      return false;
    case WhatsNewDecision.alreadySeen:
      return false;
    case WhatsNewDecision.showUpdate:
      if (!context.mounted) return false;
      final entries = AppChangelog.entriesSince(lastSeen);
      await showWhatsNewDialog(context, entries: entries);
      await writeLastSeen(currentVersion);
      return true;
  }
}
