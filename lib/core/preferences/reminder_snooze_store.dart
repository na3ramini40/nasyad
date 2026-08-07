import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReminderSnoozeStore {
  ReminderSnoozeStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  ReminderSnoozeStore.memory() : _preferences = null, _memoryOnly = true;

  static const _key = 'reminder_snoozes';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  Map<String, String>? _memoryValue;
  SharedPreferencesAsync? _lazyPreferences;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<Map<String, DateTime>> readActive({DateTime? now}) async {
    final raw = await _readRaw();
    final current = _dateOnly(now ?? DateTime.now());
    final active = <String, DateTime>{};

    for (final entry in raw.entries) {
      final until = DateTime.tryParse(entry.value);
      if (until == null) continue;
      if (!until.isBefore(current)) {
        active[entry.key] = _dateOnly(until);
      }
    }

    if (active.length != raw.length) {
      await _writeRaw({
        for (final entry in active.entries)
          entry.key: entry.value.toIso8601String(),
      });
    }

    return active;
  }

  Future<void> snooze({
    required String reminderId,
    required int days,
    DateTime? now,
  }) async {
    final start = _dateOnly(now ?? DateTime.now());
    final until = start.add(Duration(days: days));
    final raw = await _readRaw();
    raw[reminderId] = until.toIso8601String();
    await _writeRaw(raw);
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  Future<Map<String, String>> _readRaw() async {
    if (_memoryOnly) {
      return Map<String, String>.from(_memoryValue ?? const {});
    }
    final encoded = await _prefs.getString(_key);
    if (encoded == null || encoded.isEmpty) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  Future<void> _writeRaw(Map<String, String> value) async {
    if (_memoryOnly) {
      _memoryValue = Map<String, String>.from(value);
      return;
    }
    await _prefs.setString(_key, jsonEncode(value));
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  void dispose() {
    _changes.close();
  }
}
