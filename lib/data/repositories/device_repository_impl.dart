import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/datasources/maintenance_rule_local_datasource.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/models/maintenance_rule_model.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/services/maintenance_status_calculator.dart';

class DeviceRepositoryImpl extends DeviceRepository {
  final AppDatabase _db;
  final DeviceLocalDataSource _devices;
  final MaintenanceRuleLocalDataSource _rules;
  final DeviceLogLocalDataSource _logs;
  final MaintenanceStatusCalculator _calculator;

  DeviceRepositoryImpl({
    required AppDatabase db,
    required DeviceLocalDataSource devices,
    required MaintenanceRuleLocalDataSource rules,
    required DeviceLogLocalDataSource logs,
    MaintenanceStatusCalculator? calculator,
  })  : _db = db,
        _devices = devices,
        _rules = rules,
        _logs = logs,
        _calculator = calculator ?? MaintenanceStatusCalculator();

  @override
  Future<List<Device>> getDevices() async {
    final models = await _devices.getActiveDevices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Device>> getAllDevices() async {
    final models = await _devices.getAllDevices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Device>> getDevicesByIds(List<String> ids) async {
    final models = await _devices.getDevicesByIds(ids);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<DeviceSummary>> watchDeviceSummaries() {
    return _devices.watchActiveDevices().asyncMap((deviceModels) async {
      final devices = deviceModels.map((m) => m.toEntity()).toList();
      final ids = devices.map((d) => d.id).toList();
      final ruleModels = await _rules.getRulesForDevices(ids);
      final rulesByDevice = <String, List<MaintenanceRule>>{};
      for (final rule in ruleModels) {
        rulesByDevice
            .putIfAbsent(rule.deviceId, () => [])
            .add(rule.toEntity());
      }

      final summaries = <DeviceSummary>[];
      for (final device in devices) {
        final rules = rulesByDevice[device.id] ?? const [];
        final latestLog =
            (await _logs.getLatestLogForDevice(device.id))?.toEntity();
        final result = _calculator.evaluateDevice(
          device: device,
          rules: rules,
          latestLog: latestLog,
        );
        summaries.add(
          DeviceSummary(
            device: device,
            rules: rules,
            latestLog: latestLog,
            status: result.status,
            progress: result.progress,
          ),
        );
      }

      summaries.sort((a, b) {
        final byStatus = b.status.severity.compareTo(a.status.severity);
        if (byStatus != 0) return byStatus;
        return a.device.name.toLowerCase().compareTo(b.device.name.toLowerCase());
      });
      return summaries;
    });
  }

  @override
  Future<Device?> getDevice(String id) async {
    final model = await _devices.getDevice(id);
    return model?.toEntity();
  }

  @override
  Future<List<MaintenanceRule>> getRulesForDevice(String deviceId) async {
    final models = await _rules.getRulesForDevice(deviceId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<MaintenanceRule>> watchRulesForDevice(String deviceId) {
    return _rules.watchRulesForDevice(deviceId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<void> createDevice(Device device, MaintenanceRule rule) async {
    await _db.transaction(() async {
      await _devices.insertDevice(DeviceModel.fromEntity(device));
      await _rules.insertRule(MaintenanceRuleModel.fromEntity(rule));
    });
  }

  @override
  Future<void> updateDevice(Device device, MaintenanceRule rule) async {
    await _db.transaction(() async {
      await _devices.updateDevice(DeviceModel.fromEntity(device));
      final existing = await _rules.getRulesForDevice(device.id);
      if (existing.isEmpty) {
        await _rules.insertRule(MaintenanceRuleModel.fromEntity(rule));
      } else {
        final updated = MaintenanceRule(
          id: existing.first.id,
          deviceId: device.id,
          name: rule.name,
          scheduleType: rule.scheduleType,
          intervalValue: rule.intervalValue,
          intervalUnit: rule.intervalUnit,
          fixedDueAt: rule.fixedDueAt,
          createdAt: existing.first.createdAt,
          updatedAt: rule.updatedAt,
        );
        await _rules.replaceRule(MaintenanceRuleModel.fromEntity(updated));
      }
    });
  }

  @override
  Future<void> setDeviceStatus(String id, DeviceStatus status) async {
    await _devices.setDeviceStatus(
      id,
      status.storageValue,
      DateTime.now(),
    );
  }

  @override
  Future<void> importBundle(ExportBundle bundle) async {
    await _db.transaction(() async {
      for (final item in bundle.devices) {
        await _devices.upsertDevice(DeviceModel.fromEntity(item.device));
        for (final rule in item.rules) {
          await _rules.upsertRule(MaintenanceRuleModel.fromEntity(rule));
        }
        for (final log in item.logs) {
          await _logs.upsertDeviceLog(DeviceLogModel.fromEntity(log));
        }
      }
    });
  }
}
