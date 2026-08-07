import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/theme/app_fonts.dart';
import 'package:nasyad/core/theme/app_status_colors.dart';
import 'package:nasyad/core/theme/app_theme.dart';
import 'package:nasyad/core/theme/season_theme_palette.dart';
import 'package:nasyad/domain/entities/season_theme.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/device/schedule_presets.dart';

void main() {
  test('AppStatusColors copyWith and lerp', () {
    final updated = AppStatusColors.light.copyWith(muted: Colors.grey);
    expect(updated.muted, Colors.grey);
    expect(updated.success, AppStatusColors.light.success);

    final lerped = AppStatusColors.light.lerp(AppStatusColors.dark, 0.5);
    expect(lerped.success, isNot(AppStatusColors.light.success));
  });

  testWidgets('schedule display name', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      scheduleDisplayName(l10n: l10n, value: 3, unitStorage: 'months'),
      contains('3'),
    );
    expect(
      scheduleDisplayName(l10n: l10n, value: 1, unitStorage: 'hours'),
      contains('1'),
    );
  });

  test('AppTheme exposes light and dark for each season', () {
    for (final season in SeasonTheme.selectable) {
      expect(AppTheme.lightTheme(season: season).brightness, Brightness.light);
      expect(AppTheme.darkTheme(season: season).brightness, Brightness.dark);
    }
  });

  test('SeasonTheme round-trips storage', () {
    for (final season in SeasonTheme.selectable) {
      expect(SeasonTheme.fromStorage(season.storageValue), season);
    }
    expect(SeasonTheme.fromStorage(null), SeasonTheme.classic);
    expect(SeasonTheme.fromStorage('unknown'), SeasonTheme.classic);
  });

  test('SeasonThemePalette differs between seasons', () {
    final spring = SeasonThemePalette.forSeason(
      SeasonTheme.spring,
      Brightness.light,
    );
    final winter = SeasonThemePalette.forSeason(
      SeasonTheme.winter,
      Brightness.light,
    );
    expect(spring.primary, isNot(winter.primary));
  });

  test('Persian locale uses Vazir font family', () {
    final theme = AppTheme.lightTheme(
      fontFamily: AppFonts.familyForLocale(const Locale('fa')),
    );
    expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.vazir);
    expect(AppFonts.familyForLocale(const Locale('en')), isNull);
  });
}
