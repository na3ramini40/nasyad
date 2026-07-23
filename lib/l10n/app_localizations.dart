import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nasyad'**
  String get appTitle;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get addDevice;

  /// No description provided for @addLog.
  ///
  /// In en, this message translates to:
  /// **'Add Log'**
  String get addLog;

  /// No description provided for @submitLog.
  ///
  /// In en, this message translates to:
  /// **'Submit Log'**
  String get submitLog;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @persian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get persian;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @deviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device name...'**
  String get deviceNameHint;

  /// No description provided for @deviceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Device name is required'**
  String get deviceNameRequired;

  /// No description provided for @maintenanceRule.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Rule'**
  String get maintenanceRule;

  /// No description provided for @selectMaintenanceRule.
  ///
  /// In en, this message translates to:
  /// **'Select a maintenance rule'**
  String get selectMaintenanceRule;

  /// No description provided for @selectScheduleType.
  ///
  /// In en, this message translates to:
  /// **'Choose time or usage'**
  String get selectScheduleType;

  /// No description provided for @selectIntervalUnit.
  ///
  /// In en, this message translates to:
  /// **'Choose a unit'**
  String get selectIntervalUnit;

  /// No description provided for @scheduleType.
  ///
  /// In en, this message translates to:
  /// **'Schedule type'**
  String get scheduleType;

  /// No description provided for @scheduleByTime.
  ///
  /// In en, this message translates to:
  /// **'By time'**
  String get scheduleByTime;

  /// No description provided for @scheduleByUsage.
  ///
  /// In en, this message translates to:
  /// **'By usage'**
  String get scheduleByUsage;

  /// No description provided for @intervalAmount.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get intervalAmount;

  /// No description provided for @intervalAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a number...'**
  String get intervalAmountHint;

  /// No description provided for @intervalAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than 0'**
  String get intervalAmountRequired;

  /// No description provided for @intervalUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get intervalUnit;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get unitDays;

  /// No description provided for @unitWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get unitWeeks;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get unitMonths;

  /// No description provided for @ruleEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {value} {unit}'**
  String ruleEvery(int value, String unit);

  /// No description provided for @addEditDevice.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit Device'**
  String get addEditDevice;

  /// No description provided for @editDevice.
  ///
  /// In en, this message translates to:
  /// **'Edit Device'**
  String get editDevice;

  /// No description provided for @deviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Device Details'**
  String get deviceDetails;

  /// No description provided for @needsService.
  ///
  /// In en, this message translates to:
  /// **'Needs Service'**
  String get needsService;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to Date'**
  String get upToDate;

  /// No description provided for @maintenanceDue.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Due'**
  String get maintenanceDue;

  /// No description provided for @maintenanceSoon.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get maintenanceSoon;

  /// No description provided for @noDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get noDevicesTitle;

  /// No description provided for @noDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'Add a device and choose one maintenance rule to start tracking.'**
  String get noDevicesHint;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @usageDelta.
  ///
  /// In en, this message translates to:
  /// **'Usage since last log'**
  String get usageDelta;

  /// No description provided for @usageDeltaHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. 120'**
  String get usageDeltaHint;

  /// No description provided for @usageUnit.
  ///
  /// In en, this message translates to:
  /// **'Usage unit'**
  String get usageUnit;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get unitHours;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get unitKm;

  /// No description provided for @unitCycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get unitCycles;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @activeMaintenanceRules.
  ///
  /// In en, this message translates to:
  /// **'Active Maintenance Rules'**
  String get activeMaintenanceRules;

  /// No description provided for @logHistory.
  ///
  /// In en, this message translates to:
  /// **'Log History'**
  String get logHistory;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter maintenance notes...'**
  String get notesHint;

  /// No description provided for @notesRequired.
  ///
  /// In en, this message translates to:
  /// **'Notes are required'**
  String get notesRequired;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @lastLog.
  ///
  /// In en, this message translates to:
  /// **'Last Log: {value}'**
  String lastLog(String value);

  /// No description provided for @lastLogMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mins ago'**
  String lastLogMinutesAgo(int count);

  /// No description provided for @lastLogDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String lastLogDaysAgo(int count);

  /// No description provided for @lastLogWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} week ago'**
  String lastLogWeeksAgo(int count);

  /// No description provided for @ruleEvery3Months.
  ///
  /// In en, this message translates to:
  /// **'Every 3 Months'**
  String get ruleEvery3Months;

  /// No description provided for @ruleEvery500Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 500 Hours'**
  String get ruleEvery500Hours;

  /// No description provided for @ruleEvery6Months.
  ///
  /// In en, this message translates to:
  /// **'Every 6 Months'**
  String get ruleEvery6Months;

  /// No description provided for @sampleDeviceAc.
  ///
  /// In en, this message translates to:
  /// **'AC Unit - Living Room'**
  String get sampleDeviceAc;

  /// No description provided for @sampleDeviceCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get sampleDeviceCar;

  /// No description provided for @sampleDeviceLaptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get sampleDeviceLaptop;

  /// No description provided for @sampleLogFilterReplaced.
  ///
  /// In en, this message translates to:
  /// **'Filter Replaced'**
  String get sampleLogFilterReplaced;

  /// No description provided for @sampleLogOilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil Change'**
  String get sampleLogOilChange;

  /// No description provided for @sampleLogGeneralCheck.
  ///
  /// In en, this message translates to:
  /// **'General check'**
  String get sampleLogGeneralCheck;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exportImport.
  ///
  /// In en, this message translates to:
  /// **'Export & Import'**
  String get exportImport;

  /// No description provided for @exportImportHint.
  ///
  /// In en, this message translates to:
  /// **'Back up or restore devices, rules, and logs.'**
  String get exportImportHint;

  /// No description provided for @exportSection.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportSection;

  /// No description provided for @importSection.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importSection;

  /// No description provided for @exportScope.
  ///
  /// In en, this message translates to:
  /// **'What to export'**
  String get exportScope;

  /// No description provided for @exportScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All data'**
  String get exportScopeAll;

  /// No description provided for @exportScopeOne.
  ///
  /// In en, this message translates to:
  /// **'One device'**
  String get exportScopeOne;

  /// No description provided for @exportScopeSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected devices'**
  String get exportScopeSelected;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get exportFormat;

  /// No description provided for @formatJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get formatJson;

  /// No description provided for @formatCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get formatCsv;

  /// No description provided for @formatPlainText.
  ///
  /// In en, this message translates to:
  /// **'Plain text'**
  String get formatPlainText;

  /// No description provided for @selectDevices.
  ///
  /// In en, this message translates to:
  /// **'Select devices'**
  String get selectDevices;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveFile.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveFile;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Ready to import: {devices} devices, {rules} rules, {logs} logs'**
  String importPreview(int devices, int rules, int logs);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get exportSuccess;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String exportSaved(String path);

  /// No description provided for @exportCopied.
  ///
  /// In en, this message translates to:
  /// **'Export copied to clipboard (share not available on this platform)'**
  String get exportCopied;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {devices} devices'**
  String importSuccess(int devices);

  /// No description provided for @exportNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices selected to export'**
  String get exportNoDevices;

  /// No description provided for @importInvalid.
  ///
  /// In en, this message translates to:
  /// **'Could not read this file'**
  String get importInvalid;

  /// No description provided for @noDevicesForExport.
  ///
  /// In en, this message translates to:
  /// **'No devices available to export'**
  String get noDevicesForExport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
