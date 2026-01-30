import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../../controllers/bottom_nav_controller.dart';
import '../../controllers/home_header_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../services/app_lifecycle_service.dart';
import '../../services/pusher_service.dart';
import '../../services/user_info.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(InboxController(), permanent: true);
    Get.put(AppLifecycleService(), permanent: true);

    // Initialize Pusher only if both token and userId exist; call init once
    _initializePusherIfLoggedIn();

    Get.lazyPut(() => BottomNavController());
    Get.lazyPut(() => HomeHeaderController());
  }

  /// Initialize Pusher at app start only when token and userId exist.
  /// Calls init(userId) once; PusherService prevents double init for same user.
  void _initializePusherIfLoggedIn() {
    final token = UserInfo.apiToken;
    final userId = UserInfo.userId;

    if (token == null || token.isEmpty || userId == null) {
      if (kDebugMode) {
        debugPrint(
            '[InitialBindings] Pusher skip: token=${token != null && token.isNotEmpty}, userId=$userId');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[InitialBindings] Pusher init for userId=$userId');
    }
    final ps = PusherService();
    ps.init(userId: userId).then((_) {
      if (kDebugMode) {
        ps.debugPrintConnectionState();
      }
    }).catchError((error) {
      if (kDebugMode) {
        debugPrint('[InitialBindings] Pusher init failed: $error');
        ps.debugPrintConnectionState();
      }
    });
  }
}

