import 'package:nasyad/core/version/semver.dart';

class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.en,
    required this.fa,
  });

  final String version;
  final List<String> en;
  final List<String> fa;

  List<String> notesFor(String languageCode) {
    return languageCode == 'fa' ? fa : en;
  }
}

abstract final class AppChangelog {
  /// Newest first.
  static const List<ChangelogEntry> entries = [
    ChangelogEntry(
      version: '1.1.0',
      en: [
        'Nest devices under parent assets; progress rolls up the tree.',
        'Optional schedule on any node: calendar, usage, or a fixed date.',
        'Mark maintained vs update usage (odometer) without resetting cycles.',
        'Set how much of a cycle was already used when you add a schedule.',
        'Export format v2 keeps parent links; older backups still import.',
      ],
      fa: [
        'دستگاه‌ها را زیر دارایی والد تو در تو کنید؛ پیشرفت در درخت جمع می‌شود.',
        'زمان‌بندی اختیاری روی هر گره: تقویم، کارکرد، یا تاریخ ثابت.',
        'ثبت نگهداری در برابر به‌روزرسانی کارکرد (کیلومترشمار) بدون ریست چرخه.',
        'هنگام افزودن زمان‌بندی مشخص کنید چقدر از دوره از قبل مصرف شده.',
        'خروجی نسخه ۲ پیوند والد را نگه می‌دارد؛ پشتیبان‌های قدیمی هم وارد می‌شوند.',
      ],
    ),
    ChangelogEntry(
      version: '1.0.0',
      en: [
        'Track devices and maintenance schedules locally.',
        'Log service history and see due status at a glance.',
        'Export and import your data as JSON, CSV, or plain text.',
      ],
      fa: [
        'دستگاه‌ها و زمان‌بندی نگهداری را به‌صورت محلی پیگیری کنید.',
        'تاریخچه سرویس را ثبت کنید و وضعیت سررسید را ببینید.',
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
