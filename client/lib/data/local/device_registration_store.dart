import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists this install's stable [device_id] and last successfully synced
/// FCM token for silent registration upserts.
class DeviceRegistrationStore {
  DeviceRegistrationStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  DeviceRegistrationStore.memory({String? deviceId, String? lastSyncedFcmToken})
    : _preferences = null,
      _memoryOnly = true,
      _memoryDeviceId = deviceId,
      _memoryLastSyncedFcmToken = lastSyncedFcmToken;

  static const _deviceIdKey = 'device_registration_device_id';
  static const _fcmTokenKey = 'device_registration_fcm_token';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  String? _memoryDeviceId;
  String? _memoryLastSyncedFcmToken;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  /// Returns the install id, generating and persisting one on first call.
  Future<String> getOrCreateDeviceId() async {
    final existing = await readDeviceId();
    if (existing != null && existing.isNotEmpty) return existing;
    final created = _generateDeviceId();
    await _writeDeviceId(created);
    return created;
  }

  Future<String?> readDeviceId() async {
    if (_memoryOnly) return _memoryDeviceId;
    return _prefs.getString(_deviceIdKey);
  }

  Future<String?> readLastSyncedFcmToken() async {
    if (_memoryOnly) return _memoryLastSyncedFcmToken;
    return _prefs.getString(_fcmTokenKey);
  }

  Future<void> writeLastSyncedFcmToken(String token) async {
    if (_memoryOnly) {
      _memoryLastSyncedFcmToken = token;
      return;
    }
    await _prefs.setString(_fcmTokenKey, token);
  }

  Future<void> _writeDeviceId(String deviceId) async {
    if (_memoryOnly) {
      _memoryDeviceId = deviceId;
      return;
    }
    await _prefs.setString(_deviceIdKey, deviceId);
  }

  /// Opaque hex id (32 chars) — stable for the life of the install.
  static String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
