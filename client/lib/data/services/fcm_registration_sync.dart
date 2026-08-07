import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nasyad/data/local/device_registration_store.dart';
import 'package:nasyad/data/services/push_notification_service.dart';
import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/repositories/auth_repository.dart';

/// Silently upserts this install's FCM token to the server when signed in.
///
/// Failures never throw into callers; retry on the next token event or sign-in.
class FcmRegistrationSync {
  FcmRegistrationSync({
    required AuthRepository authRepository,
    required DeviceRegistrationStore store,
    Future<String?> Function()? getToken,
    Stream<String>? tokenRefresh,
    bool? supported,
  }) : _authRepository = authRepository,
       _store = store,
       _getToken =
           getToken ?? (() => PushNotificationService.instance.getToken()),
       _tokenRefresh =
           tokenRefresh ?? PushNotificationService.instance.onTokenRefresh,
       _supported = supported ?? PushNotificationService.isSupported;

  final AuthRepository _authRepository;
  final DeviceRegistrationStore _store;
  final Future<String?> Function() _getToken;
  final Stream<String> _tokenRefresh;
  final bool _supported;

  StreamSubscription<String>? _refreshSub;
  StreamSubscription<AuthSession>? _sessionSub;
  var _started = false;
  var _wasSignedIn = false;

  /// Listen for token refresh + sign-in; sync when either fires while signed in.
  Future<void> start() async {
    if (!_supported || _started) return;
    _started = true;
    _refreshSub = _tokenRefresh.listen((token) {
      unawaited(syncWithToken(token));
    });
    // Covers restoreSession (already signed in) and every later sign-in path.
    _wasSignedIn = false;
    _sessionSub = _authRepository.watchSession().listen((session) {
      final signedIn = session.isSignedIn;
      if (signedIn && !_wasSignedIn) {
        unawaited(syncNow());
      }
      _wasSignedIn = signedIn;
    });
  }

  /// Obtain the current FCM token (if any) and upsert when signed in.
  Future<void> syncNow() async {
    if (!_supported) return;
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;
      await syncWithToken(token);
    } catch (error, stack) {
      debugPrint('FCM registration syncNow failed: $error\n$stack');
    }
  }

  /// Upsert [fcmToken] when the user is signed in; no-op for guests.
  Future<void> syncWithToken(String fcmToken) async {
    if (!_supported) return;
    if (fcmToken.isEmpty) return;

    final authToken = _authRepository.currentSession.token;
    if (authToken == null || authToken.isEmpty) return;

    try {
      final lastSynced = await _store.readLastSyncedFcmToken();
      if (lastSynced == fcmToken) return;

      final deviceId = await _store.getOrCreateDeviceId();
      await _authRepository.upsertDeviceRegistration(
        deviceId: deviceId,
        fcmToken: fcmToken,
      );
      await _store.writeLastSyncedFcmToken(fcmToken);
    } catch (error, stack) {
      debugPrint('FCM registration upsert failed: $error\n$stack');
    }
  }

  Future<void> dispose() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    await _sessionSub?.cancel();
    _sessionSub = null;
    _started = false;
    _wasSignedIn = false;
  }
}
