import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.notification?.title}');
}

class FcmService {
  static final _messaging = FirebaseMessaging.instance;

  /// True only once a Firebase app has been initialised via
  /// Firebase.initializeApp(). Until then FCM calls would throw
  /// `[core/no-app]`, so we skip them silently.
  static bool get isAvailable => Firebase.apps.isNotEmpty;

  static Future<void> init() async {
    if (!isAvailable) return;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
    });
  }

  static Future<String?> getToken() async {
    if (!isAvailable) return null;
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }
}
