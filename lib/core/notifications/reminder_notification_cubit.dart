import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/notifications/reminder_notification_preference_store.dart';
import 'package:nasyad/data/services/local_reminder_scheduler.dart';

class ReminderNotificationCubit extends Cubit<ReminderNotificationPreferences> {
  ReminderNotificationCubit({
    ReminderNotificationPreferenceStore? store,
    LocalReminderScheduler? scheduler,
    ReminderNotificationPreferences initial =
        ReminderNotificationPreferences.defaults,
  }) : _store = store ?? ReminderNotificationPreferenceStore(),
       _scheduler = scheduler,
       super(initial) {
    _hydrating = _load();
  }

  final ReminderNotificationPreferenceStore _store;
  final LocalReminderScheduler? _scheduler;
  Future<void>? _hydrating;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await _update(state.copyWith(enabled: enabled));
  }

  Future<void> setTime({required int hour, required int minute}) async {
    await _update(state.copyWith(hour: hour, minute: minute));
  }

  Future<void> _update(ReminderNotificationPreferences next) async {
    await _hydrating;
    if (state == next) return;
    emit(next);
    await _store.write(next);
    await _scheduler?.reschedule();
  }
}
