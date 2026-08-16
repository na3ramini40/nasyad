import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/sync_preference_store.dart';
import 'package:nasyad/core/sync/network_status_reader.dart';
import 'package:nasyad/core/sync/sync_state_store.dart';
import 'package:nasyad/data/datasources/birthday_local_datasource.dart';
import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/datasources/sync_remote_datasource.dart';
import 'package:nasyad/data/datasources/tag_local_datasource.dart';
import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/models/device_tag_link_model.dart';
import 'package:nasyad/data/models/tag_model.dart';
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
      await store.writeTagsUpdatedSince(stamp);
      await store.writeDeviceTagLinksCreatedSince(stamp);

      expect(await store.readDevicesUpdatedSince(), stamp);
      expect(await store.readDeviceLogsCreatedSince(), stamp);
      expect(await store.readBirthdaysUpdatedSince(), stamp);
      expect(await store.readTagsUpdatedSince(), stamp);
      expect(await store.readDeviceTagLinksCreatedSince(), stamp);
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
          tags: _MemoryTags(),
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
          tags: _MemoryTags(),
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
          tags: _MemoryTags(),
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
        tags: _MemoryTags(),
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
        tags: _MemoryTags(),
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
        ]
        ..pulledTags = [
          TagModel(
            id: 'remote-t',
            name: 'Remote tag',
            createdAt: DateTime.utc(2026, 4, 4),
            updatedAt: DateTime.utc(2026, 4, 4),
          ),
        ]
        ..pulledLinks = [
          DeviceTagLinkModel(
            deviceId: 'remote-d',
            tagId: 'remote-t',
            createdAt: DateTime.utc(2026, 4, 5),
          ),
        ];
      final state = SyncStateStore.memory();
      final engine = RemoteSyncEngine(
        remote: remote,
        devices: _MemoryDevices(),
        logs: _MemoryLogs(),
        birthdays: _MemoryBirthdays(),
        tags: _MemoryTags(),
        syncState: state,
      );

      await engine.sync(token: 'tok');

      expect(await state.readDevicesUpdatedSince(), DateTime.utc(2026, 4, 1));
      expect(
        await state.readDeviceLogsCreatedSince(),
        DateTime.utc(2026, 4, 2),
      );
      expect(await state.readBirthdaysUpdatedSince(), DateTime.utc(2026, 4, 3));
      expect(await state.readTagsUpdatedSince(), DateTime.utc(2026, 4, 4));
      expect(
        await state.readDeviceTagLinksCreatedSince(),
        DateTime.utc(2026, 4, 5),
      );
    });
  });

  group('Tag / link sync', () {
    test('pushes local tags and pulls remote-only tags', () async {
      final tags = _MemoryTags()
        ..seed(
          TagModel(
            id: 't-local',
            name: 'Local',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
      final remote = _RecordingRemote()
        ..pulledTags = [
          TagModel(
            id: 't-remote',
            name: 'Remote only',
            createdAt: DateTime.utc(2026, 4, 1),
            updatedAt: DateTime.utc(2026, 4, 1),
          ),
        ];
      final state = SyncStateStore.memory();
      final engine = RemoteSyncEngine(
        remote: remote,
        devices: _MemoryDevices(),
        logs: _MemoryLogs(),
        birthdays: _MemoryBirthdays(),
        tags: tags,
        syncState: state,
      );

      await engine.sync(token: 'tok');

      expect(remote.calls, contains('upsertTag'));
      expect(remote.lastUpsertedTag?.id, 't-local');
      expect((await tags.getTag('t-remote'))?.name, 'Remote only');
      expect(await state.readTagsUpdatedSince(), DateTime.utc(2026, 4, 1));
    });

    test('deletes remote-only links and remote-only tags on push', () async {
      final tags = _MemoryTags()
        ..seed(
          TagModel(
            id: 't1',
            name: 'Keep',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        )
        ..seedLink(
          DeviceTagLinkModel(
            deviceId: 'd1',
            tagId: 't1',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
      final remote = _RecordingRemote()
        ..pulledTags = [
          TagModel(
            id: 't1',
            name: 'Keep',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
          TagModel(
            id: 't-gone',
            name: 'Remote only tag',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ]
        ..pulledLinks = [
          DeviceTagLinkModel(
            deviceId: 'd1',
            tagId: 't1',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          DeviceTagLinkModel(
            deviceId: 'd2',
            tagId: 't-gone',
            createdAt: DateTime.utc(2026, 1, 2),
          ),
        ];
      final engine = RemoteSyncEngine(
        remote: remote,
        devices: _MemoryDevices(),
        logs: _MemoryLogs(),
        birthdays: _MemoryBirthdays(),
        tags: tags,
        syncState: SyncStateStore.memory(),
      );

      await engine.sync(token: 'tok');

      expect(remote.deletedTagIds, contains('t-gone'));
      expect(remote.deletedLinkKeys, contains('d2/t-gone'));
      expect(remote.deletedLinkKeys, isNot(contains('d1/t1')));
    });

    test('pull links append-only by pair', () async {
      final tags = _MemoryTags()
        ..seedLink(
          DeviceTagLinkModel(
            deviceId: 'd1',
            tagId: 't1',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
      await mergeLinkAppendOnly(
        localStore: tags,
        remote: DeviceTagLinkModel(
          deviceId: 'd1',
          tagId: 't1',
          createdAt: DateTime.utc(2026, 5, 1),
        ),
      );
      expect(
        (await tags.getDeviceTagLink('d1', 't1'))!.createdAt,
        DateTime.utc(2026, 1, 1),
      );

      await mergeLinkAppendOnly(
        localStore: tags,
        remote: DeviceTagLinkModel(
          deviceId: 'd1',
          tagId: 't2',
          createdAt: DateTime.utc(2026, 5, 1),
        ),
      );
      expect(await tags.getDeviceTagLink('d1', 't2'), isNotNull);
    });

    test('tag sync json round-trip', () {
      final tag = TagModel(
        id: 't1',
        name: 'Garage',
        createdAt: DateTime.utc(2026, 2, 1, 10),
        updatedAt: DateTime.utc(2026, 2, 2, 11),
      );
      final restored = TagModel.fromSyncJson(tag.toSyncJson());
      expect(restored.id, tag.id);
      expect(restored.name, tag.name);
      expect(restored.createdAt, tag.createdAt);
      expect(restored.updatedAt, tag.updatedAt);

      final link = DeviceTagLinkModel(
        deviceId: 'd1',
        tagId: 't1',
        createdAt: DateTime.utc(2026, 3, 1),
      );
      final linkRestored = DeviceTagLinkModel.fromSyncJson(link.toSyncJson());
      expect(linkRestored.deviceId, link.deviceId);
      expect(linkRestored.tagId, link.tagId);
      expect(linkRestored.createdAt, link.createdAt);
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
          tags: _MemoryTags(),
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
          tags: _MemoryTags(),
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
        tags: _MemoryTags(),
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
  List<TagModel> pulledTags = const [];
  List<DeviceTagLinkModel> pulledLinks = const [];
  DeviceModel? lastUpsertedDevice;
  TagModel? lastUpsertedTag;
  final deletedTagIds = <String>[];
  final deletedLinkKeys = <String>[];

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

  @override
  Future<List<TagModel>> listTags({
    required String token,
    DateTime? updatedSince,
  }) async {
    calls.add('listTags');
    return pulledTags;
  }

  @override
  Future<TagModel> upsertTag({
    required String token,
    required TagModel tag,
  }) async {
    calls.add('upsertTag');
    lastUpsertedTag = tag;
    return tag;
  }

  @override
  Future<void> deleteTag({required String token, required String id}) async {
    calls.add('deleteTag');
    deletedTagIds.add(id);
  }

  @override
  Future<List<DeviceTagLinkModel>> listDeviceTagLinks({
    required String token,
    DateTime? createdSince,
  }) async {
    calls.add('listLinks');
    return pulledLinks;
  }

  @override
  Future<DeviceTagLinkModel> upsertDeviceTagLink({
    required String token,
    required DeviceTagLinkModel link,
  }) async {
    calls.add('upsertLink');
    return link;
  }

  @override
  Future<void> deleteDeviceTagLink({
    required String token,
    required String deviceId,
    required String tagId,
  }) async {
    calls.add('deleteLink');
    deletedLinkKeys.add('$deviceId/$tagId');
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

class _MemoryTags implements TagLocalDataSource {
  final tags = <String, TagModel>{};
  final links = <String, DeviceTagLinkModel>{};

  String _key(String deviceId, String tagId) => '$deviceId\u0000$tagId';

  void seed(TagModel tag) => tags[tag.id] = tag;

  void seedLink(DeviceTagLinkModel link) =>
      links[_key(link.deviceId, link.tagId)] = link;

  @override
  Stream<List<TagModel>> watchTags() => Stream.value(tags.values.toList());

  @override
  Future<List<TagModel>> getAllTags() async => tags.values.toList();

  @override
  Future<TagModel?> getTag(String id) async => tags[id];

  @override
  Future<void> insertTag(TagModel tag) async => tags[tag.id] = tag;

  @override
  Future<void> updateTag(TagModel tag) async => tags[tag.id] = tag;

  @override
  Future<void> upsertTag(TagModel tag) async => tags[tag.id] = tag;

  @override
  Future<void> deleteTag(String id) async {
    tags.remove(id);
    links.removeWhere((_, link) => link.tagId == id);
  }

  @override
  Stream<List<TagModel>> watchTagsForDevice(String deviceId) =>
      Stream.value(const <TagModel>[]);

  @override
  Future<List<TagModel>> getTagsForDevice(String deviceId) async => [];

  @override
  Future<void> setDeviceTags(String deviceId, List<String> tagIds) async {}

  @override
  Stream<List<DeviceTagLinkModel>> watchDeviceTagLinks() =>
      Stream.value(links.values.toList());

  @override
  Future<List<DeviceTagLinkModel>> getDeviceTagLinks() async =>
      links.values.toList();

  @override
  Future<DeviceTagLinkModel?> getDeviceTagLink(
    String deviceId,
    String tagId,
  ) async => links[_key(deviceId, tagId)];

  @override
  Future<void> upsertDeviceTagLink(DeviceTagLinkModel link) async {
    links[_key(link.deviceId, link.tagId)] = link;
  }

  @override
  Future<void> deleteLinksForDevice(String deviceId) async {
    links.removeWhere((_, link) => link.deviceId == deviceId);
  }
}
