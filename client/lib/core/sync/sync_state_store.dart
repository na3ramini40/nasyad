import 'package:shared_preferences/shared_preferences.dart';

/// Persists pull cursors for remote sync resources.
///
/// Keys match [docs/domain/sync.md]: devices/birthdays by `updated_at`,
/// device logs by `created_at`.
class SyncStateStore {
  SyncStateStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  SyncStateStore.memory({
    DateTime? devicesUpdatedSince,
    DateTime? deviceLogsCreatedSince,
    DateTime? birthdaysUpdatedSince,
  }) : _preferences = null,
       _memoryOnly = true,
       _devicesUpdatedSince = devicesUpdatedSince,
       _deviceLogsCreatedSince = deviceLogsCreatedSince,
       _birthdaysUpdatedSince = birthdaysUpdatedSince;

  static const devicesUpdatedSinceKey = 'devices_updated_since';
  static const deviceLogsCreatedSinceKey = 'device_logs_created_since';
  static const birthdaysUpdatedSinceKey = 'birthdays_updated_since';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  DateTime? _devicesUpdatedSince;
  DateTime? _deviceLogsCreatedSince;
  DateTime? _birthdaysUpdatedSince;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<DateTime?> readDevicesUpdatedSince() =>
      _read(devicesUpdatedSinceKey, () => _devicesUpdatedSince);

  Future<DateTime?> readDeviceLogsCreatedSince() =>
      _read(deviceLogsCreatedSinceKey, () => _deviceLogsCreatedSince);

  Future<DateTime?> readBirthdaysUpdatedSince() =>
      _read(birthdaysUpdatedSinceKey, () => _birthdaysUpdatedSince);

  Future<void> writeDevicesUpdatedSince(DateTime value) =>
      _write(devicesUpdatedSinceKey, value, (v) => _devicesUpdatedSince = v);

  Future<void> writeDeviceLogsCreatedSince(DateTime value) => _write(
    deviceLogsCreatedSinceKey,
    value,
    (v) => _deviceLogsCreatedSince = v,
  );

  Future<void> writeBirthdaysUpdatedSince(DateTime value) => _write(
    birthdaysUpdatedSinceKey,
    value,
    (v) => _birthdaysUpdatedSince = v,
  );

  Future<DateTime?> _read(String key, DateTime? Function() memory) async {
    if (_memoryOnly) return memory();
    final raw = await _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  Future<void> _write(
    String key,
    DateTime value,
    void Function(DateTime) setMemory,
  ) async {
    final utc = value.toUtc();
    if (_memoryOnly) {
      setMemory(utc);
      return;
    }
    await _prefs.setString(key, utc.toIso8601String());
  }
}
