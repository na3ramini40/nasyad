import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/l10n/app_localizations.dart';

abstract final class LocalReminderNotificationCopy {
  static ({String title, String body}) forReminder(
    AppLocalizations l10n,
    HomeReminder reminder,
  ) {
    return switch (reminder.kind) {
      HomeReminderKind.device => (
        title: reminder.title,
        body: reminder.deviceStatus == MaintenanceStatus.due
            ? l10n.reminderDeviceDue
            : l10n.reminderDeviceSoon,
      ),
      HomeReminderKind.birthday => (
        title: reminder.title,
        body: switch (reminder.daysUntilBirthday) {
          0 => l10n.reminderBirthdayToday,
          1 => l10n.reminderBirthdayTomorrow,
          final days? => l10n.reminderBirthdayInDays(days),
          null => l10n.reminderBirthdayToday,
        },
      ),
    };
  }
}
