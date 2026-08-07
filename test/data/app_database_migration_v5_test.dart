import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../sqlite_test_setup.dart';

void main() {
  setUpAll(setupSqliteForTests);

  test('v4 database migrates to v5 and adds log extra columns', () async {
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
      CREATE TABLE birthdays_table (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        month INTEGER NOT NULL,
        day INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    handle.execute('PRAGMA user_version = 4');

    final executor = NativeDatabase.opened(handle);
    addTearDown(executor.close);

    final database = AppDatabase(executor);
    addTearDown(database.close);

    expect(database.schemaVersion, 5);

    await database
        .into(database.devicesTable)
        .insert(
          DevicesTableCompanion.insert(
            id: 'dev-1',
            name: 'Pump',
            createdAt: DateTime.utc(2024, 1, 1),
            updatedAt: DateTime.utc(2024, 1, 1),
          ),
        );

    await database
        .into(database.deviceLogsTable)
        .insert(
          DeviceLogsTableCompanion.insert(
            id: 'log-extra',
            deviceId: 'dev-1',
            date: DateTime.utc(2024, 1, 1),
            cost: const Value(25.5),
            vendor: const Value('Shop'),
            createdAt: DateTime.utc(2024, 1, 1),
          ),
        );

    final logs = await database.select(database.deviceLogsTable).get();
    expect(logs.single.cost, 25.5);
    expect(logs.single.vendor, 'Shop');
  });
}
