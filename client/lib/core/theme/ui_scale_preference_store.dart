import 'package:shared_preferences/shared_preferences.dart';

import 'package:nasyad/core/theme/ui_scale.dart';

class UiScalePreferenceStore {
  UiScalePreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  UiScalePreferenceStore.memory({double? initial})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = initial == null ? null : UiScale.clamp(initial);

  static const _key = 'ui_scale';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  double? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<double> read() async {
    if (_memoryOnly) {
      return UiScale.clamp(_memoryValue ?? UiScale.defaultValue);
    }
    final value = await _prefs.getDouble(_key);
    return UiScale.clamp(value ?? UiScale.defaultValue);
  }

  Future<void> write(double scale) async {
    final clamped = UiScale.clamp(scale);
    if (_memoryOnly) {
      _memoryValue = clamped;
      return;
    }
    await _prefs.setDouble(_key, clamped);
  }
}
