import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Stub for Firebase Messaging setup.
/// Call init() from main if push notifications are needed.
class FirebaseMessagingStub {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;
    final permission = await messaging.requestPermission();
    if (kDebugMode) {
      debugPrint('[FCM] Permission: $permission');
    }
    final token = await messaging.getToken();
    if (kDebugMode && token != null) {
      debugPrint('[FCM] Token: ${token.substring(0, 20)}...');
    }
  }
}
