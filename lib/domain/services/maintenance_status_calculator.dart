import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class RuleStatusResult {
  final MaintenanceStatus status;
  final double progress;

  const RuleStatusResult({required this.status, required this.progress});
}

class MaintenanceStatusCalculator {
  static const double soonThreshold = 0.8;

  RuleStatusResult evaluateDevice({
    required Device device,
    Device? usageOwner,
    DateTime? now,
  }) {
    if (!device.hasSchedule) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final current = now ?? DateTime.now();
    return switch (device.scheduleType!) {
      ScheduleType.calendarInterval => _calendar(device: device, now: current),
      ScheduleType.usageInterval => _usage(
        device: device,
        usageOwner: usageOwner ?? device,
      ),
      ScheduleType.fixedDate => _fixedDate(device: device, now: current),
    };
  }

  RuleStatusResult aggregate(Iterable<RuleStatusResult> results) {
    final list = results.toList();
    if (list.isEmpty) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final status = MaintenanceStatus.worst(list.map((r) => r.status));
    final progress = list
        .map((r) => r.progress)
        .fold<double>(0, (max, value) => value > max ? value : max);
    return RuleStatusResult(status: status, progress: progress.clamp(0.0, 1.0));
  }

  Device? resolveUsageOwner(Device device, Map<String, Device> byId) {
    Device? current = device;
    while (current != null) {
      if (current.isUsageOwner) return current;
      final parentId = current.parentId;
      if (parentId == null) return null;
      current = byId[parentId];
    }
    return null;
  }

  List<Device> descendantsOf(String rootId, List<Device> all) {
    final byParent = <String, List<Device>>{};
    for (final device in all) {
      final parentId = device.parentId;
      if (parentId == null) continue;
      byParent.putIfAbsent(parentId, () => []).add(device);
    }

    final result = <Device>[];
    void walk(String id) {
      final children = byParent[id] ?? const [];
      for (final child in children) {
        result.add(child);
        walk(child.id);
      }
    }

    walk(rootId);
    return result;
  }

  RuleStatusResult _calendar({required Device device, required DateTime now}) {
    final value = device.intervalValue;
    final unit = device.intervalUnit;
    if (value == null || value <= 0 || unit == null) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final calendarUnit = CalendarIntervalUnitX.fromStorage(unit);
    final anchor = device.lastMaintainedAt ?? device.createdAt;
    final dueAt = _addCalendar(anchor, value, calendarUnit);
    final totalMs = dueAt.difference(anchor).inMilliseconds;
    if (totalMs <= 0) {
      return const RuleStatusResult(status: MaintenanceStatus.due, progress: 1);
    }

    final elapsedMs = now.difference(anchor).inMilliseconds;
    final progress = (elapsedMs / totalMs).clamp(0.0, 1.0);
    return RuleStatusResult(
      status: _statusFromProgress(progress),
      progress: progress,
    );
  }

  RuleStatusResult _usage({
    required Device device,
    required Device usageOwner,
  }) {
    final value = device.intervalValue;
    if (value == null || value <= 0) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final used = (usageOwner.currentUsage - device.usageAtLastMaintenance)
        .clamp(0, 1 << 30);
    final progress = (used / value).clamp(0.0, 1.0);
    return RuleStatusResult(
      status: _statusFromProgress(progress),
      progress: progress,
    );
  }

  RuleStatusResult _fixedDate({required Device device, required DateTime now}) {
    final dueAt = device.fixedDueAt;
    if (dueAt == null) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final maintained = device.lastMaintainedAt;
    if (maintained != null && !maintained.isBefore(dueAt)) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final start = maintained ?? dueAt.subtract(const Duration(days: 30));
    final totalMs = dueAt.difference(start).inMilliseconds;
    if (totalMs <= 0 || !now.isBefore(dueAt)) {
      return const RuleStatusResult(status: MaintenanceStatus.due, progress: 1);
    }

    final elapsedMs = now.difference(start).inMilliseconds;
    final progress = (elapsedMs / totalMs).clamp(0.0, 1.0);
    return RuleStatusResult(
      status: _statusFromProgress(progress),
      progress: progress,
    );
  }

  MaintenanceStatus _statusFromProgress(double progress) {
    if (progress >= 1) return MaintenanceStatus.due;
    if (progress >= soonThreshold) return MaintenanceStatus.soon;
    return MaintenanceStatus.upToDate;
  }

  DateTime _addCalendar(DateTime from, int value, CalendarIntervalUnit unit) {
    return switch (unit) {
      CalendarIntervalUnit.days => from.add(Duration(days: value)),
      CalendarIntervalUnit.weeks => from.add(Duration(days: value * 7)),
      CalendarIntervalUnit.months => DateTime(
        from.year,
        from.month + value,
        from.day,
        from.hour,
        from.minute,
        from.second,
        from.millisecond,
        from.microsecond,
      ),
    };
  }
}
