import 'package:nasyad/core/version/semver.dart';

/// Languages that must have end-user release notes (matches `lib/l10n`).
const List<String> changelogLanguageCodes = ['en', 'fa'];

class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.en,
    required this.fa,
  });

  final String version;
  final List<String> en;
  final List<String> fa;

  /// End-user bullet points for [languageCode] (`en` / `fa`).
  /// Unknown codes fall back to English.
  List<String> notesFor(String languageCode) {
    return switch (languageCode) {
      'fa' => fa,
      _ => en,
    };
  }

  /// True when every supported app language has at least one note.
  bool get hasNotesForAllLanguages {
    for (final code in changelogLanguageCodes) {
      if (notesFor(code).isEmpty) return false;
    }
    return true;
  }
}

abstract final class AppChangelog {
  /// Newest first. Notes are written for end users in every `lib/l10n` language.
  static const List<ChangelogEntry> entries = [
    ChangelogEntry(
      version: '1.4.0',
      en: [
        'Turn on local due reminders — get notified when maintenance is due or a birthday is coming up.',
        'Browse archived devices and restore whole subtrees when you need them again.',
        'Mark maintenance done from a device reminder on Home without opening the device first.',
        'Search devices and birthdays by name from the Home feature menu.',
        'Add optional category, location, and notes when editing a device.',
        'Pick bundled schedule templates when adding or editing a device — presets like oil change or HVAC filter fill in the schedule for you.',
        'Maintenance logs can include optional cost, vendor, and a photo attachment.',
        'Snooze Home reminders for 1, 3, or 7 days; choose how many days count as "Soon" in Preferences.',
        'Export and import carry device metadata, log extras, and photos in JSON, CSV, and plain text.',
      ],
      fa: [
        'یادآور سررسید محلی را روشن کنید — وقتی نگهداری سررسید است یا تولد نزدیک است، اعلان بگیرید.',
        'دستگاه‌های بایگانی‌شده را مرور کنید و در صورت نیاز کل زیردرخت را بازیابی کنید.',
        'از یادآور دستگاه در صفحهٔ اصلی، نگهداری را انجام‌شده علامت بزنید — بدون باز کردن صفحهٔ دستگاه.',
        'از منوی بخش‌ها در صفحهٔ اصلی، دستگاه‌ها و تولدها را با نام جستجو کنید.',
        'هنگام ویرایش دستگاه، دسته، مکان و یادداشت اختیاری اضافه کنید.',
        'هنگام افزودن یا ویرایش دستگاه، از الگوهای زمان‌بندی آماده استفاده کنید — پیش‌تنظیم‌هایی مثل تعویض روغن یا فیلتر HVAC، زمان‌بندی را برای شما پر می‌کنند.',
        'گزارش نگهداری می‌تواند هزینه، فروشنده و عکس پیوست اختیاری داشته باشد.',
        'یادآورهای صفحهٔ اصلی را ۱، ۳ یا ۷ روز تعویق بیندازید؛ در تنظیمات مشخص کنید چند روز «به‌زودی» حساب شود.',
        'خروجی و ورود داده، متادادهٔ دستگاه، جزئیات گزارش و عکس‌ها را در JSON، CSV و متن ساده منتقل می‌کند.',
      ],
    ),
    ChangelogEntry(
      version: '1.3.0',
      en: [
        'Check for app updates from GitHub — a banner on Home or manual check in Preferences downloads and installs the latest release.',
        'Pick a season theme (spring, summer, autumn, winter) with matching light and dark accents.',
        'Open specific screens from links — devices, birthdays, preferences, and more via nasyad:// URLs.',
      ],
      fa: [
        'به‌روزرسانی برنامه را از GitHub بررسی کنید — بنر در صفحهٔ اصلی یا بررسی دستی در تنظیمات، آخرین نسخه را دانلود و نصب می‌کند.',
        'تم فصلی (بهار، تابستان، پاییز، زمستان) با رنگ‌های متناسب در حالت روشن و تاریک انتخاب کنید.',
        'صفحات مشخص را با پیوند nasyad:// باز کنید — دستگاه‌ها، تولدها، تنظیمات و بیشتر.',
      ],
    ),
    ChangelogEntry(
      version: '1.2.0',
      en: [
        'Home is now a hub: see due maintenance and upcoming birthdays in one reminders list.',
        'Filter reminders by all items, devices only, or birthdays only.',
        'Open device management and birthdays from a feature menu on Home.',
        'The full device list moved to Device management — tap it from Home.',
      ],
      fa: [
        'صفحهٔ اصلی حالا یک مرکز است: نگهداری سررسید و تولدهای نزدیک را در یک فهرست یادآور ببینید.',
        'یادآورها را بر اساس همه، فقط دستگاه‌ها یا فقط تولدها فیلتر کنید.',
        'مدیریت دستگاه‌ها و تولدها را از منوی بخش‌ها در صفحهٔ اصلی باز کنید.',
        'فهرست کامل دستگاه‌ها به «مدیریت دستگاه‌ها» منتقل شد — از صفحهٔ اصلی آن را باز کنید.',
      ],
    ),
    ChangelogEntry(
      version: '1.1.0',
      en: [
        'Organize devices in a tree — nest parts under a car, appliance, or any parent.',
        'Add an optional schedule to any device: by calendar time, by usage (km, hours, or cycles), or a fixed due date.',
        'Log two ways: mark something as maintained, or only update the usage reading. Updating usage no longer resets your progress.',
        'When you add a schedule, you can say how much of the current cycle is already used.',
        'Exports keep parent–child links. Older backups still import fine.',
      ],
      fa: [
        'دستگاه‌ها را به‌صورت درختی مرتب کنید — قطعات را زیر خودرو، لوازم خانگی یا هر والد دیگری قرار دهید.',
        'برای هر دستگاه زمان‌بندی اختیاری بگذارید: بر اساس تقویم، کارکرد (کیلومتر، ساعت یا سیکل)، یا یک تاریخ سررسید ثابت.',
        'دو جور ثبت کنید: علامت‌گذاری نگهداری انجام‌شده، یا فقط به‌روزرسانی کارکرد. به‌روزرسانی کارکرد دیگر پیشرفت شما را صفر نمی‌کند.',
        'هنگام افزودن زمان‌بندی می‌توانید بگویید چقدر از دورهٔ فعلی از قبل مصرف شده است.',
        'خروجی‌ها پیوند والد و فرزند را نگه می‌دارند. پشتیبان‌های قدیمی همچنان بدون مشکل وارد می‌شوند.',
      ],
    ),
    ChangelogEntry(
      version: '1.0.0',
      en: [
        'Track your devices and maintenance schedules on this device — no account needed.',
        'Log service history and see at a glance what is due soon or overdue.',
        'Export or import your data as JSON, CSV, or plain text.',
      ],
      fa: [
        'دستگاه‌ها و زمان‌بندی نگهداری را روی همین گوشی پیگیری کنید — بدون نیاز به حساب کاربری.',
        'تاریخچه سرویس را ثبت کنید و ببینید چه چیزی به‌زودی سررسید می‌شود یا گذشته است.',
        'داده‌ها را به‌صورت JSON، CSV یا متن ساده خروجی بگیرید یا وارد کنید.',
      ],
    ),
  ];

  static ChangelogEntry? get latest => entries.isEmpty ? null : entries.first;

  static List<ChangelogEntry> entriesSince(String? lastSeenVersion) {
    return changelogEntriesSince(entries, lastSeenVersion);
  }

  static List<ChangelogEntry> forPreferences() => List.unmodifiable(entries);
}

List<ChangelogEntry> changelogEntriesSince(
  List<ChangelogEntry> entries,
  String? lastSeenVersion,
) {
  if (entries.isEmpty) return const [];
  if (lastSeenVersion == null || lastSeenVersion.isEmpty) {
    return [entries.first];
  }

  SemVer? lastSeen;
  try {
    lastSeen = SemVer.parse(lastSeenVersion);
  } on FormatException {
    return [entries.first];
  }

  final newer = <ChangelogEntry>[];
  for (final entry in entries) {
    try {
      final entryVersion = SemVer.parse(entry.version);
      if (entryVersion.compareName(lastSeen) > 0) {
        newer.add(entry);
      }
    } on FormatException {
      continue;
    }
  }

  if (newer.isEmpty) return [entries.first];
  return newer;
}
