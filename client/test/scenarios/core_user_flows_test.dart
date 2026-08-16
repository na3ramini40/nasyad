import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/reminder_snooze_store.dart';
import 'package:nasyad/core/preferences/soon_window_preference_store.dart';
import 'package:nasyad/data/datasources/device_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource_impl.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/repositories/device_log_repository_impl.dart';
import 'package:nasyad/data/repositories/device_repository_impl.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/services/home_reminder_aggregator.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/home/snooze_home_reminder_usecase.dart';
import 'package:nasyad/domain/usecases/home/watch_home_reminders_usecase.dart';
import 'package:nasyad/presentation/home/bloc/home_bloc.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fake_log_photo_storage.dart';
import '../helpers/fixtures.dart';
import '../sqlite_test_setup.dart';

void main() {
  setUpAll(setupSqliteForTests);

  group('adding devices — all schedule shapes', () {
    late AppDatabase db;
    late DeviceRepositoryImpl devices;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      final deviceDs = DeviceLocalDataSourceImpl(db.deviceDao);
      final logDs = DeviceLogLocalDataSourceImpl(db.deviceLogDao);
      devices = DeviceRepositoryImpl(
        db: db,
        devices: deviceDs,
        logs: logDs,
        photos: FakeLogPhotoStorage(),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('container root with no schedule', () async {
      await devices.createDevice(
        sampleDevice(
          id: 'garage',
          name: 'Garage',
          scheduleType: null,
          intervalValue: null,
          intervalUnit: null,
        ),
      );

      final summary = await devices.watchRootDeviceSummaries().first.timeout(
        const Duration(seconds: 2),
      );
      expect(summary.single.device.name, 'Garage');
      expect(summary.single.status, MaintenanceStatus.upToDate);
    });

    test('calendar interval root device', () async {
      final anchor = DateTime.now().subtract(const Duration(days: 30));
      await devices.createDevice(
        sampleDevice(
          id: 'filter',
          name: 'Filter',
          scheduleType: ScheduleType.calendarInterval,
          intervalValue: 3,
          intervalUnit: 'months',
          lastMaintainedAt: anchor,
          createdAt: anchor,
        ),
      );

      final summary = await devices.watchRootDeviceSummaries().first.timeout(
        const Duration(seconds: 2),
      );
      expect(summary.single.device.scheduleType, ScheduleType.calendarInterval);
      expect(summary.single.status, isA<MaintenanceStatus>());
    });

    test('usage interval root with usage unit', () async {
      await devices.createDevice(
        sampleDevice(
          id: 'bike',
          name: 'Bike',
          usageUnit: UsageIntervalUnit.km,
          currentUsage: 500,
          scheduleType: ScheduleType.usageInterval,
          intervalValue: 1000,
          intervalUnit: 'km',
          usageAtLastMaintenance: 0,
        ),
      );

      final summary = await devices.watchRootDeviceSummaries().first.timeout(
        const Duration(seconds: 2),
      );
      expect(summary.single.device.usageUnit, UsageIntervalUnit.km);
      expect(summary.single.progress, closeTo(0.5, 0.01));
    });

    test('usage child under usage owner parent', () async {
      await devices.createDevice(
        sampleDevice(
          id: 'car',
          name: 'Car',
          usageUnit: UsageIntervalUnit.km,
          currentUsage: 8500,
          scheduleType: null,
          intervalValue: null,
          intervalUnit: null,
        ),
      );
      await devices.createDevice(
        sampleDevice(
          id: 'oil',
          parentId: 'car',
          name: 'Oil',
          scheduleType: ScheduleType.usageInterval,
          intervalValue: 1000,
          intervalUnit: 'km',
          usageAtLastMaintenance: 7700,
        ),
        initialElapsed: 0,
      );

      final child = await devices
          .watchDeviceSummary('oil')
          .first
          .timeout(const Duration(seconds: 2));
      expect(child?.status, MaintenanceStatus.soon);
      expect(child?.progress, closeTo(0.8, 0.02));
    });

    test('fixed date device reports soon then due near deadline', () async {
      final dueAt = DateTime.now().add(const Duration(days: 6));
      await devices.createDevice(
        sampleDevice(
          id: 'annual',
          name: 'Annual check',
          scheduleType: ScheduleType.fixedDate,
          intervalValue: 1,
          intervalUnit: 'days',
          fixedDueAt: dueAt,
          lastMaintainedAt: null,
          createdAt: dueAt.subtract(const Duration(days: 30)),
        ),
      );

      final summary = await devices.watchRootDeviceSummaries().first.timeout(
        const Duration(seconds: 2),
      );
      expect(summary.single.status, MaintenanceStatus.soon);
    });
  });

  group('adding device logs — maintenance and usage', () {
    late AppDatabase db;
    late DeviceRepositoryImpl devices;
    late DeviceLogRepositoryImpl logs;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      final deviceDs = DeviceLocalDataSourceImpl(db.deviceDao);
      final logDs = DeviceLogLocalDataSourceImpl(db.deviceLogDao);
      devices = DeviceRepositoryImpl(
        db: db,
        devices: deviceDs,
        logs: logDs,
        photos: FakeLogPhotoStorage(),
      );
      logs = DeviceLogRepositoryImpl(
        db: db,
        logs: logDs,
        devices: deviceDs,
        photos: FakeLogPhotoStorage(),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('maintenance done on scheduled device clears due status', () async {
      await devices.createDevice(
        sampleDevice(
          usageUnit: UsageIntervalUnit.km,
          currentUsage: 1000,
          usageAtLastMaintenance: 0,
          scheduleType: ScheduleType.usageInterval,
          intervalValue: 1000,
          intervalUnit: 'km',
        ),
      );

      var summary = await devices.watchRootDeviceSummaries().first.timeout(
        const Duration(seconds: 2),
      );
      expect(summary.single.status, MaintenanceStatus.due);

      await logs.createLog(
        sampleLog(
          kind: DeviceLogKind.maintenanceDone,
          usageValue: 1000,
          usageUnit: UsageIntervalUnit.km,
        ),
      );

      summary = await devices.watchRootDeviceSummaries().first.timeout(
        const Duration(seconds: 2),
      );
      expect(summary.single.status, MaintenanceStatus.upToDate);
      expect(summary.single.remainingUsage, 1000);
      expect(summary.single.targetUsage, 2000);
    });

    test(
      'usage update advances reading without resetting maintenance',
      () async {
        await devices.createDevice(
          sampleDevice(
            usageUnit: UsageIntervalUnit.km,
            currentUsage: 100,
            usageAtLastMaintenance: 100,
            scheduleType: ScheduleType.usageInterval,
            intervalValue: 1000,
            intervalUnit: 'km',
          ),
        );

        await logs.createLog(
          sampleLog(
            kind: DeviceLogKind.usageUpdate,
            usageValue: 900,
            usageUnit: UsageIntervalUnit.km,
          ),
        );

        final device = await devices.getDevice('device-1');
        expect(device?.currentUsage, 900);
        expect(device?.usageAtLastMaintenance, 100);

        final summary = await devices.watchRootDeviceSummaries().first.timeout(
          const Duration(seconds: 2),
        );
        expect(summary.single.status, MaintenanceStatus.soon);
      },
    );

    test('maintenance log on child resets child baseline only', () async {
      await devices.createDevice(
        sampleDevice(
          id: 'car',
          usageUnit: UsageIntervalUnit.km,
          currentUsage: 9000,
          scheduleType: null,
          intervalValue: null,
          intervalUnit: null,
        ),
      );
      await devices.createDevice(
        sampleDevice(
          id: 'oil',
          parentId: 'car',
          name: 'Oil',
          scheduleType: ScheduleType.usageInterval,
          intervalValue: 1000,
          intervalUnit: 'km',
          usageAtLastMaintenance: 8000,
        ),
      );

      await logs.createLog(
        sampleLog(
          id: 'log-oil',
          deviceId: 'oil',
          kind: DeviceLogKind.maintenanceDone,
          usageValue: 9000,
          usageUnit: UsageIntervalUnit.km,
        ),
      );

      final oil = await devices.getDevice('oil');
      expect(oil?.usageAtLastMaintenance, 9000);

      final car = await devices.getDevice('car');
      expect(car?.currentUsage, 9000);

      final childSummary = await devices
          .watchDeviceSummary('oil')
          .first
          .timeout(const Duration(seconds: 2));
      expect(childSummary?.status, MaintenanceStatus.upToDate);
      expect(childSummary?.remainingUsage, 1000);
      expect(childSummary?.targetUsage, 10000);
    });
  });

  group('user informed when device or birthday is close', () {
    test(
      'home reminders include calendar-soon, usage-due, and birthday-soon',
      () {
        final anchor = DateTime(2024, 6, 1);
        final reminders = HomeReminderAggregator.build(
          deviceSummaries: [
            sampleSummary(
              device: sampleDevice(
                id: 'cal',
                name: 'HVAC filter',
                intervalValue: 10,
                intervalUnit: 'days',
                lastMaintainedAt: DateTime(2024, 6, 1),
                createdAt: DateTime(2024, 6, 1),
              ),
              status: MaintenanceStatus.soon,
              progress: 0.85,
            ),
            sampleSummary(
              device: sampleDevice(
                id: 'usage',
                name: 'Generator',
                usageUnit: UsageIntervalUnit.hours,
                scheduleType: ScheduleType.usageInterval,
                intervalValue: 500,
                intervalUnit: 'hours',
              ),
              status: MaintenanceStatus.due,
              progress: 1,
            ),
            sampleSummary(
              device: sampleDevice(
                id: 'ok',
                name: 'Spare',
                scheduleType: null,
                intervalValue: null,
                intervalUnit: null,
              ),
              status: MaintenanceStatus.upToDate,
            ),
          ],
          birthdays: [
            Birthday(
              id: 'b-soon',
              name: 'Nima',
              birthMonth: 6,
              birthDay: 5,
              calendarSystem: CalendarSystem.gregorian,
              createdAt: anchor,
              updatedAt: anchor,
            ),
            Birthday(
              id: 'b-later',
              name: 'Leila',
              birthMonth: 7,
              birthDay: 1,
              calendarSystem: CalendarSystem.gregorian,
              createdAt: anchor,
              updatedAt: anchor,
            ),
          ],
          filter: HomeReminderFilter.all,
          snoozedReminderIds: const {},
          now: DateTime(2024, 6, 1),
        );

        expect(reminders, hasLength(4));

        final calendarSoon = reminders.firstWhere((r) => r.deviceId == 'cal');
        expect(calendarSoon.urgency, HomeReminderUrgency.soon);
        expect(calendarSoon.deviceStatus, MaintenanceStatus.soon);

        final usageDue = reminders.firstWhere((r) => r.deviceId == 'usage');
        expect(usageDue.urgency, HomeReminderUrgency.due);

        final birthdaySoon = reminders.firstWhere(
          (r) => r.birthdayId == 'b-soon',
        );
        expect(birthdaySoon.urgency, HomeReminderUrgency.soon);
        expect(birthdaySoon.daysUntilBirthday, 4);

        final birthdayUpcoming = reminders.firstWhere(
          (r) => r.birthdayId == 'b-later',
        );
        expect(birthdayUpcoming.urgency, HomeReminderUrgency.upcoming);

        expect(reminders.any((r) => r.deviceId == 'ok'), isFalse);
      },
    );

    test(
      'watch home reminders streams soon device after repository create',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(() => db.close());
        final deviceDs = DeviceLocalDataSourceImpl(db.deviceDao);
        final logDs = DeviceLogLocalDataSourceImpl(db.deviceLogDao);
        final deviceRepo = DeviceRepositoryImpl(
          db: db,
          devices: deviceDs,
          logs: logDs,
          photos: FakeLogPhotoStorage(),
        );
        final birthdayRepo = FakeBirthdayRepository();
        addTearDown(() => birthdayRepo.dispose());

        final snoozeStore = ReminderSnoozeStore.memory();
        final soonWindowStore = SoonWindowPreferenceStore.memory();
        addTearDown(() {
          snoozeStore.dispose();
          soonWindowStore.dispose();
        });

        final usecase = WatchHomeRemindersUsecase(
          WatchDeviceSummariesUsecase(deviceRepo),
          WatchBirthdaysUsecase(birthdayRepo),
          snoozeStore,
          soonWindowStore,
        );
        final future = usecase(filter: HomeReminderFilter.all)
            .firstWhere((items) => items.isNotEmpty)
            .timeout(const Duration(seconds: 2));

        final anchor = DateTime.now().subtract(const Duration(days: 9));
        await deviceRepo.createDevice(
          sampleDevice(
            id: 'pump',
            name: 'Pump',
            scheduleType: ScheduleType.calendarInterval,
            intervalValue: 10,
            intervalUnit: 'days',
            lastMaintainedAt: anchor,
            createdAt: anchor,
          ),
        );
        birthdayRepo.emit();
        final reminders = await future;

        expect(reminders, hasLength(1));
        expect(reminders.single.title, 'Pump');
        expect(reminders.single.urgency, HomeReminderUrgency.soon);
      },
    );

    test(
      'home bloc surfaces soon and due device reminders to the user',
      () async {
        final deviceRepo = FakeDeviceRepository();
        final birthdayRepo = FakeBirthdayRepository();
        final snoozeStore = ReminderSnoozeStore.memory();
        final soonWindowStore = SoonWindowPreferenceStore.memory();
        final bloc = HomeBloc(
          WatchHomeRemindersUsecase(
            WatchDeviceSummariesUsecase(deviceRepo),
            WatchBirthdaysUsecase(birthdayRepo),
            snoozeStore,
            soonWindowStore,
          ),
          SnoozeHomeReminderUsecase(snoozeStore),
        );
        addTearDown(() async {
          await bloc.close();
          await deviceRepo.dispose();
          await birthdayRepo.dispose();
          snoozeStore.dispose();
          soonWindowStore.dispose();
        });

        expectLater(
          bloc.stream,
          emitsInOrder([
            const HomeLoading(),
            isA<HomeLoaded>(),
            isA<HomeLoaded>()
                .having((s) => s.visibleReminders, 'visible', hasLength(2))
                .having(
                  (s) => s.visibleReminders.map((r) => r.urgency).toSet(),
                  'urgencies',
                  {HomeReminderUrgency.soon, HomeReminderUrgency.due},
                ),
          ]),
        );

        bloc.add(const HomeStarted());
        await Future<void>.delayed(Duration.zero);
        deviceRepo.emitSummaries([
          sampleSummary(
            device: sampleDevice(id: 'soon', name: 'Filter'),
            status: MaintenanceStatus.soon,
            progress: 0.82,
          ),
          sampleSummary(
            device: sampleDevice(id: 'due', name: 'Motor'),
            status: MaintenanceStatus.due,
            progress: 1,
          ),
          sampleSummary(
            device: sampleDevice(id: 'ok', name: 'Shelf'),
            status: MaintenanceStatus.upToDate,
          ),
        ]);
        birthdayRepo.emit();
      },
    );
  });
}
