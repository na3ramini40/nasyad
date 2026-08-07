import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/services/local_reminder_planner.dart';

HomeReminder deviceReminder({
  String id = 'device-1',
  String deviceId = 'device-1',
  MaintenanceStatus status = MaintenanceStatus.due,
}) {
  return HomeReminder(
    id: 'device-$deviceId',
    kind: HomeReminderKind.device,
    title: 'Boiler',
    urgency: status == MaintenanceStatus.due
        ? HomeReminderUrgency.due
        : HomeReminderUrgency.soon,
    sortKey: 100,
    deviceId: deviceId,
    deviceStatus: status,
  );
}

HomeReminder birthdayReminder({
  String id = 'birthday-1',
  String birthdayId = 'birthday-1',
  int daysUntil = 0,
}) {
  return HomeReminder(
    id: 'birthday-$birthdayId',
    kind: HomeReminderKind.birthday,
    title: 'Ali',
    urgency: daysUntil == 0
        ? HomeReminderUrgency.due
        : HomeReminderUrgency.soon,
    sortKey: 2000 + daysUntil,
    birthdayId: birthdayId,
    daysUntilBirthday: daysUntil,
  );
}

void main() {
  group('LocalReminderPlanner', () {
    test('returns empty plans when disabled', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [deviceReminder()],
        enabled: false,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 8),
      );

      expect(plans, isEmpty);
    });

    test('plans daily device reminder at next preferred time', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [deviceReminder()],
        enabled: true,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 8),
      );

      expect(plans, hasLength(1));
      expect(plans.single.repeatsDaily, isTrue);
      expect(plans.single.scheduledAt, DateTime(2024, 6, 1, 9));
      expect(plans.single.deepLinkUri, 'nasyad:///device/device-1');
    });

    test('rolls device reminder to tomorrow after preferred time', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [deviceReminder()],
        enabled: true,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 10),
      );

      expect(plans.single.scheduledAt, DateTime(2024, 6, 2, 9));
    });

    test('plans birthday today at preferred time', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [birthdayReminder(daysUntil: 0)],
        enabled: true,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 8),
      );

      expect(plans.single.repeatsDaily, isFalse);
      expect(plans.single.scheduledAt, DateTime(2024, 6, 1, 9));
      expect(plans.single.deepLinkUri, 'nasyad:///birthdays/birthday-1/edit');
    });

    test('plans birthday tomorrow reminder for today', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [birthdayReminder(daysUntil: 1)],
        enabled: true,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 8),
      );

      expect(plans.single.scheduledAt, DateTime(2024, 6, 1, 9));
    });

    test('plans soon birthday on the birthday date', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [birthdayReminder(daysUntil: 5)],
        enabled: true,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 8),
      );

      expect(plans.single.scheduledAt, DateTime(2024, 6, 6, 9));
    });

    test('plans upcoming birthday seven days before', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [birthdayReminder(daysUntil: 15)],
        enabled: true,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 8),
      );

      expect(plans.single.scheduledAt, DateTime(2024, 6, 9, 9));
    });

    test('skips birthday plan when preferred time already passed today', () {
      final plans = LocalReminderPlanner.plan(
        reminders: [birthdayReminder(daysUntil: 0)],
        enabled: true,
        hour: 9,
        minute: 0,
        now: DateTime(2024, 6, 1, 10),
      );

      expect(plans, isEmpty);
    });
  });
}
