import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/services/friends_api_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/friend_user.dart';

/// Friends controller with full API integration.
class FriendsController extends GetxController {
  final RxList<FriendUser> suggestions = <FriendUser>[].obs;
  final RxList<FriendUser> friends = <FriendUser>[].obs;
  final RxList<FriendRequestItem> requests = <FriendRequestItem>[].obs;

  final RxBool isLoadingSuggestions = false.obs;
  final RxBool isLoadingFriends = false.obs;
  final RxBool isLoadingRequests = false.obs;

  final RxMap<int, bool> isSendingRequestByUserId = <int, bool>{}.obs;
  final RxMap<int, bool> isAcceptingByRequestId = <int, bool>{}.obs;
  final RxMap<int, bool> isRejectingByRequestId = <int, bool>{}.obs;

  int get pendingCount => requests.length;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Load all tabs (suggestions, friends, requests).
  Future<void> loadAll() async {
    await Future.wait([
      loadSuggestions(),
      loadFriends(),
      loadRequests(),
    ]);
  }

  Future<void> loadSuggestions() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isLoadingSuggestions.value = true;
    try {
      final list = await FriendsApiService.fetchSuggestions(token);
      suggestions.assignAll(list);
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadSuggestions: ${e.message}');
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadSuggestions error: $e');
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  Future<void> loadFriends() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isLoadingFriends.value = true;
    try {
      final list = await FriendsApiService.fetchFriends(token);
      friends.assignAll(list);
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadFriends: ${e.message}');
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadFriends error: $e');
    } finally {
      isLoadingFriends.value = false;
    }
  }

  Future<void> loadRequests() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isLoadingRequests.value = true;
    try {
      final list = await FriendsApiService.fetchRequests(token);
      requests.assignAll(list);
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadRequests: ${e.message}');
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadRequests error: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> onAddFriend(int userId) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isSendingRequestByUserId[userId] = true;
    isSendingRequestByUserId.refresh();

    try {
      final (success, message) =
          await FriendsApiService.sendFriendRequest(token, userId);

      _showSnackbar(message, isSuccess: success);

      if (success) {
        suggestions.removeWhere((u) => u.id == userId);
      } else if (message.toLowerCase().contains('already exists')) {
        // Keep UI; info snackbar already shown
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] onAddFriend error: $e');
      _showSnackbar('Failed to send request', isSuccess: false);
    } finally {
      isSendingRequestByUserId[userId] = false;
      isSendingRequestByUserId.refresh();
    }
  }

  Future<void> onAccept(int requestId) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isAcceptingByRequestId[requestId] = true;
    isAcceptingByRequestId.refresh();

    try {
      final (success, message, user) =
          await FriendsApiService.acceptRequest(token, requestId);

      _showSnackbar(message, isSuccess: success);

      if (success) {
        requests.removeWhere((r) => r.requestId == requestId);
        if (user != null && !friends.any((f) => f.id == user.id)) {
          friends.insert(0, user);
        } else {
          loadFriends();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] onAccept error: $e');
      _showSnackbar('Failed to accept request', isSuccess: false);
    } finally {
      isAcceptingByRequestId[requestId] = false;
      isAcceptingByRequestId.refresh();
    }
  }

  Future<void> onDecline(int requestId) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isRejectingByRequestId[requestId] = true;
    isRejectingByRequestId.refresh();

    try {
      final (success, message) =
          await FriendsApiService.rejectRequest(token, requestId);

      _showSnackbar(message, isSuccess: success);

      if (success) {
        requests.removeWhere((r) => r.requestId == requestId);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] onDecline error: $e');
      _showSnackbar('Failed to reject request', isSuccess: false);
    } finally {
      isRejectingByRequestId[requestId] = false;
      isRejectingByRequestId.refresh();
    }
  }

  void _showSnackbar(String message, {required bool isSuccess}) {
    final appController = Get.find<AppController>();
    final isDark = appController.isDarkMode;
    final isBn = appController.language == AppLanguage.bn;

    Get.snackbar(
      isSuccess ? (isBn ? 'সফল' : 'Success') : (isBn ? 'ত্রুটি' : 'Error'),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess
          ? (isDark ? AppColors.darkMuted : AppColors.lightMuted)
          : AppColors.darkDestructive,
      colorText: isDark ? AppColors.darkForeground : AppColors.lightForeground,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// For profile_view: remove friend (not in API spec - keep for compatibility).
  void removeFriend(int friendId) {
    friends.removeWhere((f) => f.id == friendId);
  }

  bool isFriend(int userId) => friends.any((f) => f.id == userId);
}
