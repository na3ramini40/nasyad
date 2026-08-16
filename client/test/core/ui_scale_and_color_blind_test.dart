import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/core/theme/app_status_colors.dart';
import 'package:nasyad/core/theme/app_theme.dart';
import 'package:nasyad/core/theme/season_theme_palette.dart';
import 'package:nasyad/core/theme/ui_scale.dart';
import 'package:nasyad/core/theme/ui_scale_cubit.dart';
import 'package:nasyad/core/theme/ui_scale_preference_store.dart';
import 'package:nasyad/domain/entities/season_theme.dart';

void main() {
  group('UiScalePreferenceStore', () {
    test('round-trips and clamps', () async {
      final store = UiScalePreferenceStore.memory();
      expect(await store.read(), UiScale.defaultValue);

      await store.write(1.2);
      expect(await store.read(), 1.2);

      await store.write(0.5);
      expect(await store.read(), UiScale.min);

      await store.write(2.0);
      expect(await store.read(), UiScale.max);

      final seeded = UiScalePreferenceStore.memory(initial: 1.3);
      expect(await seeded.read(), 1.3);
    });
  });

  group('UiScaleCubit', () {
    test('setScale emits and persists', () async {
      final store = UiScalePreferenceStore.memory();
      final cubit = UiScaleCubit(store: store);
      await cubit.setScale(1.25);
      expect(cubit.state, 1.25);
      expect(await store.read(), 1.25);

      await cubit.setScale(0.1);
      expect(cubit.state, UiScale.min);

      await cubit.reset();
      expect(cubit.state, UiScale.defaultValue);
      expect(await store.read(), UiScale.defaultValue);

      await cubit.close();
    });
  });

  group('SeasonTheme.colorBlind', () {
    test('storage round-trip', () {
      expect(
        SeasonTheme.fromStorage(SeasonTheme.colorBlind.storageValue),
        SeasonTheme.colorBlind,
      );
      expect(SeasonTheme.selectable, contains(SeasonTheme.colorBlind));
    });

    test('AppTheme light and dark for colorBlind', () {
      expect(
        AppTheme.lightTheme(season: SeasonTheme.colorBlind).brightness,
        Brightness.light,
      );
      expect(
        AppTheme.darkTheme(season: SeasonTheme.colorBlind).brightness,
        Brightness.dark,
      );
    });

    test(
      'palette status success differs from warning and classic green/red',
      () {
        final light = SeasonThemePalette.forSeason(
          SeasonTheme.colorBlind,
          Brightness.light,
        );
        final dark = SeasonThemePalette.forSeason(
          SeasonTheme.colorBlind,
          Brightness.dark,
        );

        expect(light.statusColors.success, isNot(light.statusColors.warning));
        expect(dark.statusColors.success, isNot(dark.statusColors.warning));

        expect(
          light.statusColors.success,
          isNot(AppStatusColors.light.success),
        );
        expect(
          light.statusColors.warning,
          isNot(AppStatusColors.light.warning),
        );

        expect(
          SeasonThemePalette.forSeason(SeasonTheme.colorBlind, Brightness.dark),
          isNot(
            SeasonThemePalette.forSeason(SeasonTheme.winter, Brightness.dark),
          ),
        );
      },
    );
  });
}
