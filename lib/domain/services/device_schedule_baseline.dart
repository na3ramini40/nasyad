import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

/// Bakes "already elapsed toward this cycle" into device baselines at create time.
class DeviceScheduleBaseline {
  static Device applyInitialElapsed({
    required Device device,
    required int initialElapsed,
    required Device? usageOwner,
    DateTime? now,
  }) {
    if (!device.hasSchedule || initialElapsed <= 0) return device;

    final current = now ?? DateTime.now();
    return switch (device.scheduleType!) {
      ScheduleType.calendarInterval => device.copyWith(
        lastMaintainedAt: _subtractCalendar(
          current,
          initialElapsed,
          device.intervalUnit,
        ),
      ),
      ScheduleType.usageInterval => () {
        final ownerUsage = usageOwner?.currentUsage ?? device.currentUsage;
        return device.copyWith(
          usageAtLastMaintenance: (ownerUsage - initialElapsed).clamp(0, 1 << 30),
          lastMaintainedAt: current,
        );
      }(),
      ScheduleType.fixedDate => device.copyWith(lastMaintainedAt: current),
    };
  }

  static DateTime _subtractCalendar(DateTime from, int value, String? unit) {
    if (unit == null) return from;
    final calendarUnit = CalendarIntervalUnitX.fromStorage(unit);
    return switch (calendarUnit) {
      CalendarIntervalUnit.days => from.subtract(Duration(days: value)),
      CalendarIntervalUnit.weeks => from.subtract(Duration(days: value * 7)),
      CalendarIntervalUnit.months => DateTime(
        from.year,
        from.month - value,
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
