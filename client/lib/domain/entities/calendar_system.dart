enum CalendarSystem {
  gregorian,
  persian;

  String get storageValue => name;

  static CalendarSystem fromStorage(String? value) {
    return switch (value) {
      'persian' => CalendarSystem.persian,
      _ => CalendarSystem.gregorian,
    };
  }
}
