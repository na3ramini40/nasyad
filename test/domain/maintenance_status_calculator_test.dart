import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/services/maintenance_status_calculator.dart';

import '../helpers/fixtures.dart';

void main() {
  late MaintenanceStatusCalculator calculator;

  setUp(() {
    calculator = MaintenanceStatusCalculator();
  });

  group('calendarInterval', () {
    test('returns upToDate when interval is invalid', () {
      final result = calculator.evaluateDevice(
        device: sampleDevice(intervalValue: 0),
        now: tNow,
      );
      expect(result.status, MaintenanceStatus.upToDate);
      expect(result.progress, 0);
    });

    test('uses lastMaintainedAt as anchor', () {
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          intervalValue: 6,
          intervalUnit: CalendarIntervalUnit.months.storageValue,
          lastMaintainedAt: DateTime.utc(2024, 1, 1),
          createdAt: DateTime.utc(2024, 1, 1),
        ),
        now: DateTime.utc(2024, 4, 1),
      );
      expect(result.progress, closeTo(0.5, 0.02));
      expect(result.status, MaintenanceStatus.upToDate);
    });

    test('marks soon near threshold', () {
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          intervalValue: 10,
          intervalUnit: CalendarIntervalUnit.days.storageValue,
          lastMaintainedAt: DateTime.utc(2024, 1, 1),
          createdAt: DateTime.utc(2024, 1, 1),
        ),
        now: DateTime.utc(2024, 1, 9),
      );
      expect(result.progress, closeTo(0.8, 0.01));
      expect(result.status, MaintenanceStatus.soon);
    });

    test('marks due when elapsed past interval', () {
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          intervalValue: 1,
          intervalUnit: CalendarIntervalUnit.weeks.storageValue,
          lastMaintainedAt: DateTime.utc(2024, 1, 1),
        ),
        now: DateTime.utc(2024, 1, 15),
      );
      expect(result.status, MaintenanceStatus.due);
      expect(result.progress, 1);
    });
  });

  group('usageInterval', () {
    test('computes progress from usage owner reading', () {
      final oil = sampleDevice(
        id: 'oil',
        parentId: 'car',
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: UsageIntervalUnit.km.storageValue,
        usageAtLastMaintenance: 0,
        usageUnit: null,
      );
      final car = sampleDevice(
        id: 'car',
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 800,
      );
      final result = calculator.evaluateDevice(device: oil, usageOwner: car);
      expect(result.progress, closeTo(0.8, 0.001));
      expect(result.status, MaintenanceStatus.soon);
    });

    test('returns upToDate when interval missing', () {
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          scheduleType: ScheduleType.usageInterval,
          intervalValue: null,
          intervalUnit: null,
        ),
      );
      expect(result.status, MaintenanceStatus.upToDate);
    });
  });

  group('fixedDate', () {
    test('upToDate when maintained on or after due date', () {
      final due = DateTime.utc(2024, 5, 1);
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          scheduleType: ScheduleType.fixedDate,
          intervalValue: null,
          intervalUnit: null,
          fixedDueAt: due,
          lastMaintainedAt: due,
        ),
        now: DateTime.utc(2024, 6, 1),
      );
      expect(result.status, MaintenanceStatus.upToDate);
      expect(result.progress, 0);
    });

    test('due when now is past due date', () {
      final due = DateTime.utc(2024, 5, 1);
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          scheduleType: ScheduleType.fixedDate,
          intervalValue: null,
          intervalUnit: null,
          fixedDueAt: due,
          lastMaintainedAt: null,
          createdAt: DateTime.utc(2024, 1, 1),
        ),
        now: DateTime.utc(2024, 5, 2),
      );
      expect(result.status, MaintenanceStatus.due);
      expect(result.progress, 1);
    });
  });

  group('aggregate and usage owner', () {
    test('returns upToDate when no schedule', () {
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          scheduleType: null,
          intervalValue: null,
          intervalUnit: null,
        ),
      );
      expect(result.status, MaintenanceStatus.upToDate);
      expect(result.progress, 0);
    });

    test('aggregate picks worst status and max progress', () {
      final result = calculator.aggregate([
        const RuleStatusResult(
          status: MaintenanceStatus.upToDate,
          progress: 0.2,
        ),
        const RuleStatusResult(status: MaintenanceStatus.due, progress: 1),
      ]);
      expect(result.status, MaintenanceStatus.due);
      expect(result.progress, 1);
    });

    test('resolveUsageOwner walks ancestors', () {
      final car = sampleDevice(
        id: 'car',
        usageUnit: UsageIntervalUnit.km,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final oil = sampleDevice(id: 'oil', parentId: 'car', usageUnit: null);
      final owner = calculator.resolveUsageOwner(oil, {
        'car': car,
        'oil': oil,
      });
      expect(owner?.id, 'car');
    });

    test('resolveUsageOwner walks grandparent when parent has no unit', () {
      final car = sampleDevice(
        id: 'car',
        usageUnit: UsageIntervalUnit.km,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final engine = sampleDevice(
        id: 'engine',
        parentId: 'car',
        usageUnit: null,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final oil = sampleDevice(
        id: 'oil',
        parentId: 'engine',
        usageUnit: null,
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
      );
      final owner = calculator.resolveUsageOwner(oil, {
        'car': car,
        'engine': engine,
        'oil': oil,
      });
      expect(owner?.id, 'car');
    });

    test('resolveUsageOwner prefers self when self is usage owner', () {
      final device = sampleDevice(
        usageUnit: UsageIntervalUnit.hours,
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 500,
        intervalUnit: 'hours',
      );
      final owner = calculator.resolveUsageOwner(device, {device.id: device});
      expect(owner?.id, device.id);
    });

    test('descendantsOf returns nested children depth-first', () {
      final car = sampleDevice(
        id: 'car',
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final engine = sampleDevice(
        id: 'engine',
        parentId: 'car',
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final oil = sampleDevice(id: 'oil', parentId: 'engine');
      final brakes = sampleDevice(id: 'brakes', parentId: 'car');
      final found = calculator.descendantsOf('car', [
        car,
        engine,
        oil,
        brakes,
      ]);
      expect(found.map((d) => d.id).toSet(), {'engine', 'oil', 'brakes'});
    });

    test('calendar with baked initial offset shows partial progress', () {
      final result = calculator.evaluateDevice(
        device: sampleDevice(
          scheduleType: ScheduleType.calendarInterval,
          intervalValue: 6,
          intervalUnit: CalendarIntervalUnit.months.storageValue,
          lastMaintainedAt: DateTime.utc(2024, 4, 1),
          createdAt: DateTime.utc(2024, 6, 1),
        ),
        now: DateTime.utc(2024, 6, 1),
      );
      expect(result.progress, closeTo(1 / 3, 0.02));
      expect(result.status, MaintenanceStatus.upToDate);
    });

    test('usage child reaches due when owner usage crosses interval', () {
      final oil = sampleDevice(
        id: 'oil',
        parentId: 'car',
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
        usageAtLastMaintenance: 0,
      );
      final car = sampleDevice(
        id: 'car',
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 1000,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final result = calculator.evaluateDevice(device: oil, usageOwner: car);
      expect(result.status, MaintenanceStatus.due);
      expect(result.progress, 1);
    });
  });
}
