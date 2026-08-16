import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/device_tag_link.dart';
import 'package:nasyad/domain/entities/home_grouping.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/services/birthday_upcoming.dart';
import 'package:nasyad/domain/services/home_reminder_sorter.dart';

abstract final class HomeReminderAggregator {
  static List<HomeReminder> build({
    required List<DeviceSummary> deviceSummaries,
    required List<Birthday> birthdays,
    required HomeReminderFilter filter,
    required Set<String> snoozedReminderIds,
    HomeGrouping grouping = HomeGrouping.device,
    List<Tag> tags = const [],
    List<DeviceTagLink> deviceTagLinks = const [],
    int soonWindowDays = BirthdayUpcomingCalculator.defaultSoonThresholdDays,
    DateTime? now,
  }) {
    final maintenanceReminders = switch (grouping) {
      HomeGrouping.device => _deviceReminders(
        deviceSummaries,
        soonWindowDays: soonWindowDays,
      ),
      HomeGrouping.tag => _tagReminders(
        deviceSummaries: deviceSummaries,
        tags: tags,
        deviceTagLinks: deviceTagLinks,
      ),
    };

    final reminders = <HomeReminder>[
      ...maintenanceReminders,
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
        sorted.where(_isMaintenanceReminder).toList(growable: false),
      HomeReminderFilter.birthdays =>
        sorted
            .where((item) => item.kind == HomeReminderKind.birthday)
            .toList(growable: false),
    };
  }

  static bool _isMaintenanceReminder(HomeReminder item) {
    return item.kind == HomeReminderKind.device ||
        item.kind == HomeReminderKind.tag;
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

  static Iterable<HomeReminder> _tagReminders({
    required List<DeviceSummary> deviceSummaries,
    required List<Tag> tags,
    required List<DeviceTagLink> deviceTagLinks,
  }) sync* {
    final rootByDeviceId = _rootSummariesByDeviceId(deviceSummaries);
    final deviceIdsByTag = <String, Set<String>>{};
    for (final link in deviceTagLinks) {
      deviceIdsByTag
          .putIfAbsent(link.tagId, () => <String>{})
          .add(link.deviceId);
    }

    for (final tag in tags) {
      final assignedIds = deviceIdsByTag[tag.id];
      if (assignedIds == null || assignedIds.isEmpty) continue;

      final rootSummaries = <DeviceSummary>[];
      final seenRootIds = <String>{};
      for (final deviceId in assignedIds) {
        final root = rootByDeviceId[deviceId];
        if (root == null) continue;
        if (seenRootIds.add(root.device.id)) {
          rootSummaries.add(root);
        }
      }

      final actionable = rootSummaries
          .where((s) => s.status != MaintenanceStatus.upToDate)
          .toList(growable: false);
      if (actionable.isEmpty) continue;

      actionable.sort((a, b) {
        final bySeverity = b.status.severity.compareTo(a.status.severity);
        if (bySeverity != 0) return bySeverity;
        final byProgress = b.progress.compareTo(a.progress);
        if (byProgress != 0) return byProgress;
        return a.device.name.compareTo(b.device.name);
      });

      final worst = actionable.first;
      final status = MaintenanceStatus.worst(actionable.map((s) => s.status));
      final urgency = _deviceUrgency(status: status);
      final sortKey = status == MaintenanceStatus.due
          ? (worst.progress * 100).round()
          : 1000 + (worst.progress * 100).round();

      yield HomeReminder(
        id: 'tag-${tag.id}',
        kind: HomeReminderKind.tag,
        title: tag.name,
        urgency: urgency,
        sortKey: sortKey,
        tagId: tag.id,
        deviceId: worst.device.id,
        deviceStatus: status,
        deviceProgress: worst.progress,
      );
    }
  }

  static Map<String, DeviceSummary> _rootSummariesByDeviceId(
    List<DeviceSummary> roots,
  ) {
    final map = <String, DeviceSummary>{};
    void walk(DeviceSummary node, DeviceSummary root) {
      map[node.device.id] = root;
      for (final child in node.children) {
        walk(child, root);
      }
    }

    for (final root in roots) {
      walk(root, root);
    }
    return map;
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
