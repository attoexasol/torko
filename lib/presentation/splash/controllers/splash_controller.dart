import 'package:get/get.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/services/auth_service.dart';

/// Splash Controller
/// Manages splash screen logic and authentication routing
class SplashController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Splash duration in milliseconds (1.5-2 seconds as per requirements)
  static const int _splashDurationMs = 1750; // 1.75 seconds - good balance
  
  @override
  void onInit() {
    super.onInit();
    _initializeSplash();
  }

  /// Initialize splash screen
  /// Waits for splash duration, checks auth, then navigates
  Future<void> _initializeSplash() async {
    // Wait for splash screen branding UX (1.5-2 seconds)
    await Future.delayed(const Duration(milliseconds: _splashDurationMs));
    
    // Check authentication status
    await _checkAuthAndNavigate();
  }

  /// Check authentication and navigate to appropriate screen
  /// This method handles all navigation logic based on auth state
  Future<void> _checkAuthAndNavigate() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        await AuthService.loadAndCacheCurrentUser();
        if (Get.isRegistered<AppController>()) {
          Get.find<AppController>().refreshUserProfile();
        }
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      _navigateToLogin();
    }
  }

  /// Navigate to Home screen
  /// Uses offAllNamed to prevent back navigation to splash
  void _navigateToHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  /// Navigate to Login screen
  /// Uses offAllNamed to prevent back navigation to splash
  void _navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }
}

