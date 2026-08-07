enum SoonWindowDays {
  seven(7),
  fourteen(14);

  const SoonWindowDays(this.days);

  final int days;

  static const defaultValue = SoonWindowDays.seven;

  static SoonWindowDays fromStorage(int? value) {
    return switch (value) {
      14 => SoonWindowDays.fourteen,
      _ => SoonWindowDays.seven,
    };
  }

  int get storageValue => days;
}
