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
  
  // Privacy settings keys
  static const String _isPostPublicShowKey = 'torko_is_post_public_show';
  static const String _isActiveStatusShowKey = 'torko_is_active_status_show';
  static const String _isLikeAndCommentShowKey = 'torko_is_like_and_comment_show';
  static const String _isAnyoneSendMessageKey = 'torko_is_anyone_send_message';
  static const String _isReadStatusShowKey = 'torko_is_read_status_show';
  static const String _isTypingIndicatorShowKey = 'torko_is_typing_indicator_show';
  static const String _isAnyoneTagKey = 'torko_is_anyone_tag';

  // Notification settings keys
  static const String _silentStartTimeKey = 'torko_silent_start_time';
  static const String _silentEndTimeKey = 'torko_silent_end_time';
  static const String _isDoNotDisturbKey = 'torko_is_do_not_disturb';
  static const String _isPushNotifyKey = 'torko_is_push_notify';
  static const String _isLikeNotifyKey = 'torko_is_like_notify';
  static const String _isCommentNotifyKey = 'torko_is_comment_notify';
  static const String _isMentionNotifyKey = 'torko_is_mention_notify';
  static const String _isNewFollowerNotifyKey = 'torko_is_new_follower_notify';
  static const String _isMessageNotifyKey = 'torko_is_message_notify';
  static const String _isCommunityUpdateNotifyKey = 'torko_is_community_update_notify';
  static const String _isEmailNotifyKey = 'torko_is_email_notify';

  /// Initialize GetStorage - call this in main()
  static Future<void> init() async {
    await GetStorage.init();
  }

  // ==================== API Token ====================
  
  static String? get apiToken => _box.read<String>(_apiTokenKey);
  static Future<void> setApiToken(String token) async => await _box.write(_apiTokenKey, token);
  static Future<void> saveApiToken(String token) => setApiToken(token);
  static String? getApiToken() => apiToken;
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

  // ==================== Privacy Settings ====================
  
  static bool get isPostPublicShow => _box.read<bool>(_isPostPublicShowKey) ?? true;
  static Future<void> setIsPostPublicShow(bool value) async => await _box.write(_isPostPublicShowKey, value);
  
  static bool get isActiveStatusShow => _box.read<bool>(_isActiveStatusShowKey) ?? true;
  static Future<void> setIsActiveStatusShow(bool value) async => await _box.write(_isActiveStatusShowKey, value);
  
  static bool get isLikeAndCommentShow => _box.read<bool>(_isLikeAndCommentShowKey) ?? true;
  static Future<void> setIsLikeAndCommentShow(bool value) async => await _box.write(_isLikeAndCommentShowKey, value);
  
  static bool get isAnyoneSendMessage => _box.read<bool>(_isAnyoneSendMessageKey) ?? true;
  static Future<void> setIsAnyoneSendMessage(bool value) async => await _box.write(_isAnyoneSendMessageKey, value);
  
  static bool get isReadStatusShow => _box.read<bool>(_isReadStatusShowKey) ?? true;
  static Future<void> setIsReadStatusShow(bool value) async => await _box.write(_isReadStatusShowKey, value);
  
  static bool get isTypingIndicatorShow => _box.read<bool>(_isTypingIndicatorShowKey) ?? true;
  static Future<void> setIsTypingIndicatorShow(bool value) async => await _box.write(_isTypingIndicatorShowKey, value);
  
  static bool get isAnyoneTag => _box.read<bool>(_isAnyoneTagKey) ?? true;
  static Future<void> setIsAnyoneTag(bool value) async => await _box.write(_isAnyoneTagKey, value);

  /// Save privacy settings from API response
  static Future<void> savePrivacySettings(Map<String, dynamic> data) async {
    if (data['is_post_public_show'] != null) {
      await setIsPostPublicShow(data['is_post_public_show'] == 1);
    }
    if (data['is_active_status_show'] != null) {
      await setIsActiveStatusShow(data['is_active_status_show'] == 1);
    }
    if (data['is_like_and_comment_show'] != null) {
      await setIsLikeAndCommentShow(data['is_like_and_comment_show'] == 1);
    }
    if (data['is_anyone_send_message'] != null) {
      await setIsAnyoneSendMessage(data['is_anyone_send_message'] == 1);
    }
    if (data['is_read_status_show'] != null) {
      await setIsReadStatusShow(data['is_read_status_show'] == 1);
    }
    if (data['is_typing_indicator_show'] != null) {
      await setIsTypingIndicatorShow(data['is_typing_indicator_show'] == 1);
    }
    if (data['is_anyone_tag'] != null) {
      await setIsAnyoneTag(data['is_anyone_tag'] == 1);
    }
  }

  // ==================== Notification Settings ====================
  
  static String? get silentStartTime => _box.read<String>(_silentStartTimeKey);
  static Future<void> setSilentStartTime(String? time) async => await _box.write(_silentStartTimeKey, time);
  
  static String? get silentEndTime => _box.read<String>(_silentEndTimeKey);
  static Future<void> setSilentEndTime(String? time) async => await _box.write(_silentEndTimeKey, time);
  
  static bool get isDoNotDisturb => _box.read<bool>(_isDoNotDisturbKey) ?? false;
  static Future<void> setIsDoNotDisturb(bool value) async => await _box.write(_isDoNotDisturbKey, value);
  
  static bool get isPushNotify => _box.read<bool>(_isPushNotifyKey) ?? true;
  static Future<void> setIsPushNotify(bool value) async => await _box.write(_isPushNotifyKey, value);
  
  static bool get isLikeNotify => _box.read<bool>(_isLikeNotifyKey) ?? true;
  static Future<void> setIsLikeNotify(bool value) async => await _box.write(_isLikeNotifyKey, value);
  
  static bool get isCommentNotify => _box.read<bool>(_isCommentNotifyKey) ?? true;
  static Future<void> setIsCommentNotify(bool value) async => await _box.write(_isCommentNotifyKey, value);
  
  static bool get isMentionNotify => _box.read<bool>(_isMentionNotifyKey) ?? true;
  static Future<void> setIsMentionNotify(bool value) async => await _box.write(_isMentionNotifyKey, value);
  
  static bool get isNewFollowerNotify => _box.read<bool>(_isNewFollowerNotifyKey) ?? true;
  static Future<void> setIsNewFollowerNotify(bool value) async => await _box.write(_isNewFollowerNotifyKey, value);
  
  static bool get isMessageNotify => _box.read<bool>(_isMessageNotifyKey) ?? true;
  static Future<void> setIsMessageNotify(bool value) async => await _box.write(_isMessageNotifyKey, value);
  
  static bool get isCommunityUpdateNotify => _box.read<bool>(_isCommunityUpdateNotifyKey) ?? true;
  static Future<void> setIsCommunityUpdateNotify(bool value) async => await _box.write(_isCommunityUpdateNotifyKey, value);
  
  static bool get isEmailNotify => _box.read<bool>(_isEmailNotifyKey) ?? false;
  static Future<void> setIsEmailNotify(bool value) async => await _box.write(_isEmailNotifyKey, value);

  /// Save notification settings from API response
  static Future<void> saveNotificationSettings(Map<String, dynamic> data) async {
    if (data['silent_stat_time'] != null) {
      await setSilentStartTime(data['silent_stat_time']);
    }
    if (data['silent_end_time'] != null) {
      await setSilentEndTime(data['silent_end_time']);
    }
    if (data['is_do_not_disturd'] != null) {
      await setIsDoNotDisturb(data['is_do_not_disturd'] == 1);
    }
    if (data['is_push_notify'] != null) {
      await setIsPushNotify(data['is_push_notify'] == 1);
    }
    if (data['is_like_notify'] != null) {
      await setIsLikeNotify(data['is_like_notify'] == 1);
    }
    if (data['is_comment_notify'] != null) {
      await setIsCommentNotify(data['is_comment_notify'] == 1);
    }
    if (data['is_mention_notify'] != null) {
      await setIsMentionNotify(data['is_mention_notify'] == 1);
    }
    if (data['is_new_folower_notify'] != null) {
      await setIsNewFollowerNotify(data['is_new_folower_notify'] == 1);
    }
    if (data['is_message_notify'] != null) {
      await setIsMessageNotify(data['is_message_notify'] == 1);
    }
    if (data['is_community_update_notify'] != null) {
      await setIsCommunityUpdateNotify(data['is_community_update_notify'] == 1);
    }
    if (data['is_email_notify'] != null) {
      await setIsEmailNotify(data['is_email_notify'] == 1);
    }
  }

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
    if (data['id'] != null) {
      final id = data['id'];
      if (id is int) {
        await setUserId(id);
      } else if (id is String) {
        await setUserId(int.tryParse(id) ?? 0);
      }
    }
    final name = data['fullname'] ?? data['name'];
    if (name != null) await setFullname(name.toString());
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
