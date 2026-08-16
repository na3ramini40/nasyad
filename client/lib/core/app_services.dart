import 'package:flutter/material.dart';
import 'package:nasyad/core/calendar/calendar_preference_store.dart';
import 'package:nasyad/core/notifications/reminder_notification_preference_store.dart';
import 'package:nasyad/core/preferences/app_lock_store.dart';
import 'package:nasyad/core/preferences/home_grouping_preference_store.dart';
import 'package:nasyad/core/preferences/reminder_snooze_store.dart';
import 'package:nasyad/core/preferences/soon_window_preference_store.dart';
import 'package:nasyad/core/preferences/sync_preference_store.dart';
import 'package:nasyad/core/app_lock/biometric_authenticator.dart';
import 'package:nasyad/core/sync/network_status_reader.dart';
import 'package:nasyad/core/sync/sync_state_store.dart';
import 'package:nasyad/core/theme/season_theme_preference_store.dart';
import 'package:nasyad/core/theme/theme_mode_preference_store.dart';
import 'package:nasyad/core/version/last_seen_version_store.dart';
import 'package:nasyad/domain/services/local_sync_coordinator.dart';
import 'package:nasyad/data/datasources/app_config_remote_datasource.dart';
import 'package:nasyad/data/datasources/auth_remote_datasource.dart';
import 'package:nasyad/data/datasources/birthday_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/place_local_datasource_impl.dart';
import 'package:nasyad/data/datasources/sync_remote_datasource.dart';
import 'package:nasyad/data/datasources/tag_local_datasource_impl.dart';
import 'package:nasyad/data/local/app_config_store.dart';
import 'package:nasyad/data/local/auth_session_store.dart';
import 'package:nasyad/data/local/device_registration_store.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/repositories/app_config_repository_impl.dart';
import 'package:nasyad/data/repositories/auth_repository_impl.dart';
import 'package:nasyad/data/repositories/birthday_repository_impl.dart';
import 'package:nasyad/data/repositories/device_log_repository_impl.dart';
import 'package:nasyad/data/repositories/device_repository_impl.dart';
import 'package:nasyad/data/repositories/place_repository_impl.dart';
import 'package:nasyad/data/repositories/tag_repository_impl.dart';
import 'package:nasyad/data/services/app_update_service_impl.dart';
import 'package:nasyad/data/services/fcm_registration_sync.dart';
import 'package:nasyad/data/services/local_reminder_notification_service.dart';
import 'package:nasyad/data/services/local_reminder_scheduler.dart';
import 'package:nasyad/data/services/log_photo_storage.dart';
import 'package:nasyad/data/services/remote_sync_engine.dart';
import 'package:nasyad/domain/repositories/app_config_repository.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/repositories/place_repository.dart';
import 'package:nasyad/domain/repositories/tag_repository.dart';
import 'package:nasyad/domain/services/app_update_service.dart';
import 'package:nasyad/domain/services/remote_sync_port.dart';
import 'package:nasyad/domain/usecases/auth/complete_intro_usecase.dart';
import 'package:nasyad/domain/usecases/auth/get_profile_usecase.dart';
import 'package:nasyad/domain/usecases/auth/has_completed_intro_usecase.dart';
import 'package:nasyad/domain/usecases/auth/request_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/resend_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/sign_out_usecase.dart';
import 'package:nasyad/domain/usecases/auth/update_profile_usecase.dart';
import 'package:nasyad/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/watch_auth_session_usecase.dart';
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
import 'package:nasyad/domain/usecases/device/restore_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_archived_root_devices_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summary_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/create_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/delete_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/watch_logs_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/home/snooze_home_reminder_usecase.dart';
import 'package:nasyad/domain/usecases/home/watch_home_reminders_usecase.dart';
import 'package:nasyad/domain/usecases/place/create_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/delete_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/get_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/update_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/watch_places_usecase.dart';
import 'package:nasyad/domain/usecases/search/search_usecase.dart';
import 'package:nasyad/domain/usecases/tag/create_tag_usecase.dart';
import 'package:nasyad/domain/usecases/tag/delete_tag_usecase.dart';
import 'package:nasyad/domain/usecases/tag/set_device_tags_usecase.dart';
import 'package:nasyad/domain/usecases/tag/update_tag_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_device_tag_links_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_tags_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_tags_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/export_data_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/import_data_usecase.dart';
import 'package:nasyad/domain/services/transfer/birthday_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/device_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/place_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/tag_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/transfer_service.dart';

class AppServices {
  AppServices(
    this.database, {
    LastSeenVersionStore? lastSeenVersionStore,
    CalendarPreferenceStore? calendarPreferenceStore,
    SoonWindowPreferenceStore? soonWindowPreferenceStore,
    HomeGroupingPreferenceStore? homeGroupingPreferenceStore,
    ReminderSnoozeStore? reminderSnoozeStore,
    SeasonThemePreferenceStore? seasonThemePreferenceStore,
    ThemeModePreferenceStore? themeModePreferenceStore,
    AppUpdateService? appUpdateService,
    ReminderNotificationPreferenceStore? reminderNotificationPreferenceStore,
    SyncPreferenceStore? syncPreferenceStore,
    AppLockStore? appLockStore,
    BiometricAuthenticator? biometricAuthenticator,
    SyncStateStore? syncStateStore,
    NetworkStatusReader? networkStatusReader,
    LocalSyncCoordinator? localSyncCoordinator,
    RemoteSyncPort? remoteSyncPort,
    SyncRemoteDataSource? syncRemoteDataSource,
    LocalReminderNotificationService? localReminderNotificationService,
    LocalReminderScheduler? localReminderScheduler,
    LogPhotoStorage? photoStorage,
    AuthSessionStore? authSessionStore,
    AuthRemoteDataSource? authRemoteDataSource,
    AuthRepository? authRepository,
    DeviceRegistrationStore? deviceRegistrationStore,
    FcmRegistrationSync? fcmRegistrationSync,
    AppConfigStore? appConfigStore,
    AppConfigRemoteDataSource? appConfigRemoteDataSource,
    AppConfigRepository? appConfigRepository,
  }) : lastSeenVersionStore = lastSeenVersionStore ?? LastSeenVersionStore(),
       calendarPreferenceStore =
           calendarPreferenceStore ?? CalendarPreferenceStore(),
       soonWindowPreferenceStore =
           soonWindowPreferenceStore ?? SoonWindowPreferenceStore(),
       homeGroupingPreferenceStore =
           homeGroupingPreferenceStore ?? HomeGroupingPreferenceStore(),
       reminderSnoozeStore = reminderSnoozeStore ?? ReminderSnoozeStore(),
       seasonThemePreferenceStore =
           seasonThemePreferenceStore ?? SeasonThemePreferenceStore(),
       themeModePreferenceStore =
           themeModePreferenceStore ?? ThemeModePreferenceStore(),
       reminderNotificationPreferenceStore =
           reminderNotificationPreferenceStore ??
           ReminderNotificationPreferenceStore(),
       syncPreferenceStore = syncPreferenceStore ?? SyncPreferenceStore(),
       appLockStore = appLockStore ?? AppLockStore(),
       biometricAuthenticator =
           biometricAuthenticator ?? LocalBiometricAuthenticator(),
       syncStateStore = syncStateStore ?? SyncStateStore(),
       networkStatusReader = networkStatusReader ?? LookupNetworkStatusReader(),
       appUpdateService = appUpdateService ?? AppUpdateServiceImpl(),
       logPhotoStorage = photoStorage ?? LogPhotoStorageImpl(),
       authSessionStore = authSessionStore ?? AuthSessionStore(),
       deviceRegistrationStore =
           deviceRegistrationStore ?? DeviceRegistrationStore(),
       appConfigStore = appConfigStore ?? AppConfigStore(),
       deviceRepository = DeviceRepositoryImpl(
         db: database,
         devices: DeviceLocalDataSourceImpl(database.deviceDao),
         logs: DeviceLogLocalDataSourceImpl(database.deviceLogDao),
         photos: (photoStorage ?? LogPhotoStorageImpl()),
       ),
       deviceLogRepository = DeviceLogRepositoryImpl(
         db: database,
         logs: DeviceLogLocalDataSourceImpl(database.deviceLogDao),
         devices: DeviceLocalDataSourceImpl(database.deviceDao),
         photos: (photoStorage ?? LogPhotoStorageImpl()),
       ),
       birthdayRepository = BirthdayRepositoryImpl(
         BirthdayLocalDataSourceImpl(database.birthdayDao),
       ),
       placeRepository = PlaceRepositoryImpl(
         PlaceLocalDataSourceImpl(database.placeDao),
       ),
       tagRepository = TagRepositoryImpl(
         TagLocalDataSourceImpl(database.tagDao),
       ) {
    final deviceLocal = DeviceLocalDataSourceImpl(database.deviceDao);
    final logLocal = DeviceLogLocalDataSourceImpl(database.deviceLogDao);
    final birthdayLocal = BirthdayLocalDataSourceImpl(database.birthdayDao);
    final resolvedAuthStore = this.authSessionStore;
    this.authRepository =
        authRepository ??
        AuthRepositoryImpl(
          remote: authRemoteDataSource ?? AuthRemoteDataSource(),
          sessionStore: resolvedAuthStore,
        );
    this.fcmRegistrationSync =
        fcmRegistrationSync ??
        FcmRegistrationSync(
          authRepository: this.authRepository,
          store: this.deviceRegistrationStore,
        );
    this.appConfigRepository =
        appConfigRepository ??
        AppConfigRepositoryImpl(
          store: this.appConfigStore,
          remote: appConfigRemoteDataSource ?? HttpAppConfigRemoteDataSource(),
        );
    final resolvedRemote =
        remoteSyncPort ??
        RemoteSyncEngine(
          remote: syncRemoteDataSource ?? HttpSyncRemoteDataSource(),
          devices: deviceLocal,
          logs: logLocal,
          birthdays: birthdayLocal,
          syncState: this.syncStateStore,
        );
    this.localSyncCoordinator =
        localSyncCoordinator ??
        LocalSyncCoordinator(
          preferenceStore: this.syncPreferenceStore,
          networkStatus: this.networkStatusReader,
          remoteEngine: resolvedRemote,
        );
    watchAuthSession = WatchAuthSessionUsecase(this.authRepository);
    requestOtp = RequestOtpUsecase(this.authRepository);
    resendOtp = ResendOtpUsecase(this.authRepository);
    verifyOtp = VerifyOtpUsecase(this.authRepository);
    getProfile = GetProfileUsecase(this.authRepository);
    updateProfile = UpdateProfileUsecase(this.authRepository);
    signOut = SignOutUsecase(this.authRepository);
    completeIntro = CompleteIntroUsecase(this.authRepository);
    hasCompletedIntro = HasCompletedIntroUsecase(this.authRepository);
    watchDeviceSummaries = WatchDeviceSummariesUsecase(deviceRepository);
    watchDeviceSummary = WatchDeviceSummaryUsecase(deviceRepository);
    getDevice = GetDeviceUsecase(deviceRepository);
    getAllDevices = GetAllDevicesUsecase(deviceRepository);
    createDevice = CreateDeviceUsecase(deviceRepository);
    updateDevice = UpdateDeviceUsecase(deviceRepository);
    deleteDevice = DeleteDeviceUsecase(deviceRepository);
    archiveDevice = ArchiveDeviceUsecase(deviceRepository);
    restoreDevice = RestoreDeviceUsecase(deviceRepository);
    watchArchivedRootDevices = WatchArchivedRootDevicesUsecase(
      deviceRepository,
    );
    watchLogsForDevice = WatchLogsForDeviceUsecase(deviceLogRepository);
    createDeviceLog = CreateDeviceLogUsecase(deviceLogRepository);
    deleteDeviceLog = DeleteDeviceLogUsecase(deviceLogRepository);
    final transferService = TransferService([
      DeviceTransferHandler(
        deviceRepository,
        deviceLogRepository,
        logPhotoStorage,
      ),
      BirthdayTransferHandler(birthdayRepository),
      PlaceTransferHandler(placeRepository),
      TagTransferHandler(tagRepository),
    ]);
    exportData = ExportDataUsecase(transferService);
    importData = ImportDataUsecase(transferService);
    watchBirthdays = WatchBirthdaysUsecase(birthdayRepository);
    getBirthday = GetBirthdayUsecase(birthdayRepository);
    createBirthday = CreateBirthdayUsecase(birthdayRepository);
    updateBirthday = UpdateBirthdayUsecase(birthdayRepository);
    deleteBirthday = DeleteBirthdayUsecase(birthdayRepository);
    watchPlaces = WatchPlacesUsecase(placeRepository);
    getPlace = GetPlaceUsecase(placeRepository);
    createPlace = CreatePlaceUsecase(placeRepository);
    updatePlace = UpdatePlaceUsecase(placeRepository);
    deletePlace = DeletePlaceUsecase(placeRepository);
    watchTags = WatchTagsUsecase(tagRepository);
    createTag = CreateTagUsecase(tagRepository);
    updateTag = UpdateTagUsecase(tagRepository);
    deleteTag = DeleteTagUsecase(tagRepository);
    setDeviceTags = SetDeviceTagsUsecase(tagRepository);
    watchTagsForDevice = WatchTagsForDeviceUsecase(tagRepository);
    watchDeviceTagLinks = WatchDeviceTagLinksUsecase(tagRepository);
    watchHomeReminders = WatchHomeRemindersUsecase(
      watchDeviceSummaries,
      watchBirthdays,
      this.reminderSnoozeStore,
      this.soonWindowPreferenceStore,
      watchTags: watchTags,
      watchDeviceTagLinks: watchDeviceTagLinks,
      homeGroupingStore: this.homeGroupingPreferenceStore,
    );
    this.localReminderNotificationService =
        localReminderNotificationService ?? LocalReminderNotificationService();
    this.localReminderScheduler =
        localReminderScheduler ??
        LocalReminderScheduler(
          watchHomeReminders: watchHomeReminders,
          preferenceStore: this.reminderNotificationPreferenceStore,
          notificationService: this.localReminderNotificationService,
        );
    search = SearchUsecase(
      deviceRepository,
      birthdayRepository,
      placeRepository,
    );
    snoozeHomeReminder = SnoozeHomeReminderUsecase(this.reminderSnoozeStore);
  }

  static Future<AppServices> createForTests(
    AppDatabase database, {
    LastSeenVersionStore? lastSeenVersionStore,
    CalendarPreferenceStore? calendarPreferenceStore,
    SoonWindowPreferenceStore? soonWindowPreferenceStore,
    HomeGroupingPreferenceStore? homeGroupingPreferenceStore,
    ReminderSnoozeStore? reminderSnoozeStore,
    SeasonThemePreferenceStore? seasonThemePreferenceStore,
    ThemeModePreferenceStore? themeModePreferenceStore,
    ReminderNotificationPreferenceStore? reminderNotificationPreferenceStore,
    SyncPreferenceStore? syncPreferenceStore,
    AppLockStore? appLockStore,
    BiometricAuthenticator? biometricAuthenticator,
    SyncStateStore? syncStateStore,
    NetworkStatusReader? networkStatusReader,
    LocalSyncCoordinator? localSyncCoordinator,
    RemoteSyncPort? remoteSyncPort,
    SyncRemoteDataSource? syncRemoteDataSource,
    LogPhotoStorage? photoStorage,
    AuthSessionStore? authSessionStore,
    AuthRemoteDataSource? authRemoteDataSource,
    AuthRepository? authRepository,
    DeviceRegistrationStore? deviceRegistrationStore,
    FcmRegistrationSync? fcmRegistrationSync,
    AppConfigStore? appConfigStore,
    AppConfigRemoteDataSource? appConfigRemoteDataSource,
    AppConfigRepository? appConfigRepository,
  }) async {
    final prefs = syncPreferenceStore ?? SyncPreferenceStore.memory();
    final network = networkStatusReader ?? const AlwaysOnlineNetworkStatus();
    final hasRemoteOverride =
        remoteSyncPort != null || syncRemoteDataSource != null;
    final sessionStore =
        authSessionStore ?? AuthSessionStore.memory(introCompleted: true);
    final registrationStore =
        deviceRegistrationStore ?? DeviceRegistrationStore.memory();
    final resolvedAuth =
        authRepository ??
        AuthRepositoryImpl(
          remote: authRemoteDataSource ?? AuthRemoteDataSource(),
          sessionStore: sessionStore,
        );
    return AppServices(
      database,
      lastSeenVersionStore: lastSeenVersionStore,
      calendarPreferenceStore: calendarPreferenceStore,
      soonWindowPreferenceStore: soonWindowPreferenceStore,
      homeGroupingPreferenceStore:
          homeGroupingPreferenceStore ?? HomeGroupingPreferenceStore.memory(),
      reminderSnoozeStore: reminderSnoozeStore,
      seasonThemePreferenceStore: seasonThemePreferenceStore,
      themeModePreferenceStore: themeModePreferenceStore,
      reminderNotificationPreferenceStore: reminderNotificationPreferenceStore,
      syncPreferenceStore: prefs,
      appLockStore: appLockStore ?? AppLockStore.memory(),
      biometricAuthenticator:
          biometricAuthenticator ?? const UnavailableBiometricAuthenticator(),
      syncStateStore: syncStateStore ?? SyncStateStore.memory(),
      networkStatusReader: network,
      localSyncCoordinator:
          localSyncCoordinator ??
          (hasRemoteOverride
              ? null
              : LocalSyncCoordinator(
                  preferenceStore: prefs,
                  networkStatus: network,
                )),
      remoteSyncPort: remoteSyncPort,
      syncRemoteDataSource: syncRemoteDataSource,
      photoStorage: photoStorage,
      authSessionStore: sessionStore,
      authRemoteDataSource: authRemoteDataSource,
      authRepository: resolvedAuth,
      deviceRegistrationStore: registrationStore,
      fcmRegistrationSync:
          fcmRegistrationSync ??
          FcmRegistrationSync(
            authRepository: resolvedAuth,
            store: registrationStore,
            supported: false,
            getToken: () async => null,
            tokenRefresh: const Stream<String>.empty(),
          ),
      appConfigStore: appConfigStore ?? AppConfigStore.memory(),
      appConfigRemoteDataSource: appConfigRemoteDataSource,
      appConfigRepository: appConfigRepository,
    );
  }

  final AppDatabase database;
  final LastSeenVersionStore lastSeenVersionStore;
  final CalendarPreferenceStore calendarPreferenceStore;
  final SoonWindowPreferenceStore soonWindowPreferenceStore;
  final HomeGroupingPreferenceStore homeGroupingPreferenceStore;
  final ReminderSnoozeStore reminderSnoozeStore;
  final SeasonThemePreferenceStore seasonThemePreferenceStore;
  final ThemeModePreferenceStore themeModePreferenceStore;
  final ReminderNotificationPreferenceStore reminderNotificationPreferenceStore;
  final SyncPreferenceStore syncPreferenceStore;
  final AppLockStore appLockStore;
  final BiometricAuthenticator biometricAuthenticator;
  final SyncStateStore syncStateStore;
  final NetworkStatusReader networkStatusReader;
  late final LocalSyncCoordinator localSyncCoordinator;
  final AppUpdateService appUpdateService;
  final LogPhotoStorage logPhotoStorage;
  final AuthSessionStore authSessionStore;
  late final AuthRepository authRepository;
  final DeviceRegistrationStore deviceRegistrationStore;
  late final FcmRegistrationSync fcmRegistrationSync;
  final AppConfigStore appConfigStore;
  late final AppConfigRepository appConfigRepository;
  final DeviceRepository deviceRepository;
  final DeviceLogRepository deviceLogRepository;
  final BirthdayRepository birthdayRepository;
  final PlaceRepository placeRepository;
  final TagRepository tagRepository;

  late final WatchAuthSessionUsecase watchAuthSession;
  late final RequestOtpUsecase requestOtp;
  late final ResendOtpUsecase resendOtp;
  late final VerifyOtpUsecase verifyOtp;
  late final GetProfileUsecase getProfile;
  late final UpdateProfileUsecase updateProfile;
  late final SignOutUsecase signOut;
  late final CompleteIntroUsecase completeIntro;
  late final HasCompletedIntroUsecase hasCompletedIntro;
  late final WatchDeviceSummariesUsecase watchDeviceSummaries;
  late final WatchDeviceSummaryUsecase watchDeviceSummary;
  late final GetDeviceUsecase getDevice;
  late final GetAllDevicesUsecase getAllDevices;
  late final CreateDeviceUsecase createDevice;
  late final UpdateDeviceUsecase updateDevice;
  late final DeleteDeviceUsecase deleteDevice;
  late final ArchiveDeviceUsecase archiveDevice;
  late final RestoreDeviceUsecase restoreDevice;
  late final WatchArchivedRootDevicesUsecase watchArchivedRootDevices;
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
  late final WatchPlacesUsecase watchPlaces;
  late final GetPlaceUsecase getPlace;
  late final CreatePlaceUsecase createPlace;
  late final UpdatePlaceUsecase updatePlace;
  late final DeletePlaceUsecase deletePlace;
  late final WatchTagsUsecase watchTags;
  late final CreateTagUsecase createTag;
  late final UpdateTagUsecase updateTag;
  late final DeleteTagUsecase deleteTag;
  late final SetDeviceTagsUsecase setDeviceTags;
  late final WatchTagsForDeviceUsecase watchTagsForDevice;
  late final WatchDeviceTagLinksUsecase watchDeviceTagLinks;
  late final WatchHomeRemindersUsecase watchHomeReminders;
  late final LocalReminderNotificationService localReminderNotificationService;
  late final LocalReminderScheduler localReminderScheduler;
  late final SearchUsecase search;
  late final SnoozeHomeReminderUsecase snoozeHomeReminder;

  Future<void> dispose() async {
    await localReminderScheduler.dispose();
    await fcmRegistrationSync.dispose();
    syncPreferenceStore.dispose();
    homeGroupingPreferenceStore.dispose();
    authSessionStore.dispose();
    final auth = authRepository;
    if (auth is AuthRepositoryImpl) {
      await auth.dispose();
    }
    final appConfig = appConfigRepository;
    if (appConfig is AppConfigRepositoryImpl) {
      await appConfig.dispose();
    }
    await database.close();
  }
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
