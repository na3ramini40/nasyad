import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/usecases/device/archive_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_all_devices_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/restore_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_archived_root_devices_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summary_usecase.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository repository;

  setUp(() {
    repository = FakeDeviceRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  test('CreateDeviceUsecase validates name and delegates', () async {
    final usecase = CreateDeviceUsecase(repository);
    expect(
      () => usecase(sampleDevice(name: '  ')),
      throwsA(isA<ArgumentError>()),
    );

    await usecase(sampleDevice(), initialElapsed: 1);
    expect(repository.createCalls, 1);
    expect(repository.lastInitialElapsed, 1);
    expect(repository.devices, hasLength(1));
  });

  test('CreateDeviceUsecase rejects negative initialElapsed', () {
    final usecase = CreateDeviceUsecase(repository);
    expect(
      () => usecase(sampleDevice(), initialElapsed: -1),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('CreateDeviceUsecase rejects initialElapsed above interval', () {
    final usecase = CreateDeviceUsecase(repository);
    expect(
      () => usecase(sampleDevice(intervalValue: 1000), initialElapsed: 1001),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('CreateDeviceUsecase allows container with no schedule', () async {
    final usecase = CreateDeviceUsecase(repository);
    await usecase(
      sampleDevice(scheduleType: null, intervalValue: null, intervalUnit: null),
    );
    expect(repository.createCalls, 1);
    expect(repository.devices.first.hasSchedule, isFalse);
  });

  test('CreateDeviceUsecase requires interval when schedule set', () {
    final usecase = CreateDeviceUsecase(repository);
    expect(
      () => usecase(
        sampleDevice(
          scheduleType: ScheduleType.calendarInterval,
          intervalValue: 0,
          intervalUnit: 'months',
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('UpdateDeviceUsecase validates name and delegates', () async {
    final usecase = UpdateDeviceUsecase(repository);
    expect(
      () => usecase(sampleDevice(name: '')),
      throwsA(isA<ArgumentError>()),
    );

    await usecase(sampleDevice());
    expect(repository.updateCalls, 1);
  });

  test('DeleteDeviceUsecase sets deleted status', () async {
    await DeleteDeviceUsecase(repository)('device-1');
    expect(repository.statusChanges.single.$1, 'device-1');
    expect(repository.statusChanges.single.$2, DeviceStatus.deleted);
  });

  test('ArchiveDeviceUsecase sets archived status', () async {
    await ArchiveDeviceUsecase(repository)('device-1');
    expect(repository.statusChanges.single.$1, 'device-1');
    expect(repository.statusChanges.single.$2, DeviceStatus.archived);
  });

  test('RestoreDeviceUsecase sets active status', () async {
    await RestoreDeviceUsecase(repository)('device-1');
    expect(repository.statusChanges.single.$1, 'device-1');
    expect(repository.statusChanges.single.$2, DeviceStatus.active);
  });

  test('WatchArchivedRootDevicesUsecase exposes repository stream', () async {
    final usecase = WatchArchivedRootDevicesUsecase(repository);
    final future = usecase().first;
    repository.emitArchivedRoots([
      sampleDevice(id: 'archived-1', status: DeviceStatus.archived),
    ]);
    final items = await future;
    expect(items, hasLength(1));
    expect(items.first.id, 'archived-1');
  });

  test('GetDeviceUsecase returns device or null', () async {
    repository.devices.add(sampleDevice());
    final usecase = GetDeviceUsecase(repository);
    expect((await usecase('device-1'))?.name, 'Pump');
    expect(await usecase('missing'), isNull);
  });

  test('GetAllDevicesUsecase returns all devices', () async {
    repository.devices.addAll([
      sampleDevice(id: 'a', name: 'A'),
      sampleDevice(id: 'b', name: 'B'),
    ]);
    final result = await GetAllDevicesUsecase(repository)();
    expect(result.map((d) => d.id), ['a', 'b']);
  });

  test('WatchDeviceSummariesUsecase exposes repository stream', () async {
    final usecase = WatchDeviceSummariesUsecase(repository);
    final future = usecase().first;
    repository.emitSummaries([sampleSummary()]);
    final items = await future;
    expect(items, hasLength(1));
  });

  test('WatchDeviceSummaryUsecase exposes detail stream', () async {
    final usecase = WatchDeviceSummaryUsecase(repository);
    final future = usecase('device-1').first;
    repository.emitDetail(sampleSummary());
    final item = await future;
    expect(item?.device.id, 'device-1');
  });
}
