import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:nasyad/data/local/db/dao/birthday_dao.dart';
import 'package:nasyad/data/local/db/dao/device_dao.dart';
import 'package:nasyad/data/local/db/dao/device_log_dao.dart';
import 'package:nasyad/data/local/db/dao/place_dao.dart';
import 'package:nasyad/data/local/db/dao/tag_dao.dart';
import 'package:nasyad/data/local/db/tables/birthdays_table.dart';
import 'package:nasyad/data/local/db/tables/device_logs_table.dart';
import 'package:nasyad/data/local/db/tables/device_tags_table.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';
import 'package:nasyad/data/local/db/tables/places_table.dart';
import 'package:nasyad/data/local/db/tables/tags_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    DevicesTable,
    DeviceLogsTable,
    BirthdaysTable,
    PlacesTable,
    TagsTable,
    DeviceTagsTable,
  ],
  daos: [DeviceDao, DeviceLogDao, BirthdayDao, PlaceDao, TagDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'nasyad'));

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.deleteTable('device_logs_table');
        await m.deleteTable('devices_table');
        await customStatement('DROP TABLE IF EXISTS maintenance_rules_table');
        await m.createAll();
        return;
      }

      if (from < 3) {
        await _migrateToV3(m);
      }

      if (from < 4) {
        await m.createTable(birthdaysTable);
      }

      if (from < 5) {
        await customStatement(
          'ALTER TABLE device_logs_table ADD COLUMN cost REAL NULL',
        );
        await customStatement(
          'ALTER TABLE device_logs_table ADD COLUMN cost_currency TEXT NULL',
        );
        await customStatement(
          'ALTER TABLE device_logs_table ADD COLUMN vendor TEXT NULL',
        );
        await customStatement(
          'ALTER TABLE device_logs_table ADD COLUMN photo_path TEXT NULL',
        );
      }

      if (from < 6) {
        await customStatement(
          'ALTER TABLE devices_table ADD COLUMN category_preset TEXT NULL',
        );
        await customStatement(
          'ALTER TABLE devices_table ADD COLUMN location_label TEXT NULL',
        );
      }

      if (from < 7) {
        await m.createTable(placesTable);
      }

      if (from < 9) {
        if (from < 8) {
          await m.createTable(tagsTable);
          await m.createTable(deviceTagsTable);
        } else {
          // v8 device_tags lacked created_at; new creates (from < 8) already
          // include it via current schema.
          await customStatement(
            'ALTER TABLE device_tags_table '
            'ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
          );
        }
      }
    },
  );

  Future<void> _migrateToV3(Migrator m) async {
    await customStatement(
      'ALTER TABLE devices_table ADD COLUMN parent_id TEXT NULL',
    );
    await customStatement(
      'ALTER TABLE devices_table ADD COLUMN usage_unit TEXT NULL',
    );
    await customStatement(
      'ALTER TABLE devices_table ADD COLUMN schedule_type TEXT NULL',
    );
    await customStatement(
      'ALTER TABLE devices_table ADD COLUMN interval_value INTEGER NULL',
    );
    await customStatement(
      'ALTER TABLE devices_table ADD COLUMN interval_unit TEXT NULL',
    );
    await customStatement(
      'ALTER TABLE devices_table ADD COLUMN fixed_due_at INTEGER NULL',
    );
    await customStatement(
      'ALTER TABLE devices_table ADD COLUMN last_maintained_at INTEGER NULL',
    );

    await customStatement('''
      UPDATE devices_table
      SET
        schedule_type = (
          SELECT schedule_type FROM maintenance_rules_table
          WHERE maintenance_rules_table.device_id = devices_table.id
          ORDER BY created_at ASC LIMIT 1
        ),
        interval_value = (
          SELECT interval_value FROM maintenance_rules_table
          WHERE maintenance_rules_table.device_id = devices_table.id
          ORDER BY created_at ASC LIMIT 1
        ),
        interval_unit = (
          SELECT interval_unit FROM maintenance_rules_table
          WHERE maintenance_rules_table.device_id = devices_table.id
          ORDER BY created_at ASC LIMIT 1
        ),
        fixed_due_at = (
          SELECT fixed_due_at FROM maintenance_rules_table
          WHERE maintenance_rules_table.device_id = devices_table.id
          ORDER BY created_at ASC LIMIT 1
        ),
        usage_unit = (
          SELECT CASE
            WHEN interval_unit IN ('km', 'hours', 'cycles') THEN interval_unit
            ELSE NULL
          END
          FROM maintenance_rules_table
          WHERE maintenance_rules_table.device_id = devices_table.id
          ORDER BY created_at ASC LIMIT 1
        ),
        last_maintained_at = created_at
      WHERE EXISTS (
        SELECT 1 FROM maintenance_rules_table
        WHERE maintenance_rules_table.device_id = devices_table.id
      )
    ''');

    await customStatement(
      "ALTER TABLE device_logs_table ADD COLUMN kind TEXT NOT NULL DEFAULT 'maintenanceDone'",
    );
    await customStatement(
      'ALTER TABLE device_logs_table ADD COLUMN usage_value INTEGER NULL',
    );
    await customStatement('''
      UPDATE device_logs_table
      SET usage_value = usage_delta
      WHERE usage_delta IS NOT NULL
    ''');

    await customStatement('DROP TABLE IF EXISTS maintenance_rules_table');
  }
}
