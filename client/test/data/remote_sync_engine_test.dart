import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/sync_preference_store.dart';
import 'package:nasyad/core/sync/network_status_reader.dart';
import 'package:nasyad/core/sync/sync_state_store.dart';
import 'package:nasyad/data/datasources/birthday_local_datasource.dart';
import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/datasources/sync_remote_datasource.dart';
import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/services/remote_sync_engine.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/services/local_sync_coordinator.dart';
import 'package:nasyad/domain/services/remote_sync_port.dart';

import '../helpers/fixtures.dart';

void main() {
  group('SyncStateStore', () {
    test('memory read/write cursors round-trip as UTC', () async {
      final store = SyncStateStore.memory();
      expect(await store.readDevicesUpdatedSince(), isNull);

      final stamp = DateTime.utc(2026, 3, 1, 12);
      await store.writeDevicesUpdatedSince(stamp);
      await store.writeDeviceLogsCreatedSince(stamp);
      await store.writeBirthdaysUpdatedSince(stamp);

      expect(await store.readDevicesUpdatedSince(), stamp);
      expect(await store.readDeviceLogsCreatedSince(), stamp);
      expect(await store.readBirthdaysUpdatedSince(), stamp);
    });
  });

  group('Conflict detection', () {
    test(
      'same id different name → conflict; identical → none; remote-only → none',
      () async {
        final devices = _MemoryDevices()
          ..seed(
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd1',
                name: 'Local',
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ),
          )
          ..seed(
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd2',
                name: 'Same',
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ),
          );
        final birthdays = _MemoryBirthdays()
          ..seed(
            BirthdayModel.fromEntity(
              sampleBirthday(
                id: 'b1',
                name: 'Local B',
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ),
          );
        final remote = _RecordingRemote()
          ..pulledDevices = [
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd1',
                name: 'Remote',
                updatedAt: DateTime.utc(2026, 3, 1),
              ),
            ),
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd2',
                name: 'Same',
                updatedAt: DateTime.utc(2026, 3, 1),
              ),
            ),
            DeviceModel.fromEntity(sampleDevice(id: 'd3', name: 'Remote only')),
          ]
          ..pulledBirthdays = [
            BirthdayModel.fromEntity(
              sampleBirthday(
                id: 'b1',
                name: 'Remote B',
                updatedAt: DateTime.utc(2026, 3, 1),
              ),
            ),
            BirthdayModel.fromEntity(
              sampleBirthday(id: 'b2', name: 'Remote only B'),
            ),
          ];

        final engine = RemoteSyncEngine(
          remote: remote,
          devices: devices,
          logs: _MemoryLogs(),
          birthdays: birthdays,
          syncState: SyncStateStore.memory(),
        );

        final summary = await engine.detectConflicts(token: 'tok');
        expect(summary.deviceCount, 1);
        expect(summary.birthdayCount, 1);
        expect(summary.total, 2);
      },
    );
  });

  group('Local-wins merge helpers', () {
    test('remote newer must NOT overwrite local device', () async {
      final devices = _MemoryDevices();
      await devices.upsertDevice(
        DeviceModel.fromEntity(
          sampleDevice(
            id: 'd1',
            name: 'Local',
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      );

      await mergeDeviceLocalWins(
        localStore: devices,
        remote: DeviceModel.fromEntity(
          sampleDevice(
            id: 'd1',
            name: 'Remote newer',
            updatedAt: DateTime.utc(2026, 3, 1),
          ),
        ),
      );
      expect((await devices.getDevice('d1'))!.name, 'Local');
    });

    test('additive pull inserts remote-only id', () async {
      final devices = _MemoryDevices();
      await mergeDeviceLocalWins(
        localStore: devices,
        remote: DeviceModel.fromEntity(
          sampleDevice(id: 'remote-only', name: 'New'),
        ),
      );
      expect((await devices.getDevice('remote-only'))!.name, 'New');
    });

    test('log merge is append-only by id', () async {
      final logs = _MemoryLogs();
      final existing = DeviceLogModel.fromEntity(
        sampleLog(id: 'l1', notes: 'local'),
      );
      await logs.upsertDeviceLog(existing);

      await mergeLogAppendOnly(
        localStore: logs,
        remote: DeviceLogModel.fromEntity(sampleLog(id: 'l1', notes: 'remote')),
      );
      expect((await logs.getLogById('l1'))!.notes, 'local');

      await mergeLogAppendOnly(
        localStore: logs,
        remote: DeviceLogModel.fromEntity(
          sampleLog(id: 'l2', notes: 'new remote'),
        ),
      );
      expect((await logs.getLogById('l2'))!.notes, 'new remote');
    });

    test('remote newer must NOT overwrite local birthday', () async {
      final birthdays = _MemoryBirthdays();
      await birthdays.upsertBirthday(
        BirthdayModel.fromEntity(
          sampleBirthday(
            id: 'b1',
            name: 'Local',
            updatedAt: DateTime.utc(2026, 2, 1),
          ),
        ),
      );

      await mergeBirthdayLocalWins(
        localStore: birthdays,
        remote: BirthdayModel.fromEntity(
          sampleBirthday(
            id: 'b1',
            name: 'Remote newer',
            updatedAt: DateTime.utc(2026, 3, 1),
          ),
        ),
      );
      expect((await birthdays.getBirthday('b1'))!.name, 'Local');
    });
  });

  group('RemoteSyncEngine apply guards', () {
    test(
      'sync with conflicts and overrideConfirmed false refuses — no mutations',
      () async {
        final devices = _MemoryDevices()
          ..seed(
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd1',
                name: 'Local',
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ),
          );
        final remote = _RecordingRemote()
          ..pulledDevices = [
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd1',
                name: 'Remote',
                updatedAt: DateTime.utc(2026, 3, 1),
              ),
            ),
          ];
        final engine = RemoteSyncEngine(
          remote: remote,
          devices: devices,
          logs: _MemoryLogs(),
          birthdays: _MemoryBirthdays(),
          syncState: SyncStateStore.memory(),
        );

        await expectLater(
          () => engine.sync(token: 'tok'),
          throwsA(isA<SyncOverrideRequiredException>()),
        );
        expect(remote.calls, isNot(contains('upsertDevice')));
        expect((await devices.getDevice('d1'))!.name, 'Local');
        expect(
          (await devices.getDevice('d1'))!.updatedAt,
          DateTime.utc(2026, 1, 1),
        );
      },
    );

    test(
      'sync with overrideConfirmed true pushes local and bumps updated_at',
      () async {
        final devices = _MemoryDevices()
          ..seed(
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd1',
                name: 'Local',
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ),
          );
        final remote = _RecordingRemote()
          ..pulledDevices = [
            DeviceModel.fromEntity(
              sampleDevice(
                id: 'd1',
                name: 'Remote',
                updatedAt: DateTime.utc(2026, 3, 1),
              ),
            ),
          ];
        final engine = RemoteSyncEngine(
          remote: remote,
          devices: devices,
          logs: _MemoryLogs(),
          birthdays: _MemoryBirthdays(),
          syncState: SyncStateStore.memory(),
        );

        await engine.sync(token: 'tok', overrideConfirmed: true);

        expect(remote.calls, contains('upsertDevice'));
        expect(remote.lastUpsertedDevice?.name, 'Local');
        expect(
          remote.lastUpsertedDevice!.updatedAt.toUtc().isAfter(
            DateTime.utc(2026, 3, 1),
          ),
          isTrue,
        );
        expect((await devices.getDevice('d1'))!.name, 'Local');
        expect(
          (await devices.getDevice(
            'd1',
          ))!.updatedAt.toUtc().isAfter(DateTime.utc(2026, 3, 1)),
          isTrue,
        );
      },
    );

    test('pull after confirm keeps local and inserts remote-only', () async {
      final devices = _MemoryDevices()
        ..seed(
          DeviceModel.fromEntity(
            sampleDevice(
              id: 'd1',
              name: 'Local',
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          ),
        );
      final remote = _RecordingRemote()
        ..pulledDevices = [
          DeviceModel.fromEntity(
            sampleDevice(
              id: 'd1',
              name: 'Remote newer',
              updatedAt: DateTime.utc(2026, 4, 1),
            ),
          ),
          DeviceModel.fromEntity(
            sampleDevice(
              id: 'remote-d',
              name: 'Additive',
              updatedAt: DateTime.utc(2026, 4, 1),
            ),
          ),
        ];
      final state = SyncStateStore.memory();
      final engine = RemoteSyncEngine(
        remote: remote,
        devices: devices,
        logs: _MemoryLogs(),
        birthdays: _MemoryBirthdays(),
        syncState: state,
      );

      await engine.sync(token: 'tok', overrideConfirmed: true);

      expect((await devices.getDevice('d1'))!.name, 'Local');
      expect((await devices.getDevice('remote-d'))!.name, 'Additive');
      expect(await state.readDevicesUpdatedSince(), DateTime.utc(2026, 4, 1));
    });
  });

  group('RemoteSyncEngine order', () {
    test('pushes then pulls devices, logs, birthdays', () async {
      final remote = _RecordingRemote();
      final devices = _MemoryDevices()
        ..seed(DeviceModel.fromEntity(sampleDevice(id: 'd1')));
      final logs = _MemoryLogs()
        ..seed(DeviceLogModel.fromEntity(sampleLog(id: 'l1')));
      final birthdays = _MemoryBirthdays()
        ..seed(BirthdayModel.fromEntity(sampleBirthday(id: 'b1')));
      final state = SyncStateStore.memory();

      final engine = RemoteSyncEngine(
        remote: remote,
        devices: devices,
        logs: logs,
        birthdays: birthdays,
        syncState: state,
      );

      await engine.sync(token: 'tok');

      // detectConflicts lists devices + birthdays first; push lists again.
      expect(remote.calls.where((c) => c == 'upsertDevice').length, 1);
      expect(remote.calls.where((c) => c == 'upsertLog').length, 1);
      expect(remote.calls.where((c) => c == 'upsertBirthday').length, 1);
      expect(remote.calls.contains('listDevices'), isTrue);
      expect(remote.calls.contains('listLogs'), isTrue);
      expect(remote.calls.contains('listBirthdays'), isTrue);

      final firstUpsert = remote.calls.indexOf('upsertDevice');
      final firstListPull = remote.calls.lastIndexOf('listDevices');
      expect(firstUpsert, lessThan(firstListPull));
    });

    test('advances cursors from pulled rows', () async {
      final remote = _RecordingRemote()
        ..pulledDevices = [
          DeviceModel.fromEntity(
            sampleDevice(id: 'remote-d', updatedAt: DateTime.utc(2026, 4, 1)),
          ),
        ]
        ..pulledLogs = [
          DeviceLogModel.fromEntity(
            sampleLog(id: 'remote-l', createdAt: DateTime.utc(2026, 4, 2)),
          ),
        ]
        ..pulledBirthdays = [
          BirthdayModel.fromEntity(
            sampleBirthday(id: 'remote-b', updatedAt: DateTime.utc(2026, 4, 3)),
          ),
        ];
      final state = SyncStateStore.memory();
      final engine = RemoteSyncEngine(
        remote: remote,
        devices: _MemoryDevices(),
        logs: _MemoryLogs(),
        birthdays: _MemoryBirthdays(),
        syncState: state,
      );

      await engine.sync(token: 'tok');

      expect(await state.readDevicesUpdatedSince(), DateTime.utc(2026, 4, 1));
      expect(
        await state.readDeviceLogsCreatedSince(),
        DateTime.utc(2026, 4, 2),
      );
      expect(await state.readBirthdaysUpdatedSince(), DateTime.utc(2026, 4, 3));
    });
  });

  group('LocalSyncCoordinator with remote', () {
    test(
      'tick completes when preference on, online, and engine succeeds',
      () async {
        final prefs = SyncPreferenceStore.memory();
        final remote = _RecordingRemote();
        final engine = RemoteSyncEngine(
          remote: remote,
          devices: _MemoryDevices(),
          logs: _MemoryLogs(),
          birthdays: _MemoryBirthdays(),
          syncState: SyncStateStore.memory(),
        );
        final coordinator = LocalSyncCoordinator(
          preferenceStore: prefs,
          networkStatus: const AlwaysOnlineNetworkStatus(),
          remoteEngine: engine,
        );

        expect(await coordinator.tick(token: 'tok'), SyncTickResult.completed);
        expect(
          await coordinator.syncNow(token: 'tok'),
          SyncNowOutcome.completed,
        );
        prefs.dispose();
      },
    );

    test('syncNow returns failed when engine throws', () async {
      final prefs = SyncPreferenceStore.memory();
      final coordinator = LocalSyncCoordinator(
        preferenceStore: prefs,
        networkStatus: const AlwaysOnlineNetworkStatus(),
        remoteEngine: _FailingPort(),
      );

      expect(await coordinator.syncNow(token: 'tok'), SyncNowOutcome.failed);
      prefs.dispose();
    });

    test('syncNow returns needsConfirmation when conflicts exist', () async {
      final prefs = SyncPreferenceStore.memory();
      final devices = _MemoryDevices()
        ..seed(DeviceModel.fromEntity(sampleDevice(id: 'd1', name: 'Local')));
      final remote = _RecordingRemote()
        ..pulledDevices = [
          DeviceModel.fromEntity(sampleDevice(id: 'd1', name: 'Remote')),
        ];
      final coordinator = LocalSyncCoordinator(
        preferenceStore: prefs,
        networkStatus: const AlwaysOnlineNetworkStatus(),
        remoteEngine: RemoteSyncEngine(
          remote: remote,
          devices: devices,
          logs: _MemoryLogs(),
          birthdays: _MemoryBirthdays(),
          syncState: SyncStateStore.memory(),
        ),
      );

      expect(
        await coordinator.syncNow(token: 'tok'),
        SyncNowOutcome.needsConfirmation,
      );
      expect(remote.calls, isNot(contains('upsertDevice')));
      expect((await devices.getDevice('d1'))!.name, 'Local');

      final preview = await coordinator.previewSync(token: 'tok');
      expect(preview, isA<SyncPreviewConflicts>());
      prefs.dispose();
    });

    test('cancel path leaves local unchanged (no sync apply)', () async {
      final prefs = SyncPreferenceStore.memory();
      final devices = _MemoryDevices()
        ..seed(
          DeviceModel.fromEntity(
            sampleDevice(
              id: 'd1',
              name: 'Local',
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          ),
        );
      final remote = _RecordingRemote()
        ..pulledDevices = [
          DeviceModel.fromEntity(
            sampleDevice(
              id: 'd1',
              name: 'Remote',
              updatedAt: DateTime.utc(2026, 3, 1),
            ),
          ),
        ];
      final engine = RemoteSyncEngine(
        remote: remote,
        devices: devices,
        logs: _MemoryLogs(),
        birthdays: _MemoryBirthdays(),
        syncState: SyncStateStore.memory(),
      );
      final coordinator = LocalSyncCoordinator(
        preferenceStore: prefs,
        networkStatus: const AlwaysOnlineNetworkStatus(),
        remoteEngine: engine,
      );

      final preview = await coordinator.previewSync(token: 'tok');
      expect(preview, isA<SyncPreviewConflicts>());
      // User cancels — never call syncNow with override.
      expect((await devices.getDevice('d1'))!.name, 'Local');
      expect(remote.calls, isNot(contains('upsertDevice')));
      prefs.dispose();
    });
  });
}

class _FailingPort implements RemoteSyncPort {
  @override
  Future<SyncConflictSummary> detectConflicts({required String token}) async {
    throw StateError('boom');
  }

  @override
  Future<void> sync({
    required String token,
    bool overrideConfirmed = false,
  }) async {
    throw StateError('boom');
  }
}

class _RecordingRemote implements SyncRemoteDataSource {
  final calls = <String>[];
  List<DeviceModel> pulledDevices = const [];
  List<DeviceLogModel> pulledLogs = const [];
  List<BirthdayModel> pulledBirthdays = const [];
  DeviceModel? lastUpsertedDevice;

  @override
  Future<List<DeviceModel>> listDevices({
    required String token,
    DateTime? updatedSince,
  }) async {
    calls.add('listDevices');
    return pulledDevices;
  }

  @override
  Future<DeviceModel> upsertDevice({
    required String token,
    required DeviceModel device,
  }) async {
    calls.add('upsertDevice');
    lastUpsertedDevice = device;
    return device;
  }

  @override
  Future<List<DeviceLogModel>> listDeviceLogs({
    required String token,
    DateTime? createdSince,
  }) async {
    calls.add('listLogs');
    return pulledLogs;
  }

  @override
  Future<DeviceLogModel> upsertDeviceLog({
    required String token,
    required DeviceLogModel log,
  }) async {
    calls.add('upsertLog');
    return log;
  }

  @override
  Future<List<BirthdayModel>> listBirthdays({
    required String token,
    DateTime? updatedSince,
  }) async {
    calls.add('listBirthdays');
    return pulledBirthdays;
  }

  @override
  Future<BirthdayModel> upsertBirthday({
    required String token,
    required BirthdayModel birthday,
  }) async {
    calls.add('upsertBirthday');
    return birthday;
  }
}

class _MemoryDevices implements DeviceLocalDataSource {
  final map = <String, DeviceModel>{};

  void seed(DeviceModel device) => map[device.id] = device;

  @override
  Future<List<DeviceModel>> getAllDevices() async => map.values.toList();

  @override
  Future<DeviceModel?> getDevice(String id) async => map[id];

  @override
  Future<void> upsertDevice(DeviceModel device) async {
    map[device.id] = device;
  }

  @override
  Future<List<DeviceModel>> getActiveDevices() async =>
      map.values.where((d) => d.status == DeviceStatus.active).toList();

  @override
  Future<List<DeviceModel>> getActiveRootDevices() async => getActiveDevices();

  @override
  Future<List<DeviceModel>> getDevicesByIds(List<String> ids) async =>
      ids.map((id) => map[id]).whereType<DeviceModel>().toList();

  @override
  Future<List<DeviceModel>> getChildren(String parentId) async =>
      map.values.where((d) => d.parentId == parentId).toList();

  @override
  Stream<List<DeviceModel>> watchActiveDevices() =>
      Stream.value(const <DeviceModel>[]);

  @override
  Stream<List<DeviceModel>> watchAllDevices() =>
      Stream.value(const <DeviceModel>[]);

  @override
  Future<void> insertDevice(DeviceModel device) => upsertDevice(device);

  @override
  Future<void> updateDevice(DeviceModel device) => upsertDevice(device);

  @override
  Future<void> setDeviceStatus(
    String id,
    String status,
    DateTime updatedAt,
  ) async {}

  @override
  Future<void> setDeviceStatusForIds(
    List<String> ids,
    String status,
    DateTime updatedAt,
  ) async {}

  @override
  Future<List<DeviceModel>> searchActiveDevicesByName(String query) async => [];
}

class _MemoryLogs implements DeviceLogLocalDataSource {
  final map = <String, DeviceLogModel>{};

  void seed(DeviceLogModel log) => map[log.id] = log;

  @override
  Future<List<DeviceLogModel>> getAllLogs() async => map.values.toList();

  @override
  Future<DeviceLogModel?> getLogById(String id) async => map[id];

  @override
  Future<void> upsertDeviceLog(DeviceLogModel log) async {
    map[log.id] = log;
  }

  @override
  Future<List<DeviceLogModel>> getLogsForDevice(String deviceId) async =>
      map.values.where((l) => l.deviceId == deviceId).toList();

  @override
  Stream<List<DeviceLogModel>> watchLogsForDevice(String deviceId) =>
      Stream.value(const <DeviceLogModel>[]);

  @override
  Future<DeviceLogModel?> getLatestLogForDevice(String deviceId) async => null;

  @override
  Future<void> insertDeviceLog(DeviceLogModel log) => upsertDeviceLog(log);

  @override
  Future<void> deleteDeviceLog(String id) async {
    map.remove(id);
  }
}

class _MemoryBirthdays implements BirthdayLocalDataSource {
  final map = <String, BirthdayModel>{};

  void seed(BirthdayModel birthday) => map[birthday.id] = birthday;

  @override
  Future<List<BirthdayModel>> getAllBirthdays() async => map.values.toList();

  @override
  Future<BirthdayModel?> getBirthday(String id) async => map[id];

  @override
  Future<void> upsertBirthday(BirthdayModel birthday) async {
    map[birthday.id] = birthday;
  }

  @override
  Stream<List<BirthdayModel>> watchBirthdays() =>
      Stream.value(const <BirthdayModel>[]);

  @override
  Future<void> insertBirthday(BirthdayModel birthday) =>
      upsertBirthday(birthday);

  @override
  Future<void> updateBirthday(BirthdayModel birthday) =>
      upsertBirthday(birthday);

  @override
  Future<void> deleteBirthday(String id) async {
    map.remove(id);
  }

  @override
  Future<List<BirthdayModel>> searchBirthdaysByName(String query) async => [];
}
