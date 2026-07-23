import 'package:flutter/material.dart';
import 'package:nasyad/data/datasources/device_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/maintenance_rule_local_datasource_impl.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/repositories/device_log_repository_impl.dart';
import 'package:nasyad/data/repositories/device_repository_impl.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/usecases/device/archive_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_all_devices_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_rules_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/create_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/delete_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/watch_logs_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/export_data_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/import_data_usecase.dart';

class AppServices {
  AppServices(this.database)
      : deviceRepository = DeviceRepositoryImpl(
          db: database,
          devices: DeviceLocalDataSourceImpl(database.deviceDao),
          rules: MaintenanceRuleLocalDataSourceImpl(
            database.maintenanceRuleDao,
          ),
          logs: DeviceLogLocalDataSourceImpl(database.deviceLogDao),
        ),
        deviceLogRepository = DeviceLogRepositoryImpl(
          db: database,
          logs: DeviceLogLocalDataSourceImpl(database.deviceLogDao),
          devices: DeviceLocalDataSourceImpl(database.deviceDao),
        ) {
    watchDeviceSummaries = WatchDeviceSummariesUsecase(deviceRepository);
    getDevice = GetDeviceUsecase(deviceRepository);
    getAllDevices = GetAllDevicesUsecase(deviceRepository);
    getRulesForDevice = GetRulesForDeviceUsecase(deviceRepository);
    createDevice = CreateDeviceUsecase(deviceRepository);
    updateDevice = UpdateDeviceUsecase(deviceRepository);
    deleteDevice = DeleteDeviceUsecase(deviceRepository);
    archiveDevice = ArchiveDeviceUsecase(deviceRepository);
    watchLogsForDevice = WatchLogsForDeviceUsecase(deviceLogRepository);
    createDeviceLog = CreateDeviceLogUsecase(deviceLogRepository);
    deleteDeviceLog = DeleteDeviceLogUsecase(deviceLogRepository);
    exportData = ExportDataUsecase(deviceRepository, deviceLogRepository);
    importData = ImportDataUsecase(deviceRepository);
  }

  final AppDatabase database;
  final DeviceRepository deviceRepository;
  final DeviceLogRepository deviceLogRepository;

  late final WatchDeviceSummariesUsecase watchDeviceSummaries;
  late final GetDeviceUsecase getDevice;
  late final GetAllDevicesUsecase getAllDevices;
  late final GetRulesForDeviceUsecase getRulesForDevice;
  late final CreateDeviceUsecase createDevice;
  late final UpdateDeviceUsecase updateDevice;
  late final DeleteDeviceUsecase deleteDevice;
  late final ArchiveDeviceUsecase archiveDevice;
  late final WatchLogsForDeviceUsecase watchLogsForDevice;
  late final CreateDeviceLogUsecase createDeviceLog;
  late final DeleteDeviceLogUsecase deleteDeviceLog;
  late final ExportDataUsecase exportData;
  late final ImportDataUsecase importData;

  Future<void> dispose() => database.close();
}

class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppServicesScope>();
    assert(scope != null, 'AppServicesScope not found');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) {
    return services != oldWidget.services;
  }
}
