import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/services/device_schedule_baseline.dart';

import '../helpers/fixtures.dart';

void main() {
  final now = DateTime.utc(2024, 6, 15, 12);

  group('DeviceScheduleBaseline.applyInitialElapsed', () {
    test('returns unchanged when initialElapsed is 0', () {
      final device = sampleDevice();
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: device,
        initialElapsed: 0,
        usageOwner: null,
        now: now,
      );
      expect(result, device);
    });

    test('returns unchanged when device has no schedule', () {
      final device = sampleDevice(
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: device,
        initialElapsed: 2,
        usageOwner: null,
        now: now,
      );
      expect(result, device);
    });

    test('calendar months: lastMaintainedAt = now - initialElapsed', () {
      final device = sampleDevice(
        scheduleType: ScheduleType.calendarInterval,
        intervalValue: 6,
        intervalUnit: CalendarIntervalUnit.months.storageValue,
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: device,
        initialElapsed: 2,
        usageOwner: null,
        now: now,
      );
      final anchor = result.lastMaintainedAt!;
      expect(anchor.year, 2024);
      expect(anchor.month, 4);
      expect(anchor.day, 15);
      expect(anchor.hour, 12);
    });

    test('calendar days subtracts correctly', () {
      final device = sampleDevice(
        scheduleType: ScheduleType.calendarInterval,
        intervalValue: 30,
        intervalUnit: CalendarIntervalUnit.days.storageValue,
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: device,
        initialElapsed: 10,
        usageOwner: null,
        now: now,
      );
      expect(result.lastMaintainedAt, DateTime.utc(2024, 6, 5, 12));
    });

    test('calendar weeks subtracts correctly', () {
      final device = sampleDevice(
        scheduleType: ScheduleType.calendarInterval,
        intervalValue: 4,
        intervalUnit: CalendarIntervalUnit.weeks.storageValue,
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: device,
        initialElapsed: 1,
        usageOwner: null,
        now: now,
      );
      expect(result.lastMaintainedAt, DateTime.utc(2024, 6, 8, 12));
    });

    test('usage: usageAtLastMaintenance = ownerUsage - initialElapsed', () {
      final owner = sampleDevice(
        id: 'car',
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 10000,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final oil = sampleDevice(
        id: 'oil',
        parentId: 'car',
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: UsageIntervalUnit.km.storageValue,
        usageAtLastMaintenance: 0,
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: oil,
        initialElapsed: 300,
        usageOwner: owner,
        now: now,
      );
      expect(result.usageAtLastMaintenance, 9700);
      expect(result.lastMaintainedAt, now);
    });

    test('usage falls back to device.currentUsage when no owner', () {
      final device = sampleDevice(
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 500,
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
        usageAtLastMaintenance: 0,
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: device,
        initialElapsed: 100,
        usageOwner: null,
        now: now,
      );
      expect(result.usageAtLastMaintenance, 400);
    });

    test('usage clamps baseline at 0 when initial exceeds owner usage', () {
      final owner = sampleDevice(
        id: 'car',
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 50,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      );
      final oil = sampleDevice(
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: oil,
        initialElapsed: 200,
        usageOwner: owner,
        now: now,
      );
      expect(result.usageAtLastMaintenance, 0);
    });

    test('fixedDate sets lastMaintainedAt to now', () {
      final device = sampleDevice(
        scheduleType: ScheduleType.fixedDate,
        intervalValue: null,
        intervalUnit: null,
        fixedDueAt: DateTime.utc(2024, 12, 1),
        lastMaintainedAt: t0,
      );
      final result = DeviceScheduleBaseline.applyInitialElapsed(
        device: device,
        initialElapsed: 1,
        usageOwner: null,
        now: now,
      );
      expect(result.lastMaintainedAt, now);
    });
  });
}
