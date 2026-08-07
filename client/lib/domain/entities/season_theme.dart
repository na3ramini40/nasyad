enum SeasonTheme {
  classic,
  spring,
  summer,
  autumn,
  winter;

  String get storageValue => name;

  static SeasonTheme fromStorage(String? value) {
    return switch (value) {
      'spring' => SeasonTheme.spring,
      'summer' => SeasonTheme.summer,
      'autumn' => SeasonTheme.autumn,
      'winter' => SeasonTheme.winter,
      _ => SeasonTheme.classic,
    };
  }

  static const selectable = [
    SeasonTheme.classic,
    SeasonTheme.spring,
    SeasonTheme.summer,
    SeasonTheme.autumn,
    SeasonTheme.winter,
  ];
}
