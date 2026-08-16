// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'نصیاد';

  @override
  String get more => 'بیشتر';

  @override
  String get back => 'بازگشت';

  @override
  String get save => 'ذخیره';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'ویرایش';

  @override
  String get addDevice => 'افزودن دستگاه';

  @override
  String get addLog => 'افزودن گزارش';

  @override
  String get submitLog => 'ثبت گزارش';

  @override
  String get language => 'زبان';

  @override
  String get english => 'انگلیسی';

  @override
  String get persian => 'فارسی';

  @override
  String get preferences => 'تنظیمات';

  @override
  String get appearance => 'ظاهر';

  @override
  String get themeSystem => 'پیش‌فرض سیستم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

  @override
  String get seasonTheme => 'تم فصلی';

  @override
  String get seasonThemeHint => 'رنگ‌های الهام‌گرفته از فصل‌های سال';

  @override
  String get seasonClassic => 'پیش‌فرض';

  @override
  String get seasonSpring => 'بهار';

  @override
  String get seasonSummer => 'تابستان';

  @override
  String get seasonAutumn => 'پاییز';

  @override
  String get seasonWinter => 'زمستان';

  @override
  String get seasonColorBlind => 'مناسب کوررنگی';

  @override
  String get seasonColorBlindHint => 'رنگ‌های وضعیت بدون وابستگی به قرمز و سبز';

  @override
  String get displaySize => 'اندازه نمایش';

  @override
  String get displaySizeHint => 'با دو انگشت بکشید یا از لغزنده استفاده کنید';

  @override
  String get displaySizeReset => 'بازنشانی';

  @override
  String get brightness => 'روشنایی';

  @override
  String get deviceName => 'نام دستگاه';

  @override
  String get deviceNameHint => 'نام دستگاه را وارد کنید...';

  @override
  String get deviceNameRequired => 'نام دستگاه الزامی است';

  @override
  String get deviceMetadataSection => 'جزئیات';

  @override
  String get categoryPreset => 'دسته‌بندی';

  @override
  String get categoryGeneric => 'عمومی';

  @override
  String get categoryCar => 'وسیله نقلیه';

  @override
  String get categoryHvac => 'سرمایش و گرمایش';

  @override
  String get categoryAppliance => 'لوازم خانگی';

  @override
  String get categoryElectronics => 'الکترونیک';

  @override
  String get categoryPlumbing => 'لوله‌کشی';

  @override
  String get locationLabel => 'مکان';

  @override
  String get locationLabelHint => 'مثلاً گاراژ، آشپزخانه...';

  @override
  String get deviceNotes => 'یادداشت دستگاه';

  @override
  String get deviceNotesHint =>
      'یادداشت اختیاری درباره این دستگاه (نه سوابق نگهداری)...';

  @override
  String get maintenanceRule => 'قانون نگهداری';

  @override
  String get selectMaintenanceRule => 'یک قانون نگهداری انتخاب کنید';

  @override
  String get selectScheduleType => 'زمان یا مصرف را انتخاب کنید';

  @override
  String get selectIntervalUnit => 'یک واحد انتخاب کنید';

  @override
  String get scheduleType => 'نوع زمان‌بندی';

  @override
  String get scheduleByTime => 'بر اساس زمان';

  @override
  String get scheduleByUsage => 'بر اساس مصرف';

  @override
  String get intervalAmount => 'هر';

  @override
  String get intervalAmountHint => 'یک عدد وارد کنید...';

  @override
  String get intervalAmountRequired => 'عددی بزرگ‌تر از ۰ وارد کنید';

  @override
  String get intervalUnit => 'واحد';

  @override
  String get suggestions => 'پیشنهادها';

  @override
  String get scheduleTemplates => 'الگوهای زمان‌بندی';

  @override
  String get unitDays => 'روز';

  @override
  String get unitWeeks => 'هفته';

  @override
  String get unitMonths => 'ماه';

  @override
  String ruleEvery(int value, String unit) {
    return 'هر $value $unit';
  }

  @override
  String get addEditDevice => 'افزودن/ویرایش دستگاه';

  @override
  String get editDevice => 'ویرایش دستگاه';

  @override
  String get deviceDetails => 'جزئیات دستگاه';

  @override
  String get needsService => 'نیاز به سرویس';

  @override
  String get upToDate => 'به‌روز';

  @override
  String get maintenanceDue => 'زمان سرویس رسیده';

  @override
  String get maintenanceSoon => 'به زودی';

  @override
  String get noDevicesTitle => 'هنوز دستگاهی نیست';

  @override
  String get noDevicesHint =>
      'یک دستگاه اضافه کنید. بعداً می‌توانید قطعات را زیر آن قرار دهید.';

  @override
  String get noLogsYet => 'هنوز گزارشی نیست';

  @override
  String get usageReading => 'مقدار مصرف فعلی';

  @override
  String get usageReadingHint => 'مثلاً ۱۲۴۵۰';

  @override
  String get usageReadingRequired => 'مقدار مصرف فعلی را وارد کنید';

  @override
  String get usageUnit => 'واحد مصرف';

  @override
  String get unitHours => 'ساعت';

  @override
  String get unitKm => 'کیلومتر';

  @override
  String get unitCycles => 'سیکل';

  @override
  String get archive => 'بایگانی';

  @override
  String get archivedDevices => 'دستگاه‌های بایگانی‌شده';

  @override
  String get archivedDevicesHint =>
      'دستگاه‌ها و قطعات بایگانی‌شده را ببینید و بازیابی کنید.';

  @override
  String get noArchivedDevicesTitle => 'چیزی بایگانی نشده';

  @override
  String get noArchivedDevicesHint =>
      'وقتی دستگاهی را بایگانی کنید، آن و قطعاتش اینجا نمایش داده می‌شوند.';

  @override
  String get restore => 'بازیابی';

  @override
  String get restoreDeviceTitle => 'بازیابی دستگاه؟';

  @override
  String restoreDeviceBody(String name) {
    return '$name و همه قطعاتش به فهرست دستگاه‌های فعال برمی‌گردند.';
  }

  @override
  String get scheduleSection => 'زمان‌بندی';

  @override
  String get noSchedule => 'بدون زمان‌بندی (فقط ظرف)';

  @override
  String get initialElapsed => 'از این دوره قبلاً گذشته';

  @override
  String get initialElapsedHint => 'پیش‌فرض ۰';

  @override
  String get childrenSection => 'قطعات و زیرمجموعه‌ها';

  @override
  String get addChild => 'افزودن زیرمجموعه';

  @override
  String get markMaintained => 'ثبت سرویس';

  @override
  String get maintainAction => 'سرویس';

  @override
  String remainingUsageLabel(String remaining) {
    return 'باقی‌مانده: $remaining';
  }

  @override
  String targetUsageLabel(String target) {
    return 'هدف: $target';
  }

  @override
  String get useParentUsage => 'استفاده از مصرف والد';

  @override
  String get useParentUsageSubtitle =>
      'خوانش مصرف از والد به ارث می‌رسد. برای ردیابی جداگانه خاموش کنید.';

  @override
  String get updateUsage => 'به‌روزرسانی مصرف';

  @override
  String get logKind => 'نوع گزارش';

  @override
  String get logKindMaintenance => 'سرویس انجام شد';

  @override
  String get logKindUsage => 'به‌روزرسانی مصرف';

  @override
  String currentUsageLabel(int value, String unit) {
    return 'مصرف فعلی: $value $unit';
  }

  @override
  String scheduleSummary(int value, String unit) {
    return 'هر $value $unit';
  }

  @override
  String get noScheduleConfigured => 'برای این دستگاه زمان‌بندی تعریف نشده';

  @override
  String get logHistory => 'تاریخچه گزارش‌ها';

  @override
  String get usageDelta => 'مصرف از آخرین گزارش';

  @override
  String get usageDeltaHint => 'اختیاری، مثلاً ۱۲۰';

  @override
  String get activeMaintenanceRules => 'قوانین نگهداری فعال';

  @override
  String get notes => 'یادداشت‌ها';

  @override
  String get notesHint => 'یادداشت نگهداری را وارد کنید...';

  @override
  String get notesRequired => 'یادداشت الزامی است';

  @override
  String get logCost => 'هزینه';

  @override
  String get logCostHint => 'اختیاری، مثلاً ۴۹.۹۹';

  @override
  String get logCostCurrency => 'برچسب ارز';

  @override
  String get logCostCurrencyHint =>
      'اختیاری — در صورت خالی بودن از ارز محلی استفاده می‌شود';

  @override
  String get logVendor => 'فروشنده / ارائه‌دهنده خدمات';

  @override
  String get logVendorHint => 'اختیاری، مثلاً تعمیرگاه';

  @override
  String get logPhoto => 'عکس';

  @override
  String get logPhotoAttach => 'پیوست عکس';

  @override
  String get logPhotoRemove => 'حذف عکس';

  @override
  String get logInvalidCost => 'مبلغ هزینه معتبر وارد کنید';

  @override
  String get date => 'تاریخ';

  @override
  String lastLog(String value) {
    return 'آخرین گزارش: $value';
  }

  @override
  String lastLogMinutesAgo(int count) {
    return '$count دقیقه پیش';
  }

  @override
  String lastLogDaysAgo(int count) {
    return '$count روز پیش';
  }

  @override
  String lastLogWeeksAgo(int count) {
    return '$count هفته پیش';
  }

  @override
  String get ruleEvery3Months => 'هر ۳ ماه';

  @override
  String get ruleEvery500Hours => 'هر ۵۰۰ ساعت';

  @override
  String get ruleEvery6Months => 'هر ۶ ماه';

  @override
  String get sampleDeviceAc => 'کولر گازی - پذیرایی';

  @override
  String get sampleDeviceCar => 'خودرو';

  @override
  String get sampleDeviceLaptop => 'لپ‌تاپ';

  @override
  String get sampleLogFilterReplaced => 'تعویض فیلتر';

  @override
  String get sampleLogOilChange => 'تعویض روغن';

  @override
  String get sampleLogGeneralCheck => 'بازرسی عمومی';

  @override
  String get data => 'داده';

  @override
  String get exportImport => 'خروجی و ورودی';

  @override
  String get exportImportHint =>
      'پشتیبان‌گیری یا بازیابی دستگاه‌ها، تولدها و مکان‌ها.';

  @override
  String get exportSection => 'خروجی';

  @override
  String get importSection => 'ورودی';

  @override
  String get exportScope => 'محدوده خروجی';

  @override
  String get exportScopeAll => 'همه داده‌ها';

  @override
  String get exportScopeOne => 'یک دستگاه';

  @override
  String get exportScopeSelected => 'دستگاه‌های انتخاب‌شده';

  @override
  String get exportFormat => 'قالب';

  @override
  String get formatJson => 'JSON';

  @override
  String get formatCsv => 'CSV';

  @override
  String get formatPlainText => 'متن ساده';

  @override
  String get selectDevices => 'انتخاب دستگاه‌ها';

  @override
  String get share => 'اشتراک‌گذاری';

  @override
  String get saveFile => 'ذخیره';

  @override
  String get chooseFile => 'انتخاب فایل';

  @override
  String get importAction => 'وارد کردن';

  @override
  String importPreview(int devices, int logs, int birthdays, int places) {
    return 'آماده برای وارد کردن: $devices دستگاه، $logs گزارش، $birthdays تولد، $places مکان';
  }

  @override
  String get ruleEvery1000Km => 'هر ۱۰۰۰ کیلومتر';

  @override
  String get exportSuccess => 'خروجی آماده است';

  @override
  String exportSaved(String path) {
    return 'ذخیره شد در $path';
  }

  @override
  String get exportCopied =>
      'خروجی در کلیپ‌بورد کپی شد (اشتراک‌گذاری در این سامانه در دسترس نیست)';

  @override
  String importSuccess(int devices, int birthdays, int places) {
    return '$devices دستگاه، $birthdays تولد و $places مکان وارد شد';
  }

  @override
  String get exportNoDevices => 'دستگاهی برای خروجی انتخاب نشده است';

  @override
  String get importInvalid => 'خواندن این فایل ممکن نشد';

  @override
  String get noDevicesForExport => 'دستگاهی برای خروجی وجود ندارد';

  @override
  String get noDataForExport => 'هنوز چیزی برای خروجی نیست';

  @override
  String get about => 'درباره';

  @override
  String get whatsNew => 'تازه‌ها';

  @override
  String get whatsNewHint => 'تغییرات این نسخه را ببینید';

  @override
  String appVersionLabel(String version) {
    return 'نسخه $version';
  }

  @override
  String get gotIt => 'متوجه شدم';

  @override
  String get cancel => 'لغو';

  @override
  String get confirm => 'تأیید';

  @override
  String get birthdays => 'تولدها';

  @override
  String get addBirthday => 'افزودن تولد';

  @override
  String get editBirthday => 'ویرایش تولد';

  @override
  String get personName => 'نام';

  @override
  String get personNameHint => 'نام فرد...';

  @override
  String get personNameRequired => 'نام الزامی است';

  @override
  String get birthMonthDay => 'تاریخ تولد';

  @override
  String get birthMonthDayHint => 'ماه و روز';

  @override
  String get birthMonthDayRequired => 'ماه و روز را انتخاب کنید';

  @override
  String get pickMonthDay => 'انتخاب ماه و روز';

  @override
  String get month => 'ماه';

  @override
  String get day => 'روز';

  @override
  String get noBirthdaysTitle => 'هنوز تولدی ثبت نشده';

  @override
  String get noBirthdaysHint =>
      'کسی را اضافه کنید تا تولدش را به خاطر بسپارید.';

  @override
  String get deleteBirthdayTitle => 'حذف تولد؟';

  @override
  String deleteBirthdayBody(String name) {
    return '$name از این دستگاه حذف می‌شود.';
  }

  @override
  String get calendarSystem => 'تقویم تاریخ';

  @override
  String get calendarGregorian => 'میلادی';

  @override
  String get calendarPersian => 'شمسی';

  @override
  String get calendarSystemHint => 'برای تاریخ تولد. مستقل از زبان برنامه.';

  @override
  String get remindersSection => 'یادآورها';

  @override
  String get featuresSection => 'بخش‌ها';

  @override
  String get deviceManagement => 'مدیریت دستگاه‌ها';

  @override
  String get deviceManagementHint =>
      'دستگاه‌ها، قطعات و برنامه نگهداری را پیگیری کنید.';

  @override
  String get birthdaysFeatureHint => 'تولد افراد مهم را به خاطر بسپارید.';

  @override
  String get places => 'مکان‌ها';

  @override
  String get placesFeatureHint =>
      'نقطه، مسیر و محدوده را روی نقشه ذخیره کنید تا آفلاین در دسترس باشد.';

  @override
  String get tags => 'برچسب‌ها';

  @override
  String get tagsFeatureHint =>
      'دستگاه‌ها را برای گروه‌بندی صفحهٔ خانه برچسب بزنید. برچسب دستگاه نیست.';

  @override
  String get addTag => 'افزودن برچسب';

  @override
  String get editTag => 'ویرایش برچسب';

  @override
  String get tagName => 'نام برچسب';

  @override
  String get tagNameHint => 'نام برچسب…';

  @override
  String get tagNameRequired => 'نام برچسب الزامی است';

  @override
  String get createTag => 'ایجاد برچسب';

  @override
  String get noTagsTitle => 'هنوز برچسبی نیست';

  @override
  String get noTagsHint =>
      'برچسب بسازید تا دستگاه‌ها را در صفحهٔ خانه گروه کنید.';

  @override
  String get deleteTagTitle => 'حذف برچسب؟';

  @override
  String deleteTagBody(String name) {
    return '$name حذف می‌شود و انتساب دستگاه‌ها پاک می‌شود.';
  }

  @override
  String get deviceTagsSection => 'برچسب‌ها';

  @override
  String get deviceTagsHint => 'برچسب‌های اختیاری برای گروه‌بندی یادآورها.';

  @override
  String get homeGroupingByDevice => 'بر اساس دستگاه';

  @override
  String get homeGroupingByTag => 'بر اساس برچسب';

  @override
  String get homeGroupingLabel => 'گروه‌بندی یادآورها';

  @override
  String get reminderTagRollup =>
      'جمع‌بندی برچسب · بدترین وضعیت دستگاه‌های مرتبط';

  @override
  String get addPlace => 'افزودن مکان';

  @override
  String get editPlace => 'ویرایش مکان';

  @override
  String get placeName => 'نام';

  @override
  String get placeNameHint => 'نام مکان…';

  @override
  String get placeNameRequired => 'نام الزامی است';

  @override
  String get placeGeometryRequired => 'نقاط لازم را روی نقشه اضافه کنید';

  @override
  String get placeKindPoint => 'نقطه';

  @override
  String get placeKindLine => 'خط';

  @override
  String get placeKindArea => 'محدوده';

  @override
  String placeKindLineWithCount(int count) {
    return 'خط · $count نقطه';
  }

  @override
  String placeKindAreaWithCount(int count) {
    return 'محدوده · $count نقطه';
  }

  @override
  String placeCoordinateSummary(double lat, double lng) {
    return '$lat, $lng';
  }

  @override
  String get placeMapHintPoint => 'روی نقشه بزنید تا نقطه را تنظیم کنید';

  @override
  String placeMapHintLine(int count) {
    return 'نقطه اضافه کنید ($count تا الان). حداقل ۲ نقطه لازم است.';
  }

  @override
  String placeMapHintArea(int count) {
    return 'نقطه اضافه کنید ($count تا الان). حداقل ۳ نقطه لازم است.';
  }

  @override
  String get placeUseMyLocation => 'موقعیت من';

  @override
  String get placeUndoPoint => 'برگرداندن نقطه';

  @override
  String get placeLocationDenied =>
      'برای استفاده از موقعیت شما، اجازه دسترسی به مکان لازم است.';

  @override
  String get noPlacesTitle => 'هنوز مکانی ثبت نشده';

  @override
  String get noPlacesHint =>
      'یک نقطه، مسیر یا محدوده اضافه کنید تا آفلاین پیدا کنید.';

  @override
  String get deletePlaceTitle => 'حذف مکان؟';

  @override
  String deletePlaceBody(String name) {
    return '$name از این دستگاه حذف می‌شود.';
  }

  @override
  String get reminderFilterAll => 'همه';

  @override
  String get reminderFilterDevices => 'دستگاه‌ها';

  @override
  String get reminderFilterBirthdays => 'تولدها';

  @override
  String get noRemindersTitle => 'مورد فوری نیست';

  @override
  String get noRemindersHint =>
      'نگهداری سررسید و تولدهای نزدیک اینجا نمایش داده می‌شوند.';

  @override
  String get reminderDeviceDue => 'نگهداری سررسید شده';

  @override
  String get reminderDeviceSoon => 'نگهداری به زودی';

  @override
  String get reminderBirthdayToday => 'امروز تولد است';

  @override
  String get reminderBirthdayTomorrow => 'فردا تولد است';

  @override
  String reminderBirthdayInDays(int days) {
    return 'تولد تا $days روز دیگر';
  }

  @override
  String get reminderBadgeDue => 'سررسید';

  @override
  String get reminderBadgeSoon => 'به زودی';

  @override
  String get reminderBadgeUpcoming => 'نزدیک';

  @override
  String get reminderNotificationsSection => 'یادآور سررسید';

  @override
  String get reminderNotificationsEnabled => 'یادآور محلی سررسید';

  @override
  String get reminderNotificationsHint =>
      'وقتی نگهداری سررسید شود یا تولد نزدیک باشد، اعلان بده.';

  @override
  String get reminderNotificationTime => 'زمان اعلان';

  @override
  String get reminderNotificationTimeHint =>
      'زمان روزانه برای یادآور نگهداری و تولد.';

  @override
  String get reminderQuickActionsMenu => 'اقدام‌های سریع';

  @override
  String get reminderSnooze => 'تعویق';

  @override
  String get reminderSnoozeTitle => 'تعویق یادآور';

  @override
  String get reminderSnoozeOneDay => '۱ روز';

  @override
  String get reminderSnoozeThreeDays => '۳ روز';

  @override
  String get reminderSnoozeSevenDays => '۷ روز';

  @override
  String reminderSnoozedForDays(int days) {
    return 'به مدت $days روز تعویق شد';
  }

  @override
  String get soonWindowSevenDays => '۷ روز';

  @override
  String get soonWindowFourteenDays => '۱۴ روز';

  @override
  String get soonWindowHint =>
      'نشان «به زودی» برای تولد و یادآورهای خانه بر اساس این بازه است.';

  @override
  String get checkForUpdates => 'بررسی به‌روزرسانی';

  @override
  String get checkForUpdatesHint => 'آخرین نسخه را از گیت‌هاب دریافت کنید';

  @override
  String get updateChecking => 'در حال بررسی به‌روزرسانی…';

  @override
  String get updateUpToDate => 'آخرین نسخه را دارید';

  @override
  String get updateUnsupportedPlatform =>
      'به‌روزرسانی درون‌برنامه‌ای روی این پلتفرم پشتیبانی نمی‌شود';

  @override
  String get updateAvailableTitle => 'به‌روزرسانی موجود است';

  @override
  String updateAvailableBody(String version, String size) {
    return 'نسخه $version آماده است ($size).';
  }

  @override
  String get updateReleaseNotes => 'یادداشت انتشار';

  @override
  String get updateDownload => 'دانلود';

  @override
  String get updateInstall => 'نصب به‌روزرسانی';

  @override
  String updateDownloadProgress(int percent) {
    return 'در حال دانلود… $percent٪';
  }

  @override
  String get updateReadyToInstall =>
      'دانلود کامل شد. برای پایان به‌روزرسانی نصب کنید.';

  @override
  String updateBannerMessage(String version) {
    return 'نسخه $version موجود است';
  }

  @override
  String get updateErrorOffline =>
      'اتصال به گیت‌هاب برقرار نشد. اینترنت را بررسی کنید و دوباره تلاش کنید.';

  @override
  String updateSizeKb(int size) {
    return '$size کیلوبایت';
  }

  @override
  String updateSizeMb(String size) {
    return '$size مگابایت';
  }

  @override
  String get dismiss => 'بستن';

  @override
  String get search => 'جستجو';

  @override
  String get searchHint => 'جستجو بر اساس نام…';

  @override
  String get searchPromptTitle => 'دستگاه‌ها، تولدها و مکان‌ها را پیدا کنید';

  @override
  String get searchPromptHint =>
      'نام را وارد کنید تا در دستگاه‌ها، تولدها و مکان‌ها جستجو شود.';

  @override
  String get searchNoResultsTitle => 'نتیجه‌ای یافت نشد';

  @override
  String get searchNoResultsHint =>
      'نام دیگری امتحان کنید یا املای آن را بررسی کنید.';

  @override
  String get searchDevicesSection => 'دستگاه‌ها';

  @override
  String get searchBirthdaysSection => 'تولدها';

  @override
  String get searchPlacesSection => 'مکان‌ها';

  @override
  String get searchPathSeparator => ' › ';

  @override
  String get syncSection => 'همگام‌سازی';

  @override
  String get syncWithRemote => 'همگام‌سازی با سرور';

  @override
  String get syncWithRemoteHint =>
      'وقتی روشن باشد و آنلاین باشید، برنامه ممکن است با سرور شما همگام شود. برای نگه‌داشتن داده فقط روی این دستگاه خاموش کنید. همه چیز همچنان آفلاین کار می‌کند.';

  @override
  String get syncStatusOff =>
      'همگام‌سازی خاموش — داده فقط روی این دستگاه می‌ماند.';

  @override
  String get syncStatusOffline => 'آفلاین — تا اتصال دوباره فقط دادهٔ محلی.';

  @override
  String get syncStatusReady =>
      'آماده — تا فراهم شدن همگام‌سازی سرور فقط محلی.';

  @override
  String get navHome => 'خانه';

  @override
  String get navProfile => 'پروفایل';

  @override
  String get introTitle => 'به نصیاد خوش آمدید';

  @override
  String get introBody =>
      'برای همگام‌سازی حساب بین دستگاه‌ها وارد شوید. می‌توانید بدون حساب هم ادامه دهید — همه چیز روی این دستگاه کار می‌کند.';

  @override
  String get introSignInWithPhone => 'ورود با موبایل';

  @override
  String get introContinueOffline => 'ادامه بدون حساب';

  @override
  String get authSignInTitle => 'ورود';

  @override
  String get authPhoneBody =>
      'شماره موبایل خود را وارد کنید. یک کد یک‌بارمصرف برایتان ارسال می‌شود.';

  @override
  String get authPhoneLabel => 'شماره موبایل';

  @override
  String get authPhoneHint => '+۹۸۹۱۲… یا ۰۹۱۲…';

  @override
  String get authSendCode => 'ارسال کد';

  @override
  String get authOtpTitle => 'ورود کد';

  @override
  String authOtpBody(String phone) {
    return 'کد ارسال‌شده به $phone را وارد کنید.';
  }

  @override
  String get authOtpLabel => 'کد تأیید';

  @override
  String get authOtpHint => 'کد ۶ رقمی';

  @override
  String get authVerify => 'تأیید';

  @override
  String get authResendCode => 'ارسال دوباره';

  @override
  String authResendCooldown(int seconds) {
    return 'ارسال دوباره تا $seconds ثانیه';
  }

  @override
  String get authInvalidPhone => 'یک شماره موبایل معتبر وارد کنید';

  @override
  String get authInvalidCode => 'یک کد تأیید معتبر وارد کنید';

  @override
  String get authGenericError => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get authSyncing => 'در حال همگام‌سازی داده‌ها…';

  @override
  String get authSyncFailed =>
      'وارد شدید. همگام‌سازی الان ممکن نبود — دادهٔ محلی‌تان امن است.';

  @override
  String get authSyncConflictTitle => 'داده روی این دستگاه و سرور فرق دارد';

  @override
  String authSyncConflictBody(int count) {
    return 'چند مورد در هر دو جا با مقدار متفاوت وجود دارد ($count). ادامه دادن دادهٔ این دستگاه را نگه می‌دارد و سرور را به‌روز می‌کند. دادهٔ محلی جایگزین نمی‌شود.';
  }

  @override
  String get authSyncConflictConfirm => 'نگه داشتن دادهٔ دستگاه';

  @override
  String get authSyncConflictCancel => 'رد کردن همگام‌سازی';

  @override
  String get authSyncCancelled =>
      'وارد شدید. همگام‌سازی رد شد — دادهٔ محلی‌تان بدون تغییر ماند.';

  @override
  String get authSignOut => 'خروج';

  @override
  String get appLockResetSuccess => 'قفل برنامه خاموش شد';

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get profileGuestTitle => 'وارد نشده‌اید';

  @override
  String get profileGuestBody =>
      'با موبایل وارد شوید تا پروفایل را مدیریت کنید. دادهٔ محلی در هر صورت آفلاین کار می‌کند.';

  @override
  String get profileEditTitle => 'ویرایش پروفایل';

  @override
  String get profileNameLabel => 'نام';

  @override
  String get profileNameHint => 'نام نمایشی شما';

  @override
  String get profileNameEmpty => 'نامی تنظیم نشده';

  @override
  String get profileIdLabel => 'شناسه حساب';

  @override
  String get profileIdHint => 'شناسه صادرشده توسط سرور (فقط خواندنی)';

  @override
  String get profileChangePhoto => 'تغییر تصویر';

  @override
  String get profileSaved => 'پروفایل ذخیره شد';

  @override
  String get appLockSection => 'قفل برنامه';

  @override
  String get languageAndRegion => 'زبان و منطقه';

  @override
  String get appLockMethodOff => 'خاموش';

  @override
  String get appLockMethodPassword => 'رمز عبور';

  @override
  String get appLockMethodPin => 'پین';

  @override
  String get appLockMethodBiometric => 'اثر انگشت';

  @override
  String get appLockTimeout => 'قفل بعد از';

  @override
  String get appLockTimeoutImmediate => 'فوری';

  @override
  String get appLockTimeoutOneMinute => '۱ دقیقه';

  @override
  String get appLockTimeoutFiveMinutes => '۵ دقیقه';

  @override
  String get appLockTimeoutFifteenMinutes => '۱۵ دقیقه';

  @override
  String get appLockTimeoutThirtyMinutes => '۳۰ دقیقه';

  @override
  String get appLockTimeoutOneHour => '۱ ساعت';

  @override
  String get appLockUnlockTitle => 'باز کردن ناصیاد';

  @override
  String get appLockUnlock => 'باز کردن';

  @override
  String get appLockPasswordLabel => 'رمز عبور';

  @override
  String get appLockPasswordHint => 'رمز را وارد کنید';

  @override
  String get appLockPinLabel => 'پین';

  @override
  String get appLockPinHint => '۴ تا ۸ رقم';

  @override
  String get appLockUseBiometric => 'استفاده از اثر انگشت';

  @override
  String get appLockBiometricPrompt => 'باز کردن ناصیاد';

  @override
  String get appLockForgot => 'قفل را فراموش کرده‌اید؟';

  @override
  String get appLockForgotPhoneBody =>
      'برای برداشتن قفل برنامه، شماره موبایل را تأیید کنید. داده‌هایتان روی همین دستگاه می‌ماند.';

  @override
  String get appLockCreatePassword => 'ساخت رمز عبور';

  @override
  String get appLockCreatePin => 'ساخت پین';

  @override
  String get appLockConfirmLabel => 'تأیید';

  @override
  String get appLockConfirmHint => 'دوباره وارد کنید';

  @override
  String get appLockMismatch => 'مقادیر یکسان نیستند';

  @override
  String get appLockPasswordTooShort => 'حداقل ۴ نویسه وارد کنید';

  @override
  String get appLockPinTooShort => '۴ تا ۸ رقم وارد کنید';

  @override
  String get appLockWrongSecret => 'اشتباه است';

  @override
  String get appLockBiometricUnavailable =>
      'اثر انگشت روی این دستگاه در دسترس نیست';

  @override
  String get appLockBiometricFailed => 'اثر انگشت کار نکرد. دوباره تلاش کنید.';

  @override
  String get appLockVerifyToContinue => 'برای ادامه باز کنید';

  @override
  String get shareHistory => 'اشتراک‌گذاری تاریخچه';

  @override
  String get noMaintenanceToShare => 'تاریخچه تعمیراتی برای اشتراک‌گذاری نیست';

  @override
  String get historyCopiedToClipboard => 'تاریخچه در کلیپ‌بورد کپی شد';

  @override
  String maintenanceHistoryTitle(String deviceName) {
    return 'تاریخچه تعمیرات $deviceName';
  }
}
