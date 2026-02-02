import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../../controllers/bottom_nav_controller.dart';
import '../../controllers/home_header_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../services/app_lifecycle_service.dart';
import '../../services/reverb_service.dart';
import '../../services/user_info.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(InboxController(), permanent: true);
    Get.put(AppLifecycleService(), permanent: true);

    // Initialize Reverb only if both token and userId exist; call init once
    _initializeReverbIfLoggedIn();

    Get.lazyPut(() => BottomNavController());
    Get.lazyPut(() => HomeHeaderController());
  }

  /// Initialize Reverb at app start only when token and userId exist.
  /// Calls init(userId) once; ReverbService prevents double init for same user.
  void _initializeReverbIfLoggedIn() {
    final token = UserInfo.apiToken;
    final userId = UserInfo.userId;

    if (token == null || token.isEmpty || userId == null) {
      if (kDebugMode) {
        debugPrint(
            '[InitialBindings] Reverb skip: token=${token != null && token.isNotEmpty}, userId=$userId');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[InitialBindings] Reverb init for userId=$userId');
    }
    final rs = ReverbService();
    rs.init(userId: userId).then((_) {
      if (kDebugMode) {
        rs.debugPrintConnectionState();
      }
    }).catchError((error) {
      if (kDebugMode) {
        debugPrint('[InitialBindings] Reverb init failed: $error');
        rs.debugPrintConnectionState();
      }
    });
  }
}

