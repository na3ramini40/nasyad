import 'dart:async';

import 'package:nasyad/core/preferences/reminder_snooze_store.dart';
import 'package:nasyad/core/preferences/soon_window_preference_store.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/soon_window_days.dart';
import 'package:nasyad/domain/services/home_reminder_aggregator.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';

class WatchHomeRemindersUsecase {
  WatchHomeRemindersUsecase(
    this._watchDeviceSummaries,
    this._watchBirthdays,
    this._snoozeStore,
    this._soonWindowStore,
  );

  final WatchDeviceSummariesUsecase _watchDeviceSummaries;
  final WatchBirthdaysUsecase _watchBirthdays;
  final ReminderSnoozeStore _snoozeStore;
  final SoonWindowPreferenceStore _soonWindowStore;

  Stream<List<HomeReminder>> call({
    required HomeReminderFilter filter,
    DateTime? now,
  }) {
    final controller = StreamController<List<HomeReminder>>();
    var deviceSummaries = const <DeviceSummary>[];
    var birthdays = const <Birthday>[];
    var snoozedReminderIds = <String>{};
    var soonWindowDays = SoonWindowDays.defaultValue.days;

    Future<void> emit() async {
      if (controller.isClosed) return;
      snoozedReminderIds = (await _snoozeStore.readActive(
        now: now,
      )).keys.toSet();
      controller.add(
        HomeReminderAggregator.build(
          deviceSummaries: List.unmodifiable(deviceSummaries),
          birthdays: List.unmodifiable(birthdays),
          filter: filter,
          snoozedReminderIds: snoozedReminderIds,
          soonWindowDays: soonWindowDays,
          now: now,
        ),
      );
    }

    final subscriptions = <StreamSubscription<dynamic>>[];

    subscriptions.add(
      _watchDeviceSummaries().listen((value) {
        deviceSummaries = value;
        unawaited(emit());
      }, onError: controller.addError),
    );
    subscriptions.add(
      _watchBirthdays().listen((value) {
        birthdays = value;
        unawaited(emit());
      }, onError: controller.addError),
    );
    subscriptions.add(
      _snoozeStore.changes.listen((_) {
        unawaited(emit());
      }),
    );
    subscriptions.add(
      _soonWindowStore.changes.listen((_) async {
        soonWindowDays = (await _soonWindowStore.read()).days;
        await emit();
      }),
    );

    unawaited(() async {
      soonWindowDays = (await _soonWindowStore.read()).days;
      await emit();
    }());

    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await controller.close();
    };

    return controller.stream;
  }
}
