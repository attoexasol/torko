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

/// Controller for inbox/conversation list
/// Groups messages by otherUserId to show ONE conversation per user (like Messenger)
class InboxController extends GetxController {
  // Inbox threads (grouped conversations)
  final RxList<InboxThreadModel> threads = <InboxThreadModel>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  // Search functionality
  final TextEditingController searchEC = TextEditingController();
  final RxBool isSearchMode = false.obs; // true after search submitted OR when search text not empty
  final RxBool searching = false.obs;
  final RxString searchError = ''.obs;
  final RxList<SearchMessageResultModel> searchResults = <SearchMessageResultModel>[].obs;

  // Pusher subscription for real-time updates
  StreamSubscription<Map<String, dynamic>>? _pusherSubscription;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('🔍 [InboxController] onInit called');
    }
    fetchInbox();
    _connectPusher();
  }

  @override
  void onClose() {
    _pusherSubscription?.cancel();
    searchEC.dispose();
    super.onClose();
  }

  /// Connect to Pusher for real-time inbox updates
  Future<void> _connectPusher() async {
    final currentUserId = UserInfo.userId;
    if (currentUserId == null) return;

    try {
      final pusherService = PusherService();
      
      if (!pusherService.isConnected) {
        await pusherService.connect(currentUserId: currentUserId);
      }

      _pusherSubscription = pusherService.onEventStream.listen((eventData) {
        _handlePusherEvent(eventData);
      });

      if (kDebugMode) {
        print('DEBUG InboxController: Connected to Pusher for real-time updates');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG InboxController: Pusher connection error - $e');
      }
    }
  }

  /// Handle incoming Pusher events
  void _handlePusherEvent(Map<String, dynamic> eventData) {
    try {
      final eventName = eventData['eventName'] as String?;
      final data = eventData['data'] as Map<String, dynamic>?;

      if (data == null) return;

      if (eventName != null && 
          (eventName.contains('message') || eventName.contains('Message'))) {
        // Refresh inbox when new message arrives
        fetchInbox();
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG InboxController: Error handling Pusher event: $e');
      }
    }
  }

  /// Fetch inbox and group messages by otherUserId
  Future<void> fetchInbox() async {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [fetchInbox] fetchInbox() called');
    }
    
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('❌ [fetchInbox] Token is null or empty');
      }
      error.value = 'User not logged in';
      loading.value = false;
      return;
    }

    final currentUserId = UserInfo.userId;
    if (currentUserId == null) {
      if (kDebugMode) {
        print('❌ [fetchInbox] UserId is null');
      }
      error.value = 'User ID not found';
      loading.value = false;
      return;
    }

    if (kDebugMode) {
      print('✅ [fetchInbox] Token found (length: ${token.length})');
      print('✅ [fetchInbox] CurrentUserId: $currentUserId');
    }

    loading.value = true;
    error.value = '';

    try {
      if (kDebugMode) {
        print('🔄 [fetchInbox] Calling MessageApiService.fetchInboxRows()...');
      }
      
      final rawRows = await MessageApiService.fetchInboxRows(token: token);
      
      if (kDebugMode) {
        print('✅ [fetchInbox] API returned ${rawRows.length} raw message rows');
      }
      
      // Group by otherUserId and count unreads
      final Map<int, List<MessageRowModel>> rowsByOtherUser = {};
      final Map<int, UserMiniModel> userInfoMap = {};
      
      // First pass: group all rows by otherUserId
      for (var row in rawRows) {
        final otherUserId = row.getOtherUserId(currentUserId);
        final otherUser = row.getOtherUser(currentUserId);
        
        if (otherUser == null || otherUserId == 0) {
          if (kDebugMode) {
            print('⚠️ [fetchInbox] Skipping row ${row.id}: invalid otherUser');
          }
          continue;
        }
        
        if (!rowsByOtherUser.containsKey(otherUserId)) {
          rowsByOtherUser[otherUserId] = [];
          userInfoMap[otherUserId] = otherUser;
        }
        
        rowsByOtherUser[otherUserId]!.add(row);
      }
      
      // Second pass: create threads with proper unread counts
      final Map<int, InboxThreadModel> threadMap = {};
      
      for (var entry in rowsByOtherUser.entries) {
        final otherUserId = entry.key;
        final rows = entry.value;
        final otherUser = userInfoMap[otherUserId]!;
        
        // Sort rows by createdAt DESC to get latest
        rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latestRow = rows.first;
        
        // Count unread messages (messages sent TO current user that are unread)
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
      
      // Convert to list and sort by lastTime DESC (newest first)
      final threadList = threadMap.values.toList();
      threadList.sort((a, b) => b.lastTime.compareTo(a.lastTime));
      
      threads.assignAll(threadList);
      
      if (kDebugMode) {
        print('✅ [fetchInbox] Grouped into ${threads.length} unique threads');
        for (var thread in threads.take(5)) {
          print('   - User ${thread.otherUserId} (${thread.otherName}): "${thread.lastMessage}" (${thread.unreadCount} unread)');
        }
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      error.value = e is MessageApiException 
          ? e.message 
          : 'Failed to load conversations';
      
      if (kDebugMode) {
        print('❌ [fetchInbox] Error: $e');
        print('   Stack trace: $stackTrace');
        print('═══════════════════════════════════════════════════════════');
      }
    } finally {
      loading.value = false;
    }
  }

  /// Pull to refresh
  Future<void> refresh() async {
    await fetchInbox();
  }

  /// Navigate to conversation from inbox thread
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

  /// Submit search query
  Future<void> onSubmitSearch() async {
    final keyword = searchEC.text.trim();
    
    if (keyword.isEmpty) {
      clearSearch();
      return;
    }

    // Prevent double request while searching
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
      if (kDebugMode) {
        print('🔍 [InboxController] Searching messages with keyword: "$keyword"');
      }

      final results = await MessageApiService.searchMessages(
        token: token,
        keyword: keyword,
      );

      searchResults.assignAll(results);
      searchError.value = '';

      if (kDebugMode) {
        print('✅ [InboxController] Search completed: ${results.length} results');
      }
    } catch (e) {
      searchError.value = e is MessageApiException 
          ? e.message 
          : 'Failed to search messages';
      
      searchResults.clear();

      if (kDebugMode) {
        print('❌ [InboxController] Search error: $e');
      }
    } finally {
      searching.value = false;
    }
  }

  /// Clear search and return to inbox
  void clearSearch() {
    searchEC.clear();
    isSearchMode.value = false;
    searchResults.clear();
    searchError.value = '';
  }

  /// Navigate to conversation from search result
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

  /// Update conversation list from incoming message (real-time)
  /// Called by ChatController when a new message is sent/received
  void updateConversationFromMessage(MessageModel message) {
    final currentUserId = UserInfo.userId;
    if (currentUserId == null) return;

    // Determine the other user in the conversation
    final otherUserId = message.fromUserId == currentUserId 
        ? message.toUserId 
        : message.fromUserId;

    // Refresh inbox to get updated data
    // This ensures we have the latest message and correct unread counts
    fetchInbox();
  }
}
