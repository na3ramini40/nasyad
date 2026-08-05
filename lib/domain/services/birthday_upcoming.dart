import 'package:shamsi_date/shamsi_date.dart';

import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/services/month_day.dart';

class BirthdayUpcoming {
  const BirthdayUpcoming({required this.daysUntil, required this.isToday});

  final int daysUntil;
  final bool isToday;
}

abstract final class BirthdayUpcomingCalculator {
  static const reminderWindowDays = 30;
  static const soonThresholdDays = 7;

  static BirthdayUpcoming? calculate(Birthday birthday, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final next = _nextOccurrence(
      month: birthday.birthMonth,
      day: birthday.birthDay,
      calendar: birthday.calendarSystem,
      onOrAfter: today,
    );
    final daysUntil = next.difference(today).inDays;
    if (daysUntil > reminderWindowDays) return null;
    return BirthdayUpcoming(daysUntil: daysUntil, isToday: daysUntil == 0);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime _nextOccurrence({
    required int month,
    required int day,
    required CalendarSystem calendar,
    required DateTime onOrAfter,
  }) {
    return switch (calendar) {
      CalendarSystem.gregorian => _nextGregorian(
        month: month,
        day: day,
        onOrAfter: onOrAfter,
      ),
      CalendarSystem.persian => _nextPersian(
        month: month,
        day: day,
        onOrAfter: onOrAfter,
      ),
    };
  }

  static DateTime _nextGregorian({
    required int month,
    required int day,
    required DateTime onOrAfter,
  }) {
    var year = onOrAfter.year;
    var candidate = _safeGregorian(year, month, day);
    if (candidate.isBefore(onOrAfter)) {
      year += 1;
      candidate = _safeGregorian(year, month, day);
    }
    return candidate;
  }

  static DateTime _safeGregorian(int year, int month, int day) {
    final maxDay = MonthDay.daysInMonth(month, CalendarSystem.gregorian);
    final safeDay = day.clamp(1, maxDay);
    if (month == 2 && day == 29) {
      var safeYear = year;
      while (!Gregorian(safeYear).isLeapYear()) {
        safeYear -= 1;
      }
      return DateTime(safeYear, month, safeDay);
    }
    return DateTime(year, month, safeDay);
  }

  static DateTime _nextPersian({
    required int month,
    required int day,
    required DateTime onOrAfter,
  }) {
    final jNow = Jalali.fromDateTime(onOrAfter);
    var year = jNow.year;
    var candidate = _safePersianDateTime(year, month, day);
    if (candidate.isBefore(onOrAfter)) {
      year += 1;
      candidate = _safePersianDateTime(year, month, day);
    }
    return candidate;
  }

  static DateTime _safePersianDateTime(int year, int month, int day) {
    if (month == 12 && day == 30) {
      var safeYear = year;
      while (!Jalali(safeYear).isLeapYear()) {
        safeYear += 1;
      }
      return Jalali(safeYear, month, day).toDateTime();
    }
    final maxDay = MonthDay.daysInMonth(month, CalendarSystem.persian);
    final safeDay = day.clamp(1, maxDay);
    return Jalali(year, month, safeDay).toDateTime();
  }
}
