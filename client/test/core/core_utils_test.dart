import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/l10n/locale_cubit.dart';
import 'package:nasyad/core/theme/app_breakpoints.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/theme/season_theme_cubit.dart';
import 'package:nasyad/core/theme/season_theme_preference_store.dart';
import 'package:nasyad/core/theme/theme_mode_cubit.dart';
import 'package:nasyad/core/theme/theme_mode_preference_store.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/season_theme.dart';

void main() {
  group('LocaleCubit', () {
    test('starts with english by default and toggles', () {
      final cubit = LocaleCubit();
      expect(cubit.state, AppLocales.english);
      expect(cubit.isPersian, isFalse);

      cubit.toggle();
      expect(cubit.state, AppLocales.persian);
      expect(cubit.isPersian, isTrue);

      cubit.setLocale(const Locale('de'));
      expect(cubit.state, AppLocales.persian);
      cubit.close();
    });

    test('AppLocales.resolve uses device locale when supported', () {
      expect(
        AppLocales.resolve(const Locale('fa'), AppLocales.supported),
        AppLocales.persian,
      );
      expect(
        AppLocales.resolve(const Locale('de'), AppLocales.supported),
        AppLocales.english,
      );
      expect(
        AppLocales.resolve(null, AppLocales.supported),
        AppLocales.english,
      );
    });
  });

  group('ThemeModeCubit', () {
    test('updates theme mode and ignores duplicates', () async {
      final cubit = ThemeModeCubit(store: ThemeModePreferenceStore.memory());
      expect(cubit.state, ThemeMode.system);
      await cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
      await cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
      await cubit.close();
    });
  });

  group('SeasonThemeCubit', () {
    test('updates season theme and ignores duplicates', () async {
      final cubit = SeasonThemeCubit(
        store: SeasonThemePreferenceStore.memory(),
      );
      expect(cubit.state, SeasonTheme.classic);
      await cubit.setSeasonTheme(SeasonTheme.winter);
      expect(cubit.state, SeasonTheme.winter);
      await cubit.setSeasonTheme(SeasonTheme.winter);
      expect(cubit.state, SeasonTheme.winter);
      await cubit.close();
    });
  });

  group('AppBreakpoints', () {
    test('maps width buckets and grid helpers', () {
      expect(AppBreakpoints.ofWidth(320), AppWindowSize.compact);
      expect(AppBreakpoints.ofWidth(800), AppWindowSize.medium);
      expect(AppBreakpoints.ofWidth(1200), AppWindowSize.expanded);
      expect(AppBreakpoints.ofWidth(1600), AppWindowSize.large);

      expect(AppBreakpoints.deviceGridColumns(AppWindowSize.compact), 1);
      expect(AppBreakpoints.deviceGridColumns(AppWindowSize.large), 4);
      expect(AppBreakpoints.contentMaxWidth(AppWindowSize.medium), 840);
      expect(AppBreakpoints.pagePadding(AppWindowSize.expanded), 32);
    });
  });

  group('tokens', () {
    test('spacing and radius constants are stable', () {
      expect(AppSpacing.md, 16);
      expect(AppSpacing.minTapTarget, 48);
      expect(AppRadius.md, 12);
      expect(AppRadius.borderMd.topLeft.x, 12);
    });
  });

  group('IdGenerator', () {
    test('produces unique non-empty ids', () {
      final a = IdGenerator.newId();
      final b = IdGenerator.newId();
      expect(a, isNotEmpty);
      expect(b, isNotEmpty);
      expect(a, isNot(b));
    });
  });
}
