// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_rule_dao.dart';

// ignore_for_file: type=lint
mixin _$MaintenanceRuleDaoMixin on DatabaseAccessor<AppDatabase> {
  $DevicesTableTable get devicesTable => attachedDatabase.devicesTable;
  $MaintenanceRulesTableTable get maintenanceRulesTable =>
      attachedDatabase.maintenanceRulesTable;
  MaintenanceRuleDaoManager get managers => MaintenanceRuleDaoManager(this);
}

class MaintenanceRuleDaoManager {
  final _$MaintenanceRuleDaoMixin _db;
  MaintenanceRuleDaoManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db.attachedDatabase, _db.devicesTable);
  $$MaintenanceRulesTableTableTableManager get maintenanceRulesTable =>
      $$MaintenanceRulesTableTableTableManager(
        _db.attachedDatabase,
        _db.maintenanceRulesTable,
      );
}
