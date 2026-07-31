import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/theme/app_fonts.dart';
import 'package:nasyad/core/theme/app_status_colors.dart';
import 'package:nasyad/core/theme/app_theme.dart';
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

  testWidgets('schedule presets and display name', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final suggestions = scheduleSuggestions(l10n);
    expect(suggestions, hasLength(4));
    expect(suggestions.first.intervalValue, 3);

    expect(
      scheduleDisplayName(l10n: l10n, value: 3, unitStorage: 'months'),
      contains('3'),
    );
    expect(
      scheduleDisplayName(l10n: l10n, value: 1, unitStorage: 'hours'),
      contains('1'),
    );
  });

  test('AppTheme exposes light and dark', () {
    expect(AppTheme.lightTheme().brightness, Brightness.light);
    expect(AppTheme.darkTheme().brightness, Brightness.dark);
  });

  test('Persian locale uses Vazir font family', () {
    final theme = AppTheme.lightTheme(
      fontFamily: AppFonts.familyForLocale(const Locale('fa')),
    );
    expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.vazir);
    expect(
      AppFonts.familyForLocale(const Locale('en')),
      isNull,
    );
  });
}
