import 'package:flutter/material.dart';
import 'package:nasyad/core/calendar/calendar_preference_store.dart';
import 'package:nasyad/core/theme/season_theme_preference_store.dart';
import 'package:nasyad/core/theme/theme_mode_preference_store.dart';
import 'package:nasyad/core/version/last_seen_version_store.dart';
import 'package:nasyad/data/datasources/birthday_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource_impl.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/repositories/birthday_repository_impl.dart';
import 'package:nasyad/data/repositories/device_log_repository_impl.dart';
import 'package:nasyad/data/repositories/device_repository_impl.dart';
import 'package:nasyad/data/services/app_update_service_impl.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/services/app_update_service.dart';
import 'package:nasyad/domain/usecases/birthday/create_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/delete_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/get_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/update_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';
import 'package:nasyad/domain/usecases/device/archive_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_all_devices_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/home/watch_home_reminders_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summary_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/create_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/delete_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/watch_logs_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/export_data_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/import_data_usecase.dart';
import 'package:nasyad/domain/usecases/search/search_usecase.dart';

class AppServices {
  AppServices(
    this.database, {
    LastSeenVersionStore? lastSeenVersionStore,
    CalendarPreferenceStore? calendarPreferenceStore,
    SeasonThemePreferenceStore? seasonThemePreferenceStore,
    ThemeModePreferenceStore? themeModePreferenceStore,
    AppUpdateService? appUpdateService,
  }) : lastSeenVersionStore = lastSeenVersionStore ?? LastSeenVersionStore(),
       calendarPreferenceStore =
           calendarPreferenceStore ?? CalendarPreferenceStore(),
       seasonThemePreferenceStore =
           seasonThemePreferenceStore ?? SeasonThemePreferenceStore(),
       themeModePreferenceStore =
           themeModePreferenceStore ?? ThemeModePreferenceStore(),
       appUpdateService = appUpdateService ?? AppUpdateServiceImpl(),
       deviceRepository = DeviceRepositoryImpl(
         db: database,
         devices: DeviceLocalDataSourceImpl(database.deviceDao),
         logs: DeviceLogLocalDataSourceImpl(database.deviceLogDao),
       ),
       deviceLogRepository = DeviceLogRepositoryImpl(
         db: database,
         logs: DeviceLogLocalDataSourceImpl(database.deviceLogDao),
         devices: DeviceLocalDataSourceImpl(database.deviceDao),
       ),
       birthdayRepository = BirthdayRepositoryImpl(
         BirthdayLocalDataSourceImpl(database.birthdayDao),
       ) {
    watchDeviceSummaries = WatchDeviceSummariesUsecase(deviceRepository);
    watchDeviceSummary = WatchDeviceSummaryUsecase(deviceRepository);
    getDevice = GetDeviceUsecase(deviceRepository);
    getAllDevices = GetAllDevicesUsecase(deviceRepository);
    createDevice = CreateDeviceUsecase(deviceRepository);
    updateDevice = UpdateDeviceUsecase(deviceRepository);
    deleteDevice = DeleteDeviceUsecase(deviceRepository);
    archiveDevice = ArchiveDeviceUsecase(deviceRepository);
    watchLogsForDevice = WatchLogsForDeviceUsecase(deviceLogRepository);
    createDeviceLog = CreateDeviceLogUsecase(deviceLogRepository);
    deleteDeviceLog = DeleteDeviceLogUsecase(deviceLogRepository);
    exportData = ExportDataUsecase(deviceRepository, deviceLogRepository);
    importData = ImportDataUsecase(deviceRepository);
    watchBirthdays = WatchBirthdaysUsecase(birthdayRepository);
    getBirthday = GetBirthdayUsecase(birthdayRepository);
    createBirthday = CreateBirthdayUsecase(birthdayRepository);
    updateBirthday = UpdateBirthdayUsecase(birthdayRepository);
    deleteBirthday = DeleteBirthdayUsecase(birthdayRepository);
    watchHomeReminders = WatchHomeRemindersUsecase(
      watchDeviceSummaries,
      watchBirthdays,
    );
    search = SearchUsecase(deviceRepository, birthdayRepository);
  }

  final AppDatabase database;
  final LastSeenVersionStore lastSeenVersionStore;
  final CalendarPreferenceStore calendarPreferenceStore;
  final SeasonThemePreferenceStore seasonThemePreferenceStore;
  final ThemeModePreferenceStore themeModePreferenceStore;
  final AppUpdateService appUpdateService;
  final DeviceRepository deviceRepository;
  final DeviceLogRepository deviceLogRepository;
  final BirthdayRepository birthdayRepository;

  late final WatchDeviceSummariesUsecase watchDeviceSummaries;
  late final WatchDeviceSummaryUsecase watchDeviceSummary;
  late final GetDeviceUsecase getDevice;
  late final GetAllDevicesUsecase getAllDevices;
  late final CreateDeviceUsecase createDevice;
  late final UpdateDeviceUsecase updateDevice;
  late final DeleteDeviceUsecase deleteDevice;
  late final ArchiveDeviceUsecase archiveDevice;
  late final WatchLogsForDeviceUsecase watchLogsForDevice;
  late final CreateDeviceLogUsecase createDeviceLog;
  late final DeleteDeviceLogUsecase deleteDeviceLog;
  late final ExportDataUsecase exportData;
  late final ImportDataUsecase importData;
  late final WatchBirthdaysUsecase watchBirthdays;
  late final GetBirthdayUsecase getBirthday;
  late final CreateBirthdayUsecase createBirthday;
  late final UpdateBirthdayUsecase updateBirthday;
  late final DeleteBirthdayUsecase deleteBirthday;
  late final WatchHomeRemindersUsecase watchHomeReminders;
  late final SearchUsecase search;

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
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppServicesScope>();
    assert(scope != null, 'AppServicesScope not found');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) {
    return services != oldWidget.services;
  }
}
