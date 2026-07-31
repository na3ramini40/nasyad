import 'package:shared_preferences/shared_preferences.dart';

class LastSeenVersionStore {
  LastSeenVersionStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  LastSeenVersionStore.memory() : _preferences = null, _memoryOnly = true;

  static const _key = 'last_seen_app_version';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  String? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<String?> read() async {
    if (_memoryOnly) return _memoryValue;
    return _prefs.getString(_key);
  }

  Future<void> write(String version) async {
    if (_memoryOnly) {
      _memoryValue = version;
      return;
    }
    await _prefs.setString(_key, version);
  }
}
