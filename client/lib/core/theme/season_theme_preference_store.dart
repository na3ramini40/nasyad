import 'package:shared_preferences/shared_preferences.dart';

import 'package:nasyad/domain/entities/season_theme.dart';

class SeasonThemePreferenceStore {
  SeasonThemePreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  SeasonThemePreferenceStore.memory({SeasonTheme? initial})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = initial?.storageValue;

  static const _key = 'season_theme';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  String? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<SeasonTheme> read() async {
    if (_memoryOnly) {
      return SeasonTheme.fromStorage(_memoryValue);
    }
    return SeasonTheme.fromStorage(await _prefs.getString(_key));
  }

  Future<void> write(SeasonTheme season) async {
    if (_memoryOnly) {
      _memoryValue = season.storageValue;
      return;
    }
    await _prefs.setString(_key, season.storageValue);
  }
}
