import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:torko/core/services/reverb_service.dart';
import 'package:torko/core/services/user_info.dart';

/// Listens to app lifecycle. On resume: reconnect Reverb if needed.
/// Firestore network is enabled once at startup; Firestore handles reconnects.
class AppLifecycleService extends GetxController
    with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    final userId = UserInfo.userId;
    final token = UserInfo.apiToken;
    if (userId == null || token == null || token.isEmpty) return;

    final rs = ReverbService();
    if (rs.isConnected && rs.currentUserId == userId) return;

    rs.init(userId: userId).catchError((_) {});
  }
}
