import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'reverb_service.dart';
import 'user_info.dart';

/// Listens to app lifecycle and re-initializes Reverb on resume when the OS
/// may have dropped the socket. No disconnect on pause; only reconnect on resume.
class AppLifecycleService extends GetxController
    with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (kDebugMode) {
      debugPrint('[AppLifecycleService] observer registered');
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    if (kDebugMode) {
      debugPrint('[AppLifecycleService] observer removed');
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    final userId = UserInfo.userId;
    final token = UserInfo.apiToken;
    if (userId == null || token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint('[AppLifecycleService] resume: skip (no userId or token)');
      }
      return;
    }

    final rs = ReverbService();
    if (rs.isConnected && rs.currentUserId == userId) {
      if (kDebugMode) {
        debugPrint('[AppLifecycleService] resume: already connected, skip re-subscribe');
      }
      rs.debugPrintConnectionState();
      return;
    }

    if (kDebugMode) {
      debugPrint('[AppLifecycleService] resume: reconnecting Reverb for userId=$userId');
    }
    rs.debugPrintConnectionState();
    rs.init(userId: userId).catchError((e) {
      if (kDebugMode) debugPrint('[AppLifecycleService] resume reconnect failed: $e');
    });
  }
}
