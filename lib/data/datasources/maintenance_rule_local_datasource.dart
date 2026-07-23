import 'package:nasyad/data/models/maintenance_rule_model.dart';

abstract class MaintenanceRuleLocalDataSource {
  Future<List<MaintenanceRuleModel>> getRulesForDevice(String deviceId);

  Stream<List<MaintenanceRuleModel>> watchRulesForDevice(String deviceId);

  Future<List<MaintenanceRuleModel>> getRulesForDevices(List<String> deviceIds);

  Future<void> insertRule(MaintenanceRuleModel rule);

  Future<void> upsertRule(MaintenanceRuleModel rule);

  Future<void> replaceRule(MaintenanceRuleModel rule);

  Future<void> deleteRulesForDevice(String deviceId);
}
