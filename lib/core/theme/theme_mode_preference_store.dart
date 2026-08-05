import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModePreferenceStore {
  ThemeModePreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  ThemeModePreferenceStore.memory({ThemeMode? initial})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = initial?.name;

  static const _key = 'theme_mode';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  String? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<ThemeMode> read() async {
    if (_memoryOnly) {
      return _fromStorage(_memoryValue);
    }
    return _fromStorage(await _prefs.getString(_key));
  }

  Future<void> write(ThemeMode mode) async {
    if (_memoryOnly) {
      _memoryValue = mode.name;
      return;
    }
    await _prefs.setString(_key, mode.name);
  }

  static ThemeMode _fromStorage(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
