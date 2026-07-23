import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class RuleStatusResult {
  final MaintenanceStatus status;
  final double progress;

  const RuleStatusResult({required this.status, required this.progress});
}

class MaintenanceStatusCalculator {
  static const double soonThreshold = 0.8;

  RuleStatusResult evaluateRule({
    required MaintenanceRule rule,
    required Device device,
    required DeviceLog? latestLog,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();

    return switch (rule.scheduleType) {
      ScheduleType.calendarInterval => _calendar(
        rule: rule,
        latestLog: latestLog,
        createdAt: device.createdAt,
        now: current,
      ),
      ScheduleType.usageInterval => _usage(rule: rule, device: device),
      ScheduleType.fixedDate => _fixedDate(
        rule: rule,
        latestLog: latestLog,
        now: current,
      ),
    };
  }

  ({MaintenanceStatus status, double progress}) evaluateDevice({
    required Device device,
    required List<MaintenanceRule> rules,
    required DeviceLog? latestLog,
    DateTime? now,
  }) {
    if (rules.isEmpty) {
      return (status: MaintenanceStatus.upToDate, progress: 0);
    }

    final results = rules
        .map(
          (rule) => evaluateRule(
            rule: rule,
            device: device,
            latestLog: latestLog,
            now: now,
          ),
        )
        .toList();

    final status = MaintenanceStatus.worst(results.map((r) => r.status));
    final progress = results
        .map((r) => r.progress)
        .fold<double>(0, (max, value) => value > max ? value : max);

    return (status: status, progress: progress.clamp(0.0, 1.0));
  }

  RuleStatusResult _calendar({
    required MaintenanceRule rule,
    required DeviceLog? latestLog,
    required DateTime createdAt,
    required DateTime now,
  }) {
    final value = rule.intervalValue;
    final unit = rule.intervalUnit;
    if (value == null || value <= 0 || unit == null) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final calendarUnit = CalendarIntervalUnitX.fromStorage(unit);
    final anchor = latestLog?.date ?? createdAt;
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
    required MaintenanceRule rule,
    required Device device,
  }) {
    final value = rule.intervalValue;
    if (value == null || value <= 0) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final used = (device.currentUsage - device.usageAtLastMaintenance).clamp(
      0,
      1 << 30,
    );
    final progress = (used / value).clamp(0.0, 1.0);
    return RuleStatusResult(
      status: _statusFromProgress(progress),
      progress: progress,
    );
  }

  RuleStatusResult _fixedDate({
    required MaintenanceRule rule,
    required DeviceLog? latestLog,
    required DateTime now,
  }) {
    final dueAt = rule.fixedDueAt;
    if (dueAt == null) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    if (latestLog != null && !latestLog.date.isBefore(dueAt)) {
      return const RuleStatusResult(
        status: MaintenanceStatus.upToDate,
        progress: 0,
      );
    }

    final start = latestLog?.date ?? dueAt.subtract(const Duration(days: 30));
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
