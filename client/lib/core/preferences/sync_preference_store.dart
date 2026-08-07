import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user wants remote sync when online.
///
/// Default is **on** (`true`) when the key is unset so first launch is
/// sync-ready once a remote adapter exists. Local Drift remains the UI
/// source of truth either way.
class SyncPreferenceStore {
  SyncPreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  SyncPreferenceStore.memory({bool initial = defaultEnabled})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = initial;

  static const _key = 'sync_with_remote';

  /// Default when preference has never been written.
  static const bool defaultEnabled = true;

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  bool? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<bool> read() async {
    if (_memoryOnly) {
      return _memoryValue ?? defaultEnabled;
    }
    final value = await _prefs.getBool(_key);
    return value ?? defaultEnabled;
  }

  Future<void> write(bool enabled) async {
    if (_memoryOnly) {
      _memoryValue = enabled;
    } else {
      await _prefs.setBool(_key, enabled);
    }
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  void dispose() {
    _changes.close();
  }
}
