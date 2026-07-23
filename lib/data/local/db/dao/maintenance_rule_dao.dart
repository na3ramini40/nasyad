import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/maintenance_rules_table.dart';

part 'maintenance_rule_dao.g.dart';

@DriftAccessor(tables: [MaintenanceRulesTable])
class MaintenanceRuleDao extends DatabaseAccessor<AppDatabase>
    with _$MaintenanceRuleDaoMixin {
  MaintenanceRuleDao(super.db);

  Future<List<MaintenanceRulesTableData>> getRulesForDevice(String deviceId) {
    return (select(maintenanceRulesTable)
          ..where((t) => t.deviceId.equals(deviceId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<MaintenanceRulesTableData>> watchRulesForDevice(String deviceId) {
    return (select(maintenanceRulesTable)
          ..where((t) => t.deviceId.equals(deviceId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<MaintenanceRulesTableData>> getRulesForDevices(
    List<String> deviceIds,
  ) {
    if (deviceIds.isEmpty) return Future.value(const []);
    return (select(
      maintenanceRulesTable,
    )..where((t) => t.deviceId.isIn(deviceIds))).get();
  }

  Future<int> insertRule(MaintenanceRulesTableCompanion rule) {
    return into(maintenanceRulesTable).insert(rule);
  }

  Future<int> upsertRule(MaintenanceRulesTableCompanion rule) {
    return into(maintenanceRulesTable).insertOnConflictUpdate(rule);
  }

  Future<bool> replaceRule(MaintenanceRulesTableData rule) {
    return update(maintenanceRulesTable).replace(rule);
  }

  Future<int> deleteRulesForDevice(String deviceId) {
    return (delete(
      maintenanceRulesTable,
    )..where((t) => t.deviceId.equals(deviceId))).go();
  }
}
