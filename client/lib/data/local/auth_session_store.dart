import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:nasyad/data/models/user_profile_model.dart';
import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/entities/user_profile.dart';

/// Persists auth token, cached profile, and first-install intro flag.
class AuthSessionStore {
  AuthSessionStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  AuthSessionStore.memory({
    String? token,
    UserProfile? profile,
    bool introCompleted = false,
  }) : _preferences = null,
       _memoryOnly = true,
       _memoryToken = token,
       _memoryProfile = profile,
       _memoryIntroCompleted = introCompleted;

  static const _tokenKey = 'auth_token';
  static const _profileKey = 'auth_profile_json';
  static const _introKey = 'intro_completed';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  String? _memoryToken;
  UserProfile? _memoryProfile;
  bool _memoryIntroCompleted = false;
  SharedPreferencesAsync? _lazyPreferences;
  final _changes = StreamController<AuthSession>.broadcast();

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Stream<AuthSession> get changes => _changes.stream;

  Future<AuthSession> readSession() async {
    final token = await readToken();
    final profile = await readCachedProfile();
    return AuthSession(token: token, profile: profile);
  }

  Future<String?> readToken() async {
    if (_memoryOnly) return _memoryToken;
    return _prefs.getString(_tokenKey);
  }

  Future<UserProfile?> readCachedProfile() async {
    if (_memoryOnly) return _memoryProfile;
    final raw = await _prefs.getString(_profileKey);
    return UserProfileModel.tryDecode(raw)?.toEntity();
  }

  Future<void> writeSession({
    required String token,
    required UserProfile profile,
  }) async {
    if (_memoryOnly) {
      _memoryToken = token;
      _memoryProfile = profile;
    } else {
      await _prefs.setString(_tokenKey, token);
      await _prefs.setString(
        _profileKey,
        UserProfileModel.fromEntity(profile).encode(),
      );
    }
    _emit();
  }

  Future<void> writeCachedProfile(UserProfile profile) async {
    if (_memoryOnly) {
      _memoryProfile = profile;
    } else {
      await _prefs.setString(
        _profileKey,
        UserProfileModel.fromEntity(profile).encode(),
      );
    }
    _emit();
  }

  Future<void> clearSession() async {
    if (_memoryOnly) {
      _memoryToken = null;
      _memoryProfile = null;
    } else {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_profileKey);
    }
    _emit();
  }

  Future<bool> hasCompletedIntro() async {
    if (_memoryOnly) return _memoryIntroCompleted;
    return await _prefs.getBool(_introKey) ?? false;
  }

  Future<void> setIntroCompleted() async {
    if (_memoryOnly) {
      _memoryIntroCompleted = true;
      return;
    }
    await _prefs.setBool(_introKey, true);
  }

  void _emit() {
    if (_changes.isClosed) return;
    unawaited(_emitAsync());
  }

  Future<void> _emitAsync() async {
    final session = await readSession();
    if (!_changes.isClosed) {
      _changes.add(session);
    }
  }

  /// Debug helper for tests that want a raw profile JSON round-trip check.
  static String encodeProfile(UserProfile profile) =>
      UserProfileModel.fromEntity(profile).encode();

  static UserProfile? decodeProfile(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return UserProfileModel.fromJson(decoded).toEntity();
  }

  void dispose() {
    _changes.close();
  }
}
