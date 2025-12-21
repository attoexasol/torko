import 'package:get_storage/get_storage.dart';

class UserInfo {
  static final _box = GetStorage();
  
  // Storage keys
  static const String _apiTokenKey = 'torko_api_token';
  static const String _otpCodeKey = 'torko_otp_code';
  static const String _phoneKey = 'torko_phone';
  static const String _isVerifiedKey = 'torko_is_verified';

  /// Initialize GetStorage - call this in main()
  static Future<void> init() async {
    await GetStorage.init();
  }

  // ==================== API Token ====================
  
  /// Get API token
  static String? get apiToken => _box.read<String>(_apiTokenKey);
  
  /// Set API token
  static Future<void> setApiToken(String token) async {
    await _box.write(_apiTokenKey, token);
  }
  
  /// Alias for compatibility
  static String? get token => apiToken;
  static Future<void> setToken(String token) => setApiToken(token);
  
  /// Methods requested by user
  static String? getToken() => apiToken;
  static Future<void> saveToken(String token) => setApiToken(token);

  // ==================== OTP Code ====================
  
  /// Get OTP code as String
  static String? get otpCode => _box.read<String>(_otpCodeKey);
  
  /// Get OTP code as int
  static int? get otpCodeInt {
    final code = _box.read(_otpCodeKey);
    if (code == null) return null;
    if (code is int) return code;
    return int.tryParse(code.toString());
  }
  
  /// Set OTP code (accepts int or String)
  static Future<void> setOtpCode(dynamic otpCode) async {
    await _box.write(_otpCodeKey, otpCode.toString());
  }
  
  /// Alias for compatibility
  static Future<void> setOtp(int otpCode) => setOtpCode(otpCode);
  
  /// Methods requested by user
  static String? getOtp() => otpCode;
  static Future<void> saveOtp(dynamic otp) => setOtpCode(otp);

  // ==================== Phone ====================
  
  /// Get phone number
  static String? get phone => _box.read<String>(_phoneKey);
  
  /// Set phone number
  static Future<void> setPhone(String phone) async {
    await _box.write(_phoneKey, phone);
  }

  // ==================== Verification Status ====================
  
  /// Get verification status
  static bool get isVerified => _box.read<bool>(_isVerifiedKey) ?? false;
  
  /// Set verification status
  static Future<void> setVerified(bool verified) async {
    await _box.write(_isVerifiedKey, verified);
  }

  // ==================== Utility Methods ====================
  
  /// Check if user is logged in (has token)
  static bool get isLoggedIn => apiToken != null && apiToken!.isNotEmpty;
  
  /// Check if user is fully verified
  static bool get isFullyVerified => isLoggedIn && isVerified;

  /// Save login response data (from create_users API)
  static Future<void> saveLoginResponse({
    required String phone,
    required String token,
    required dynamic otpCode,
  }) async {
    await setPhone(phone);
    await setApiToken(token);
    await setOtpCode(otpCode);
  }

  /// Save verification response (from verify_otp API)
  static Future<void> saveVerifyResponse({String? newToken}) async {
    if (newToken != null) {
      await setApiToken(newToken);
    }
    await setVerified(true);
  }

  /// Clear all user data (logout)
  static Future<void> clear() async {
    await _box.remove(_apiTokenKey);
    await _box.remove(_otpCodeKey);
    await _box.remove(_phoneKey);
    await _box.remove(_isVerifiedKey);
  }
  
  /// Erase all data
  static Future<void> eraseAll() async {
    await _box.erase();
  }
}
