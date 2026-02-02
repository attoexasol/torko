import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/controllers/app_controller.dart';
import '../models/auth/create_user_response.dart';
import '../models/auth/verify_otp_response.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import 'user_info.dart';

/// Authentication Service
/// Handles authentication state checks, token validation, and auth API calls
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

  /// Create users / send OTP - POST create_users
  /// Throws [Exception] on API error or non-JSON/HTML response
  Future<CreateUserResponse> createUsers({required String phone}) async {
    final response = await NetworkCaller.postRequest(
      url: Urls.create_users,
      body: {'phone': phone},
    );

    if (!response.isSuccess || response.body == null) {
      throw Exception(response.errorMessage ?? 'Failed to send OTP');
    }

    final body = response.body!;
    final res = CreateUserResponse.fromJson(Map<String, dynamic>.from(body));
    if (!res.status) {
      throw Exception(res.message.isNotEmpty ? res.message : 'OTP request failed');
    }

    if (res.token.isEmpty) {
      throw Exception('No token received');
    }

    if (kDebugMode) {
      debugPrint('[AuthService] createUsers: exist=${res.exist} tokenLen=${res.token.length}');
    }
    return res;
  }

  /// Verify OTP - POST verify_otp
  /// Throws [Exception] on API error or non-JSON/HTML response
  Future<VerifyOtpResponse> verifyOtp({
    required String apiToken,
    required int otp,
  }) async {
    final response = await NetworkCaller.postRequest(
      url: Urls.verify_otp,
      body: {'api_token': apiToken, 'otp_code': otp},
    );

    if (!response.isSuccess || response.body == null) {
      throw Exception(response.errorMessage ?? 'OTP verification failed');
    }

    final body = response.body!;
    final res = VerifyOtpResponse.fromJson(Map<String, dynamic>.from(body));
    if (!res.status) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Invalid OTP');
    }

    if (res.apiToken.isEmpty) {
      throw Exception('No api_token received');
    }

    if (kDebugMode) {
      debugPrint('[AuthService] verifyOtp: success tokenLen=${res.apiToken.length}');
    }
    return res;
  }

  /// Load and cache current user profile from update_users API.
  /// POST update_users with api_token only returns current user.
  /// Supports response.data or response.data.user structure.
  static Future<void> loadAndCacheCurrentUser() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    final response = await NetworkCaller.postRequest(
      url: Urls.update_users,
      body: {'api_token': token},
    );

    if (!response.isSuccess || response.body == null || response.body!['status'] != true) {
      if (kDebugMode) {
        debugPrint('[AuthService] loadAndCacheCurrentUser failed status=${response.body?['status']}');
      }
      return;
    }

    dynamic rawData = response.body!['data'];
    Map<String, dynamic>? data;
    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is Map && rawData['user'] != null) {
      final user = rawData['user'];
      data = user is Map<String, dynamic> ? user : Map<String, dynamic>.from(user as Map);
    }

    if (data != null) {
      await UserInfo.saveUserProfile(data);
      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().refreshUserProfile();
      }
      if (kDebugMode) {
        final id = data['id'];
        final name = data['fullname']?.toString() ?? data['name']?.toString() ?? '';
        final img = data['profile_image']?.toString() ?? '';
        debugPrint('[AuthService] USER loaded id=$id name=${name.isNotEmpty ? "${name.length}ch" : "empty"} img=${img.isNotEmpty ? "ok" : "empty"}');
      }
    }
  }

  /// Single entry point for login success: save token, load user, mark verified
  /// Call after verify_otp success. Both returning and new users use this.
  /// Returns true if profile loaded, false if load failed (caller may show snackbar).
  /// If load fails, retries once after delay.
  Future<bool> onLoginSuccess(String token) async {
    await UserInfo.saveApiToken(token);
    await UserInfo.setVerified(true);
    try {
      await loadAndCacheCurrentUser();
      return true;
    } catch (_) {
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          await loadAndCacheCurrentUser();
        } catch (__) {}
      });
      return false;
    }
  }
}
