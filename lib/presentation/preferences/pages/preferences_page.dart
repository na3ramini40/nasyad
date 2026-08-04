import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/locale_cubit.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/theme/theme_mode_cubit.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/core/version/app_version.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/l10n/app_localizations.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: l10n.back,
        ),
        title: Text(l10n.preferences),
      ),
      body: AppContent(
        child: ListView(
          children: [
            SectionHeader(title: l10n.language),
            Card(
              child: BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return RadioGroup<Locale>(
                    groupValue: locale,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<LocaleCubit>().setLocale(value);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<Locale>(
                          value: AppLocales.english,
                          title: Text(l10n.english),
                          secondary: const Icon(Icons.language),
                        ),
                        const Divider(height: 1),
                        RadioListTile<Locale>(
                          value: AppLocales.persian,
                          title: Text(l10n.persian),
                          secondary: const Icon(Icons.translate),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SectionHeader(title: l10n.calendarSystem),
            Card(
              child: BlocBuilder<CalendarSystemCubit, CalendarSystem>(
                builder: (context, calendar) {
                  return RadioGroup<CalendarSystem>(
                    groupValue: calendar,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<CalendarSystemCubit>().setCalendarSystem(
                          value,
                        );
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<CalendarSystem>(
                          value: CalendarSystem.gregorian,
                          title: Text(l10n.calendarGregorian),
                          subtitle: Text(l10n.calendarSystemHint),
                          secondary: const Icon(Icons.calendar_month_outlined),
                        ),
                        const Divider(height: 1),
                        RadioListTile<CalendarSystem>(
                          value: CalendarSystem.persian,
                          title: Text(l10n.calendarPersian),
                          secondary: const Icon(Icons.calendar_today_outlined),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SectionHeader(title: l10n.appearance),
            Card(
              child: BlocBuilder<ThemeModeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return RadioGroup<ThemeMode>(
                    groupValue: themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ThemeModeCubit>().setThemeMode(value);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.system,
                          title: Text(l10n.themeSystem),
                          secondary: const Icon(Icons.brightness_auto_outlined),
                        ),
                        const Divider(height: 1),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.light,
                          title: Text(l10n.themeLight),
                          secondary: const Icon(Icons.light_mode_outlined),
                        ),
                        const Divider(height: 1),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.dark,
                          title: Text(l10n.themeDark),
                          secondary: const Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SectionHeader(title: l10n.data),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(l10n.birthdays),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/birthdays'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.import_export_outlined),
                    title: Text(l10n.exportImport),
                    subtitle: Text(l10n.exportImportHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/preferences/transfer'),
                  ),
                ],
              ),
            ),
            SectionHeader(title: l10n.about),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const AppLogo.mark(height: 36),
                    title: Text(l10n.appTitle),
                    subtitle: Text(AppVersion.full),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.new_releases_outlined),
                    title: Text(l10n.whatsNew),
                    subtitle: Text(l10n.whatsNewHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showWhatsNewDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
