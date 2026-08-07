import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';

abstract final class HomeReminderSorter {
  static int compare(HomeReminder a, HomeReminder b) {
    final urgencyCompare = a.urgency.index.compareTo(b.urgency.index);
    if (urgencyCompare != 0) return urgencyCompare;

    final dueCompare = _dueRank(a).compareTo(_dueRank(b));
    if (dueCompare != 0) return dueCompare;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  static int _dueRank(HomeReminder reminder) {
    final birthdayDays = reminder.daysUntilBirthday;
    if (birthdayDays != null) return birthdayDays;

    if (reminder.deviceStatus == MaintenanceStatus.due) {
      return 0;
    }

    final progress = reminder.deviceProgress;
    if (progress != null) {
      return ((1 - progress) * 10000).round();
    }

    return reminder.sortKey;
  }

  static List<HomeReminder> sort(List<HomeReminder> reminders) {
    final sorted = List<HomeReminder>.from(reminders)..sort(compare);
    return sorted;
  }
}
