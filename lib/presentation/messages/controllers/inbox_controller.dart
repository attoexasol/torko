import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/core/services/firestore_chat_service.dart';
import 'package:torko/core/services/message_api_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/inbox_thread_model.dart';
import 'package:torko/data/models/search_message_result_model.dart';

/// Realtime inbox controller via Firestore snapshots.
/// Streams conversations where members arrayContains currentUid.
/// Search remains via REST.
class InboxController extends GetxService {
  final RxList<InboxThreadModel> threads = <InboxThreadModel>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  final TextEditingController searchEC = TextEditingController();
  final RxBool isSearchMode = false.obs;
  final RxBool searching = false.obs;
  final RxString searchError = ''.obs;
  final RxList<SearchMessageResultModel> searchResults = <SearchMessageResultModel>[].obs;

  final FirestoreChatService _firestoreChat = FirestoreChatService();
  StreamSubscription<List<InboxThreadModel>>? _inboxSubscription;
  String? _inboxActiveUid; // Guard: prevent double subscription for same user

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _cancelInboxSubscription();
    searchEC.dispose();
    super.onClose();
  }

  void _cancelInboxSubscription() {
    _inboxSubscription?.cancel();
    _inboxSubscription = null;
    _inboxActiveUid = null;
  }

  /// Start Firestore inbox stream. Call when Messages screen opens.
  /// Guard: skip if already subscribed for same uid (prevents double subscription).
  void startInboxStream() {
    final currentUserId = UserInfo.userId;
    if (currentUserId == null) {
      error.value = 'User not logged in';
      return;
    }
    final uidStr = currentUserId.toString();

    // Guard: already subscribed for this user - do not restart
    if (_inboxSubscription != null && _inboxActiveUid == uidStr) return;

    _cancelInboxSubscription();
    _inboxActiveUid = uidStr;
    loading.value = true;
    error.value = '';

    _inboxSubscription = _firestoreChat.inboxStream(uidStr).listen(
      (list) {
        threads.assignAll(list);
        loading.value = false;
        error.value = '';
      },
      onError: (e) {
        error.value = 'Failed to load conversations';
        loading.value = false;
      },
      cancelOnError: false,
    );
  }

  /// Pull-to-refresh: cancel and restart stream (bypasses guard).
  Future<void> refreshInbox() async {
    _cancelInboxSubscription();
    startInboxStream();
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
  // SEARCH (REST)
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
      searchError.value = e is MessageApiException ? e.message : 'Search failed';
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
}
