import 'package:shared_preferences/shared_preferences.dart';

class SyncStateStore {
  SyncStateStore({SharedPreferences? preferences})
    : _preferencesFuture = preferences != null
          ? Future.value(preferences)
          : SharedPreferences.getInstance(),
      _memoryOnly = false;

  SyncStateStore.memory()
    : _preferencesFuture = Future.value(null),
      _memoryOnly = true;

  static const _lastPulledAtKey = 'sync.last_pulled_at';
  static const _lastSyncedAtKey = 'sync.last_synced_at';

  final Future<SharedPreferences?> _preferencesFuture;
  final bool _memoryOnly;
  DateTime? _memoryLastPulledAt;
  DateTime? _memoryLastSyncedAt;

  Future<DateTime?> lastPulledAt() async {
    if (_memoryOnly) return _memoryLastPulledAt;
    final prefs = await _preferencesFuture;
    final raw = prefs?.getString(_lastPulledAtKey);
    return raw == null ? null : DateTime.parse(raw);
  }

  Future<DateTime?> lastSyncedAt() async {
    if (_memoryOnly) return _memoryLastSyncedAt;
    final prefs = await _preferencesFuture;
    final raw = prefs?.getString(_lastSyncedAtKey);
    return raw == null ? null : DateTime.parse(raw);
  }

  Future<void> setLastPulledAt(DateTime value) async {
    if (_memoryOnly) {
      _memoryLastPulledAt = value;
      return;
    }
    final prefs = await _preferencesFuture;
    await prefs?.setString(_lastPulledAtKey, value.toUtc().toIso8601String());
  }

  Future<void> setLastSyncedAt(DateTime value) async {
    if (_memoryOnly) {
      _memoryLastSyncedAt = value;
      return;
    }
    final prefs = await _preferencesFuture;
    await prefs?.setString(_lastSyncedAtKey, value.toUtc().toIso8601String());
  }
}
