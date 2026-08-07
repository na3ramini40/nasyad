import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/services/month_day.dart';

void main() {
  group('MonthDay', () {
    test('validates gregorian days', () {
      expect(
        () => MonthDay.validate(2, 29, CalendarSystem.gregorian),
        returnsNormally,
      );
      expect(
        () => MonthDay.validate(2, 30, CalendarSystem.gregorian),
        throwsArgumentError,
      );
    });

    test('validates persian days', () {
      expect(
        () => MonthDay.validate(1, 31, CalendarSystem.persian),
        returnsNormally,
      );
      expect(
        () => MonthDay.validate(7, 31, CalendarSystem.persian),
        throwsArgumentError,
      );
    });

    test('keeps month/day when calendar unchanged', () {
      final result = MonthDay.convert(
        month: 3,
        day: 15,
        from: CalendarSystem.persian,
        to: CalendarSystem.persian,
      );
      expect(result.month, 3);
      expect(result.day, 15);
    });

    test('formats using display calendar', () {
      final text = MonthDay.format(
        1,
        1,
        CalendarSystem.persian,
        displayCalendar: CalendarSystem.persian,
        persianLabels: false,
      );
      expect(text, 'Farvardin 1');
    });
  });
}
