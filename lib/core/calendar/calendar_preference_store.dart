import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';

class CalendarPreferenceStore {
  CalendarPreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  CalendarPreferenceStore.memory({CalendarSystem? initial})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = initial?.storageValue;

  static const _key = 'calendar_system';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  String? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<CalendarSystem> read() async {
    if (_memoryOnly) {
      return CalendarSystem.fromStorage(_memoryValue);
    }
    return CalendarSystem.fromStorage(await _prefs.getString(_key));
  }

  Future<void> write(CalendarSystem system) async {
    if (_memoryOnly) {
      _memoryValue = system.storageValue;
      return;
    }
    await _prefs.setString(_key, system.storageValue);
  }
}
