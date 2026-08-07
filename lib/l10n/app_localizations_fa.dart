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
  String get brightness => 'روشنایی';

  @override
  String get deviceName => 'نام دستگاه';

  @override
  String get deviceNameHint => 'نام دستگاه را وارد کنید...';

  @override
  String get deviceNameRequired => 'نام دستگاه الزامی است';

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
      'پشتیبان‌گیری یا بازیابی دستگاه‌ها و گزارش‌ها.';

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
  String importPreview(int devices, int logs) {
    return 'آماده برای وارد کردن: $devices دستگاه، $logs گزارش';
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
  String importSuccess(int devices) {
    return '$devices دستگاه وارد شد';
  }

  @override
  String get exportNoDevices => 'دستگاهی برای خروجی انتخاب نشده است';

  @override
  String get importInvalid => 'خواندن این فایل ممکن نشد';

  @override
  String get noDevicesForExport => 'دستگاهی برای خروجی وجود ندارد';

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
}
