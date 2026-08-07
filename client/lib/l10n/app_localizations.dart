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

  /// No description provided for @seasonTheme.
  ///
  /// In en, this message translates to:
  /// **'Season theme'**
  String get seasonTheme;

  /// No description provided for @seasonThemeHint.
  ///
  /// In en, this message translates to:
  /// **'Accent colors inspired by the seasons'**
  String get seasonThemeHint;

  /// No description provided for @seasonClassic.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get seasonClassic;

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonAutumn;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

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

  /// No description provided for @deviceMetadataSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get deviceMetadataSection;

  /// No description provided for @categoryPreset.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryPreset;

  /// No description provided for @categoryGeneric.
  ///
  /// In en, this message translates to:
  /// **'Generic'**
  String get categoryGeneric;

  /// No description provided for @categoryCar.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get categoryCar;

  /// No description provided for @categoryHvac.
  ///
  /// In en, this message translates to:
  /// **'HVAC'**
  String get categoryHvac;

  /// No description provided for @categoryAppliance.
  ///
  /// In en, this message translates to:
  /// **'Appliance'**
  String get categoryAppliance;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get categoryPlumbing;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Garage, Kitchen...'**
  String get locationLabelHint;

  /// No description provided for @deviceNotes.
  ///
  /// In en, this message translates to:
  /// **'Device notes'**
  String get deviceNotes;

  /// No description provided for @deviceNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this device (not log entries)...'**
  String get deviceNotesHint;

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

  /// No description provided for @scheduleTemplates.
  ///
  /// In en, this message translates to:
  /// **'Schedule templates'**
  String get scheduleTemplates;

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
  /// **'Add a device to start tracking. You can nest parts under it later.'**
  String get noDevicesHint;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @usageReading.
  ///
  /// In en, this message translates to:
  /// **'Current usage reading'**
  String get usageReading;

  /// No description provided for @usageReadingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12450'**
  String get usageReadingHint;

  /// No description provided for @usageReadingRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the current usage reading'**
  String get usageReadingRequired;

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

  /// No description provided for @archivedDevices.
  ///
  /// In en, this message translates to:
  /// **'Archived devices'**
  String get archivedDevices;

  /// No description provided for @archivedDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'Browse and restore archived devices and their parts.'**
  String get archivedDevicesHint;

  /// No description provided for @noArchivedDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived'**
  String get noArchivedDevicesTitle;

  /// No description provided for @noArchivedDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'When you archive a device, it and its parts will appear here.'**
  String get noArchivedDevicesHint;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore device?'**
  String get restoreDeviceTitle;

  /// No description provided for @restoreDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'{name} and all its parts will return to your active device list.'**
  String restoreDeviceBody(String name);

  /// No description provided for @scheduleSection.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleSection;

  /// No description provided for @noSchedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule (container only)'**
  String get noSchedule;

  /// No description provided for @initialElapsed.
  ///
  /// In en, this message translates to:
  /// **'Already used toward this cycle'**
  String get initialElapsed;

  /// No description provided for @initialElapsedHint.
  ///
  /// In en, this message translates to:
  /// **'Default 0'**
  String get initialElapsedHint;

  /// No description provided for @childrenSection.
  ///
  /// In en, this message translates to:
  /// **'Parts & children'**
  String get childrenSection;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get addChild;

  /// No description provided for @markMaintained.
  ///
  /// In en, this message translates to:
  /// **'Mark maintained'**
  String get markMaintained;

  /// No description provided for @updateUsage.
  ///
  /// In en, this message translates to:
  /// **'Update usage'**
  String get updateUsage;

  /// No description provided for @logKind.
  ///
  /// In en, this message translates to:
  /// **'Log type'**
  String get logKind;

  /// No description provided for @logKindMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance done'**
  String get logKindMaintenance;

  /// No description provided for @logKindUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage update'**
  String get logKindUsage;

  /// No description provided for @currentUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'Current usage: {value} {unit}'**
  String currentUsageLabel(int value, String unit);

  /// No description provided for @scheduleSummary.
  ///
  /// In en, this message translates to:
  /// **'Every {value} {unit}'**
  String scheduleSummary(int value, String unit);

  /// No description provided for @noScheduleConfigured.
  ///
  /// In en, this message translates to:
  /// **'No schedule on this device'**
  String get noScheduleConfigured;

  /// No description provided for @logHistory.
  ///
  /// In en, this message translates to:
  /// **'Log History'**
  String get logHistory;

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

  /// No description provided for @activeMaintenanceRules.
  ///
  /// In en, this message translates to:
  /// **'Active Maintenance Rules'**
  String get activeMaintenanceRules;

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

  /// No description provided for @logCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get logCost;

  /// No description provided for @logCostHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. 49.99'**
  String get logCostHint;

  /// No description provided for @logCostCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency label'**
  String get logCostCurrency;

  /// No description provided for @logCostCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — uses locale currency if empty'**
  String get logCostCurrencyHint;

  /// No description provided for @logVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor / service provider'**
  String get logVendor;

  /// No description provided for @logVendorHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. Auto shop'**
  String get logVendorHint;

  /// No description provided for @logPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get logPhoto;

  /// No description provided for @logPhotoAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get logPhotoAttach;

  /// No description provided for @logPhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get logPhotoRemove;

  /// No description provided for @logInvalidCost.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid cost amount'**
  String get logInvalidCost;

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
  /// **'Back up or restore devices, birthdays, and places.'**
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
  /// **'Ready to import: {devices} devices, {logs} logs, {birthdays} birthdays, {places} places'**
  String importPreview(int devices, int logs, int birthdays, int places);

  /// No description provided for @ruleEvery1000Km.
  ///
  /// In en, this message translates to:
  /// **'Every 1000 Kilometers'**
  String get ruleEvery1000Km;

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
  /// **'Imported {devices} devices, {birthdays} birthdays, {places} places'**
  String importSuccess(int devices, int birthdays, int places);

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

  /// No description provided for @noDataForExport.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export yet'**
  String get noDataForExport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get whatsNew;

  /// No description provided for @whatsNewHint.
  ///
  /// In en, this message translates to:
  /// **'See what\'s new in this version'**
  String get whatsNewHint;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersionLabel(String version);

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @birthdays.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get birthdays;

  /// No description provided for @addBirthday.
  ///
  /// In en, this message translates to:
  /// **'Add birthday'**
  String get addBirthday;

  /// No description provided for @editBirthday.
  ///
  /// In en, this message translates to:
  /// **'Edit birthday'**
  String get editBirthday;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get personName;

  /// No description provided for @personNameHint.
  ///
  /// In en, this message translates to:
  /// **'Person\'s name...'**
  String get personNameHint;

  /// No description provided for @personNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get personNameRequired;

  /// No description provided for @birthMonthDay.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthMonthDay;

  /// No description provided for @birthMonthDayHint.
  ///
  /// In en, this message translates to:
  /// **'Month and day'**
  String get birthMonthDayHint;

  /// No description provided for @birthMonthDayRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a month and day'**
  String get birthMonthDayRequired;

  /// No description provided for @pickMonthDay.
  ///
  /// In en, this message translates to:
  /// **'Choose month and day'**
  String get pickMonthDay;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @noBirthdaysTitle.
  ///
  /// In en, this message translates to:
  /// **'No birthdays yet'**
  String get noBirthdaysTitle;

  /// No description provided for @noBirthdaysHint.
  ///
  /// In en, this message translates to:
  /// **'Add someone to remember their birthday.'**
  String get noBirthdaysHint;

  /// No description provided for @deleteBirthdayTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete birthday?'**
  String get deleteBirthdayTitle;

  /// No description provided for @deleteBirthdayBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this device.'**
  String deleteBirthdayBody(String name);

  /// No description provided for @calendarSystem.
  ///
  /// In en, this message translates to:
  /// **'Date calendar'**
  String get calendarSystem;

  /// No description provided for @calendarGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get calendarGregorian;

  /// No description provided for @calendarPersian.
  ///
  /// In en, this message translates to:
  /// **'Persian (Shamsi)'**
  String get calendarPersian;

  /// No description provided for @calendarSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Used for birthday dates. Independent of language.'**
  String get calendarSystemHint;

  /// No description provided for @remindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersSection;

  /// No description provided for @featuresSection.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresSection;

  /// No description provided for @deviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Device management'**
  String get deviceManagement;

  /// No description provided for @deviceManagementHint.
  ///
  /// In en, this message translates to:
  /// **'Track devices, parts, and maintenance schedules.'**
  String get deviceManagementHint;

  /// No description provided for @birthdaysFeatureHint.
  ///
  /// In en, this message translates to:
  /// **'Remember birthdays for people you care about.'**
  String get birthdaysFeatureHint;

  /// No description provided for @places.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get places;

  /// No description provided for @placesFeatureHint.
  ///
  /// In en, this message translates to:
  /// **'Save points, paths, and areas on a map for offline use.'**
  String get placesFeatureHint;

  /// No description provided for @addPlace.
  ///
  /// In en, this message translates to:
  /// **'Add place'**
  String get addPlace;

  /// No description provided for @editPlace.
  ///
  /// In en, this message translates to:
  /// **'Edit place'**
  String get editPlace;

  /// No description provided for @placeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get placeName;

  /// No description provided for @placeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Place name…'**
  String get placeNameHint;

  /// No description provided for @placeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get placeNameRequired;

  /// No description provided for @placeGeometryRequired.
  ///
  /// In en, this message translates to:
  /// **'Add the required points on the map'**
  String get placeGeometryRequired;

  /// No description provided for @placeKindPoint.
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get placeKindPoint;

  /// No description provided for @placeKindLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get placeKindLine;

  /// No description provided for @placeKindArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get placeKindArea;

  /// No description provided for @placeKindLineWithCount.
  ///
  /// In en, this message translates to:
  /// **'Line · {count} points'**
  String placeKindLineWithCount(int count);

  /// No description provided for @placeKindAreaWithCount.
  ///
  /// In en, this message translates to:
  /// **'Area · {count} points'**
  String placeKindAreaWithCount(int count);

  /// No description provided for @placeCoordinateSummary.
  ///
  /// In en, this message translates to:
  /// **'{lat}, {lng}'**
  String placeCoordinateSummary(double lat, double lng);

  /// No description provided for @placeMapHintPoint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set the point'**
  String get placeMapHintPoint;

  /// No description provided for @placeMapHintLine.
  ///
  /// In en, this message translates to:
  /// **'Tap to add points ({count} so far). Need at least 2.'**
  String placeMapHintLine(int count);

  /// No description provided for @placeMapHintArea.
  ///
  /// In en, this message translates to:
  /// **'Tap to add points ({count} so far). Need at least 3.'**
  String placeMapHintArea(int count);

  /// No description provided for @placeUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get placeUseMyLocation;

  /// No description provided for @placeUndoPoint.
  ///
  /// In en, this message translates to:
  /// **'Undo point'**
  String get placeUndoPoint;

  /// No description provided for @placeLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to use your position.'**
  String get placeLocationDenied;

  /// No description provided for @noPlacesTitle.
  ///
  /// In en, this message translates to:
  /// **'No places yet'**
  String get noPlacesTitle;

  /// No description provided for @noPlacesHint.
  ///
  /// In en, this message translates to:
  /// **'Add a point, path, or area to find it again offline.'**
  String get noPlacesHint;

  /// No description provided for @deletePlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete place?'**
  String get deletePlaceTitle;

  /// No description provided for @deletePlaceBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this device.'**
  String deletePlaceBody(String name);

  /// No description provided for @reminderFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reminderFilterAll;

  /// No description provided for @reminderFilterDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get reminderFilterDevices;

  /// No description provided for @reminderFilterBirthdays.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get reminderFilterBirthdays;

  /// No description provided for @noRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs attention'**
  String get noRemindersTitle;

  /// No description provided for @noRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Due maintenance and upcoming birthdays will show up here.'**
  String get noRemindersHint;

  /// No description provided for @reminderDeviceDue.
  ///
  /// In en, this message translates to:
  /// **'Maintenance is due'**
  String get reminderDeviceDue;

  /// No description provided for @reminderDeviceSoon.
  ///
  /// In en, this message translates to:
  /// **'Maintenance due soon'**
  String get reminderDeviceSoon;

  /// No description provided for @reminderBirthdayToday.
  ///
  /// In en, this message translates to:
  /// **'Birthday is today'**
  String get reminderBirthdayToday;

  /// No description provided for @reminderBirthdayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Birthday is tomorrow'**
  String get reminderBirthdayTomorrow;

  /// No description provided for @reminderBirthdayInDays.
  ///
  /// In en, this message translates to:
  /// **'Birthday in {days} days'**
  String reminderBirthdayInDays(int days);

  /// No description provided for @reminderBadgeDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get reminderBadgeDue;

  /// No description provided for @reminderBadgeSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get reminderBadgeSoon;

  /// No description provided for @reminderBadgeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get reminderBadgeUpcoming;

  /// No description provided for @reminderNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Due reminders'**
  String get reminderNotificationsSection;

  /// No description provided for @reminderNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Local due reminders'**
  String get reminderNotificationsEnabled;

  /// No description provided for @reminderNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Notify when maintenance is due or a birthday is coming up.'**
  String get reminderNotificationsHint;

  /// No description provided for @reminderNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification time'**
  String get reminderNotificationTime;

  /// No description provided for @reminderNotificationTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Daily time for maintenance reminders and birthday alerts.'**
  String get reminderNotificationTimeHint;

  /// No description provided for @reminderQuickActionsMenu.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get reminderQuickActionsMenu;

  /// No description provided for @reminderSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get reminderSnooze;

  /// No description provided for @reminderSnoozeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze reminder'**
  String get reminderSnoozeTitle;

  /// No description provided for @reminderSnoozeOneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get reminderSnoozeOneDay;

  /// No description provided for @reminderSnoozeThreeDays.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get reminderSnoozeThreeDays;

  /// No description provided for @reminderSnoozeSevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get reminderSnoozeSevenDays;

  /// No description provided for @reminderSnoozedForDays.
  ///
  /// In en, this message translates to:
  /// **'Snoozed for {days} days'**
  String reminderSnoozedForDays(int days);

  /// No description provided for @soonWindowSevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get soonWindowSevenDays;

  /// No description provided for @soonWindowFourteenDays.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get soonWindowFourteenDays;

  /// No description provided for @soonWindowHint.
  ///
  /// In en, this message translates to:
  /// **'Birthday and home reminder badges use this window for \"Soon\".'**
  String get soonWindowHint;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'Download the latest release from GitHub'**
  String get checkForUpdatesHint;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the latest version'**
  String get updateUpToDate;

  /// No description provided for @updateUnsupportedPlatform.
  ///
  /// In en, this message translates to:
  /// **'In-app updates aren\'t available on this platform'**
  String get updateUnsupportedPlatform;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is ready ({size}).'**
  String updateAvailableBody(String version, String size);

  /// No description provided for @updateReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get updateReleaseNotes;

  /// No description provided for @updateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownload;

  /// No description provided for @updateInstall.
  ///
  /// In en, this message translates to:
  /// **'Install update'**
  String get updateInstall;

  /// No description provided for @updateDownloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String updateDownloadProgress(int percent);

  /// No description provided for @updateReadyToInstall.
  ///
  /// In en, this message translates to:
  /// **'Download complete. Install to finish updating.'**
  String get updateReadyToInstall;

  /// No description provided for @updateBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available'**
  String updateBannerMessage(String version);

  /// No description provided for @updateErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach GitHub. Check your connection and try again.'**
  String get updateErrorOffline;

  /// No description provided for @updateSizeKb.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String updateSizeKb(int size);

  /// No description provided for @updateSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String updateSizeMb(String size);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name…'**
  String get searchHint;

  /// No description provided for @searchPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Find devices, birthdays, and places'**
  String get searchPromptTitle;

  /// No description provided for @searchPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Type a name to search your devices, birthdays, and places.'**
  String get searchPromptHint;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different name or check your spelling.'**
  String get searchNoResultsHint;

  /// No description provided for @searchDevicesSection.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get searchDevicesSection;

  /// No description provided for @searchBirthdaysSection.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get searchBirthdaysSection;

  /// No description provided for @searchPlacesSection.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get searchPlacesSection;

  /// No description provided for @searchPathSeparator.
  ///
  /// In en, this message translates to:
  /// **' › '**
  String get searchPathSeparator;

  /// No description provided for @syncSection.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncSection;

  /// No description provided for @syncWithRemote.
  ///
  /// In en, this message translates to:
  /// **'Sync with remote'**
  String get syncWithRemote;

  /// No description provided for @syncWithRemoteHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled and online, the app may sync with your server. Turn off to keep data only on this device. Everything still works offline.'**
  String get syncWithRemoteHint;

  /// No description provided for @syncStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Sync off — data stays on this device only.'**
  String get syncStatusOff;

  /// No description provided for @syncStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — local data only until you reconnect.'**
  String get syncStatusOffline;

  /// No description provided for @syncStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready — local-only until a server sync is available.'**
  String get syncStatusReady;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @introTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nasyad'**
  String get introTitle;

  /// No description provided for @introBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your account across devices. You can also continue offline — everything works on this device without an account.'**
  String get introBody;

  /// No description provided for @introSignInWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone'**
  String get introSignInWithPhone;

  /// No description provided for @introContinueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue offline'**
  String get introContinueOffline;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// No description provided for @authPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number. We’ll send a one-time code.'**
  String get authPhoneBody;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+98912… or 0912…'**
  String get authPhoneHint;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get authOtpTitle;

  /// No description provided for @authOtpBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phone}.'**
  String authOtpBody(String phone);

  /// No description provided for @authOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authOtpLabel;

  /// No description provided for @authOtpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get authOtpHint;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authResendCooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendCooldown(int seconds);

  /// No description provided for @authInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get authInvalidPhone;

  /// No description provided for @authInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid verification code'**
  String get authInvalidCode;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get authGenericError;

  /// No description provided for @authSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing your data…'**
  String get authSyncing;

  /// No description provided for @authSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Couldn’t sync now — your local data is safe.'**
  String get authSyncFailed;

  /// No description provided for @authSyncConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Data differs on this device and the server'**
  String get authSyncConflictTitle;

  /// No description provided for @authSyncConflictBody.
  ///
  /// In en, this message translates to:
  /// **'Some items exist in both places with different values ({count}). Continuing keeps this device’s data and updates the server. Local data will not be replaced.'**
  String authSyncConflictBody(int count);

  /// No description provided for @authSyncConflictConfirm.
  ///
  /// In en, this message translates to:
  /// **'Keep device data'**
  String get authSyncConflictConfirm;

  /// No description provided for @authSyncConflictCancel.
  ///
  /// In en, this message translates to:
  /// **'Skip sync'**
  String get authSyncConflictCancel;

  /// No description provided for @authSyncCancelled.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Sync skipped — your local data is unchanged.'**
  String get authSyncCancelled;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @appLockResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'App lock turned off'**
  String get appLockResetSuccess;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re signed out'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone to manage your profile. Local data keeps working offline either way.'**
  String get profileGuestBody;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your display name'**
  String get profileNameHint;

  /// No description provided for @profileNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'No name set'**
  String get profileNameEmpty;

  /// No description provided for @profileIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get profileIdLabel;

  /// No description provided for @profileIdHint.
  ///
  /// In en, this message translates to:
  /// **'Server-issued ID (read-only)'**
  String get profileIdHint;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @appLockSection.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLockSection;

  /// No description provided for @languageAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & region'**
  String get languageAndRegion;

  /// No description provided for @appLockMethodOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get appLockMethodOff;

  /// No description provided for @appLockMethodPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get appLockMethodPassword;

  /// No description provided for @appLockMethodPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get appLockMethodPin;

  /// No description provided for @appLockMethodBiometric.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get appLockMethodBiometric;

  /// No description provided for @appLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get appLockTimeout;

  /// No description provided for @appLockTimeoutImmediate.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get appLockTimeoutImmediate;

  /// No description provided for @appLockTimeoutOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get appLockTimeoutOneMinute;

  /// No description provided for @appLockTimeoutFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get appLockTimeoutFiveMinutes;

  /// No description provided for @appLockTimeoutFifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get appLockTimeoutFifteenMinutes;

  /// No description provided for @appLockTimeoutThirtyMinutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get appLockTimeoutThirtyMinutes;

  /// No description provided for @appLockTimeoutOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get appLockTimeoutOneHour;

  /// No description provided for @appLockUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Nasyad'**
  String get appLockUnlockTitle;

  /// No description provided for @appLockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// No description provided for @appLockPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get appLockPasswordLabel;

  /// No description provided for @appLockPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get appLockPasswordHint;

  /// No description provided for @appLockPinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get appLockPinLabel;

  /// No description provided for @appLockPinHint.
  ///
  /// In en, this message translates to:
  /// **'4–8 digits'**
  String get appLockPinHint;

  /// No description provided for @appLockUseBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get appLockUseBiometric;

  /// No description provided for @appLockBiometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock Nasyad'**
  String get appLockBiometricPrompt;

  /// No description provided for @appLockForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot lock?'**
  String get appLockForgot;

  /// No description provided for @appLockForgotPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone to remove the app lock. Your data stays on this device.'**
  String get appLockForgotPhoneBody;

  /// No description provided for @appLockCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get appLockCreatePassword;

  /// No description provided for @appLockCreatePin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get appLockCreatePin;

  /// No description provided for @appLockConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get appLockConfirmLabel;

  /// No description provided for @appLockConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Enter again'**
  String get appLockConfirmHint;

  /// No description provided for @appLockMismatch.
  ///
  /// In en, this message translates to:
  /// **'Entries don’t match'**
  String get appLockMismatch;

  /// No description provided for @appLockPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 4 characters'**
  String get appLockPasswordTooShort;

  /// No description provided for @appLockPinTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use 4 to 8 digits'**
  String get appLockPinTooShort;

  /// No description provided for @appLockWrongSecret.
  ///
  /// In en, this message translates to:
  /// **'That’s not correct'**
  String get appLockWrongSecret;

  /// No description provided for @appLockBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint isn’t available on this device'**
  String get appLockBiometricUnavailable;

  /// No description provided for @appLockBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint didn’t work. Try again.'**
  String get appLockBiometricFailed;

  /// No description provided for @appLockVerifyToContinue.
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue'**
  String get appLockVerifyToContinue;
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
