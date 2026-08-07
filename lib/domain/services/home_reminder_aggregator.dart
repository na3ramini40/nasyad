import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/services/birthday_upcoming.dart';
import 'package:nasyad/domain/services/home_reminder_sorter.dart';

abstract final class HomeReminderAggregator {
  static List<HomeReminder> build({
    required List<DeviceSummary> deviceSummaries,
    required List<Birthday> birthdays,
    required HomeReminderFilter filter,
    required Set<String> snoozedReminderIds,
    int soonWindowDays = BirthdayUpcomingCalculator.defaultSoonThresholdDays,
    DateTime? now,
  }) {
    final reminders = <HomeReminder>[
      ..._deviceReminders(deviceSummaries, soonWindowDays: soonWindowDays),
      ..._birthdayReminders(
        birthdays,
        soonWindowDays: soonWindowDays,
        now: now,
      ),
    ].where((item) => !snoozedReminderIds.contains(item.id)).toList();

    final sorted = HomeReminderSorter.sort(reminders);

    return switch (filter) {
      HomeReminderFilter.all => sorted,
      HomeReminderFilter.devices =>
        sorted
            .where((item) => item.kind == HomeReminderKind.device)
            .toList(growable: false),
      HomeReminderFilter.birthdays =>
        sorted
            .where((item) => item.kind == HomeReminderKind.birthday)
            .toList(growable: false),
    };
  }

  static Iterable<HomeReminder> _deviceReminders(
    List<DeviceSummary> summaries, {
    required int soonWindowDays,
  }) sync* {
    for (final summary in summaries) {
      final status = summary.status;
      if (status == MaintenanceStatus.upToDate) continue;

      final urgency = _deviceUrgency(status: status);
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
        deviceProgress: summary.progress,
      );
    }
  }

  static HomeReminderUrgency _deviceUrgency({
    required MaintenanceStatus status,
  }) {
    return switch (status) {
      MaintenanceStatus.due => HomeReminderUrgency.due,
      MaintenanceStatus.soon => HomeReminderUrgency.soon,
      MaintenanceStatus.upToDate => HomeReminderUrgency.upcoming,
    };
  }

  static Iterable<HomeReminder> _birthdayReminders(
    List<Birthday> birthdays, {
    required int soonWindowDays,
    DateTime? now,
  }) sync* {
    for (final birthday in birthdays) {
      final upcoming = BirthdayUpcomingCalculator.calculate(
        birthday,
        now: now,
        soonThresholdDays: soonWindowDays,
      );
      if (upcoming == null) continue;

      final urgency = upcoming.isToday
          ? HomeReminderUrgency.due
          : upcoming.daysUntil <= soonWindowDays
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
