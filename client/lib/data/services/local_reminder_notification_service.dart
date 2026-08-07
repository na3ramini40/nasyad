import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nasyad/core/notifications/local_reminder_notification_copy.dart';
import 'package:nasyad/data/services/push_notification_service.dart';
import 'package:nasyad/domain/entities/planned_local_reminder.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalReminderNotificationService {
  LocalReminderNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? PushNotificationService.localNotificationsPlugin;

  static const remindersChannelId = 'nasyad_reminders';
  static const remindersChannelName = 'Due reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  static var _timezoneReady = false;

  static bool get isSupported =>
      !kIsWeb &&
      (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isLinux ||
          Platform.isWindows);

  static Future<void> _ensureTimezoneReady() async {
    if (_timezoneReady) return;
    tz_data.initializeTimeZones();
    _timezoneReady = true;
  }

  Future<void> applyPlans({
    required List<PlannedLocalReminder> plans,
    required Locale locale,
  }) async {
    if (!isSupported) return;

    await PushNotificationService.ensureLocalNotificationsReady();
    await _ensureTimezoneReady();
    await _ensureChannel();

    final l10n = lookupAppLocalizations(locale);
    final plannedIds = plans.map((plan) => plan.notificationId).toSet();

    for (final plan in plans) {
      final copy = LocalReminderNotificationCopy.forReminder(
        l10n,
        plan.reminder,
      );
      await _schedulePlan(plan, title: copy.title, body: copy.body);
    }

    await _cancelStale(plannedIds);
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    await PushNotificationService.ensureLocalNotificationsReady();
    await _plugin.cancelAll();
  }

  Future<void> _ensureChannel() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        remindersChannelId,
        remindersChannelName,
        description: 'Local reminders for due maintenance and birthdays',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _schedulePlan(
    PlannedLocalReminder plan, {
    required String title,
    required String body,
  }) async {
    final scheduledDate = tz.TZDateTime.from(plan.scheduledAt, tz.local);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        remindersChannelId,
        remindersChannelName,
        channelDescription: 'Local reminders for due maintenance and birthdays',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: const LinuxNotificationDetails(),
      windows: const WindowsNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      plan.notificationId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: plan.repeatsDaily
          ? DateTimeComponents.time
          : null,
      payload: plan.deepLinkUri,
    );
  }

  Future<void> _cancelStale(Set<int> plannedIds) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (!plannedIds.contains(request.id)) {
        await _plugin.cancel(request.id);
      }
    }
  }
}
