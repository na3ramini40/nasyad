import 'package:nasyad/core/deep_link/deep_link_constants.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/planned_local_reminder.dart';

abstract final class LocalReminderPlanner {
  static List<PlannedLocalReminder> plan({
    required List<HomeReminder> reminders,
    required bool enabled,
    required int hour,
    required int minute,
    DateTime? now,
  }) {
    if (!enabled) return const [];

    final current = now ?? DateTime.now();
    final plans = <PlannedLocalReminder>[];

    for (final reminder in reminders) {
      final plan = switch (reminder.kind) {
        HomeReminderKind.device || HomeReminderKind.tag => _planDeviceReminder(
          reminder: reminder,
          now: current,
          hour: hour,
          minute: minute,
        ),
        HomeReminderKind.birthday => _planBirthdayReminder(
          reminder: reminder,
          now: current,
          hour: hour,
          minute: minute,
        ),
      };
      if (plan != null) {
        plans.add(plan);
      }
    }

    return plans;
  }

  static int notificationIdFor(String reminderId) =>
      reminderId.hashCode & 0x7FFFFFFF;

  static PlannedLocalReminder? _planDeviceReminder({
    required HomeReminder reminder,
    required DateTime now,
    required int hour,
    required int minute,
  }) {
    final scheduledAt = _nextDailyTime(now: now, hour: hour, minute: minute);
    final deviceId = reminder.deviceId;
    if (deviceId == null) return null;

    return PlannedLocalReminder(
      notificationId: notificationIdFor(reminder.id),
      reminder: reminder,
      scheduledAt: scheduledAt,
      repeatsDaily: true,
      deepLinkUri: DeepLinkConstants.locationUri('/device/$deviceId'),
    );
  }

  static PlannedLocalReminder? _planBirthdayReminder({
    required HomeReminder reminder,
    required DateTime now,
    required int hour,
    required int minute,
  }) {
    final daysUntil = reminder.daysUntilBirthday;
    final birthdayId = reminder.birthdayId;
    if (daysUntil == null || birthdayId == null) return null;

    final dayOffset = switch (daysUntil) {
      0 => 0,
      1 => 0,
      <= 7 => daysUntil,
      _ => daysUntil - 7,
    };

    final scheduledAt = _dateTimeAt(
      now: now,
      dayOffset: dayOffset,
      hour: hour,
      minute: minute,
    );
    if (scheduledAt == null || scheduledAt.isBefore(now)) return null;

    return PlannedLocalReminder(
      notificationId: notificationIdFor(reminder.id),
      reminder: reminder,
      scheduledAt: scheduledAt,
      repeatsDaily: false,
      deepLinkUri: DeepLinkConstants.locationUri('/birthdays/$birthdayId/edit'),
    );
  }

  static DateTime _nextDailyTime({
    required DateTime now,
    required int hour,
    required int minute,
  }) {
    final today = _dateTimeAt(
      now: now,
      dayOffset: 0,
      hour: hour,
      minute: minute,
    )!;
    if (!today.isBefore(now)) return today;
    return _dateTimeAt(now: now, dayOffset: 1, hour: hour, minute: minute)!;
  }

  static DateTime? _dateTimeAt({
    required DateTime now,
    required int dayOffset,
    required int hour,
    required int minute,
  }) {
    final date = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: dayOffset));
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
