import 'dart:io';

import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/entities/otp_request_result.dart';
import 'package:nasyad/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Stream<AuthSession> watchSession();

  AuthSession get currentSession;

  Future<void> restoreSession();

  Future<bool> hasCompletedIntro();

  Future<void> completeIntro();

  Future<OtpRequestResult> requestOtp(String phone);

  Future<OtpRequestResult> resendOtp(String phone);

  Future<UserProfile> verifyOtp({required String phone, required String code});

  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({String? name, File? imageFile});

  Future<void> signOut();

  /// Upserts FCM registration for this install. Requires a signed-in session.
  Future<void> upsertDeviceRegistration({
    required String deviceId,
    required String fcmToken,
  });
}
