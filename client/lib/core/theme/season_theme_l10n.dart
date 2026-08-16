import 'package:flutter/material.dart';
import 'package:nasyad/domain/entities/season_theme.dart';
import 'package:nasyad/l10n/app_localizations.dart';

extension SeasonThemeL10n on SeasonTheme {
  String label(AppLocalizations l10n) {
    return switch (this) {
      SeasonTheme.classic => l10n.seasonClassic,
      SeasonTheme.spring => l10n.seasonSpring,
      SeasonTheme.summer => l10n.seasonSummer,
      SeasonTheme.autumn => l10n.seasonAutumn,
      SeasonTheme.winter => l10n.seasonWinter,
      SeasonTheme.colorBlind => l10n.seasonColorBlind,
    };
  }

  IconData get icon {
    return switch (this) {
      SeasonTheme.classic => Icons.palette_outlined,
      SeasonTheme.spring => Icons.local_florist_outlined,
      SeasonTheme.summer => Icons.wb_sunny_outlined,
      SeasonTheme.autumn => Icons.park_outlined,
      SeasonTheme.winter => Icons.ac_unit_outlined,
      SeasonTheme.colorBlind => Icons.visibility_outlined,
    };
  }
}
