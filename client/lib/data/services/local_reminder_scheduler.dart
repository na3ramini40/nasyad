import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasyad/core/l10n/locale_cubit.dart';
import 'package:nasyad/core/notifications/reminder_notification_preference_store.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/services/local_reminder_planner.dart';
import 'package:nasyad/domain/usecases/home/watch_home_reminders_usecase.dart';
import 'package:nasyad/data/services/local_reminder_notification_service.dart';

class LocalReminderScheduler {
  LocalReminderScheduler({
    required WatchHomeRemindersUsecase watchHomeReminders,
    required ReminderNotificationPreferenceStore preferenceStore,
    required LocalReminderNotificationService notificationService,
    Locale Function()? localeReader,
  }) : _watchHomeReminders = watchHomeReminders,
       _preferenceStore = preferenceStore,
       _notificationService = notificationService,
       _localeReader = localeReader ?? _defaultLocaleReader;

  final WatchHomeRemindersUsecase _watchHomeReminders;
  final ReminderNotificationPreferenceStore _preferenceStore;
  final LocalReminderNotificationService _notificationService;
  final Locale Function() _localeReader;

  StreamSubscription<List<HomeReminder>>? _subscription;
  List<HomeReminder> _latestReminders = const [];
  Locale? _localeOverride;

  void setLocale(Locale locale) {
    _localeOverride = locale;
  }

  Locale get _currentLocale => _localeOverride ?? _localeReader();

  static Locale _defaultLocaleReader() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return AppLocales.resolve(deviceLocale, AppLocales.supported);
  }

  Future<void> start() async {
    if (!LocalReminderNotificationService.isSupported) return;

    await _subscription?.cancel();
    _subscription = _watchHomeReminders(filter: HomeReminderFilter.all).listen((
      reminders,
    ) {
      _latestReminders = reminders;
      reschedule();
    }, onError: (_, _) {});
  }

  Future<void> reschedule() async {
    if (!LocalReminderNotificationService.isSupported) return;

    try {
      final preferences = await _preferenceStore.read();
      if (!preferences.enabled) {
        await _notificationService.cancelAll();
        return;
      }

      final plans = LocalReminderPlanner.plan(
        reminders: _latestReminders,
        enabled: preferences.enabled,
        hour: preferences.hour,
        minute: preferences.minute,
      );

      await _notificationService.applyPlans(
        plans: plans,
        locale: _currentLocale,
      );
    } catch (_) {
      // Notification plugins are unavailable in widget tests and some shells.
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
