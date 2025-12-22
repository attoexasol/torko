import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../services/network_caller.dart';
import '../../services/urls.dart';
import '../../services/user_info.dart';

class PrivacySettingsController extends GetxController {
  final appController = Get.find<AppController>();

  // ==================== Observable States ====================
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Privacy settings - mapped to API fields
  // is_post_public_show (0 = private, 1 = public) - inverted for "Private Account" switch
  final RxBool privateAccount = false.obs;
  
  // is_active_status_show
  final RxBool showOnlineStatus = true.obs;
  
  // is_like_and_comment_show
  final RxBool showActivity = true.obs;
  
  // is_anyone_send_message
  final RxBool allowMessages = true.obs;
  
  // is_read_status_show
  final RxBool showReadReceipts = true.obs;
  
  // is_typing_indicator_show
  final RxBool showTypingIndicator = true.obs;
  
  // is_anyone_tag
  final RxBool allowTagging = true.obs;

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
      // Private account is inverted from is_post_public_show
      privateAccount.value = !UserInfo.isPostPublicShow;
      showOnlineStatus.value = UserInfo.isActiveStatusShow;
      showActivity.value = UserInfo.isLikeAndCommentShow;
      allowMessages.value = UserInfo.isAnyoneSendMessage;
      showReadReceipts.value = UserInfo.isReadStatusShow;
      showTypingIndicator.value = UserInfo.isTypingIndicatorShow;
      allowTagging.value = UserInfo.isAnyoneTag;
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
        url: Urls.privacy_settings,
        body: {
          'api_token': token,
          // is_post_public_show is inverted from privateAccount
          'is_post_public_show': privateAccount.value ? 0 : 1,
          'is_active_status_show': showOnlineStatus.value ? 1 : 0,
          'is_like_and_comment_show': showActivity.value ? 1 : 0,
          'is_anyone_send_message': allowMessages.value ? 1 : 0,
          'is_read_status_show': showReadReceipts.value ? 1 : 0,
          'is_typing_indicator_show': showTypingIndicator.value ? 1 : 0,
          'is_anyone_tag': allowTagging.value ? 1 : 0,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          // Save to UserInfo from API response
          await UserInfo.savePrivacySettings(data['data']);
          
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

  // ==================== Helper Methods ====================
  bool _getSettingValue(String settingName) {
    switch (settingName) {
      case 'privateAccount':
        return privateAccount.value;
      case 'showOnlineStatus':
        return showOnlineStatus.value;
      case 'showActivity':
        return showActivity.value;
      case 'allowMessages':
        return allowMessages.value;
      case 'showReadReceipts':
        return showReadReceipts.value;
      case 'showTypingIndicator':
        return showTypingIndicator.value;
      case 'allowTagging':
        return allowTagging.value;
      default:
        return false;
    }
  }

  void _setSettingValue(String settingName, bool value) {
    switch (settingName) {
      case 'privateAccount':
        privateAccount.value = value;
        break;
      case 'showOnlineStatus':
        showOnlineStatus.value = value;
        break;
      case 'showActivity':
        showActivity.value = value;
        break;
      case 'allowMessages':
        allowMessages.value = value;
        break;
      case 'showReadReceipts':
        showReadReceipts.value = value;
        break;
      case 'showTypingIndicator':
        showTypingIndicator.value = value;
        break;
      case 'allowTagging':
        allowTagging.value = value;
        break;
    }
  }

  void _syncFromResponse(Map<String, dynamic> data) {
    if (data['is_post_public_show'] != null) {
      privateAccount.value = data['is_post_public_show'] == 0;
    }
    if (data['is_active_status_show'] != null) {
      showOnlineStatus.value = data['is_active_status_show'] == 1;
    }
    if (data['is_like_and_comment_show'] != null) {
      showActivity.value = data['is_like_and_comment_show'] == 1;
    }
    if (data['is_anyone_send_message'] != null) {
      allowMessages.value = data['is_anyone_send_message'] == 1;
    }
    if (data['is_read_status_show'] != null) {
      showReadReceipts.value = data['is_read_status_show'] == 1;
    }
    if (data['is_typing_indicator_show'] != null) {
      showTypingIndicator.value = data['is_typing_indicator_show'] == 1;
    }
    if (data['is_anyone_tag'] != null) {
      allowTagging.value = data['is_anyone_tag'] == 1;
    }
  }

  // ==================== Switch Handlers ====================
  void onPrivateAccountChanged(bool value) => updateSetting('privateAccount', value);
  void onShowOnlineStatusChanged(bool value) => updateSetting('showOnlineStatus', value);
  void onShowActivityChanged(bool value) => updateSetting('showActivity', value);
  void onAllowMessagesChanged(bool value) => updateSetting('allowMessages', value);
  void onShowReadReceiptsChanged(bool value) => updateSetting('showReadReceipts', value);
  void onShowTypingIndicatorChanged(bool value) => updateSetting('showTypingIndicator', value);
  void onAllowTaggingChanged(bool value) => updateSetting('allowTagging', value);

  // ==================== Check if setting is updating ====================
  bool isSettingUpdating(String settingName) => updatingSetting.value == settingName;

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

