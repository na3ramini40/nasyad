import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

import '../helpers/fixtures.dart';

void main() {
  group('DeviceStatusX', () {
    test('round-trips storage values', () {
      for (final status in DeviceStatus.values) {
        expect(DeviceStatusX.fromStorage(status.storageValue), status);
      }
    });

    test('falls back to active for unknown value', () {
      expect(DeviceStatusX.fromStorage('nope'), DeviceStatus.active);
    });
  });

  group('ScheduleTypeX', () {
    test('round-trips storage values', () {
      for (final type in ScheduleType.values) {
        expect(ScheduleTypeX.fromStorage(type.storageValue), type);
      }
    });

    test('falls back to calendarInterval for unknown value', () {
      expect(
        ScheduleTypeX.fromStorage('unknown'),
        ScheduleType.calendarInterval,
      );
    });
  });

  group('interval units', () {
    test('calendar units round-trip and default', () {
      for (final unit in CalendarIntervalUnit.values) {
        expect(CalendarIntervalUnitX.fromStorage(unit.storageValue), unit);
      }
      expect(
        CalendarIntervalUnitX.fromStorage('x'),
        CalendarIntervalUnit.months,
      );
    });

    test('usage units round-trip and default', () {
      for (final unit in UsageIntervalUnit.values) {
        expect(UsageIntervalUnitX.fromStorage(unit.storageValue), unit);
      }
      expect(UsageIntervalUnitX.fromStorage('x'), UsageIntervalUnit.hours);
    });
  });

  group('MaintenanceStatus.worst', () {
    test('returns highest severity', () {
      expect(
        MaintenanceStatus.worst(const [
          MaintenanceStatus.upToDate,
          MaintenanceStatus.soon,
          MaintenanceStatus.due,
        ]),
        MaintenanceStatus.due,
      );
    });

    test('returns upToDate for empty', () {
      expect(MaintenanceStatus.worst(const []), MaintenanceStatus.upToDate);
    });
  });

  group('Device', () {
    test('copyWith replaces selected fields', () {
      final device = sampleDevice();
      final updated = device.copyWith(name: 'Valve', currentUsage: 9);
      expect(updated.name, 'Valve');
      expect(updated.currentUsage, 9);
      expect(updated.id, device.id);
    });

    test('equality uses equatable props', () {
      expect(sampleDevice(), sampleDevice());
      expect(sampleDevice(name: 'A'), isNot(sampleDevice(name: 'B')));
    });

    test('hasSchedule reflects scheduleType', () {
      expect(sampleDevice().hasSchedule, isTrue);
      expect(
        sampleDevice(
          scheduleType: null,
          intervalValue: null,
          intervalUnit: null,
        ).hasSchedule,
        isFalse,
      );
    });
  });

  group('ExportBundle', () {
    test('counts devices and logs', () {
      final bundle = sampleBundle();
      expect(bundle.deviceCount, 1);
      expect(bundle.logCount, 1);
      expect(bundle.version, 2);
    });
  });

  group('ExportFormatX', () {
    test('exposes extension and mime', () {
      expect(ExportFormat.json.fileExtension, 'json');
      expect(ExportFormat.csv.mimeType, 'text/csv');
      expect(ExportFormat.plainText.fileExtension, 'txt');
    });
  });

  group('DeviceLog', () {
    test('equality', () {
      expect(sampleLog(), sampleLog());
      expect(sampleLog(id: 'a'), isNot(sampleLog(id: 'b')));
    });
  });
}
