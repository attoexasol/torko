import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_info.dart';
import '../translations/app_translations.dart';

enum AppLanguage { bn, en }
enum AppThemeMode { light, dark }

class NotificationModel {
  final String id;
  final String title;
  final String? message;
  final String? type;
  final int? duration;

  NotificationModel({
    required this.id,
    required this.title,
    this.message,
    this.type,
    this.duration,
  });
}

// Using Map<String, dynamic> for flexible data passing like React
typedef ConversationData = Map<String, dynamic>;
typedef CallData = Map<String, dynamic>;

class AppController extends GetxController {
  // Language
  final Rx<AppLanguage> _language = AppLanguage.bn.obs;
  AppLanguage get language => _language.value;
  String get languageCode => _language.value == AppLanguage.bn ? 'bn' : 'en';

  // Theme
  final Rx<AppThemeMode> _theme = AppThemeMode.dark.obs;
  AppThemeMode get theme => _theme.value;
  bool get isDarkMode => _theme.value == AppThemeMode.dark;

  // Notification
  final Rx<NotificationModel?> _notification = Rx<NotificationModel?>(null);
  NotificationModel? get notification => _notification.value;

  // Conversation
  final Rx<ConversationData?> _conversationData = Rx<ConversationData?>(null);
  ConversationData? get conversationData => _conversationData.value;

  // Call
  final Rx<CallData?> _callData = Rx<CallData?>(null);
  CallData? get callData => _callData.value;

  // Bottom Nav
  final RxBool _hideBottomNav = false.obs;
  bool get hideBottomNav => _hideBottomNav.value;

  // Post Detail
  final Rx<dynamic> _postDetailData = Rx<dynamic>(null);
  dynamic get postDetailData => _postDetailData.value;

  // Message Notification Count
  final RxInt _messageNotificationCount = 5.obs;
  int get messageNotificationCount => _messageNotificationCount.value;

  // Profile Image (reactive)
  final RxString _profileImageUrl = ''.obs;
  String? get profileImageUrl => _profileImageUrl.value.isEmpty ? null : _profileImageUrl.value;
  void updateProfileImageUrl(String? url) {
    _profileImageUrl.value = url ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
    _loadTheme();
    _loadProfileImage();
  }

  void _loadProfileImage() {
    final imageUrl = UserInfo.profileImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      _profileImageUrl.value = imageUrl;
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('torko_language');
    if (saved == 'en') {
      _language.value = AppLanguage.en;
    } else {
      _language.value = AppLanguage.bn;
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('torko_theme');
    if (saved == 'light') {
      _theme.value = AppThemeMode.light;
    } else {
      _theme.value = AppThemeMode.dark;
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('torko_language', lang == AppLanguage.en ? 'en' : 'bn');
  }

  Future<void> setTheme(AppThemeMode newTheme) async {
    _theme.value = newTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('torko_theme', newTheme == AppThemeMode.light ? 'light' : 'dark');
    Get.changeThemeMode(newTheme == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final newTheme = _theme.value == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    setTheme(newTheme);
  }

  void toggleLanguage() {
    final newLanguage = _language.value == AppLanguage.bn ? AppLanguage.en : AppLanguage.bn;
    setLanguage(newLanguage);
  }

  String t(String key) {
    return AppTranslations.translate(key, languageCode);
  }

  void showNotification({
    required String title,
    String? message,
    String? type,
    int? duration,
  }) {
    _notification.value = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      duration: duration ?? 5000,
    );
  }

  void dismissNotification(String id) {
    if (_notification.value?.id == id) {
      _notification.value = null;
    }
  }

  void openConversation(Map<String, dynamic> data) {
    _conversationData.value = data;
  }

  void closeConversation() {
    _conversationData.value = null;
  }

  void startCall(Map<String, dynamic> data) {
    _callData.value = data;
  }

  void endCall() {
    _callData.value = null;
  }

  void setHideBottomNav(bool hide) {
    _hideBottomNav.value = hide;
  }

  void openPostDetail(dynamic postData) {
    _postDetailData.value = postData;
  }

  void closePostDetail() {
    _postDetailData.value = null;
  }

  void resetMessageNotifications() {
    _messageNotificationCount.value = 0;
  }
}

