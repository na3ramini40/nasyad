import 'dart:async';
import 'dart:io';

import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/entities/otp_request_result.dart';
import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AuthSession initial = AuthSession.guest,
    bool introCompleted = false,
  }) : _session = initial,
       _introCompleted = introCompleted;

  AuthSession _session;
  bool _introCompleted;
  final _controller = StreamController<AuthSession>.broadcast();

  var requestOtpCalls = 0;
  var resendOtpCalls = 0;
  var verifyOtpCalls = 0;
  var signOutCalls = 0;
  var upsertRegistrationCalls = 0;
  String? lastPhone;
  String? lastCode;
  String? lastUpsertDeviceId;
  String? lastUpsertFcmToken;
  Object? requestError;
  Object? resendError;
  Object? verifyError;
  Object? upsertError;
  OtpRequestResult nextOtpResult = const OtpRequestResult(
    phone: '+989121111111',
    cooldownSeconds: 120,
    expiresInSeconds: 600,
  );
  UserProfile? nextProfile;

  void emitSession(AuthSession session) {
    _session = session;
    _controller.add(session);
  }

  @override
  AuthSession get currentSession => _session;

  @override
  Stream<AuthSession> watchSession() async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  Future<void> restoreSession() async {}

  @override
  Future<bool> hasCompletedIntro() async => _introCompleted;

  @override
  Future<void> completeIntro() async {
    _introCompleted = true;
  }

  @override
  Future<OtpRequestResult> requestOtp(String phone) async {
    requestOtpCalls += 1;
    lastPhone = phone;
    final error = requestError;
    if (error != null) throw error;
    return nextOtpResult;
  }

  @override
  Future<OtpRequestResult> resendOtp(String phone) async {
    resendOtpCalls += 1;
    lastPhone = phone;
    final error = resendError;
    if (error != null) throw error;
    return nextOtpResult;
  }

  @override
  Future<UserProfile> verifyOtp({
    required String phone,
    required String code,
  }) async {
    verifyOtpCalls += 1;
    lastPhone = phone;
    lastCode = code;
    final error = verifyError;
    if (error != null) throw error;
    final profile =
        nextProfile ??
        UserProfile(
          id: 'hash-1',
          phone: phone,
          name: null,
          imageUrl: null,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );
    _session = AuthSession(token: 'token-1', profile: profile);
    _introCompleted = true;
    _controller.add(_session);
    return profile;
  }

  @override
  Future<UserProfile> getProfile() async {
    final profile = _session.profile ?? nextProfile;
    if (profile == null) throw StateError('Not signed in');
    return profile;
  }

  @override
  Future<UserProfile> updateProfile({String? name, File? imageFile}) async {
    final current = _session.profile;
    if (current == null) throw StateError('Not signed in');
    final updated = current.copyWith(name: name ?? current.name);
    _session = _session.copyWith(profile: updated);
    _controller.add(_session);
    return updated;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    _session = AuthSession.guest;
    _controller.add(_session);
  }

  @override
  Future<void> upsertDeviceRegistration({
    required String deviceId,
    required String fcmToken,
  }) async {
    final error = upsertError;
    if (error != null) throw error;
    lastUpsertDeviceId = deviceId;
    lastUpsertFcmToken = fcmToken;
    upsertRegistrationCalls += 1;
  }

  void dispose() {
    _controller.close();
  }
}
