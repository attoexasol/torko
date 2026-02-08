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
  final RxList<FriendRequestItem> sentRequests = <FriendRequestItem>[].obs;

  final RxBool isLoadingSuggestions = false.obs;
  final RxBool isLoadingFriends = false.obs;
  final RxBool isLoadingRequests = false.obs;
  final RxBool isLoadingSent = false.obs;

  final RxBool hasErrorSuggestions = false.obs;
  final RxBool hasErrorFriends = false.obs;
  final RxBool hasErrorRequests = false.obs;
  final RxBool hasErrorSent = false.obs;

  final RxMap<int, bool> isCancellingByRequestId = <int, bool>{}.obs;
  final RxMap<int, bool> isSendingRequestByUserId = <int, bool>{}.obs;
  RxMap<int, bool> get isSendingByUserId => isSendingRequestByUserId;
  final RxMap<int, bool> isAcceptingByRequestId = <int, bool>{}.obs;
  final RxMap<int, bool> isRejectingByRequestId = <int, bool>{}.obs;

  /// User IDs we have sent a request to (show "Requested" state).
  final RxSet<int> requestedUserIds = <int>{}.obs;

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  int get pendingCount => requests.length;
  int get sentCount => sentRequests.length;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  static bool _matchesQuery(FriendUser user, String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase().trim();
    final name = (user.fullname ?? '').toLowerCase();
    final username = (user.username ?? '').toLowerCase();
    final address = (user.address ?? '').toLowerCase();
    return name.contains(lower) || username.contains(lower) || address.contains(lower);
  }

  List<FriendUser> get filteredSuggestions {
    final q = searchQuery.value;
    if (q.isEmpty) return suggestions;
    return suggestions.where((u) => _matchesQuery(u, q)).toList();
  }

  List<FriendUser> get filteredFriends {
    final q = searchQuery.value;
    if (q.isEmpty) return friends;
    return friends.where((u) => _matchesQuery(u, q)).toList();
  }

  List<FriendRequestItem> get filteredRequests {
    final q = searchQuery.value;
    if (q.isEmpty) return requests;
    return requests.where((r) => _matchesQuery(r.user, q)).toList();
  }

  List<FriendRequestItem> get filteredSentRequests {
    final q = searchQuery.value;
    if (q.isEmpty) return sentRequests;
    return sentRequests.where((r) => _matchesQuery(r.user, q)).toList();
  }

  /// Load all tabs (suggestions, friends, requests, sent).
  Future<void> loadAll() async {
    await Future.wait([
      loadSuggestions(),
      loadFriends(),
      loadRequests(),
      loadSentRequests(),
    ]);
  }

  Future<void> loadSuggestions({bool showLoader = true}) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    if (showLoader) isLoadingSuggestions.value = true;
    hasErrorSuggestions.value = false;
    try {
      final list = await FriendsApiService.fetchSuggestions(token);
      suggestions.assignAll(list);
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadSuggestions: ${e.message}');
      hasErrorSuggestions.value = true;
      if (!showLoader) _showSnackbar(e.message, isSuccess: false);
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadSuggestions error: $e');
      hasErrorSuggestions.value = true;
      if (!showLoader) {
        _showSnackbar(
          e.toString().contains('timeout') || e.toString().contains('Timeout')
              ? 'Request timed out. Please check your connection.'
              : 'Failed to load suggestions. Please try again.',
          isSuccess: false,
        );
      }
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  Future<void> loadFriends() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isLoadingFriends.value = true;
    hasErrorFriends.value = false;
    try {
      final list = await FriendsApiService.fetchFriends(token);
      friends.assignAll(list);
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadFriends: ${e.message}');
      hasErrorFriends.value = true;
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadFriends error: $e');
      hasErrorFriends.value = true;
    } finally {
      isLoadingFriends.value = false;
    }
  }

  Future<void> loadRequests() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isLoadingRequests.value = true;
    hasErrorRequests.value = false;
    try {
      final list = await FriendsApiService.fetchRequests(token);
      requests.assignAll(list);
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadRequests: ${e.message}');
      hasErrorRequests.value = true;
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadRequests error: $e');
      hasErrorRequests.value = true;
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> loadSentRequests({bool showLoader = true}) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    if (showLoader) isLoadingSent.value = true;
    hasErrorSent.value = false;
    try {
      final list = await FriendsApiService.fetchPendingOutgoingRequests(token);
      sentRequests.assignAll(list);
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadSentRequests: ${e.message}');
      hasErrorSent.value = true;
      if (!showLoader) _showSnackbar(e.message, isSuccess: false);
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] loadSentRequests error: $e');
      hasErrorSent.value = true;
      if (!showLoader) {
        _showSnackbar(
          e.toString().contains('timeout') || e.toString().contains('Timeout')
              ? 'Request timed out. Please check your connection.'
              : 'Failed to load sent requests.',
          isSuccess: false,
        );
      }
    } finally {
      isLoadingSent.value = false;
    }
  }

  Future<void> cancelRequestAndRefresh(int requestId) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      _showSnackbar('Session expired. Please login again.', isSuccess: false);
      return;
    }

    isCancellingByRequestId[requestId] = true;
    isCancellingByRequestId.refresh();

    try {
      final (success, message) =
          await FriendsApiService.cancelSentRequest(token, requestId);
      _showSnackbar(message, isSuccess: success);
      await loadSentRequests(showLoader: false);
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] cancelRequestAndRefresh error: $e');
      _showSnackbar(
        e.toString().contains('timeout') || e.toString().contains('Timeout')
            ? 'Request timed out. Please check your connection.'
            : 'Failed to cancel request.',
        isSuccess: false,
      );
    } finally {
      isCancellingByRequestId[requestId] = false;
      isCancellingByRequestId.refresh();
    }
  }

  /// Sends friend request and always refreshes suggestions list.
  Future<void> sendFriendRequestAndRefresh(int receiverId) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      _showSnackbar('Session expired. Please login again.', isSuccess: false);
      return;
    }

    isSendingRequestByUserId[receiverId] = true;
    isSendingRequestByUserId.refresh();

    try {
      final (success, message) =
          await FriendsApiService.sendFriendRequest(token, receiverId);

      _showSnackbar(message, isSuccess: success);

      // Always refresh suggestions after request (success or already exists)
      await loadSuggestions(showLoader: false);
    } catch (e) {
      if (kDebugMode) debugPrint('[Friends] sendFriendRequestAndRefresh error: $e');
      _showSnackbar(
        e.toString().contains('timeout') || e.toString().contains('Timeout')
            ? 'Request timed out. Please check your connection.'
            : 'Failed to send request. Please try again.',
        isSuccess: false,
      );
    } finally {
      isSendingRequestByUserId[receiverId] = false;
      isSendingRequestByUserId.refresh();
    }
  }

  /// Legacy alias - delegates to sendFriendRequestAndRefresh.
  Future<void> onAddFriend(int userId) => sendFriendRequestAndRefresh(userId);

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
