import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService._();

  static final instance = PushNotificationService._();

  static const androidChannelId = 'nasyad_default';
  static const androidChannelName = 'Nasyad';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static var _localNotificationsReady = false;

  static FlutterLocalNotificationsPlugin get localNotificationsPlugin =>
      _localNotifications;

  /// Invoked when the user taps a local notification (push or due reminder).
  static void Function(String? payload)? onNotificationPayloadTapped;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  Future<void> initialize() async {
    if (!isSupported) return;

    await _ensureLocalNotificationsReady();
    await _requestPermission();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(showMessageNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpened(initialMessage);
    }
  }

  static Future<void> ensureLocalNotificationsReady() =>
      _ensureLocalNotificationsReady();

  static Future<void> _ensureLocalNotificationsReady() async {
    if (_localNotificationsReady) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Nasyad',
      appUserModelId: 'amini.apps.nasyad',
      guid: 'e68fe3c2-f773-427f-b7e8-e25699de5a02',
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          androidChannelId,
          androidChannelName,
          importance: Importance.high,
        ),
      );
      await androidPlugin?.requestNotificationsPermission();
    }

    _localNotificationsReady = true;
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  /// Current FCM registration token, or null when unsupported / unavailable.
  Future<String?> getToken() async {
    if (!isSupported) return null;
    try {
      return await _messaging.getToken();
    } catch (error, stack) {
      debugPrint('FCM getToken failed: $error\n$stack');
      return null;
    }
  }

  /// Emits a new token whenever FCM refreshes it. Empty when unsupported.
  Stream<String> get onTokenRefresh {
    if (!isSupported) return const Stream<String>.empty();
    return _messaging.onTokenRefresh;
  }

  static Future<void> showMessageNotification(RemoteMessage message) async {
    if (!isSupported) return;

    final notification = message.notification;
    if (notification == null) return;

    await _ensureLocalNotificationsReady();

    final androidDetails = notification.android;
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannelId,
          androidChannelName,
          channelDescription: 'Push notifications from Nasyad',
          importance: Importance.high,
          priority: Priority.high,
          icon: androidDetails?.smallIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        linux: const LinuxNotificationDetails(),
        windows: const WindowsNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    debugPrint('Notification opened: ${message.messageId}');
  }

  static void _onLocalNotificationTapped(NotificationResponse response) {
    onNotificationPayloadTapped?.call(response.payload);
  }
}
