import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/user_info.dart';

class NotificationSettingsController extends GetxController {
  final appController = Get.find<AppController>();

  // ==================== Observable States ====================
  final RxBool isLoading = false.obs;

  // Quiet hours
  final RxString silentStartTime = '22:00'.obs;
  final RxString silentEndTime = '06:00'.obs;
  final RxBool isDoNotDisturb = false.obs;

  // Notification settings
  final RxBool pushNotifications = true.obs;
  final RxBool likes = true.obs;
  final RxBool comments = true.obs;
  final RxBool mentions = true.obs;
  final RxBool newFollowers = true.obs;
  final RxBool messages = true.obs;
  final RxBool communityUpdates = true.obs;
  final RxBool emailNotifications = false.obs;

  // Track which setting is currently being updated
  final RxString updatingSetting = ''.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadSettingsFromLocal();
  }

  // ==================== Load Settings from UserInfo ====================
  void loadSettingsFromLocal() {
    isLoading.value = true;

    try {
      // Load from UserInfo (GetStorage)
      silentStartTime.value = UserInfo.silentStartTime ?? '22:00';
      silentEndTime.value = UserInfo.silentEndTime ?? '06:00';
      isDoNotDisturb.value = UserInfo.isDoNotDisturb;
      pushNotifications.value = UserInfo.isPushNotify;
      likes.value = UserInfo.isLikeNotify;
      comments.value = UserInfo.isCommentNotify;
      mentions.value = UserInfo.isMentionNotify;
      newFollowers.value = UserInfo.isNewFollowerNotify;
      messages.value = UserInfo.isMessageNotify;
      communityUpdates.value = UserInfo.isCommunityUpdateNotify;
      emailNotifications.value = UserInfo.isEmailNotify;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Update Setting ====================
  Future<void> updateSetting(String settingName, bool value) async {
    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please login again.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // Store old value for revert
    final oldValue = _getSettingValue(settingName);

    // Optimistic UI update
    _setSettingValue(settingName, value);
    updatingSetting.value = settingName;

    try {
      // Build request with all current values
      final response = await NetworkCaller.postRequest(
        url: Urls.notifications,
        body: {
          'api_token': token,
          'silent_stat_time': silentStartTime.value,
          'silent_end_time': silentEndTime.value,
          'is_do_not_disturd': isDoNotDisturb.value ? 1 : 0,
          'is_push_notify': pushNotifications.value ? 1 : 0,
          'is_like_notify': likes.value ? 1 : 0,
          'is_comment_notify': comments.value ? 1 : 0,
          'is_mention_notify': mentions.value ? 1 : 0,
          'is_new_folower_notify': newFollowers.value ? 1 : 0,
          'is_message_notify': messages.value ? 1 : 0,
          'is_community_update_notify': communityUpdates.value ? 1 : 0,
          'is_email_notify': emailNotifications.value ? 1 : 0,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          // Save to UserInfo from API response
          await UserInfo.saveNotificationSettings(data['data']);

          // Sync local values with response
          _syncFromResponse(data['data']);
        } else {
          // Revert on API error
          _setSettingValue(settingName, oldValue);
          _showErrorSnackbar(data['message'] ?? 'Failed to update setting');
        }
      } else {
        // Revert on request error
        _setSettingValue(settingName, oldValue);
        _showErrorSnackbar(response.errorMessage ?? 'Failed to update setting');
      }
    } catch (e) {
      // Revert on exception
      _setSettingValue(settingName, oldValue);
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      updatingSetting.value = '';
    }
  }

  // ==================== Update Quiet Hours ====================
  Future<void> updateQuietHours(String startTime, String endTime) async {
    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please login again.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // Store old values for revert
    final oldStartTime = silentStartTime.value;
    final oldEndTime = silentEndTime.value;

    // Optimistic UI update
    silentStartTime.value = startTime;
    silentEndTime.value = endTime;
    isDoNotDisturb.value = true;
    updatingSetting.value = 'quietHours';

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.notifications,
        body: {
          'api_token': token,
          'silent_stat_time': startTime,
          'silent_end_time': endTime,
          'is_do_not_disturd': 1,
          'is_push_notify': pushNotifications.value ? 1 : 0,
          'is_like_notify': likes.value ? 1 : 0,
          'is_comment_notify': comments.value ? 1 : 0,
          'is_mention_notify': mentions.value ? 1 : 0,
          'is_new_folower_notify': newFollowers.value ? 1 : 0,
          'is_message_notify': messages.value ? 1 : 0,
          'is_community_update_notify': communityUpdates.value ? 1 : 0,
          'is_email_notify': emailNotifications.value ? 1 : 0,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          await UserInfo.saveNotificationSettings(data['data']);
          _syncFromResponse(data['data']);
        } else {
          // Revert
          silentStartTime.value = oldStartTime;
          silentEndTime.value = oldEndTime;
          _showErrorSnackbar(data['message'] ?? 'Failed to update quiet hours');
        }
      } else {
        silentStartTime.value = oldStartTime;
        silentEndTime.value = oldEndTime;
        _showErrorSnackbar(response.errorMessage ?? 'Failed to update quiet hours');
      }
    } catch (e) {
      silentStartTime.value = oldStartTime;
      silentEndTime.value = oldEndTime;
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      updatingSetting.value = '';
    }
  }

  // ==================== Helper Methods ====================
  bool _getSettingValue(String settingName) {
    switch (settingName) {
      case 'pushNotifications':
        return pushNotifications.value;
      case 'likes':
        return likes.value;
      case 'comments':
        return comments.value;
      case 'mentions':
        return mentions.value;
      case 'newFollowers':
        return newFollowers.value;
      case 'messages':
        return messages.value;
      case 'communityUpdates':
        return communityUpdates.value;
      case 'emailNotifications':
        return emailNotifications.value;
      case 'isDoNotDisturb':
        return isDoNotDisturb.value;
      default:
        return false;
    }
  }

  void _setSettingValue(String settingName, bool value) {
    switch (settingName) {
      case 'pushNotifications':
        pushNotifications.value = value;
        break;
      case 'likes':
        likes.value = value;
        break;
      case 'comments':
        comments.value = value;
        break;
      case 'mentions':
        mentions.value = value;
        break;
      case 'newFollowers':
        newFollowers.value = value;
        break;
      case 'messages':
        messages.value = value;
        break;
      case 'communityUpdates':
        communityUpdates.value = value;
        break;
      case 'emailNotifications':
        emailNotifications.value = value;
        break;
      case 'isDoNotDisturb':
        isDoNotDisturb.value = value;
        break;
    }
  }

  void _syncFromResponse(Map<String, dynamic> data) {
    if (data['silent_stat_time'] != null) {
      silentStartTime.value = data['silent_stat_time'];
    }
    if (data['silent_end_time'] != null) {
      silentEndTime.value = data['silent_end_time'];
    }
    if (data['is_do_not_disturd'] != null) {
      isDoNotDisturb.value = data['is_do_not_disturd'] == 1;
    }
    if (data['is_push_notify'] != null) {
      pushNotifications.value = data['is_push_notify'] == 1;
    }
    if (data['is_like_notify'] != null) {
      likes.value = data['is_like_notify'] == 1;
    }
    if (data['is_comment_notify'] != null) {
      comments.value = data['is_comment_notify'] == 1;
    }
    if (data['is_mention_notify'] != null) {
      mentions.value = data['is_mention_notify'] == 1;
    }
    if (data['is_new_folower_notify'] != null) {
      newFollowers.value = data['is_new_folower_notify'] == 1;
    }
    if (data['is_message_notify'] != null) {
      messages.value = data['is_message_notify'] == 1;
    }
    if (data['is_community_update_notify'] != null) {
      communityUpdates.value = data['is_community_update_notify'] == 1;
    }
    if (data['is_email_notify'] != null) {
      emailNotifications.value = data['is_email_notify'] == 1;
    }
  }

  // ==================== Switch Handlers ====================
  void onPushNotificationsChanged(bool value) => updateSetting('pushNotifications', value);
  void onLikesChanged(bool value) => updateSetting('likes', value);
  void onCommentsChanged(bool value) => updateSetting('comments', value);
  void onMentionsChanged(bool value) => updateSetting('mentions', value);
  void onNewFollowersChanged(bool value) => updateSetting('newFollowers', value);
  void onMessagesChanged(bool value) => updateSetting('messages', value);
  void onCommunityUpdatesChanged(bool value) => updateSetting('communityUpdates', value);
  void onEmailNotificationsChanged(bool value) => updateSetting('emailNotifications', value);

  // ==================== Check if setting is updating ====================
  bool isSettingUpdating(String settingName) => updatingSetting.value == settingName;

  // ==================== Quiet Hours Display ====================
  String get quietHoursDisplay {
    if (isDoNotDisturb.value) {
      return '${silentStartTime.value} - ${silentEndTime.value}';
    }
    return '';
  }

  bool get hasQuietHours => isDoNotDisturb.value;

  // ==================== Snackbar Helpers ====================
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }
}

