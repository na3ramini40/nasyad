import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:nasyad/domain/entities/app_config_snapshot.dart';

/// Persists the last successful app-config fetch (features + freshness).
///
/// Not Drift / not user domain data — preference JSON only.
class AppConfigStore {
  AppConfigStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  AppConfigStore.memory({AppConfigSnapshot? initial})
    : _preferences = null,
      _memoryOnly = true,
      _memoryValue = initial;

  static const _key = 'app_config_json';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  AppConfigSnapshot? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<AppConfigSnapshot?> read() async {
    if (_memoryOnly) return _memoryValue;
    final raw = await _prefs.getString(_key);
    return decode(raw);
  }

  Future<void> write(AppConfigSnapshot snapshot) async {
    if (_memoryOnly) {
      _memoryValue = snapshot;
      return;
    }
    await _prefs.setString(_key, encode(snapshot));
  }

  static String encode(AppConfigSnapshot snapshot) {
    return jsonEncode({
      'features': snapshot.features,
      if (snapshot.updatedAt != null)
        'updated_at': snapshot.updatedAt!.toUtc().toIso8601String(),
      if (snapshot.fetchedAt != null)
        'fetched_at': snapshot.fetchedAt!.toUtc().toIso8601String(),
    });
  }

  static AppConfigSnapshot? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      return AppConfigSnapshot(
        features: _parseFeatures(map['features']),
        updatedAt: _parseDate(map['updated_at']),
        fetchedAt: _parseDate(map['fetched_at']),
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, bool> _parseFeatures(Object? raw) {
    if (raw is! Map) return const {};
    final out = <String, bool>{};
    for (final entry in raw.entries) {
      final key = entry.key;
      if (key is! String) continue;
      final value = entry.value;
      if (value is bool) {
        out[key] = value;
      }
    }
    return Map.unmodifiable(out);
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}
