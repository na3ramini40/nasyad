enum CalendarIntervalUnit {
  days,
  weeks,
  months,
}

enum UsageIntervalUnit {
  km,
  hours,
  cycles,
}

extension CalendarIntervalUnitX on CalendarIntervalUnit {
  String get storageValue => name;

  static CalendarIntervalUnit fromStorage(String value) {
    return CalendarIntervalUnit.values.firstWhere(
      (unit) => unit.name == value,
      orElse: () => CalendarIntervalUnit.months,
    );
  }
}

extension UsageIntervalUnitX on UsageIntervalUnit {
  String get storageValue => name;

  static UsageIntervalUnit fromStorage(String value) {
    return UsageIntervalUnit.values.firstWhere(
      (unit) => unit.name == value,
      orElse: () => UsageIntervalUnit.hours,
    );
  }
}
