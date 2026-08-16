abstract final class UiScale {
  static const double min = 0.85;
  static const double max = 1.45;
  static const double defaultValue = 1.0;

  static double clamp(double value) => value.clamp(min, max).toDouble();
}
