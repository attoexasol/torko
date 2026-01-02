import 'package:get/get.dart';
import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';

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
      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();
      
      // Navigate based on authentication status
      if (isLoggedIn) {
        // User is logged in → Navigate to Home
        _navigateToHome();
      } else {
        // User is not logged in → Navigate to Login
        _navigateToLogin();
      }
    } catch (e) {
      // On any error, navigate to login for safety
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

