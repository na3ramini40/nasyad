import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:nasyad/data/local/db/dao/device_dao.dart';
import 'package:nasyad/data/local/db/dao/device_log_dao.dart';
import 'package:nasyad/data/local/db/dao/maintenance_rule_dao.dart';
import 'package:nasyad/data/local/db/tables/device_logs_table.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';
import 'package:nasyad/data/local/db/tables/maintenance_rules_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [DevicesTable, DeviceLogsTable, MaintenanceRulesTable],
  daos: [DeviceDao, DeviceLogDao, MaintenanceRuleDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'nasyad'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.deleteTable('device_logs_table');
            await m.deleteTable('devices_table');
            await m.createAll();
          }
        },
      );
}
