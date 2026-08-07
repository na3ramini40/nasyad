import 'package:nasyad/core/preferences/reminder_snooze_store.dart';

class SnoozeHomeReminderUsecase {
  SnoozeHomeReminderUsecase(this._store);

  final ReminderSnoozeStore _store;

  Future<void> call({
    required String reminderId,
    required int days,
    DateTime? now,
  }) {
    return _store.snooze(reminderId: reminderId, days: days, now: now);
  }
}
