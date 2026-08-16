// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nasyad';

  @override
  String get more => 'More';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get addDevice => 'Add device';

  @override
  String get addLog => 'Add Log';

  @override
  String get submitLog => 'Submit Log';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get persian => 'Persian';

  @override
  String get preferences => 'Preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get seasonTheme => 'Season theme';

  @override
  String get seasonThemeHint => 'Accent colors inspired by the seasons';

  @override
  String get seasonClassic => 'Default';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get brightness => 'Brightness';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceNameHint => 'Enter device name...';

  @override
  String get deviceNameRequired => 'Device name is required';

  @override
  String get deviceMetadataSection => 'Details';

  @override
  String get categoryPreset => 'Category';

  @override
  String get categoryGeneric => 'Generic';

  @override
  String get categoryCar => 'Vehicle';

  @override
  String get categoryHvac => 'HVAC';

  @override
  String get categoryAppliance => 'Appliance';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryPlumbing => 'Plumbing';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationLabelHint => 'e.g. Garage, Kitchen...';

  @override
  String get deviceNotes => 'Device notes';

  @override
  String get deviceNotesHint =>
      'Optional notes about this device (not log entries)...';

  @override
  String get maintenanceRule => 'Maintenance Rule';

  @override
  String get selectMaintenanceRule => 'Select a maintenance rule';

  @override
  String get selectScheduleType => 'Choose time or usage';

  @override
  String get selectIntervalUnit => 'Choose a unit';

  @override
  String get scheduleType => 'Schedule type';

  @override
  String get scheduleByTime => 'By time';

  @override
  String get scheduleByUsage => 'By usage';

  @override
  String get intervalAmount => 'Every';

  @override
  String get intervalAmountHint => 'Enter a number...';

  @override
  String get intervalAmountRequired => 'Enter a number greater than 0';

  @override
  String get intervalUnit => 'Unit';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get scheduleTemplates => 'Schedule templates';

  @override
  String get unitDays => 'Days';

  @override
  String get unitWeeks => 'Weeks';

  @override
  String get unitMonths => 'Months';

  @override
  String ruleEvery(int value, String unit) {
    return 'Every $value $unit';
  }

  @override
  String get addEditDevice => 'Add/Edit Device';

  @override
  String get editDevice => 'Edit Device';

  @override
  String get deviceDetails => 'Device Details';

  @override
  String get needsService => 'Needs Service';

  @override
  String get upToDate => 'Up to Date';

  @override
  String get maintenanceDue => 'Maintenance Due';

  @override
  String get maintenanceSoon => 'Due Soon';

  @override
  String get noDevicesTitle => 'No devices yet';

  @override
  String get noDevicesHint =>
      'Add a device to start tracking. You can nest parts under it later.';

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get usageReading => 'Current usage reading';

  @override
  String get usageReadingHint => 'e.g. 12450';

  @override
  String get usageReadingRequired => 'Enter the current usage reading';

  @override
  String get usageUnit => 'Usage unit';

  @override
  String get unitHours => 'Hours';

  @override
  String get unitKm => 'Kilometers';

  @override
  String get unitCycles => 'Cycles';

  @override
  String get archive => 'Archive';

  @override
  String get archivedDevices => 'Archived devices';

  @override
  String get archivedDevicesHint =>
      'Browse and restore archived devices and their parts.';

  @override
  String get noArchivedDevicesTitle => 'Nothing archived';

  @override
  String get noArchivedDevicesHint =>
      'When you archive a device, it and its parts will appear here.';

  @override
  String get restore => 'Restore';

  @override
  String get restoreDeviceTitle => 'Restore device?';

  @override
  String restoreDeviceBody(String name) {
    return '$name and all its parts will return to your active device list.';
  }

  @override
  String get scheduleSection => 'Schedule';

  @override
  String get noSchedule => 'No schedule (container only)';

  @override
  String get initialElapsed => 'Already used toward this cycle';

  @override
  String get initialElapsedHint => 'Default 0';

  @override
  String get childrenSection => 'Parts & children';

  @override
  String get addChild => 'Add child';

  @override
  String get markMaintained => 'Mark maintained';

  @override
  String get maintainAction => 'Maintain';

  @override
  String remainingUsageLabel(String remaining) {
    return 'Remaining: $remaining';
  }

  @override
  String targetUsageLabel(String target) {
    return 'Target: $target';
  }

  @override
  String get useParentUsage => 'Use parent usage';

  @override
  String get useParentUsageSubtitle =>
      'Inherit the parent\'s usage reading. Turn off to track separately.';

  @override
  String get updateUsage => 'Update usage';

  @override
  String get logKind => 'Log type';

  @override
  String get logKindMaintenance => 'Maintenance done';

  @override
  String get logKindUsage => 'Usage update';

  @override
  String currentUsageLabel(int value, String unit) {
    return 'Current usage: $value $unit';
  }

  @override
  String scheduleSummary(int value, String unit) {
    return 'Every $value $unit';
  }

  @override
  String get noScheduleConfigured => 'No schedule on this device';

  @override
  String get logHistory => 'Log History';

  @override
  String get usageDelta => 'Usage since last log';

  @override
  String get usageDeltaHint => 'Optional, e.g. 120';

  @override
  String get activeMaintenanceRules => 'Active Maintenance Rules';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Enter maintenance notes...';

  @override
  String get notesRequired => 'Notes are required';

  @override
  String get logCost => 'Cost';

  @override
  String get logCostHint => 'Optional, e.g. 49.99';

  @override
  String get logCostCurrency => 'Currency label';

  @override
  String get logCostCurrencyHint => 'Optional — uses locale currency if empty';

  @override
  String get logVendor => 'Vendor / service provider';

  @override
  String get logVendorHint => 'Optional, e.g. Auto shop';

  @override
  String get logPhoto => 'Photo';

  @override
  String get logPhotoAttach => 'Attach photo';

  @override
  String get logPhotoRemove => 'Remove photo';

  @override
  String get logInvalidCost => 'Enter a valid cost amount';

  @override
  String get date => 'Date';

  @override
  String lastLog(String value) {
    return 'Last Log: $value';
  }

  @override
  String lastLogMinutesAgo(int count) {
    return '$count mins ago';
  }

  @override
  String lastLogDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String lastLogWeeksAgo(int count) {
    return '$count week ago';
  }

  @override
  String get ruleEvery3Months => 'Every 3 Months';

  @override
  String get ruleEvery500Hours => 'Every 500 Hours';

  @override
  String get ruleEvery6Months => 'Every 6 Months';

  @override
  String get sampleDeviceAc => 'AC Unit - Living Room';

  @override
  String get sampleDeviceCar => 'Car';

  @override
  String get sampleDeviceLaptop => 'Laptop';

  @override
  String get sampleLogFilterReplaced => 'Filter Replaced';

  @override
  String get sampleLogOilChange => 'Oil Change';

  @override
  String get sampleLogGeneralCheck => 'General check';

  @override
  String get data => 'Data';

  @override
  String get exportImport => 'Export & Import';

  @override
  String get exportImportHint =>
      'Back up or restore devices, birthdays, and places.';

  @override
  String get exportSection => 'Export';

  @override
  String get importSection => 'Import';

  @override
  String get exportScope => 'What to export';

  @override
  String get exportScopeAll => 'All data';

  @override
  String get exportScopeOne => 'One device';

  @override
  String get exportScopeSelected => 'Selected devices';

  @override
  String get exportFormat => 'Format';

  @override
  String get formatJson => 'JSON';

  @override
  String get formatCsv => 'CSV';

  @override
  String get formatPlainText => 'Plain text';

  @override
  String get selectDevices => 'Select devices';

  @override
  String get share => 'Share';

  @override
  String get saveFile => 'Save';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get importAction => 'Import';

  @override
  String importPreview(int devices, int logs, int birthdays, int places) {
    return 'Ready to import: $devices devices, $logs logs, $birthdays birthdays, $places places';
  }

  @override
  String get ruleEvery1000Km => 'Every 1000 Kilometers';

  @override
  String get exportSuccess => 'Export ready';

  @override
  String exportSaved(String path) {
    return 'Saved to $path';
  }

  @override
  String get exportCopied =>
      'Export copied to clipboard (share not available on this platform)';

  @override
  String importSuccess(int devices, int birthdays, int places) {
    return 'Imported $devices devices, $birthdays birthdays, $places places';
  }

  @override
  String get exportNoDevices => 'No devices selected to export';

  @override
  String get importInvalid => 'Could not read this file';

  @override
  String get noDevicesForExport => 'No devices available to export';

  @override
  String get noDataForExport => 'Nothing to export yet';

  @override
  String get about => 'About';

  @override
  String get whatsNew => 'What\'s New';

  @override
  String get whatsNewHint => 'See what\'s new in this version';

  @override
  String appVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get birthdays => 'Birthdays';

  @override
  String get addBirthday => 'Add birthday';

  @override
  String get editBirthday => 'Edit birthday';

  @override
  String get personName => 'Name';

  @override
  String get personNameHint => 'Person\'s name...';

  @override
  String get personNameRequired => 'Name is required';

  @override
  String get birthMonthDay => 'Birthday';

  @override
  String get birthMonthDayHint => 'Month and day';

  @override
  String get birthMonthDayRequired => 'Choose a month and day';

  @override
  String get pickMonthDay => 'Choose month and day';

  @override
  String get month => 'Month';

  @override
  String get day => 'Day';

  @override
  String get noBirthdaysTitle => 'No birthdays yet';

  @override
  String get noBirthdaysHint => 'Add someone to remember their birthday.';

  @override
  String get deleteBirthdayTitle => 'Delete birthday?';

  @override
  String deleteBirthdayBody(String name) {
    return '$name will be removed from this device.';
  }

  @override
  String get calendarSystem => 'Date calendar';

  @override
  String get calendarGregorian => 'Gregorian';

  @override
  String get calendarPersian => 'Persian (Shamsi)';

  @override
  String get calendarSystemHint =>
      'Used for birthday dates. Independent of language.';

  @override
  String get remindersSection => 'Reminders';

  @override
  String get featuresSection => 'Features';

  @override
  String get deviceManagement => 'Device management';

  @override
  String get deviceManagementHint =>
      'Track devices, parts, and maintenance schedules.';

  @override
  String get birthdaysFeatureHint =>
      'Remember birthdays for people you care about.';

  @override
  String get places => 'Places';

  @override
  String get placesFeatureHint =>
      'Save points, paths, and areas on a map for offline use.';

  @override
  String get tags => 'Tags';

  @override
  String get tagsFeatureHint =>
      'Label devices for Home grouping. Tags are not devices.';

  @override
  String get addTag => 'Add tag';

  @override
  String get editTag => 'Edit tag';

  @override
  String get tagName => 'Tag name';

  @override
  String get tagNameHint => 'Tag name…';

  @override
  String get tagNameRequired => 'Tag name is required';

  @override
  String get createTag => 'Create tag';

  @override
  String get noTagsTitle => 'No tags yet';

  @override
  String get noTagsHint => 'Create tags to group devices on Home.';

  @override
  String get deleteTagTitle => 'Delete tag?';

  @override
  String deleteTagBody(String name) {
    return '$name will be removed. Device assignments are cleared.';
  }

  @override
  String get deviceTagsSection => 'Tags';

  @override
  String get deviceTagsHint => 'Optional labels for Home tag grouping.';

  @override
  String get homeGroupingByDevice => 'By device';

  @override
  String get homeGroupingByTag => 'By tag';

  @override
  String get homeGroupingLabel => 'Group reminders';

  @override
  String get reminderTagRollup => 'Tag rollup · worst of assigned devices';

  @override
  String get addPlace => 'Add place';

  @override
  String get editPlace => 'Edit place';

  @override
  String get placeName => 'Name';

  @override
  String get placeNameHint => 'Place name…';

  @override
  String get placeNameRequired => 'Name is required';

  @override
  String get placeGeometryRequired => 'Add the required points on the map';

  @override
  String get placeKindPoint => 'Point';

  @override
  String get placeKindLine => 'Line';

  @override
  String get placeKindArea => 'Area';

  @override
  String placeKindLineWithCount(int count) {
    return 'Line · $count points';
  }

  @override
  String placeKindAreaWithCount(int count) {
    return 'Area · $count points';
  }

  @override
  String placeCoordinateSummary(double lat, double lng) {
    return '$lat, $lng';
  }

  @override
  String get placeMapHintPoint => 'Tap the map to set the point';

  @override
  String placeMapHintLine(int count) {
    return 'Tap to add points ($count so far). Need at least 2.';
  }

  @override
  String placeMapHintArea(int count) {
    return 'Tap to add points ($count so far). Need at least 3.';
  }

  @override
  String get placeUseMyLocation => 'Use my location';

  @override
  String get placeUndoPoint => 'Undo point';

  @override
  String get placeLocationDenied =>
      'Location permission is needed to use your position.';

  @override
  String get noPlacesTitle => 'No places yet';

  @override
  String get noPlacesHint =>
      'Add a point, path, or area to find it again offline.';

  @override
  String get deletePlaceTitle => 'Delete place?';

  @override
  String deletePlaceBody(String name) {
    return '$name will be removed from this device.';
  }

  @override
  String get reminderFilterAll => 'All';

  @override
  String get reminderFilterDevices => 'Devices';

  @override
  String get reminderFilterBirthdays => 'Birthdays';

  @override
  String get noRemindersTitle => 'Nothing needs attention';

  @override
  String get noRemindersHint =>
      'Due maintenance and upcoming birthdays will show up here.';

  @override
  String get reminderDeviceDue => 'Maintenance is due';

  @override
  String get reminderDeviceSoon => 'Maintenance due soon';

  @override
  String get reminderBirthdayToday => 'Birthday is today';

  @override
  String get reminderBirthdayTomorrow => 'Birthday is tomorrow';

  @override
  String reminderBirthdayInDays(int days) {
    return 'Birthday in $days days';
  }

  @override
  String get reminderBadgeDue => 'Due';

  @override
  String get reminderBadgeSoon => 'Soon';

  @override
  String get reminderBadgeUpcoming => 'Upcoming';

  @override
  String get reminderNotificationsSection => 'Due reminders';

  @override
  String get reminderNotificationsEnabled => 'Local due reminders';

  @override
  String get reminderNotificationsHint =>
      'Notify when maintenance is due or a birthday is coming up.';

  @override
  String get reminderNotificationTime => 'Notification time';

  @override
  String get reminderNotificationTimeHint =>
      'Daily time for maintenance reminders and birthday alerts.';

  @override
  String get reminderQuickActionsMenu => 'Quick actions';

  @override
  String get reminderSnooze => 'Snooze';

  @override
  String get reminderSnoozeTitle => 'Snooze reminder';

  @override
  String get reminderSnoozeOneDay => '1 day';

  @override
  String get reminderSnoozeThreeDays => '3 days';

  @override
  String get reminderSnoozeSevenDays => '7 days';

  @override
  String reminderSnoozedForDays(int days) {
    return 'Snoozed for $days days';
  }

  @override
  String get soonWindowSevenDays => '7 days';

  @override
  String get soonWindowFourteenDays => '14 days';

  @override
  String get soonWindowHint =>
      'Birthday and home reminder badges use this window for \"Soon\".';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkForUpdatesHint => 'Download the latest release from GitHub';

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String get updateUpToDate => 'You\'re on the latest version';

  @override
  String get updateUnsupportedPlatform =>
      'In-app updates aren\'t available on this platform';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String version, String size) {
    return 'Version $version is ready ($size).';
  }

  @override
  String get updateReleaseNotes => 'Release notes';

  @override
  String get updateDownload => 'Download';

  @override
  String get updateInstall => 'Install update';

  @override
  String updateDownloadProgress(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updateReadyToInstall =>
      'Download complete. Install to finish updating.';

  @override
  String updateBannerMessage(String version) {
    return 'Version $version is available';
  }

  @override
  String get updateErrorOffline =>
      'Couldn\'t reach GitHub. Check your connection and try again.';

  @override
  String updateSizeKb(int size) {
    return '$size KB';
  }

  @override
  String updateSizeMb(String size) {
    return '$size MB';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search by name…';

  @override
  String get searchPromptTitle => 'Find devices, birthdays, and places';

  @override
  String get searchPromptHint =>
      'Type a name to search your devices, birthdays, and places.';

  @override
  String get searchNoResultsTitle => 'No matches';

  @override
  String get searchNoResultsHint =>
      'Try a different name or check your spelling.';

  @override
  String get searchDevicesSection => 'Devices';

  @override
  String get searchBirthdaysSection => 'Birthdays';

  @override
  String get searchPlacesSection => 'Places';

  @override
  String get searchPathSeparator => ' › ';

  @override
  String get syncSection => 'Sync';

  @override
  String get syncWithRemote => 'Sync with remote';

  @override
  String get syncWithRemoteHint =>
      'When enabled and online, the app may sync with your server. Turn off to keep data only on this device. Everything still works offline.';

  @override
  String get syncStatusOff => 'Sync off — data stays on this device only.';

  @override
  String get syncStatusOffline =>
      'Offline — local data only until you reconnect.';

  @override
  String get syncStatusReady =>
      'Ready — local-only until a server sync is available.';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get introTitle => 'Welcome to Nasyad';

  @override
  String get introBody =>
      'Sign in to sync your account across devices. You can also continue offline — everything works on this device without an account.';

  @override
  String get introSignInWithPhone => 'Sign in with phone';

  @override
  String get introContinueOffline => 'Continue offline';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authPhoneBody =>
      'Enter your mobile number. We’ll send a one-time code.';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHint => '+98912… or 0912…';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authOtpTitle => 'Enter code';

  @override
  String authOtpBody(String phone) {
    return 'Enter the code sent to $phone.';
  }

  @override
  String get authOtpLabel => 'Verification code';

  @override
  String get authOtpHint => '6-digit code';

  @override
  String get authVerify => 'Verify';

  @override
  String get authResendCode => 'Resend code';

  @override
  String authResendCooldown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authInvalidPhone => 'Enter a valid phone number';

  @override
  String get authInvalidCode => 'Enter a valid verification code';

  @override
  String get authGenericError => 'Something went wrong. Try again.';

  @override
  String get authSyncing => 'Syncing your data…';

  @override
  String get authSyncFailed =>
      'Signed in. Couldn’t sync now — your local data is safe.';

  @override
  String get authSyncConflictTitle =>
      'Data differs on this device and the server';

  @override
  String authSyncConflictBody(int count) {
    return 'Some items exist in both places with different values ($count). Continuing keeps this device’s data and updates the server. Local data will not be replaced.';
  }

  @override
  String get authSyncConflictConfirm => 'Keep device data';

  @override
  String get authSyncConflictCancel => 'Skip sync';

  @override
  String get authSyncCancelled =>
      'Signed in. Sync skipped — your local data is unchanged.';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get appLockResetSuccess => 'App lock turned off';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGuestTitle => 'You’re signed out';

  @override
  String get profileGuestBody =>
      'Sign in with your phone to manage your profile. Local data keeps working offline either way.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileNameHint => 'Your display name';

  @override
  String get profileNameEmpty => 'No name set';

  @override
  String get profileIdLabel => 'Account ID';

  @override
  String get profileIdHint => 'Server-issued ID (read-only)';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get appLockSection => 'App lock';

  @override
  String get languageAndRegion => 'Language & region';

  @override
  String get appLockMethodOff => 'Off';

  @override
  String get appLockMethodPassword => 'Password';

  @override
  String get appLockMethodPin => 'PIN';

  @override
  String get appLockMethodBiometric => 'Fingerprint';

  @override
  String get appLockTimeout => 'Lock after';

  @override
  String get appLockTimeoutImmediate => 'Immediately';

  @override
  String get appLockTimeoutOneMinute => '1 minute';

  @override
  String get appLockTimeoutFiveMinutes => '5 minutes';

  @override
  String get appLockTimeoutFifteenMinutes => '15 minutes';

  @override
  String get appLockTimeoutThirtyMinutes => '30 minutes';

  @override
  String get appLockTimeoutOneHour => '1 hour';

  @override
  String get appLockUnlockTitle => 'Unlock Nasyad';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockPasswordLabel => 'Password';

  @override
  String get appLockPasswordHint => 'Enter password';

  @override
  String get appLockPinLabel => 'PIN';

  @override
  String get appLockPinHint => '4–8 digits';

  @override
  String get appLockUseBiometric => 'Use fingerprint';

  @override
  String get appLockBiometricPrompt => 'Unlock Nasyad';

  @override
  String get appLockForgot => 'Forgot lock?';

  @override
  String get appLockForgotPhoneBody =>
      'Verify your phone to remove the app lock. Your data stays on this device.';

  @override
  String get appLockCreatePassword => 'Create password';

  @override
  String get appLockCreatePin => 'Create PIN';

  @override
  String get appLockConfirmLabel => 'Confirm';

  @override
  String get appLockConfirmHint => 'Enter again';

  @override
  String get appLockMismatch => 'Entries don’t match';

  @override
  String get appLockPasswordTooShort => 'Use at least 4 characters';

  @override
  String get appLockPinTooShort => 'Use 4 to 8 digits';

  @override
  String get appLockWrongSecret => 'That’s not correct';

  @override
  String get appLockBiometricUnavailable =>
      'Fingerprint isn’t available on this device';

  @override
  String get appLockBiometricFailed => 'Fingerprint didn’t work. Try again.';

  @override
  String get appLockVerifyToContinue => 'Unlock to continue';
}
