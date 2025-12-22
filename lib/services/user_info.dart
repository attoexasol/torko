import 'package:get_storage/get_storage.dart';

class UserInfo {
  static final _box = GetStorage();
  
  // Storage keys
  static const String _apiTokenKey = 'torko_api_token';
  static const String _otpCodeKey = 'torko_otp_code';
  static const String _phoneKey = 'torko_phone';
  static const String _isVerifiedKey = 'torko_is_verified';
  static const String _userIdKey = 'torko_user_id';
  static const String _fullnameKey = 'torko_fullname';
  static const String _usernameKey = 'torko_username';
  static const String _emailKey = 'torko_email';
  static const String _bioKey = 'torko_bio';
  static const String _dateOfBirthKey = 'torko_date_of_birth';
  static const String _genderKey = 'torko_gender';
  static const String _addressKey = 'torko_address';
  static const String _latKey = 'torko_lat';
  static const String _lngKey = 'torko_lng';
  static const String _profileImageKey = 'torko_profile_image';
  static const String _coverImageKey = 'torko_cover_image';

  /// Initialize GetStorage - call this in main()
  static Future<void> init() async {
    await GetStorage.init();
  }

  // ==================== API Token ====================
  
  static String? get apiToken => _box.read<String>(_apiTokenKey);
  static Future<void> setApiToken(String token) async => await _box.write(_apiTokenKey, token);
  static String? get token => apiToken;
  static Future<void> setToken(String token) => setApiToken(token);
  static String? getToken() => apiToken;
  static Future<void> saveToken(String token) => setApiToken(token);

  // ==================== OTP Code ====================
  
  static String? get otpCode => _box.read<String>(_otpCodeKey);
  static int? get otpCodeInt {
    final code = _box.read(_otpCodeKey);
    if (code == null) return null;
    if (code is int) return code;
    return int.tryParse(code.toString());
  }
  static Future<void> setOtpCode(dynamic otpCode) async => await _box.write(_otpCodeKey, otpCode.toString());
  static Future<void> setOtp(int otpCode) => setOtpCode(otpCode);
  static String? getOtp() => otpCode;
  static Future<void> saveOtp(dynamic otp) => setOtpCode(otp);

  // ==================== Phone ====================
  
  static String? get phone => _box.read<String>(_phoneKey);
  static Future<void> setPhone(String phone) async => await _box.write(_phoneKey, phone);

  // ==================== User ID ====================
  
  static int? get userId => _box.read<int>(_userIdKey);
  static Future<void> setUserId(int id) async => await _box.write(_userIdKey, id);

  // ==================== Fullname ====================
  
  static String? get fullname => _box.read<String>(_fullnameKey);
  static Future<void> setFullname(String name) async => await _box.write(_fullnameKey, name);

  // ==================== Username ====================
  
  static String? get username => _box.read<String>(_usernameKey);
  static Future<void> setUsername(String name) async => await _box.write(_usernameKey, name);

  // ==================== Email ====================
  
  static String? get email => _box.read<String>(_emailKey);
  static Future<void> setEmail(String email) async => await _box.write(_emailKey, email);

  // ==================== Bio ====================
  
  static String? get bio => _box.read<String>(_bioKey);
  static Future<void> setBio(String bio) async => await _box.write(_bioKey, bio);

  // ==================== Date of Birth ====================
  
  static String? get dateOfBirth => _box.read<String>(_dateOfBirthKey);
  static Future<void> setDateOfBirth(String dob) async => await _box.write(_dateOfBirthKey, dob);

  // ==================== Gender ====================
  
  static String? get gender => _box.read<String>(_genderKey);
  static Future<void> setGender(String gender) async => await _box.write(_genderKey, gender);

  // ==================== Address ====================
  
  static String? get address => _box.read<String>(_addressKey);
  static Future<void> setAddress(String address) async => await _box.write(_addressKey, address);

  // ==================== Lat/Lng ====================
  
  static double? get lat => _box.read<double>(_latKey);
  static Future<void> setLat(double lat) async => await _box.write(_latKey, lat);
  
  static double? get lng => _box.read<double>(_lngKey);
  static Future<void> setLng(double lng) async => await _box.write(_lngKey, lng);

  // ==================== Profile Image ====================
  
  static String? get profileImage => _box.read<String>(_profileImageKey);
  static Future<void> setProfileImage(String? url) async => await _box.write(_profileImageKey, url);

  // ==================== Cover Image ====================
  
  static String? get coverImage => _box.read<String>(_coverImageKey);
  static Future<void> setCoverImage(String? url) async => await _box.write(_coverImageKey, url);

  // ==================== Verification Status ====================
  
  static bool get isVerified => _box.read<bool>(_isVerifiedKey) ?? false;
  static Future<void> setVerified(bool verified) async => await _box.write(_isVerifiedKey, verified);

  // ==================== Utility Methods ====================
  
  static bool get isLoggedIn => apiToken != null && apiToken!.isNotEmpty;
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

  /// Save user profile data from update_users API response
  static Future<void> saveUserProfile(Map<String, dynamic> data) async {
    if (data['id'] != null) await setUserId(data['id']);
    if (data['fullname'] != null) await setFullname(data['fullname']);
    if (data['username'] != null) await setUsername(data['username']);
    if (data['email'] != null) await setEmail(data['email']);
    if (data['phone'] != null) await setPhone(data['phone']);
    if (data['bio'] != null) await setBio(data['bio']);
    if (data['date_of_birth'] != null) await setDateOfBirth(data['date_of_birth']);
    if (data['gender'] != null) await setGender(data['gender']);
    if (data['address'] != null) await setAddress(data['address']);
    if (data['lat'] != null) await setLat(double.tryParse(data['lat'].toString()) ?? 0.0);
    if (data['lng'] != null) await setLng(double.tryParse(data['lng'].toString()) ?? 0.0);
    if (data['profile_image'] != null) await setProfileImage(data['profile_image']);
    if (data['cover_image'] != null) await setCoverImage(data['cover_image']);
  }

  /// Clear all user data (logout)
  static Future<void> clear() async {
    await _box.erase();
  }
  
  /// Erase all data
  static Future<void> eraseAll() async {
    await _box.erase();
  }
}
