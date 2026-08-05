import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/services/birthday_upcoming.dart';
import 'package:nasyad/domain/services/home_reminder_aggregator.dart';

import '../helpers/fixtures.dart';

Birthday sampleBirthday({
  String id = 'birthday-1',
  String name = 'Ali',
  int birthMonth = 6,
  int birthDay = 15,
  CalendarSystem calendarSystem = CalendarSystem.gregorian,
}) {
  return Birthday(
    id: id,
    name: name,
    birthMonth: birthMonth,
    birthDay: birthDay,
    calendarSystem: calendarSystem,
    createdAt: t0,
    updatedAt: t0,
  );
}

void main() {
  group('BirthdayUpcomingCalculator', () {
    test('returns days until next gregorian birthday', () {
      final birthday = sampleBirthday(birthMonth: 6, birthDay: 10);
      final upcoming = BirthdayUpcomingCalculator.calculate(
        birthday,
        now: DateTime(2024, 6, 5),
      );

      expect(upcoming, isNotNull);
      expect(upcoming!.daysUntil, 5);
      expect(upcoming.isToday, isFalse);
    });

    test('returns today when birthday matches', () {
      final birthday = sampleBirthday(birthMonth: 6, birthDay: 10);
      final upcoming = BirthdayUpcomingCalculator.calculate(
        birthday,
        now: DateTime(2024, 6, 10),
      );

      expect(upcoming?.daysUntil, 0);
      expect(upcoming?.isToday, isTrue);
    });

    test('returns null when birthday is outside reminder window', () {
      final birthday = sampleBirthday(birthMonth: 12, birthDay: 25);
      final upcoming = BirthdayUpcomingCalculator.calculate(
        birthday,
        now: DateTime(2024, 1, 1),
      );

      expect(upcoming, isNull);
    });
  });

  group('HomeReminderAggregator', () {
    test('includes due devices and upcoming birthdays sorted by urgency', () {
      final reminders = HomeReminderAggregator.build(
        deviceSummaries: [
          sampleSummary(status: MaintenanceStatus.soon),
          sampleSummary(
            device: sampleDevice(id: 'device-2', name: 'Car'),
            status: MaintenanceStatus.due,
            progress: 1.1,
          ),
        ],
        birthdays: [sampleBirthday(birthMonth: 6, birthDay: 3)],
        filter: HomeReminderFilter.all,
        now: DateTime(2024, 6, 1),
      );

      expect(reminders, hasLength(3));
      expect(reminders.first.kind, HomeReminderKind.device);
      expect(reminders.first.deviceId, 'device-2');
      expect(
        reminders.any((item) => item.kind == HomeReminderKind.birthday),
        isTrue,
      );
    });

    test('filters devices only', () {
      final reminders = HomeReminderAggregator.build(
        deviceSummaries: [sampleSummary(status: MaintenanceStatus.due)],
        birthdays: [sampleBirthday(birthMonth: 6, birthDay: 3)],
        filter: HomeReminderFilter.devices,
        now: DateTime(2024, 6, 1),
      );

      expect(reminders, hasLength(1));
      expect(reminders.single.kind, HomeReminderKind.device);
    });

    test('skips up to date devices', () {
      final reminders = HomeReminderAggregator.build(
        deviceSummaries: [sampleSummary(status: MaintenanceStatus.upToDate)],
        birthdays: const [],
        filter: HomeReminderFilter.all,
        now: DateTime(2024, 6, 1),
      );

      expect(reminders, isEmpty);
    });
  });
}
