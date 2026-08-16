import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../sqlite_test_setup.dart';

NativeDatabase openV8Database() {
  final handle = sqlite.sqlite3.openInMemory();
  handle.execute('PRAGMA foreign_keys = ON');

  handle.execute('''
    CREATE TABLE devices_table (
      id TEXT NOT NULL PRIMARY KEY,
      parent_id TEXT NULL,
      name TEXT NOT NULL,
      description TEXT NULL,
      category_preset TEXT NULL,
      location_label TEXT NULL,
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
      cost REAL NULL,
      cost_currency TEXT NULL,
      vendor TEXT NULL,
      photo_path TEXT NULL,
      created_at INTEGER NOT NULL
    )
  ''');
  handle.execute('''
    CREATE TABLE birthdays_table (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      month INTEGER NOT NULL,
      day INTEGER NOT NULL,
      calendar_system TEXT NOT NULL DEFAULT 'gregorian',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  handle.execute('''
    CREATE TABLE places_table (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      kind TEXT NOT NULL,
      points_json TEXT NOT NULL,
      notes TEXT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  handle.execute('''
    CREATE TABLE tags_table (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  handle.execute('''
    CREATE TABLE device_tags_table (
      device_id TEXT NOT NULL,
      tag_id TEXT NOT NULL,
      PRIMARY KEY (device_id, tag_id)
    )
  ''');

  handle.execute('''
    INSERT INTO tags_table (id, name, created_at, updated_at)
    VALUES ('tag-1', 'Garage', 1700000000000, 1700000000000)
  ''');
  handle.execute('''
    INSERT INTO device_tags_table (device_id, tag_id)
    VALUES ('dev-1', 'tag-1')
  ''');

  handle.execute('PRAGMA user_version = 8');
  return NativeDatabase.opened(handle);
}

void main() {
  setUpAll(setupSqliteForTests);

  test('v8 database migrates to v9 and preserves tags/links', () async {
    final executor = openV8Database();
    addTearDown(executor.close);

    final database = AppDatabase(executor);
    addTearDown(database.close);

    expect(database.schemaVersion, 9);

    final tags = await database.select(database.tagsTable).get();
    expect(tags, hasLength(1));
    expect(tags.single.id, 'tag-1');
    expect(tags.single.name, 'Garage');

    final links = await database.select(database.deviceTagsTable).get();
    expect(links, hasLength(1));
    expect(links.single.deviceId, 'dev-1');
    expect(links.single.tagId, 'tag-1');
    expect(links.single.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });
}
