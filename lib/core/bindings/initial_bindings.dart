import 'package:get/get.dart';
import '../controllers/app_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize all controllers here
    Get.put(AppController(), permanent: true);
    
    // Add other controllers as needed
    // Get.put(HomeController(), permanent: true);
    // Get.put(ProfileController(), permanent: true);
    // etc.
  }
}

