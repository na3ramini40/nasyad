/// Idle timeout before the app locks. Stored as a stable string key.
enum LockIdleTimeout {
  immediate(Duration.zero, 'immediate'),
  oneMinute(Duration(minutes: 1), '1m'),
  fiveMinutes(Duration(minutes: 5), '5m'),
  fifteenMinutes(Duration(minutes: 15), '15m'),
  thirtyMinutes(Duration(minutes: 30), '30m'),
  oneHour(Duration(hours: 1), '1h');

  const LockIdleTimeout(this.duration, this.storageValue);

  final Duration duration;
  final String storageValue;

  bool get isImmediate => this == LockIdleTimeout.immediate;

  static const LockIdleTimeout defaultValue = LockIdleTimeout.fiveMinutes;

  static LockIdleTimeout fromStorage(String? value) {
    return LockIdleTimeout.values.firstWhere(
      (e) => e.storageValue == value,
      orElse: () => defaultValue,
    );
  }
}
