import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message_row_model.dart';
import '../models/inbox_thread_model.dart';
import '../models/search_message_result_model.dart';
import '../models/user_mini_model.dart';
import '../models/message_model.dart';
import '../services/message_api_service.dart';
import '../services/pusher_service.dart';
import '../services/user_info.dart';
import '../core/routes/app_routes.dart';

// ⚠️ REALTIME RULE:
// DO NOT call API after Pusher events.
// This controller uses STREAM-ONLY updates.
// API calls happen ONLY:
//   1) Once when screen first opens (loadInboxOnce)
//   2) Manual pull-to-refresh (refresh)
//   3) Error retry button
//
// ⚠️ PERMANENT CONTROLLER:
// This controller is PERMANENT and lives for entire app lifecycle.
// Stream listener is attached ONCE in onInit() and never dies.
class InboxController extends GetxController {
  final RxList<InboxThreadModel> threads = <InboxThreadModel>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  final TextEditingController searchEC = TextEditingController();
  final RxBool isSearchMode = false.obs;
  final RxBool searching = false.obs;
  final RxString searchError = ''.obs;
  final RxList<SearchMessageResultModel> searchResults = <SearchMessageResultModel>[].obs;

  StreamSubscription<MessageModel>? _pusherSubscription;
  
  // One-time loader flag to prevent multiple API calls
  bool _loadedOnce = false;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      debugPrint('[INBOX] onInit - attaching stream listener');
      debugPrint('[INBOX] Instance ID: ${hashCode}');
    }
    // DO NOT call fetchInbox() here - use loadInboxOnce() from view instead
    // Attach stream listener ONCE - it will never die (permanent controller)
    _connectPusher();
  }
  
  /// Safe one-time loader - prevents duplicate API calls
  /// Call this from MessagesView.initState() ONCE
  void loadInboxOnce() {
    if (_loadedOnce) {
      if (kDebugMode) {
        debugPrint('[INBOX] loadInboxOnce skipped - already loaded');
      }
      return;
    }
    _loadedOnce = true;
    if (kDebugMode) {
      debugPrint('[INBOX] loadInboxOnce - calling fetchInbox()');
    }
    fetchInbox();
  }

  void resetLoadedFlag() {
    _loadedOnce = false;
    if (kDebugMode) {
      debugPrint('[INBOX] resetLoadedFlag - will reload on next loadInboxOnce()');
    }
  }

  @override
  void onClose() {
    if (kDebugMode) {
      debugPrint('[INBOX] onClose (permanent controller, keeping state)');
    }
    super.onClose();
  }

  /// Listen to Pusher stream - NEVER calls connect()
  void _connectPusher() {
    final pusherService = PusherService();

    _pusherSubscription?.cancel();
    _pusherSubscription = null;

    _pusherSubscription = pusherService.incomingMessages.listen(
      (message) {
        if (kDebugMode) {
          debugPrint('[INBOX] REALTIME message | id=${message.id}');
        }
        _handleIncomingMessage(message);
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('[INBOX] Stream error: $error');
        }
      },
      cancelOnError: false,
    );

    if (kDebugMode) {
      debugPrint('[INBOX] Listening to Pusher stream');
    }
  }

  /// Handle incoming message - INCREMENTAL UPDATE ONLY, NO API CALLS
  /// ⚠️ CRITICAL: This method MUST NEVER call fetchInbox() or any API
  void _handleIncomingMessage(MessageModel message) {
    try {
      final currentUserId = UserInfo.userId;
      if (currentUserId == null) return;

      final otherUserId = message.fromUserId == currentUserId 
          ? message.toUserId 
          : message.fromUserId;

      final threadIndex = threads.indexWhere((t) => t.otherUserId == otherUserId);
      
      if (threadIndex >= 0) {
        // Update existing thread INCREMENTALLY
        final existingThread = threads[threadIndex];
        
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
        
        int newUnreadCount = existingThread.unreadCount;
        if (message.toUserId == currentUserId && message.isRead == 0) {
          newUnreadCount = existingThread.unreadCount + 1;
        } else if (message.fromUserId == currentUserId) {
          newUnreadCount = existingThread.unreadCount;
        }
        
        final updatedThread = InboxThreadModel(
          otherUserId: existingThread.otherUserId,
          otherName: existingThread.otherName,
          otherAvatar: existingThread.otherAvatar,
          lastMessage: message.messageContent,
          lastTime: message.createdAt,
          unreadCount: newUnreadCount,
          lastRow: lastRow,
        );
        
        threads[threadIndex] = updatedThread;
        final updated = threads.removeAt(threadIndex);
        threads.insert(0, updated);
        threads.refresh();

        if (kDebugMode) {
          debugPrint('[INBOX] REALTIME thread updated | unread=$newUnreadCount');
        }
      } else {
        // New conversation - create thread locally if we have user data
        if (message.sender != null && message.receiver != null) {
          final otherUser = message.fromUserId == currentUserId 
              ? message.receiver! 
              : message.sender!;
          
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
          
          final newThread = InboxThreadModel(
            otherUserId: otherUser.id,
            otherName: otherUser.fullname,
            otherAvatar: otherUser.profileImage,
            lastMessage: message.messageContent,
            lastTime: message.createdAt,
            unreadCount: message.toUserId == currentUserId && message.isRead == 0 ? 1 : 0,
            lastRow: lastRow,
          );
          
          threads.insert(0, newThread);
          threads.refresh();

          if (kDebugMode) {
            debugPrint('[INBOX] REALTIME new thread created locally');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[INBOX] Error handling message: $e');
      }
    }
  }

  Future<void> fetchInbox() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      error.value = 'User not logged in';
      loading.value = false;
      return;
    }

    final currentUserId = UserInfo.userId;
    if (currentUserId == null) {
      error.value = 'User ID not found';
      loading.value = false;
      return;
    }

    loading.value = true;
    error.value = '';

    try {
      final rawRows = await MessageApiService.fetchInboxRows(token: token);
      
      final Map<int, List<MessageRowModel>> rowsByOtherUser = {};
      final Map<int, UserMiniModel> userInfoMap = {};
      
      for (var row in rawRows) {
        final otherUserId = row.getOtherUserId(currentUserId);
        final otherUser = row.getOtherUser(currentUserId);
        
        if (otherUser == null || otherUserId == 0) {
          continue;
        }
        
        if (!rowsByOtherUser.containsKey(otherUserId)) {
          rowsByOtherUser[otherUserId] = [];
          userInfoMap[otherUserId] = otherUser;
        }
        
        rowsByOtherUser[otherUserId]!.add(row);
      }
      
      final Map<int, InboxThreadModel> threadMap = {};
      
      for (var entry in rowsByOtherUser.entries) {
        final otherUserId = entry.key;
        final rows = entry.value;
        final otherUser = userInfoMap[otherUserId]!;
        
        rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latestRow = rows.first;
        
        int unreadCount = 0;
        for (var row in rows) {
          if (row.toUserId == currentUserId && row.isRead == 0) {
            unreadCount++;
          }
        }
        
        threadMap[otherUserId] = InboxThreadModel(
          otherUserId: otherUserId,
          otherName: otherUser.fullname,
          otherAvatar: otherUser.profileImage,
          lastMessage: latestRow.content,
          lastTime: latestRow.createdAt,
          unreadCount: unreadCount,
          lastRow: latestRow,
        );
      }
      
      final threadList = threadMap.values.toList();
      threadList.sort((a, b) => b.lastTime.compareTo(a.lastTime));
      
      threads.assignAll(threadList);
    } catch (e) {
      error.value = e is MessageApiException 
          ? e.message 
          : 'Failed to load conversations';
    } finally {
      loading.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchInbox();
  }

  void openThreadFromInbox(InboxThreadModel thread) {
    Get.toNamed(
      AppRoutes.conversation,
      arguments: {
        'to_user_id': thread.otherUserId,
        'fullname': thread.otherName,
        'profile_image': thread.otherAvatar,
        'toUserId': thread.otherUserId,
        'receiverName': thread.otherName,
        'receiverAvatar': thread.otherAvatar,
      },
    );
  }

  Future<void> onSubmitSearch() async {
    final keyword = searchEC.text.trim();
    
    if (keyword.isEmpty) {
      clearSearch();
      return;
    }

    if (searching.value) {
      return;
    }

    isSearchMode.value = true;
    searching.value = true;
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
      searchError.value = '';
    } catch (e) {
      searchError.value = e is MessageApiException 
          ? e.message 
          : 'Failed to search messages';
      
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
        'to_user_id': item.user.id,
        'fullname': item.user.fullname,
        'profile_image': item.user.profileImage,
        'toUserId': item.user.id,
        'receiverName': item.user.fullname,
        'receiverAvatar': item.user.profileImage,
      },
    );
  }

  /// Update conversation from message - delegates to _handleIncomingMessage
  void updateConversationFromMessage(MessageModel message) {
    _handleIncomingMessage(message);
  }
}
