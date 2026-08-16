import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasyad/domain/entities/home_grouping.dart';

class HomeGroupingPreferenceStore {
  HomeGroupingPreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  HomeGroupingPreferenceStore.memory({HomeGrouping? initial})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = (initial ?? HomeGrouping.defaultValue).storageValue;

  static const _key = 'home_grouping';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  String? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<HomeGrouping> read() async {
    if (_memoryOnly) {
      return HomeGrouping.fromStorage(_memoryValue);
    }
    final value = await _prefs.getString(_key);
    return HomeGrouping.fromStorage(value);
  }

  Future<void> write(HomeGrouping value) async {
    if (_memoryOnly) {
      _memoryValue = value.storageValue;
    } else {
      await _prefs.setString(_key, value.storageValue);
    }
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  void dispose() {
    _changes.close();
  }
}
