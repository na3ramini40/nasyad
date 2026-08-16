import 'dart:async';

import 'package:nasyad/core/preferences/home_grouping_preference_store.dart';
import 'package:nasyad/core/preferences/reminder_snooze_store.dart';
import 'package:nasyad/core/preferences/soon_window_preference_store.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/device_tag_link.dart';
import 'package:nasyad/domain/entities/home_grouping.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/soon_window_days.dart';
import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/services/home_reminder_aggregator.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_device_tag_links_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_tags_usecase.dart';

class WatchHomeRemindersUsecase {
  WatchHomeRemindersUsecase(
    this._watchDeviceSummaries,
    this._watchBirthdays,
    this._snoozeStore,
    this._soonWindowStore, {
    WatchTagsUsecase? watchTags,
    WatchDeviceTagLinksUsecase? watchDeviceTagLinks,
    HomeGroupingPreferenceStore? homeGroupingStore,
  }) : _watchTags = watchTags,
       _watchDeviceTagLinks = watchDeviceTagLinks,
       _homeGroupingStore = homeGroupingStore;

  final WatchDeviceSummariesUsecase _watchDeviceSummaries;
  final WatchBirthdaysUsecase _watchBirthdays;
  final ReminderSnoozeStore _snoozeStore;
  final SoonWindowPreferenceStore _soonWindowStore;
  final WatchTagsUsecase? _watchTags;
  final WatchDeviceTagLinksUsecase? _watchDeviceTagLinks;
  final HomeGroupingPreferenceStore? _homeGroupingStore;

  Stream<List<HomeReminder>> call({
    required HomeReminderFilter filter,
    DateTime? now,
  }) {
    final controller = StreamController<List<HomeReminder>>();
    var deviceSummaries = const <DeviceSummary>[];
    var birthdays = const <Birthday>[];
    var tags = const <Tag>[];
    var deviceTagLinks = const <DeviceTagLink>[];
    var snoozedReminderIds = <String>{};
    var soonWindowDays = SoonWindowDays.defaultValue.days;
    var grouping = HomeGrouping.defaultValue;

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
          grouping: grouping,
          tags: List.unmodifiable(tags),
          deviceTagLinks: List.unmodifiable(deviceTagLinks),
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
    final watchTags = _watchTags;
    if (watchTags != null) {
      subscriptions.add(
        watchTags().listen((value) {
          tags = value;
          unawaited(emit());
        }, onError: controller.addError),
      );
    }
    final watchLinks = _watchDeviceTagLinks;
    if (watchLinks != null) {
      subscriptions.add(
        watchLinks().listen((value) {
          deviceTagLinks = value;
          unawaited(emit());
        }, onError: controller.addError),
      );
    }
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
    final groupingStore = _homeGroupingStore;
    if (groupingStore != null) {
      subscriptions.add(
        groupingStore.changes.listen((_) async {
          grouping = await groupingStore.read();
          await emit();
        }),
      );
    }

    unawaited(() async {
      soonWindowDays = (await _soonWindowStore.read()).days;
      if (groupingStore != null) {
        grouping = await groupingStore.read();
      }
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
