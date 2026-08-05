import 'dart:async';

import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/services/home_reminder_aggregator.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';

class WatchHomeRemindersUsecase {
  WatchHomeRemindersUsecase(this._watchDeviceSummaries, this._watchBirthdays);

  final WatchDeviceSummariesUsecase _watchDeviceSummaries;
  final WatchBirthdaysUsecase _watchBirthdays;

  Stream<List<HomeReminder>> call({
    required HomeReminderFilter filter,
    DateTime? now,
  }) {
    final controller = StreamController<List<HomeReminder>>();
    var deviceSummaries = const <DeviceSummary>[];
    var birthdays = const <Birthday>[];

    void emit() {
      if (controller.isClosed) return;
      controller.add(
        HomeReminderAggregator.build(
          deviceSummaries: List.unmodifiable(deviceSummaries),
          birthdays: List.unmodifiable(birthdays),
          filter: filter,
          now: now,
        ),
      );
    }

    final deviceSub = _watchDeviceSummaries().listen((value) {
      deviceSummaries = value;
      emit();
    }, onError: controller.addError);
    final birthdaySub = _watchBirthdays().listen((value) {
      birthdays = value;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await deviceSub.cancel();
      await birthdaySub.cancel();
      await controller.close();
    };

    return controller.stream;
  }
}
