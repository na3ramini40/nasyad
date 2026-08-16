import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nasyad/core/sync/sync_state_store.dart';
import 'package:nasyad/data/datasources/birthday_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/sync_remote_datasource.dart';
import 'package:nasyad/data/datasources/tag_local_datasource_impl.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/models/device_tag_link_model.dart';
import 'package:nasyad/data/models/tag_model.dart';
import 'package:nasyad/data/repositories/device_log_repository_impl.dart';
import 'package:nasyad/data/repositories/device_repository_impl.dart';
import 'package:nasyad/data/services/remote_sync_engine.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

import '../helpers/fake_log_photo_storage.dart';
import '../helpers/fixtures.dart';
import '../sqlite_test_setup.dart';

/// Live Django base URL from [tool/sync_integration_test.sh].
const _baseUrl = String.fromEnvironment('SYNC_IT_BASE_URL');

/// Keep these aligned with product constants so CI fails when versions bump
/// without updating this integration gate.
const _schemaVersionUnderTest = 9;
const _exportVersionUnderTest = 4;

void main() {
  setUpAll(() {
    setupSqliteForTests();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group(
    'two-device remote sync '
    '(Drift schema v$_schemaVersionUnderTest, export v$_exportVersionUnderTest)',
    () {
      test('version constants match AppDatabase and ExportBundle', () async {
        expect(ExportBundle.currentVersion, _exportVersionUnderTest);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        expect(db.schemaVersion, _schemaVersionUnderTest);
      });

      test(
        'Device A seed → sync → Device B empty sync → catalogs match',
        () async {
          final token = await _registerUser(
            baseUrl: _baseUrl,
            username: 'sync_it_${DateTime.now().microsecondsSinceEpoch}',
            password: 'sync-it-pass-123',
          );

          final photos = FakeLogPhotoStorage();
          final deviceA = await _DeviceHarness.open(photos: photos);
          addTearDown(deviceA.close);

          await _seedDeviceA(deviceA);

          final remote = HttpSyncRemoteDataSource(baseUrl: _baseUrl);
          await RemoteSyncEngine(
            remote: remote,
            devices: deviceA.devices,
            logs: deviceA.logs,
            birthdays: deviceA.birthdays,
            tags: deviceA.tags,
            syncState: SyncStateStore.memory(),
          ).sync(token: token);

          final catalogA = await _Snapshot.capture(deviceA);

          final deviceB = await _DeviceHarness.open(photos: photos);
          addTearDown(deviceB.close);

          await RemoteSyncEngine(
            remote: remote,
            devices: deviceB.devices,
            logs: deviceB.logs,
            birthdays: deviceB.birthdays,
            tags: deviceB.tags,
            syncState: SyncStateStore.memory(),
          ).sync(token: token);

          final catalogB = await _Snapshot.capture(deviceB);

          expect(
            catalogB.devicesById.keys.toSet(),
            catalogA.devicesById.keys.toSet(),
          );
          expect(
            catalogB.logsById.keys.toSet(),
            catalogA.logsById.keys.toSet(),
          );
          expect(
            catalogB.birthdaysById.keys.toSet(),
            catalogA.birthdaysById.keys.toSet(),
          );
          expect(
            catalogB.tagsById.keys.toSet(),
            catalogA.tagsById.keys.toSet(),
          );
          expect(catalogB.linkKeys.toSet(), catalogA.linkKeys.toSet());

          for (final id in catalogA.devicesById.keys) {
            expect(
              _deviceSyncEqual(
                catalogA.devicesById[id]!,
                catalogB.devicesById[id]!,
              ),
              isTrue,
              reason:
                  'device $id\nA=${catalogA.devicesById[id]!.toSyncJson()}\n'
                  'B=${catalogB.devicesById[id]!.toSyncJson()}',
            );
          }
          for (final id in catalogA.logsById.keys) {
            expect(
              _payloadEqual(
                catalogA.logsById[id]!.toSyncJson(),
                catalogB.logsById[id]!.toSyncJson(),
              ),
              isTrue,
              reason: 'log $id',
            );
          }
          for (final id in catalogA.birthdaysById.keys) {
            expect(
              _payloadEqual(
                catalogA.birthdaysById[id]!.toSyncJson(),
                catalogB.birthdaysById[id]!.toSyncJson(),
              ),
              isTrue,
              reason: 'birthday $id',
            );
          }
          for (final id in catalogA.tagsById.keys) {
            expect(
              _payloadEqual(
                catalogA.tagsById[id]!.toSyncJson(),
                catalogB.tagsById[id]!.toSyncJson(),
              ),
              isTrue,
              reason: 'tag $id',
            );
          }
          for (final key in catalogA.linksByKey.keys) {
            expect(
              _payloadEqual(
                catalogA.linksByKey[key]!.toSyncJson(),
                catalogB.linksByKey[key]!.toSyncJson(),
              ),
              isTrue,
              reason: 'link $key',
            );
          }
        },
        skip: _baseUrl.isEmpty
            ? 'Run via tool/sync_integration_test.sh (sets SYNC_IT_BASE_URL)'
            : false,
        timeout: const Timeout(Duration(minutes: 2)),
      );
    },
  );
}

Future<String> _registerUser({
  required String baseUrl,
  required String username,
  required String password,
}) async {
  final client = http.Client();
  try {
    final response = await client.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    expect(response.statusCode, anyOf(200, 201), reason: response.body);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['token'] as String?;
    expect(token, isNotNull);
    expect(token, isNotEmpty);
    return token!;
  } finally {
    client.close();
  }
}

Future<void> _seedDeviceA(_DeviceHarness h) async {
  final now = DateTime.utc(2026, 8, 16, 12);

  await h.deviceRepo.createDevice(
    sampleDevice(
      id: 'car',
      name: 'Family car',
      usageUnit: UsageIntervalUnit.km,
      currentUsage: 10000,
      scheduleType: ScheduleType.usageInterval,
      intervalValue: 5000,
      intervalUnit: 'km',
      usageAtLastMaintenance: 10000,
      lastMaintainedAt: now,
      createdAt: now,
      updatedAt: now,
    ),
  );
  await h.deviceRepo.createDevice(
    sampleDevice(
      id: 'oil',
      parentId: 'car',
      name: 'Oil change',
      usageUnit: null,
      currentUsage: 0,
      scheduleType: ScheduleType.usageInterval,
      intervalValue: 4000,
      intervalUnit: 'km',
      usageAtLastMaintenance: 8200,
      lastMaintainedAt: now.subtract(const Duration(days: 30)),
      createdAt: now,
      updatedAt: now,
    ),
  );
  await h.deviceRepo.createDevice(
    sampleDevice(
      id: 'hvac',
      name: 'Home HVAC',
      usageUnit: null,
      scheduleType: ScheduleType.calendarInterval,
      intervalValue: 6,
      intervalUnit: 'months',
      usageAtLastMaintenance: 0,
      lastMaintainedAt: now.subtract(const Duration(days: 100)),
      createdAt: now,
      updatedAt: now,
    ),
  );

  await h.logRepo.createLog(
    sampleLog(
      id: 'log-usage-1',
      deviceId: 'car',
      kind: DeviceLogKind.usageUpdate,
      usageValue: 11200,
      usageUnit: UsageIntervalUnit.km,
      notes: 'Dashboard reading',
      createdAt: now.add(const Duration(hours: 1)),
    ),
  );
  await h.logRepo.createLog(
    sampleLog(
      id: 'log-maint-oil',
      deviceId: 'oil',
      kind: DeviceLogKind.maintenanceDone,
      usageValue: 11200,
      usageUnit: UsageIntervalUnit.km,
      notes: 'Oil done',
      cost: 45.5,
      costCurrency: 'USD',
      vendor: 'QuickLube',
      createdAt: now.add(const Duration(hours: 2)),
    ),
  );
  await h.logRepo.createLog(
    sampleLog(
      id: 'log-maint-hvac',
      deviceId: 'hvac',
      kind: DeviceLogKind.maintenanceDone,
      usageValue: null,
      usageUnit: null,
      notes: 'Filter changed',
      createdAt: now.add(const Duration(hours: 3)),
    ),
  );

  await h.birthdays.upsertBirthday(
    BirthdayModel.fromEntity(
      sampleBirthday(
        id: 'bday-1',
        name: 'Ada',
        birthMonth: 12,
        birthDay: 10,
        calendarSystem: CalendarSystem.gregorian,
        createdAt: now,
        updatedAt: now,
      ),
    ),
  );

  await h.tags.upsertTag(
    TagModel(id: 'tag-home', name: 'home', createdAt: now, updatedAt: now),
  );
  await h.tags.upsertTag(
    TagModel(
      id: 'tag-vehicles',
      name: 'vehicles',
      createdAt: now,
      updatedAt: now,
    ),
  );
  await h.tags.setDeviceTags('car', const ['tag-vehicles']);
  await h.tags.setDeviceTags('hvac', const ['tag-home']);
}

/// Server re-applies maintenance on log create with its own clock; usage and
/// identity fields must still match across installs.
bool _deviceSyncEqual(DeviceModel a, DeviceModel b) {
  final left = Map<String, dynamic>.from(a.toSyncJson())
    ..remove('updated_at')
    ..remove('created_at')
    ..remove('last_maintained_at');
  final right = Map<String, dynamic>.from(b.toSyncJson())
    ..remove('updated_at')
    ..remove('created_at')
    ..remove('last_maintained_at');
  return jsonEncode(left) == jsonEncode(right);
}

bool _payloadEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
  final left = Map<String, dynamic>.from(a)
    ..remove('updated_at')
    ..remove('created_at');
  final right = Map<String, dynamic>.from(b)
    ..remove('updated_at')
    ..remove('created_at');
  return jsonEncode(left) == jsonEncode(right);
}

class _Snapshot {
  _Snapshot({
    required this.devicesById,
    required this.logsById,
    required this.birthdaysById,
    required this.tagsById,
    required this.linksByKey,
  });

  final Map<String, DeviceModel> devicesById;
  final Map<String, DeviceLogModel> logsById;
  final Map<String, BirthdayModel> birthdaysById;
  final Map<String, TagModel> tagsById;
  final Map<String, DeviceTagLinkModel> linksByKey;

  List<String> get linkKeys => linksByKey.keys.toList()..sort();

  static Future<_Snapshot> capture(_DeviceHarness h) async {
    final devices = await h.devices.getAllDevices();
    final logs = await h.logs.getAllLogs();
    final birthdays = await h.birthdays.getAllBirthdays();
    final tags = await h.tags.getAllTags();
    final links = await h.tags.getDeviceTagLinks();
    return _Snapshot(
      devicesById: {for (final d in devices) d.id: d},
      logsById: {for (final l in logs) l.id: l},
      birthdaysById: {for (final b in birthdays) b.id: b},
      tagsById: {for (final t in tags) t.id: t},
      linksByKey: {
        for (final link in links) '${link.deviceId}\u0000${link.tagId}': link,
      },
    );
  }
}

class _DeviceHarness {
  _DeviceHarness({
    required this.db,
    required this.devices,
    required this.logs,
    required this.birthdays,
    required this.tags,
    required this.deviceRepo,
    required this.logRepo,
  });

  final AppDatabase db;
  final DeviceLocalDataSourceImpl devices;
  final DeviceLogLocalDataSourceImpl logs;
  final BirthdayLocalDataSourceImpl birthdays;
  final TagLocalDataSourceImpl tags;
  final DeviceRepositoryImpl deviceRepo;
  final DeviceLogRepositoryImpl logRepo;

  static Future<_DeviceHarness> open({
    required FakeLogPhotoStorage photos,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    final devices = DeviceLocalDataSourceImpl(db.deviceDao);
    final logs = DeviceLogLocalDataSourceImpl(db.deviceLogDao);
    final birthdays = BirthdayLocalDataSourceImpl(db.birthdayDao);
    final tags = TagLocalDataSourceImpl(db.tagDao);
    return _DeviceHarness(
      db: db,
      devices: devices,
      logs: logs,
      birthdays: birthdays,
      tags: tags,
      deviceRepo: DeviceRepositoryImpl(
        db: db,
        devices: devices,
        logs: logs,
        photos: photos,
      ),
      logRepo: DeviceLogRepositoryImpl(
        db: db,
        logs: logs,
        devices: devices,
        photos: photos,
      ),
    );
  }

  Future<void> close() => db.close();
}
