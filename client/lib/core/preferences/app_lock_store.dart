import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nasyad/core/app_lock/secure_secret_store.dart';
import 'package:nasyad/domain/entities/app_lock_config.dart';
import 'package:nasyad/domain/entities/lock_idle_timeout.dart';
import 'package:nasyad/domain/entities/lock_method.dart';

/// Local app-lock settings. Method + timeout in prefs; secrets in secure storage.
///
/// Clearing lock never touches Drift or other user data.
class AppLockStore {
  AppLockStore({
    SharedPreferencesAsync? preferences,
    SecureSecretStore? secretStore,
  }) : _preferences = preferences,
       _secretStore = secretStore ?? FlutterSecureSecretStore(),
       _memoryOnly = false;

  AppLockStore.memory({
    AppLockConfig initial = AppLockConfig.unset,
    String? secret,
    SecureSecretStore? secretStore,
  }) : _preferences = null,
       _secretStore = secretStore ?? MemorySecureSecretStore(),
       _memoryOnly = true,
       _memoryConfig = initial {
    if (secret != null) {
      _pendingSecret = secret;
    }
  }

  static const _methodKey = 'app_lock_method';
  static const _timeoutKey = 'app_lock_timeout';
  static const _secretKey = 'app_lock_secret_hash';
  static const _saltKey = 'app_lock_secret_salt';

  static const int pinMinLength = 4;
  static const int pinMaxLength = 8;
  static const int passwordMinLength = 4;

  final SharedPreferencesAsync? _preferences;
  final SecureSecretStore _secretStore;
  final bool _memoryOnly;
  AppLockConfig? _memoryConfig;
  String? _pendingSecret;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<AppLockConfig> readConfig() async {
    if (_memoryOnly) {
      return _memoryConfig ?? AppLockConfig.unset;
    }
    final method = LockMethod.fromStorage(await _prefs.getString(_methodKey));
    final timeout = LockIdleTimeout.fromStorage(
      await _prefs.getString(_timeoutKey),
    );
    return AppLockConfig(method: method, timeout: timeout);
  }

  Future<void> writeConfig(AppLockConfig config) async {
    if (_memoryOnly) {
      _memoryConfig = config;
      return;
    }
    if (config.method == null) {
      await _prefs.remove(_methodKey);
    } else {
      await _prefs.setString(_methodKey, config.method!.storageValue);
    }
    await _prefs.setString(_timeoutKey, config.timeout.storageValue);
  }

  Future<void> setSecret(String secret) async {
    final salt = _randomSalt();
    final hash = _hash(secret, salt);
    if (_memoryOnly && _secretStore is MemorySecureSecretStore) {
      await _secretStore.write(_saltKey, salt);
      await _secretStore.write(_secretKey, hash);
      _pendingSecret = null;
      return;
    }
    await _secretStore.write(_saltKey, salt);
    await _secretStore.write(_secretKey, hash);
  }

  Future<bool> verifySecret(String secret) async {
    if (_memoryOnly && _pendingSecret != null) {
      final salt = await _secretStore.read(_saltKey);
      if (salt == null) {
        return secret == _pendingSecret;
      }
    }
    final salt = await _secretStore.read(_saltKey);
    final stored = await _secretStore.read(_secretKey);
    if (salt == null || stored == null) return false;
    return _hash(secret, salt) == stored;
  }

  Future<bool> hasSecret() async {
    if (_memoryOnly && _pendingSecret != null) return true;
    final stored = await _secretStore.read(_secretKey);
    return stored != null && stored.isNotEmpty;
  }

  Future<void> clearSecret() async {
    _pendingSecret = null;
    await _secretStore.delete(_secretKey);
    await _secretStore.delete(_saltKey);
  }

  /// Clears lock settings and secrets only — does not touch Drift or other prefs.
  Future<void> clear() async {
    if (_memoryOnly) {
      _memoryConfig = AppLockConfig.unset;
      _pendingSecret = null;
    } else {
      await _prefs.remove(_methodKey);
      await _prefs.remove(_timeoutKey);
    }
    await clearSecret();
  }

  static bool isValidPin(String value) {
    if (value.length < pinMinLength || value.length > pinMaxLength) {
      return false;
    }
    return RegExp(r'^\d+$').hasMatch(value);
  }

  static bool isValidPassword(String value) {
    return value.length >= passwordMinLength;
  }

  static String _hash(String secret, String salt) {
    final bytes = utf8.encode('$salt:$secret');
    return sha256.convert(bytes).toString();
  }

  static String _randomSalt() {
    final millis = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return 's$millis';
  }
}
