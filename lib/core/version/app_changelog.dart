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
