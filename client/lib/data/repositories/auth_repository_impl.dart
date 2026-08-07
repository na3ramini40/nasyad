import 'dart:async';
import 'dart:io';

import 'package:nasyad/data/datasources/auth_remote_datasource.dart';
import 'package:nasyad/data/local/auth_session_store.dart';
import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/entities/otp_request_result.dart';
import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthSessionStore sessionStore,
  }) : _remote = remote,
       _sessionStore = sessionStore;

  final AuthRemoteDataSource _remote;
  final AuthSessionStore _sessionStore;

  AuthSession _session = AuthSession.guest;
  final _controller = StreamController<AuthSession>.broadcast();
  StreamSubscription<AuthSession>? _storeSub;

  @override
  AuthSession get currentSession => _session;

  @override
  Stream<AuthSession> watchSession() async* {
    yield _session;
    yield* _controller.stream;
  }

  void _setSession(AuthSession session) {
    _session = session;
    if (!_controller.isClosed) {
      _controller.add(session);
    }
  }

  @override
  Future<void> restoreSession() async {
    _storeSub ??= _sessionStore.changes.listen(_setSession);
    final stored = await _sessionStore.readSession();
    _setSession(stored);
    if (!stored.isSignedIn) return;

    try {
      final fresh = await _remote.getProfile(stored.token!);
      await _sessionStore.writeSession(token: stored.token!, profile: fresh);
      _setSession(AuthSession(token: stored.token, profile: fresh));
    } catch (_) {
      // Keep cached profile for offline use.
    }
  }

  @override
  Future<bool> hasCompletedIntro() => _sessionStore.hasCompletedIntro();

  @override
  Future<void> completeIntro() => _sessionStore.setIntroCompleted();

  @override
  Future<OtpRequestResult> requestOtp(String phone) {
    return _remote.requestOtp(phone);
  }

  @override
  Future<OtpRequestResult> resendOtp(String phone) {
    return _remote.resendOtp(phone);
  }

  @override
  Future<UserProfile> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final result = await _remote.verifyOtp(phone: phone, code: code);
    await _sessionStore.writeSession(token: result.token, profile: result.user);
    await _sessionStore.setIntroCompleted();
    _setSession(AuthSession(token: result.token, profile: result.user));
    return result.user;
  }

  @override
  Future<UserProfile> getProfile() async {
    final token = _session.token;
    if (token == null || token.isEmpty) {
      throw StateError('Not signed in');
    }
    final profile = await _remote.getProfile(token);
    await _sessionStore.writeCachedProfile(profile);
    _setSession(_session.copyWith(profile: profile));
    return profile;
  }

  @override
  Future<UserProfile> updateProfile({String? name, File? imageFile}) async {
    final token = _session.token;
    if (token == null || token.isEmpty) {
      throw StateError('Not signed in');
    }
    final profile = await _remote.updateProfile(
      token: token,
      name: name,
      imageFile: imageFile,
    );
    await _sessionStore.writeCachedProfile(profile);
    _setSession(_session.copyWith(profile: profile));
    return profile;
  }

  @override
  Future<void> signOut() async {
    final token = _session.token;
    if (token != null && token.isNotEmpty) {
      try {
        await _remote.logout(token);
      } catch (_) {
        // Always clear local session even if remote logout fails.
      }
    }
    await _sessionStore.clearSession();
    _setSession(AuthSession.guest);
  }

  @override
  Future<void> upsertDeviceRegistration({
    required String deviceId,
    required String fcmToken,
  }) async {
    final token = _session.token;
    if (token == null || token.isEmpty) {
      throw StateError('Not signed in');
    }
    await _remote.upsertDeviceRegistration(
      token: token,
      deviceId: deviceId,
      fcmToken: fcmToken,
    );
  }

  Future<void> dispose() async {
    await _storeSub?.cancel();
    await _controller.close();
  }
}
