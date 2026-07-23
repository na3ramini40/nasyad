import 'package:nasyad/data/datasources/maintenance_rule_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/maintenance_rule_dao.dart';
import 'package:nasyad/data/models/maintenance_rule_model.dart';

class MaintenanceRuleLocalDataSourceImpl
    implements MaintenanceRuleLocalDataSource {
  final MaintenanceRuleDao _dao;

  MaintenanceRuleLocalDataSourceImpl(this._dao);

  @override
  Future<List<MaintenanceRuleModel>> getRulesForDevice(String deviceId) async {
    final rows = await _dao.getRulesForDevice(deviceId);
    return rows.map(MaintenanceRuleModel.fromTableData).toList();
  }

  @override
  Stream<List<MaintenanceRuleModel>> watchRulesForDevice(String deviceId) {
    return _dao.watchRulesForDevice(deviceId).map(
          (rows) => rows.map(MaintenanceRuleModel.fromTableData).toList(),
        );
  }

  @override
  Future<List<MaintenanceRuleModel>> getRulesForDevices(
    List<String> deviceIds,
  ) async {
    final rows = await _dao.getRulesForDevices(deviceIds);
    return rows.map(MaintenanceRuleModel.fromTableData).toList();
  }

  @override
  Future<void> insertRule(MaintenanceRuleModel rule) async {
    await _dao.insertRule(rule.toCompanion());
  }

  @override
  Future<void> upsertRule(MaintenanceRuleModel rule) async {
    await _dao.upsertRule(rule.toCompanion());
  }

  @override
  Future<void> replaceRule(MaintenanceRuleModel rule) async {
    await _dao.replaceRule(rule.toTableData());
  }

  @override
  Future<void> deleteRulesForDevice(String deviceId) async {
    await _dao.deleteRulesForDevice(deviceId);
  }
}
