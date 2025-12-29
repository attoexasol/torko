import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../../controllers/bottom_nav_controller.dart';
import '../../controllers/home_header_controller.dart';
import '../../controllers/navigation_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize all controllers here
    Get.put(AppController(), permanent: true);
    
    // Centralized navigation controller - single source of truth
    Get.put(NavigationController(), permanent: true);
    
    // Navigation controllers (legacy - kept for compatibility)
    Get.lazyPut(() => BottomNavController());
    Get.lazyPut(() => HomeHeaderController());
  }
}

