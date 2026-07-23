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
      'یک دستگاه اضافه کنید و یک قانون نگهداری انتخاب کنید.';

  @override
  String get noLogsYet => 'هنوز گزارشی نیست';

  @override
  String get usageDelta => 'مصرف از آخرین گزارش';

  @override
  String get usageDeltaHint => 'اختیاری، مثلاً ۱۲۰';

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
  String get activeMaintenanceRules => 'قوانین نگهداری فعال';

  @override
  String get logHistory => 'تاریخچه گزارش‌ها';

  @override
  String get notes => 'یادداشت‌ها';

  @override
  String get notesHint => 'یادداشت نگهداری را وارد کنید...';

  @override
  String get notesRequired => 'یادداشت الزامی است';

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
      'پشتیبان‌گیری یا بازیابی دستگاه‌ها، قوانین و گزارش‌ها.';

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
  String importPreview(int devices, int rules, int logs) {
    return 'آماده برای وارد کردن: $devices دستگاه، $rules قانون، $logs گزارش';
  }

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
}
