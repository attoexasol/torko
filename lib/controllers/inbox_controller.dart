import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/message_row_model.dart';
import '../models/inbox_thread_model.dart';
import '../models/search_message_result_model.dart';
import '../models/user_mini_model.dart';
import '../models/message_model.dart';
import '../services/message_api_service.dart';
import '../services/reverb_service.dart';
import '../services/user_info.dart';
import '../core/routes/app_routes.dart';

/// REALTIME INBOX CONTROLLER (SAFE + SINGLE INSTANCE)
///
/// - API loads inbox ONCE (per app session unless refresh())
/// - Realtime updates are incremental
/// - No streams
/// - Proper cleanup of callback + controllers
class InboxController extends GetxService {
  // =========================
  // Reactive State
  // =========================
  final RxList<InboxThreadModel> threads = <InboxThreadModel>[].obs;

  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  // =========================
  // Search
  // =========================
  final TextEditingController searchEC = TextEditingController();

  final RxBool isSearchMode = false.obs;
  final RxBool searching = false.obs;
  final RxString searchError = ''.obs;

  final RxList<SearchMessageResultModel> searchResults =
      <SearchMessageResultModel>[].obs;

  // =========================
  // Internal State
  // =========================
  final ReverbService _reverb = ReverbService();

  bool _loadedOnce = false;
  bool _callbackRegistered = false;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();

    _registerRealtimeCallbackOnce();

    if (kDebugMode) {
      debugPrint('[INBOX] onInit');
      debugPrint('[INBOX] Instance ID: $hashCode');
    }
  }

  void _registerRealtimeCallbackOnce() {
    if (_callbackRegistered) return;
    _callbackRegistered = true;

    if (kDebugMode) {
      debugPrint('[INBOX] registering realtime callback');
    }

    _reverb.onInboxMessage = (message) {
      if (kDebugMode) {
        debugPrint('[INBOX] REALTIME message | id=${message.id}');
      }
      _handleIncomingMessage(message);
    };
  }

  // =========================
  // ONE TIME LOAD
  // =========================
  Future<void> loadInboxOnce() async {
    if (_loadedOnce) {
      if (kDebugMode) debugPrint('[INBOX] loadInboxOnce skipped');
      return;
    }

    // mark loaded first to prevent double-taps,
    // but reset if the request fails
    _loadedOnce = true;

    if (kDebugMode) debugPrint('[INBOX] loadInboxOnce → fetchInbox()');

    final ok = await fetchInbox();
    if (!ok) {
      // if failed, allow retry
      _loadedOnce = false;
    }
  }

  void resetLoadedFlag() {
    _loadedOnce = false;
    if (kDebugMode) debugPrint('[INBOX] resetLoadedFlag');
  }

  // =========================
  // REALTIME HANDLER
  // =========================
  void _handleIncomingMessage(MessageModel message) {
    try {
      final currentUserId = UserInfo.userId;
      if (currentUserId == null) return;

      final otherUserId = (message.fromUserId == currentUserId)
          ? message.toUserId
          : message.fromUserId;

      final index = threads.indexWhere((t) => t.otherUserId == otherUserId);

      final lastRow = MessageRowModel(
        id: message.id,
        fromUserId: message.fromUserId,
        toUserId: message.toUserId,
        content: message.messageContent,
        isRead: message.isRead,
        createdAt: message.createdAt,
        sender: message.sender,
        receiver: message.receiver,
      );

      // determine unread increment only if current user is receiver and unread
      final bool isUnreadForMe =
          (message.toUserId == currentUserId && message.isRead == 0);

      if (index >= 0) {
        final existing = threads[index];

        final updated = InboxThreadModel(
          otherUserId: existing.otherUserId,
          otherName: existing.otherName,
          otherAvatar: existing.otherAvatar,
          lastMessage: message.messageContent,
          lastTime: message.createdAt,
          unreadCount: existing.unreadCount + (isUnreadForMe ? 1 : 0),
          lastRow: lastRow,
        );

        // Move updated thread to top
        threads.removeAt(index);
        threads.insert(0, updated);

        if (kDebugMode) debugPrint('[INBOX] Thread updated realtime');
        return;
      }

      // New thread
      if (message.sender == null || message.receiver == null) return;

      final otherUser = (message.fromUserId == currentUserId)
          ? message.receiver!
          : message.sender!;

      final newThread = InboxThreadModel(
        otherUserId: otherUser.id,
        otherName: otherUser.fullname,
        otherAvatar: otherUser.profileImage,
        lastMessage: message.messageContent,
        lastTime: message.createdAt,
        unreadCount: isUnreadForMe ? 1 : 0,
        lastRow: lastRow,
      );

      threads.insert(0, newThread);

      if (kDebugMode) debugPrint('[INBOX] New thread created realtime');
    } catch (e) {
      if (kDebugMode) debugPrint('[INBOX] Error handling message: $e');
    }
  }

  // =========================
  // API LOAD
  // =========================
  Future<bool> fetchInbox() async {
    final token = UserInfo.apiToken;
    final currentUserId = UserInfo.userId;

    if (token == null || token.isEmpty || currentUserId == null) {
      error.value = 'User not logged in';
      return false;
    }

    loading.value = true;
    error.value = '';

    try {
      final rows = await MessageApiService.fetchInboxRows(token: token);

      final Map<int, List<MessageRowModel>> grouped = {};
      final Map<int, UserMiniModel> userMap = {};

      for (final row in rows) {
        final otherId = row.getOtherUserId(currentUserId);
        final otherUser = row.getOtherUser(currentUserId);
        if (otherUser == null) continue;

        grouped.putIfAbsent(otherId, () => <MessageRowModel>[]);
        grouped[otherId]!.add(row);
        userMap[otherId] = otherUser;
      }

      final List<InboxThreadModel> result = [];

      grouped.forEach((userId, list) {
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        int unread = 0;
        for (final row in list) {
          if (row.toUserId == currentUserId && row.isRead == 0) unread++;
        }

        final last = list.first;
        final user = userMap[userId];

        if (user == null) return;

        result.add(
          InboxThreadModel(
            otherUserId: userId,
            otherName: user.fullname,
            otherAvatar: user.profileImage,
            lastMessage: last.content,
            lastTime: last.createdAt,
            unreadCount: unread,
            lastRow: last,
          ),
        );
      });

      result.sort((a, b) => b.lastTime.compareTo(a.lastTime));
      threads.assignAll(result);

      return true;
    } catch (e) {
      error.value = e is MessageApiException
          ? e.message
          : 'Failed to load conversations';
      return false;
    } finally {
      loading.value = false;
    }
  }

  // =========================
  // UI HELPERS
  // =========================
  Future<void> refreshInbox() async {
    resetLoadedFlag();
    await fetchInbox();
  }

  void openThreadFromInbox(InboxThreadModel thread) {
    Get.toNamed(
      AppRoutes.conversation,
      arguments: {
        'toUserId': thread.otherUserId,
        'receiverName': thread.otherName,
        'receiverAvatar': thread.otherAvatar,
      },
    );
  }

  // =========================
  // SEARCH
  // =========================
  Future<void> onSubmitSearch() async {
    final keyword = searchEC.text.trim();

    if (keyword.isEmpty) {
      clearSearch();
      return;
    }
    if (searching.value) return;

    searching.value = true;
    isSearchMode.value = true;
    searchError.value = '';

    final token = UserInfo.apiToken;

    if (token == null || token.isEmpty) {
      searchError.value = 'User not logged in';
      searching.value = false;
      return;
    }

    try {
      final results = await MessageApiService.searchMessages(
        token: token,
        keyword: keyword,
      );
      searchResults.assignAll(results);
    } catch (e) {
      searchError.value = e is MessageApiException
          ? e.message
          : 'Search failed';
      searchResults.clear();
    } finally {
      searching.value = false;
    }
  }

  void clearSearch() {
    searchEC.clear();
    isSearchMode.value = false;
    searchResults.clear();
    searchError.value = '';
  }

  void openThreadFromSearch(SearchMessageResultModel item) {
    Get.toNamed(
      AppRoutes.conversation,
      arguments: {
        'toUserId': item.user.id,
        'receiverName': item.user.fullname,
        'receiverAvatar': item.user.profileImage,
      },
    );
  }

  // =========================
  // PUBLIC ENTRY (From ChatController)
  // =========================
  void updateConversationFromMessage(MessageModel message) {
    _handleIncomingMessage(message);
  }

  // =========================
  // CLEANUP
  // =========================
  @override
  void onClose() {
    // important: stop receiving realtime callbacks when this service is removed
    // (if you keep it permanent, it won't be called unless you delete it)
    if (kDebugMode) debugPrint('[INBOX] onClose - cleanup');

    if (_reverb.onInboxMessage != null) {
      _reverb.onInboxMessage = null;
    }

    searchEC.dispose();
    super.onClose();
  }
}
