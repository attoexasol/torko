import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/main/controllers/bottom_nav_controller.dart';
import 'package:torko/presentation/home/controllers/home_header_controller.dart';
import 'package:torko/presentation/main/controllers/navigation_controller.dart';
import 'package:torko/core/services/app_lifecycle_service.dart';

/// ChatController and InboxController are created ONLY when Messages screen opens.
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(AppLifecycleService(), permanent: true);

    Get.lazyPut(() => BottomNavController());
    Get.lazyPut(() => HomeHeaderController());
  }
}

