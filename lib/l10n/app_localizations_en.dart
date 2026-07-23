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
      'Add a device and choose one maintenance rule to start tracking.';

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get usageDelta => 'Usage since last log';

  @override
  String get usageDeltaHint => 'Optional, e.g. 120';

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
  String get activeMaintenanceRules => 'Active Maintenance Rules';

  @override
  String get logHistory => 'Log History';

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
  String get exportImportHint => 'Back up or restore devices, rules, and logs.';

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
  String importPreview(int devices, int rules, int logs) {
    return 'Ready to import: $devices devices, $rules rules, $logs logs';
  }

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
}
