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
  String get exportImportHint => 'Back up or restore devices and logs.';

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
  String importPreview(int devices, int logs) {
    return 'Ready to import: $devices devices, $logs logs';
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
  String importSuccess(int devices) {
    return 'Imported $devices devices';
  }

  @override
  String get exportNoDevices => 'No devices selected to export';

  @override
  String get importInvalid => 'Could not read this file';

  @override
  String get noDevicesForExport => 'No devices available to export';

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
  String get reminderQuickActionsMenu => 'Quick actions';

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
}
