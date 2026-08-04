import 'package:shamsi_date/shamsi_date.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';

class MonthDay {
  final int month;
  final int day;

  const MonthDay({required this.month, required this.day});

  static void validate(int month, int day, CalendarSystem calendar) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    final maxDay = daysInMonth(month, calendar);
    if (day < 1 || day > maxDay) {
      throw ArgumentError('Day must be between 1 and $maxDay');
    }
  }

  static int daysInMonth(int month, CalendarSystem calendar) {
    return switch (calendar) {
      CalendarSystem.gregorian => switch (month) {
        2 => 29,
        4 || 6 || 9 || 11 => 30,
        _ => 31,
      },
      CalendarSystem.persian => switch (month) {
        >= 1 && <= 6 => 31,
        >= 7 && <= 11 => 30,
        _ => 30,
      },
    };
  }

  static List<String> monthNames(
    CalendarSystem calendar, {
    required bool persianLabels,
  }) {
    if (calendar == CalendarSystem.persian) {
      return persianLabels
          ? const [
              'فروردین',
              'اردیبهشت',
              'خرداد',
              'تیر',
              'مرداد',
              'شهریور',
              'مهر',
              'آبان',
              'آذر',
              'دی',
              'بهمن',
              'اسفند',
            ]
          : const [
              'Farvardin',
              'Ordibehesht',
              'Khordad',
              'Tir',
              'Mordad',
              'Shahrivar',
              'Mehr',
              'Aban',
              'Azar',
              'Dey',
              'Bahman',
              'Esfand',
            ];
    }

    return persianLabels
        ? const [
            'ژانویه',
            'فوریه',
            'مارس',
            'آوریل',
            'مه',
            'ژوئن',
            'ژوئیه',
            'اوت',
            'سپتامبر',
            'اکتبر',
            'نوامبر',
            'دسامبر',
          ]
        : const [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ];
  }

  static String format(
    int month,
    int day,
    CalendarSystem storedCalendar, {
    required CalendarSystem displayCalendar,
    required bool persianLabels,
  }) {
    final displayed = convert(
      month: month,
      day: day,
      from: storedCalendar,
      to: displayCalendar,
    );
    final names = monthNames(displayCalendar, persianLabels: persianLabels);
    return '${names[displayed.month - 1]} ${displayed.day}';
  }

  static MonthDay convert({
    required int month,
    required int day,
    required CalendarSystem from,
    required CalendarSystem to,
  }) {
    if (from == to) return MonthDay(month: month, day: day);

    if (from == CalendarSystem.persian && to == CalendarSystem.gregorian) {
      final now = Jalali.now();
      var year = now.year;
      if (month == 12 && day == 30) {
        while (!Jalali(year).isLeapYear()) {
          year -= 1;
        }
      }
      final safeDay = day.clamp(1, daysInMonth(month, CalendarSystem.persian));
      final g = Jalali(year, month, safeDay).toGregorian();
      return MonthDay(month: g.month, day: g.day);
    }

    var year = DateTime.now().year;
    if (month == 2 && day == 29) {
      while (!Gregorian(year).isLeapYear()) {
        year -= 1;
      }
    }
    final safeDay = day.clamp(1, daysInMonth(month, CalendarSystem.gregorian));
    final j = Gregorian(year, month, safeDay).toJalali();
    return MonthDay(month: j.month, day: j.day);
  }
}
