import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class MaintenanceRuleModel {
  final String id;
  final String deviceId;
  final String name;
  final ScheduleType scheduleType;
  final int? intervalValue;
  final String? intervalUnit;
  final DateTime? fixedDueAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaintenanceRuleModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.scheduleType,
    this.intervalValue,
    this.intervalUnit,
    this.fixedDueAt,
    required this.createdAt,
    required this.updatedAt,
  });

  MaintenanceRule toEntity() {
    return MaintenanceRule(
      id: id,
      deviceId: deviceId,
      name: name,
      scheduleType: scheduleType,
      intervalValue: intervalValue,
      intervalUnit: intervalUnit,
      fixedDueAt: fixedDueAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory MaintenanceRuleModel.fromEntity(MaintenanceRule rule) {
    return MaintenanceRuleModel(
      id: rule.id,
      deviceId: rule.deviceId,
      name: rule.name,
      scheduleType: rule.scheduleType,
      intervalValue: rule.intervalValue,
      intervalUnit: rule.intervalUnit,
      fixedDueAt: rule.fixedDueAt,
      createdAt: rule.createdAt,
      updatedAt: rule.updatedAt,
    );
  }

  factory MaintenanceRuleModel.fromTableData(MaintenanceRulesTableData rule) {
    return MaintenanceRuleModel(
      id: rule.id,
      deviceId: rule.deviceId,
      name: rule.name,
      scheduleType: ScheduleTypeX.fromStorage(rule.scheduleType),
      intervalValue: rule.intervalValue,
      intervalUnit: rule.intervalUnit,
      fixedDueAt: rule.fixedDueAt,
      createdAt: rule.createdAt,
      updatedAt: rule.updatedAt,
    );
  }

  MaintenanceRulesTableData toTableData() {
    return MaintenanceRulesTableData(
      id: id,
      deviceId: deviceId,
      name: name,
      scheduleType: scheduleType.storageValue,
      intervalValue: intervalValue,
      intervalUnit: intervalUnit,
      fixedDueAt: fixedDueAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  MaintenanceRulesTableCompanion toCompanion() {
    return MaintenanceRulesTableCompanion.insert(
      id: id,
      deviceId: deviceId,
      name: name,
      scheduleType: scheduleType.storageValue,
      intervalValue: Value(intervalValue),
      intervalUnit: Value(intervalUnit),
      fixedDueAt: Value(fixedDueAt),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
