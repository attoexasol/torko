import 'user_info.dart';

/// Authentication Service
/// Handles authentication state checks and token validation
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Check if user is logged in
  /// Returns true if a valid auth token exists and is not empty, false otherwise
  /// 
  /// This method checks the stored API token in UserInfo (which uses GetStorage internally)
  /// Returns false on any error to ensure safe navigation
  Future<bool> isLoggedIn() async {
    try {
      // UserInfo uses GetStorage which is already initialized in main()
      // isLoggedIn is a static getter that checks if apiToken exists and is not empty
      return UserInfo.isLoggedIn;
    } catch (e) {
      // Handle any errors gracefully - return false to navigate to login
      return false;
    }
  }

  /// Get the current auth token
  /// Returns the token string if available, null otherwise
  String? getToken() {
    try {
      return UserInfo.apiToken;
    } catch (e) {
      return null;
    }
  }

  /// Check if user has a valid token (not just exists, but also non-empty)
  bool hasValidToken() {
    try {
      final token = UserInfo.apiToken;
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
