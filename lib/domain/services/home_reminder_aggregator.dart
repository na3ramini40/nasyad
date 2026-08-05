import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/services/birthday_upcoming.dart';

abstract final class HomeReminderAggregator {
  static List<HomeReminder> build({
    required List<DeviceSummary> deviceSummaries,
    required List<Birthday> birthdays,
    required HomeReminderFilter filter,
    DateTime? now,
  }) {
    final reminders = <HomeReminder>[
      ..._deviceReminders(deviceSummaries),
      ..._birthdayReminders(birthdays, now: now),
    ]..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    return switch (filter) {
      HomeReminderFilter.all => reminders,
      HomeReminderFilter.devices =>
        reminders
            .where((item) => item.kind == HomeReminderKind.device)
            .toList(growable: false),
      HomeReminderFilter.birthdays =>
        reminders
            .where((item) => item.kind == HomeReminderKind.birthday)
            .toList(growable: false),
    };
  }

  static Iterable<HomeReminder> _deviceReminders(
    List<DeviceSummary> summaries,
  ) sync* {
    for (final summary in summaries) {
      final status = summary.status;
      if (status == MaintenanceStatus.upToDate) continue;

      final urgency = status == MaintenanceStatus.due
          ? HomeReminderUrgency.due
          : HomeReminderUrgency.soon;
      final sortKey = status == MaintenanceStatus.due
          ? (summary.progress * 100).round()
          : 1000 + (summary.progress * 100).round();

      yield HomeReminder(
        id: 'device-${summary.device.id}',
        kind: HomeReminderKind.device,
        title: summary.device.name,
        urgency: urgency,
        sortKey: sortKey,
        deviceId: summary.device.id,
        deviceStatus: status,
      );
    }
  }

  static Iterable<HomeReminder> _birthdayReminders(
    List<Birthday> birthdays, {
    DateTime? now,
  }) sync* {
    for (final birthday in birthdays) {
      final upcoming = BirthdayUpcomingCalculator.calculate(birthday, now: now);
      if (upcoming == null) continue;

      final urgency = upcoming.isToday
          ? HomeReminderUrgency.due
          : upcoming.daysUntil <= BirthdayUpcomingCalculator.soonThresholdDays
          ? HomeReminderUrgency.soon
          : HomeReminderUrgency.upcoming;
      final sortKey = 2000 + upcoming.daysUntil;

      yield HomeReminder(
        id: 'birthday-${birthday.id}',
        kind: HomeReminderKind.birthday,
        title: birthday.name,
        urgency: urgency,
        sortKey: sortKey,
        birthdayId: birthday.id,
        daysUntilBirthday: upcoming.daysUntil,
      );
    }
  }
}
