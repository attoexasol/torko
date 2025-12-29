import 'package:get/get.dart';
import '../core/controllers/app_controller.dart';
import '../core/routes/app_routes.dart';

class BottomNavController extends GetxController {
  final RxString activeScreen = 'home'.obs;
  
  AppController get appController => Get.find<AppController>();

  bool get isHome => activeScreen.value == 'home';
  bool get isMessages => activeScreen.value == 'messages';
  bool get isLocalCommunity => 
      activeScreen.value == 'localCommunity' || activeScreen.value == 'explore';
  bool get isProfile => activeScreen.value == 'profile';

  int get messageNotificationCount => appController.messageNotificationCount;

  void setActiveScreen(String screen) {
    activeScreen.value = screen;
  }

  void handleMessageClick() {
    appController.resetMessageNotifications();
    navigateTo('messages');
  }

  void navigateTo(String screen) {
    activeScreen.value = screen;
    switch (screen) {
      case 'home':
        Get.offAllNamed(AppRoutes.home);
        break;
      case 'localCommunity':
        Get.offAllNamed(AppRoutes.localCommunity);
        break;
      case 'createPost':
        Get.toNamed(AppRoutes.createPost);
        break;
      case 'messages':
        Get.offAllNamed(AppRoutes.messages);
        break;
      case 'profile':
        Get.offAllNamed(AppRoutes.profile);
        break;
    }
  }
}

