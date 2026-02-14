import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/core/utils/app_logger.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/services/auth_service.dart';
import 'package:torko/core/services/user_profile_sync_service.dart';

/// Splash Controller
/// Manages splash screen logic and authentication routing.
/// Splash -> Login (if not auth) or Home (if auth). Chat is NEVER the initial route.
class SplashController extends GetxController {
  final AuthService _authService = AuthService();

  // Splash duration in milliseconds (1.5-2 seconds as per requirements)
  static const int _splashDurationMs = 1750; // 1.75 seconds - good balance

  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) AppLogger.nav('Splash loaded');
    _initializeSplash();
  }

  /// Initialize splash screen
  /// Waits for splash duration, checks auth, then navigates
  Future<void> _initializeSplash() async {
    await Future.delayed(const Duration(milliseconds: _splashDurationMs));
    await _checkAuthAndNavigate();
  }

  /// Check authentication and navigate. Authenticated -> Home only (never Chat).
  /// Navigate first (UI thread), then load user profile in background (deferred).
  Future<void> _checkAuthAndNavigate() async {
    if (_navigated) return;
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _navigated = true;
        if (kDebugMode) AppLogger.nav('Auth ready → navigating to Home');
        // Navigate immediately - show Home first, load user in background
        _navigateToHome();
        // Defer heavy work to next frame (after UI paints)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadUserProfileDeferred();
        });
      } else {
        _navigated = true;
        if (kDebugMode) AppLogger.nav('No uid → redirecting to Login');
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) AppLogger.err('Splash auth check failed', error: e);
      if (!_navigated) {
        _navigated = true;
        if (kDebugMode) AppLogger.nav('Error → redirecting to Login');
        _navigateToLogin();
      }
    }
  }

  /// Load user profile after navigation (non-blocking).
  void _loadUserProfileDeferred() {
    UserProfileSyncService.syncMe().then((_) {
      return AuthService.loadAndCacheCurrentUser();
    }).then((_) {
      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().refreshUserProfile();
      }
    }).catchError((_) {});
  }

  void _navigateToHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  void _navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }
}

