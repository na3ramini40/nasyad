import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/data/datasources/device_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource_impl.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/repositories/device_log_repository_impl.dart';
import 'package:nasyad/data/repositories/device_repository_impl.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

import '../helpers/fake_log_photo_storage.dart';
import '../helpers/fixtures.dart';
import '../sqlite_test_setup.dart';

void main() {
  setUpAll(setupSqliteForTests);

  late AppDatabase db;
  late DeviceRepositoryImpl devices;
  late DeviceLogRepositoryImpl logs;

  late FakeLogPhotoStorage photos;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    photos = FakeLogPhotoStorage();
    final deviceDs = DeviceLocalDataSourceImpl(db.deviceDao);
    final logDs = DeviceLogLocalDataSourceImpl(db.deviceLogDao);
    devices = DeviceRepositoryImpl(
      db: db,
      devices: deviceDs,
      logs: logDs,
      photos: photos,
    );
    logs = DeviceLogRepositoryImpl(
      db: db,
      logs: logDs,
      devices: deviceDs,
      photos: photos,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('create device and watch root summaries', () async {
    await devices.createDevice(sampleDevice());

    final summaries = await devices.watchRootDeviceSummaries().first.timeout(
      const Duration(seconds: 2),
    );
    expect(summaries, hasLength(1));
    expect(summaries.first.device.name, 'Pump');
    expect(summaries.first.status, isA<MaintenanceStatus>());
  });

  test('update device replaces schedule fields', () async {
    await devices.createDevice(sampleDevice());
    await devices.updateDevice(
      sampleDevice(
        name: 'Pump v2',
        intervalValue: 6,
        scheduleType: ScheduleType.calendarInterval,
      ),
    );

    final device = await devices.getDevice('device-1');
    expect(device?.name, 'Pump v2');
    expect(device?.intervalValue, 6);
  });

  test('setDeviceStatus archives and hides from active summaries', () async {
    await devices.createDevice(sampleDevice());
    await devices.setDeviceStatus('device-1', DeviceStatus.archived);

    final summaries = await devices.watchRootDeviceSummaries().first.timeout(
      const Duration(seconds: 2),
    );
    expect(summaries, isEmpty);

    final all = await devices.getAllDevices();
    expect(all.first.status, DeviceStatus.archived);
  });

  test('importBundle upserts devices and logs', () async {
    await devices.importBundle(sampleBundle());

    expect(await devices.getAllDevices(), hasLength(1));
    expect(await logs.getLogsForDevice('device-1'), hasLength(1));
  });

  test('getDevicesByIds returns matching devices', () async {
    await devices.createDevice(sampleDevice(id: 'a', name: 'A'));
    await devices.createDevice(sampleDevice(id: 'b', name: 'B'));

    final found = await devices.getDevicesByIds(const ['b']);
    expect(found.map((d) => d.id), ['b']);
  });

  test('usage update does not reset maintenance baseline', () async {
    await devices.createDevice(
      sampleDevice(
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 10,
        usageAtLastMaintenance: 10,
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
      ),
    );
    await logs.createLog(
      sampleLog(
        kind: DeviceLogKind.usageUpdate,
        usageValue: 110,
        usageUnit: UsageIntervalUnit.km,
      ),
    );

    final device = await devices.getDevice('device-1');
    expect(device?.currentUsage, 110);
    expect(device?.usageAtLastMaintenance, 10);
  });

  test('mark maintained resets baseline to current usage', () async {
    await devices.createDevice(
      sampleDevice(
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 500,
        usageAtLastMaintenance: 0,
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
      ),
    );
    await logs.createLog(
      sampleLog(kind: DeviceLogKind.maintenanceDone, usageValue: null),
    );

    final device = await devices.getDevice('device-1');
    expect(device?.usageAtLastMaintenance, 500);
    expect(device?.lastMaintainedAt, isNotNull);
  });

  test('createLog throws when device missing', () async {
    expect(() => logs.createLog(sampleLog()), throwsA(isA<StateError>()));
  });

  test('watchLogsForDevice emits inserted logs', () async {
    await devices.createDevice(sampleDevice());
    final future = logs
        .watchLogsForDevice('device-1')
        .firstWhere((items) => items.isNotEmpty)
        .timeout(const Duration(seconds: 2));
    await logs.createLog(sampleLog());
    final emitted = await future;
    expect(emitted.first.id, 'log-1');
  });

  test('children nest under parent and cascade archive', () async {
    await devices.createDevice(
      sampleDevice(
        id: 'car',
        name: 'Car',
        usageUnit: UsageIntervalUnit.km,
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
        usageAtLastMaintenance: 0,
      ),
    );

    final summary = await devices
        .watchDeviceSummary('car')
        .first
        .timeout(const Duration(seconds: 2));
    expect(summary?.children, hasLength(1));
    expect(summary?.children.first.device.id, 'oil');

    await devices.setDeviceStatus('car', DeviceStatus.archived);
    final all = await devices.getAllDevices();
    expect(all.every((d) => d.status == DeviceStatus.archived), isTrue);
  });

  test(
    'createDevice bakes calendar initialElapsed into lastMaintainedAt',
    () async {
      final before = DateTime.now();
      await devices.createDevice(
        sampleDevice(
          id: 'washer',
          name: 'Washer',
          scheduleType: ScheduleType.calendarInterval,
          intervalValue: 6,
          intervalUnit: 'months',
          lastMaintainedAt: null,
          createdAt: before,
        ),
        initialElapsed: 2,
      );
      final after = DateTime.now();
      final device = await devices.getDevice('washer');
      expect(device?.lastMaintainedAt, isNotNull);
      final anchor = device!.lastMaintainedAt!;
      expect(anchor.isBefore(before.add(const Duration(days: 1))), isTrue);
      expect(anchor.isAfter(after.subtract(const Duration(days: 70))), isTrue);
      expect(
        anchor.isBefore(before.subtract(const Duration(days: 40))),
        isTrue,
      );
    },
  );

  test(
    'createDevice bakes usage initialElapsed from parent odometer',
    () async {
      await devices.createDevice(
        sampleDevice(
          id: 'car',
          name: 'Car',
          usageUnit: UsageIntervalUnit.km,
          currentUsage: 10000,
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
          usageAtLastMaintenance: 0,
        ),
        initialElapsed: 300,
      );

      final oil = await devices.getDevice('oil');
      expect(oil?.usageAtLastMaintenance, 9700);

      final summary = await devices
          .watchDeviceSummary('oil')
          .first
          .timeout(const Duration(seconds: 2));
      expect(summary?.progress, closeTo(0.3, 0.02));
    },
  );

  test('root summary aggregates due child status', () async {
    await devices.createDevice(
      sampleDevice(
        id: 'car',
        name: 'Car',
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 1000,
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
        usageAtLastMaintenance: 0,
      ),
    );

    final roots = await devices.watchRootDeviceSummaries().first.timeout(
      const Duration(seconds: 2),
    );
    expect(roots, hasLength(1));
    expect(roots.first.device.id, 'car');
    expect(roots.first.status, MaintenanceStatus.due);
    expect(roots.first.progress, 1);
    expect(roots.first.children, hasLength(1));
  });

  test('getChildren returns only active direct children', () async {
    await devices.createDevice(
      sampleDevice(
        id: 'car',
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      ),
    );
    await devices.createDevice(
      sampleDevice(id: 'oil', parentId: 'car', name: 'Oil'),
    );
    await devices.createDevice(
      sampleDevice(id: 'brakes', parentId: 'car', name: 'Brakes'),
    );
    await devices.setDeviceStatus('brakes', DeviceStatus.archived);

    final children = await devices.getChildren('car');
    expect(children.map((d) => d.id), ['oil']);
  });

  test('usage update rejects reading below current usage', () async {
    await devices.createDevice(
      sampleDevice(
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 500,
        usageAtLastMaintenance: 0,
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
      ),
    );

    expect(
      () => logs.createLog(
        sampleLog(
          kind: DeviceLogKind.usageUpdate,
          usageValue: 400,
          usageUnit: UsageIntervalUnit.km,
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('three-level cascade archives all descendants', () async {
    await devices.createDevice(
      sampleDevice(
        id: 'car',
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      ),
    );
    await devices.createDevice(
      sampleDevice(
        id: 'engine',
        parentId: 'car',
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      ),
    );
    await devices.createDevice(
      sampleDevice(id: 'oil', parentId: 'engine', name: 'Oil'),
    );

    await devices.setDeviceStatus('car', DeviceStatus.deleted);
    final all = await devices.getAllDevices();
    expect(all.map((d) => d.status).toSet(), {DeviceStatus.deleted});
  });
}
