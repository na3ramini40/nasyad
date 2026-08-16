import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/locale_cubit.dart';
import 'package:nasyad/core/notifications/reminder_notification_cubit.dart';
import 'package:nasyad/core/notifications/reminder_notification_preference_store.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/preferences/soon_window_cubit.dart';
import 'package:nasyad/core/preferences/sync_preference_cubit.dart';
import 'package:nasyad/core/sync/network_status_reader.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/theme/season_theme_cubit.dart';
import 'package:nasyad/core/theme/season_theme_l10n.dart';
import 'package:nasyad/core/theme/theme_mode_cubit.dart';
import 'package:nasyad/core/theme/ui_scale.dart';
import 'package:nasyad/core/theme/ui_scale_cubit.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/core/version/app_version.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/season_theme.dart';
import 'package:nasyad/data/services/local_reminder_notification_service.dart';
import 'package:nasyad/domain/entities/soon_window_days.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';
import 'package:nasyad/presentation/app_lock/widgets/app_lock_preferences_section.dart';
import 'package:nasyad/presentation/app_update/bloc/app_update_bloc.dart';
import 'package:nasyad/presentation/app_update/widgets/app_update_dialog.dart';
import 'package:nasyad/presentation/preferences/widgets/preferences_expandable_section.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  String _updateStatusSubtitle(AppLocalizations l10n, AppUpdateState state) {
    return switch (state) {
      AppUpdateChecking() => l10n.updateChecking,
      AppUpdateUpToDate() => l10n.updateUpToDate,
      AppUpdateUnsupported() => l10n.updateUnsupportedPlatform,
      AppUpdateAvailable(:final release) => l10n.updateBannerMessage(
        release.version.name,
      ),
      AppUpdateDownloading(:final progress) => l10n.updateDownloadProgress(
        (progress.fraction * 100).round(),
      ),
      AppUpdateReadyToInstall() => l10n.updateReadyToInstall,
      AppUpdateError() => l10n.updateErrorOffline,
      _ => l10n.checkForUpdatesHint,
    };
  }

  void _onUpdateState(BuildContext context, AppUpdateState state) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    switch (state) {
      case AppUpdateUpToDate(:final manual) when manual:
        messenger.showSnackBar(SnackBar(content: Text(l10n.updateUpToDate)));
      case AppUpdateUnsupported(:final manual) when manual:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.updateUnsupportedPlatform)),
        );
      case AppUpdateError(:final manual, :final message) when manual:
        messenger.showSnackBar(SnackBar(content: Text(message)));
      case AppUpdateAvailable(:final release, :final manual) when manual:
        showAppUpdateDialog(context, release: release);
      default:
        break;
    }
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    ReminderNotificationPreferences preferences,
  ) async {
    final initial = TimeOfDay(
      hour: preferences.hour,
      minute: preferences.minute,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !context.mounted) return;
    await context.read<ReminderNotificationCubit>().setTime(
      hour: picked.hour,
      minute: picked.minute,
    );
  }

  String _formatReminderTime(BuildContext context, int hour, int minute) {
    final date = DateTime(2024, 1, 1, hour, minute);
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final services = AppServicesScope.of(context);

    return BlocListener<AppUpdateBloc, AppUpdateState>(
      listenWhen: (previous, current) =>
          current is AppUpdateUpToDate ||
          current is AppUpdateUnsupported ||
          current is AppUpdateError ||
          (current is AppUpdateAvailable && current.manual),
      listener: _onUpdateState,
      child: Scaffold(
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
              BlocBuilder<AppLockCubit, AppLockState>(
                builder: (context, lockState) {
                  return PreferencesExpandableSection(
                    title: l10n.appLockSection,
                    leading: const Icon(Icons.lock_outline),
                    subtitle: appLockMethodLabel(l10n, lockState.method),
                    initiallyExpanded: false,
                    children: const [AppLockPreferencesSection()],
                  );
                },
              ),
              PreferencesExpandableSection(
                title: l10n.languageAndRegion,
                leading: const Icon(Icons.language),
                children: [
                  BlocBuilder<LocaleCubit, Locale>(
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
                  BlocBuilder<CalendarSystemCubit, CalendarSystem>(
                    builder: (context, calendar) {
                      return RadioGroup<CalendarSystem>(
                        groupValue: calendar,
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<CalendarSystemCubit>()
                                .setCalendarSystem(value);
                          }
                        },
                        child: Column(
                          children: [
                            RadioListTile<CalendarSystem>(
                              value: CalendarSystem.gregorian,
                              title: Text(l10n.calendarGregorian),
                              subtitle: Text(l10n.calendarSystemHint),
                              secondary: const Icon(
                                Icons.calendar_month_outlined,
                              ),
                            ),
                            const Divider(height: 1),
                            RadioListTile<CalendarSystem>(
                              value: CalendarSystem.persian,
                              title: Text(l10n.calendarPersian),
                              secondary: const Icon(
                                Icons.calendar_today_outlined,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              PreferencesExpandableSection(
                title: l10n.remindersSection,
                leading: const Icon(Icons.notifications_outlined),
                children: [
                  BlocBuilder<SoonWindowCubit, SoonWindowDays>(
                    builder: (context, soonWindow) {
                      return RadioGroup<SoonWindowDays>(
                        groupValue: soonWindow,
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SoonWindowCubit>().setSoonWindow(
                              value,
                            );
                          }
                        },
                        child: Column(
                          children: [
                            RadioListTile<SoonWindowDays>(
                              value: SoonWindowDays.seven,
                              title: Text(l10n.soonWindowSevenDays),
                              subtitle: Text(l10n.soonWindowHint),
                              secondary: const Icon(
                                Icons.notifications_outlined,
                              ),
                            ),
                            const Divider(height: 1),
                            RadioListTile<SoonWindowDays>(
                              value: SoonWindowDays.fourteen,
                              title: Text(l10n.soonWindowFourteenDays),
                              secondary: const Icon(Icons.schedule_outlined),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (LocalReminderNotificationService.isSupported)
                    BlocBuilder<
                      ReminderNotificationCubit,
                      ReminderNotificationPreferences
                    >(
                      builder: (context, preferences) {
                        return Column(
                          children: [
                            SwitchListTile(
                              secondary: const Icon(
                                Icons.notifications_outlined,
                              ),
                              title: Text(l10n.reminderNotificationsEnabled),
                              subtitle: Text(l10n.reminderNotificationsHint),
                              value: preferences.enabled,
                              onChanged: (value) => context
                                  .read<ReminderNotificationCubit>()
                                  .setEnabled(value),
                            ),
                            if (preferences.enabled) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.schedule_outlined),
                                title: Text(l10n.reminderNotificationTime),
                                subtitle: Text(
                                  l10n.reminderNotificationTimeHint,
                                ),
                                trailing: Text(
                                  _formatReminderTime(
                                    context,
                                    preferences.hour,
                                    preferences.minute,
                                  ),
                                ),
                                onTap: () =>
                                    _pickReminderTime(context, preferences),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                ],
              ),
              PreferencesExpandableSection(
                title: l10n.appearance,
                leading: const Icon(Icons.palette_outlined),
                children: [
                  BlocBuilder<SeasonThemeCubit, SeasonTheme>(
                    builder: (context, seasonTheme) {
                      final previewBrightness = Theme.of(context).brightness;
                      return RadioGroup<SeasonTheme>(
                        groupValue: seasonTheme,
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SeasonThemeCubit>().setSeasonTheme(
                              value,
                            );
                          }
                        },
                        child: Column(
                          children: [
                            for (final (index, season)
                                in SeasonTheme.selectable.indexed) ...[
                              if (index > 0) const Divider(height: 1),
                              RadioListTile<SeasonTheme>(
                                value: season,
                                title: Row(
                                  children: [
                                    Expanded(child: Text(season.label(l10n))),
                                    SeasonThemeSwatch(
                                      season: season,
                                      brightness: previewBrightness,
                                    ),
                                  ],
                                ),
                                subtitle: switch (season) {
                                  SeasonTheme.classic => Text(
                                    l10n.seasonThemeHint,
                                  ),
                                  SeasonTheme.colorBlind => Text(
                                    l10n.seasonColorBlindHint,
                                  ),
                                  _ => null,
                                },
                                secondary: Icon(season.icon),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  BlocBuilder<ThemeModeCubit, ThemeMode>(
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
                              secondary: const Icon(
                                Icons.brightness_auto_outlined,
                              ),
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
                  BlocBuilder<UiScaleCubit, double>(
                    builder: (context, scale) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.text_fields_outlined),
                            title: Text(l10n.displaySize),
                            subtitle: Text(l10n.displaySizeHint),
                            trailing: TextButton(
                              onPressed: scale == UiScale.defaultValue
                                  ? null
                                  : () => context.read<UiScaleCubit>().reset(),
                              child: Text(l10n.displaySizeReset),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: AppSpacing.lg,
                              end: AppSpacing.lg,
                              bottom: AppSpacing.sm,
                            ),
                            child: Slider(
                              value: scale,
                              min: UiScale.min,
                              max: UiScale.max,
                              divisions: 12,
                              label: '${(scale * 100).round()}%',
                              onChanged: (value) =>
                                  context.read<UiScaleCubit>().setScale(value),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              PreferencesExpandableSection(
                title: l10n.syncSection,
                leading: const Icon(Icons.cloud_sync_outlined),
                children: [
                  BlocBuilder<SyncPreferenceCubit, bool>(
                    builder: (context, syncEnabled) {
                      return Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(Icons.cloud_sync_outlined),
                            title: Text(l10n.syncWithRemote),
                            subtitle: Text(l10n.syncWithRemoteHint),
                            value: syncEnabled,
                            onChanged: (value) => context
                                .read<SyncPreferenceCubit>()
                                .setEnabled(value),
                          ),
                          const Divider(height: 1),
                          _SyncStatusTile(
                            enabled: syncEnabled,
                            networkStatus: services.networkStatusReader,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              PreferencesExpandableSection(
                title: l10n.data,
                leading: const Icon(Icons.storage_outlined),
                children: [
                  ListTile(
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(l10n.birthdays),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/birthdays'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: Text(l10n.archivedDevices),
                    subtitle: Text(l10n.archivedDevicesHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/devices/archived'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.import_export_outlined),
                    title: Text(l10n.exportImport),
                    subtitle: Text(l10n.exportImportHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/preferences/transfer'),
                  ),
                ],
              ),
              PreferencesExpandableSection(
                title: l10n.about,
                leading: const Icon(Icons.info_outline),
                children: [
                  ListTile(
                    leading: const AppLogo.mark(height: 36),
                    title: Text(l10n.appTitle),
                    subtitle: Text(AppVersion.full),
                  ),
                  ListTile(
                    leading: const Icon(Icons.new_releases_outlined),
                    title: Text(l10n.whatsNew),
                    subtitle: Text(l10n.whatsNewHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showWhatsNewDialog(context),
                  ),
                  BlocBuilder<AppUpdateBloc, AppUpdateState>(
                    builder: (context, updateState) {
                      final busy =
                          updateState is AppUpdateChecking ||
                          updateState is AppUpdateDownloading;
                      return ListTile(
                        leading: const Icon(Icons.system_update_outlined),
                        title: Text(l10n.checkForUpdates),
                        subtitle: Text(
                          _updateStatusSubtitle(l10n, updateState),
                        ),
                        trailing: busy
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: busy
                            ? null
                            : () => context.read<AppUpdateBloc>().add(
                                const AppUpdateCheckRequested(
                                  background: false,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncStatusTile extends StatefulWidget {
  const _SyncStatusTile({required this.enabled, required this.networkStatus});

  final bool enabled;
  final NetworkStatusReader networkStatus;

  @override
  State<_SyncStatusTile> createState() => _SyncStatusTileState();
}

class _SyncStatusTileState extends State<_SyncStatusTile> {
  bool? _online;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(covariant _SyncStatusTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled && widget.enabled) {
      _online = null;
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (!widget.enabled) return;
    final online = await widget.networkStatus.isOnline;
    if (!mounted) return;
    setState(() => _online = online);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String status;
    final IconData icon;
    if (!widget.enabled) {
      status = l10n.syncStatusOff;
      icon = Icons.cloud_off_outlined;
    } else if (_online == false) {
      status = l10n.syncStatusOffline;
      icon = Icons.cloud_off_outlined;
    } else {
      status = l10n.syncStatusReady;
      icon = Icons.cloud_done_outlined;
    }

    return ListTile(
      leading: Icon(icon),
      title: Text(status, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
