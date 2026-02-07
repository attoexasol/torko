import 'package:get/get.dart';
import 'package:torko/presentation/splash/controllers/splash_controller.dart';

/// Splash binding: creates controller once when splash route loads.
/// Avoids controller creation inside build().
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController(), permanent: false);
    }
  }
}
