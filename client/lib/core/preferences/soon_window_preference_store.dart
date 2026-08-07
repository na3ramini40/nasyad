import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasyad/domain/entities/soon_window_days.dart';

class SoonWindowPreferenceStore {
  SoonWindowPreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  SoonWindowPreferenceStore.memory({SoonWindowDays? initial})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = (initial ?? SoonWindowDays.defaultValue).storageValue;

  static const _key = 'soon_window_days';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  int? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<SoonWindowDays> read() async {
    if (_memoryOnly) {
      return SoonWindowDays.fromStorage(_memoryValue);
    }
    final value = await _prefs.getInt(_key);
    return SoonWindowDays.fromStorage(value);
  }

  Future<void> write(SoonWindowDays value) async {
    if (_memoryOnly) {
      _memoryValue = value.storageValue;
    } else {
      await _prefs.setInt(_key, value.storageValue);
    }
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  void dispose() {
    _changes.close();
  }
}
