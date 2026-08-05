import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../sqlite_test_setup.dart';

/// Creates a v3 schema (before birthdays) with sample device data.
NativeDatabase openV3Database() {
  final handle = sqlite.sqlite3.openInMemory();

  handle.execute('PRAGMA foreign_keys = ON');

  handle.execute('''
    CREATE TABLE devices_table (
      id TEXT NOT NULL PRIMARY KEY,
      parent_id TEXT NULL,
      name TEXT NOT NULL,
      description TEXT NULL,
      status TEXT NOT NULL DEFAULT 'active',
      usage_unit TEXT NULL,
      current_usage INTEGER NOT NULL DEFAULT 0,
      schedule_type TEXT NULL,
      interval_value INTEGER NULL,
      interval_unit TEXT NULL,
      fixed_due_at INTEGER NULL,
      last_maintained_at INTEGER NULL,
      usage_at_last_maintenance INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');

  handle.execute('''
    CREATE TABLE device_logs_table (
      id TEXT NOT NULL PRIMARY KEY,
      device_id TEXT NOT NULL,
      date INTEGER NOT NULL,
      notes TEXT NULL,
      kind TEXT NOT NULL DEFAULT 'maintenanceDone',
      usage_value INTEGER NULL,
      usage_unit TEXT NULL,
      created_at INTEGER NOT NULL
    )
  ''');

  handle.execute('''
    INSERT INTO devices_table (
      id, name, status, current_usage, usage_at_last_maintenance,
      created_at, updated_at
    ) VALUES (
      'dev-1', 'Pump A', 'active', 100, 50,
      1700000000000, 1700000000000
    )
  ''');

  handle.execute('''
    INSERT INTO device_logs_table (
      id, device_id, date, notes, kind, usage_value, created_at
    ) VALUES (
      'log-1', 'dev-1', 1700000000000, 'Oil change', 'maintenanceDone', 100,
      1700000001000
    )
  ''');

  handle.execute('PRAGMA user_version = 3');

  return NativeDatabase.opened(handle);
}

void main() {
  setUpAll(setupSqliteForTests);

  test('v3 database migrates to v4 and preserves existing data', () async {
    final executor = openV3Database();
    addTearDown(executor.close);

    final database = AppDatabase(executor);
    addTearDown(database.close);

    expect(database.schemaVersion, 4);

    final devices = await database.select(database.devicesTable).get();
    expect(devices, hasLength(1));
    expect(devices.single.name, 'Pump A');
    expect(devices.single.currentUsage, 100);

    final logs = await database.select(database.deviceLogsTable).get();
    expect(logs, hasLength(1));
    expect(logs.single.notes, 'Oil change');

    final birthdays = await database.select(database.birthdaysTable).get();
    expect(birthdays, isEmpty);
  });

  test('fresh install creates all tables at current schema', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(database.schemaVersion, 4);

    await database
        .into(database.devicesTable)
        .insert(
          DevicesTableCompanion.insert(
            id: 'new-dev',
            name: 'Fresh device',
            createdAt: DateTime.utc(2024, 1, 1),
            updatedAt: DateTime.utc(2024, 1, 1),
          ),
        );

    final devices = await database.select(database.devicesTable).get();
    expect(devices, hasLength(1));
  });
}
