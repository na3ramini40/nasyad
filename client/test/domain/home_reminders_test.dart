import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/reminder_snooze_store.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/services/birthday_upcoming.dart';
import 'package:nasyad/domain/services/home_reminder_aggregator.dart';
import 'package:nasyad/domain/services/home_reminder_sorter.dart';

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

    test('respects configurable soon threshold for urgency checks', () {
      final birthday = sampleBirthday(birthMonth: 6, birthDay: 20);
      final upcoming = BirthdayUpcomingCalculator.calculate(
        birthday,
        now: DateTime(2024, 6, 1),
        soonThresholdDays: 14,
      );

      expect(upcoming?.daysUntil, 19);
    });
  });

  group('HomeReminderSorter', () {
    test('sorts due before soon before upcoming', () {
      final sorted = HomeReminderSorter.sort([
        const HomeReminder(
          id: 'upcoming',
          kind: HomeReminderKind.birthday,
          title: 'Zed',
          urgency: HomeReminderUrgency.upcoming,
          sortKey: 3000,
          daysUntilBirthday: 20,
        ),
        const HomeReminder(
          id: 'due',
          kind: HomeReminderKind.device,
          title: 'Alpha',
          urgency: HomeReminderUrgency.due,
          sortKey: 100,
          deviceStatus: MaintenanceStatus.due,
          deviceProgress: 1,
        ),
        const HomeReminder(
          id: 'soon',
          kind: HomeReminderKind.birthday,
          title: 'Bob',
          urgency: HomeReminderUrgency.soon,
          sortKey: 2005,
          daysUntilBirthday: 5,
        ),
      ]);

      expect(sorted.map((item) => item.id), ['due', 'soon', 'upcoming']);
    });

    test('sorts same urgency by nearest due date then title', () {
      final sorted = HomeReminderSorter.sort([
        const HomeReminder(
          id: 'later',
          kind: HomeReminderKind.birthday,
          title: 'Later',
          urgency: HomeReminderUrgency.soon,
          sortKey: 2010,
          daysUntilBirthday: 10,
        ),
        const HomeReminder(
          id: 'sooner',
          kind: HomeReminderKind.birthday,
          title: 'Sooner',
          urgency: HomeReminderUrgency.soon,
          sortKey: 2003,
          daysUntilBirthday: 3,
        ),
      ]);

      expect(sorted.map((item) => item.id), ['sooner', 'later']);
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
        snoozedReminderIds: const {},
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
        snoozedReminderIds: const {},
        now: DateTime(2024, 6, 1),
      );

      expect(reminders, hasLength(1));
      expect(reminders.single.kind, HomeReminderKind.device);
    });

    test('birthday today uses due urgency', () {
      final reminders = HomeReminderAggregator.build(
        deviceSummaries: const [],
        birthdays: [sampleBirthday(birthMonth: 6, birthDay: 10)],
        filter: HomeReminderFilter.all,
        snoozedReminderIds: const {},
        now: DateTime(2024, 6, 10),
      );

      expect(reminders, hasLength(1));
      expect(reminders.single.urgency, HomeReminderUrgency.due);
      expect(reminders.single.daysUntilBirthday, 0);
    });

    test('skips up to date devices', () {
      final reminders = HomeReminderAggregator.build(
        deviceSummaries: [sampleSummary(status: MaintenanceStatus.upToDate)],
        birthdays: const [],
        filter: HomeReminderFilter.all,
        snoozedReminderIds: const {},
        now: DateTime(2024, 6, 1),
      );

      expect(reminders, isEmpty);
    });

    test('hides snoozed reminders', () {
      final reminders = HomeReminderAggregator.build(
        deviceSummaries: [
          sampleSummary(
            device: sampleDevice(id: 'device-1'),
            status: MaintenanceStatus.due,
          ),
        ],
        birthdays: [sampleBirthday(id: 'birthday-1')],
        filter: HomeReminderFilter.all,
        snoozedReminderIds: {'device-device-1'},
        now: DateTime(2024, 6, 1),
      );

      expect(reminders, hasLength(1));
      expect(reminders.single.kind, HomeReminderKind.birthday);
    });

    test('uses soon window for birthday badge urgency', () {
      final reminders = HomeReminderAggregator.build(
        deviceSummaries: const [],
        birthdays: [sampleBirthday(birthMonth: 6, birthDay: 20)],
        filter: HomeReminderFilter.all,
        snoozedReminderIds: const {},
        soonWindowDays: 7,
        now: DateTime(2024, 6, 10),
      );

      expect(reminders.single.urgency, HomeReminderUrgency.upcoming);

      final widerWindow = HomeReminderAggregator.build(
        deviceSummaries: const [],
        birthdays: [sampleBirthday(birthMonth: 6, birthDay: 20)],
        filter: HomeReminderFilter.all,
        snoozedReminderIds: const {},
        soonWindowDays: 14,
        now: DateTime(2024, 6, 10),
      );

      expect(widerWindow.single.urgency, HomeReminderUrgency.soon);
    });
  });

  group('ReminderSnoozeStore', () {
    test('snooze hides reminder until date passes', () async {
      final store = ReminderSnoozeStore.memory();
      final now = DateTime(2024, 6, 1);

      await store.snooze(reminderId: 'device-1', days: 3, now: now);

      final active = await store.readActive(now: now);
      expect(active.keys, {'device-1'});
      expect(active['device-1'], DateTime(2024, 6, 4));

      final expired = await store.readActive(now: DateTime(2024, 6, 5));
      expect(expired, isEmpty);
    });
  });
}
