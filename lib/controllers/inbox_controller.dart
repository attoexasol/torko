import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/conversation_item_model.dart';
import '../models/message_model.dart';
import '../services/message_api_service.dart';
import '../services/pusher_service.dart';
import '../services/user_info.dart';
import '../core/routes/app_routes.dart';

/// Controller for inbox/conversation list
/// Groups messages by receiver.id to show ONE conversation per user (like WhatsApp)
class InboxController extends GetxController {
  final RxList<ConversationItemModel> conversations = <ConversationItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Pusher subscription for real-time updates
  StreamSubscription<Map<String, dynamic>>? _pusherSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchInbox();
    _connectPusher();
  }

  @override
  void onClose() {
    _pusherSubscription?.cancel();
    super.onClose();
  }

  /// Connect to Pusher for real-time inbox updates
  Future<void> _connectPusher() async {
    final currentUserId = UserInfo.userId;
    if (currentUserId == null) return;

    try {
      final pusherService = PusherService();
      
      // Connect to Pusher if not already connected
      if (!pusherService.isConnected) {
        await pusherService.connect(currentUserId: currentUserId);
      }

      // Listen to incoming messages
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
      // Don't show error - real-time is optional
    }
  }

  /// Handle incoming Pusher events
  void _handlePusherEvent(Map<String, dynamic> eventData) {
    try {
      final eventName = eventData['eventName'] as String?;
      final data = eventData['data'] as Map<String, dynamic>?;

      if (data == null) return;

      // Handle message events
      if (eventName != null && 
          (eventName.contains('message') || eventName.contains('Message'))) {
        try {
          final message = MessageModel.fromJson(data);
          updateConversationFromMessage(message);
        } catch (e) {
          if (kDebugMode) {
            print('DEBUG InboxController: Error parsing message from Pusher: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG InboxController: Error handling Pusher event: $e');
      }
    }
  }

  /// Update conversation list from incoming message (real-time)
  void updateConversationFromMessage(MessageModel message) {
    final currentUserId = UserInfo.userId;
    if (currentUserId == null) return;

    // Determine the other user in the conversation
    final otherUserId = message.fromUserId == currentUserId 
        ? message.toUserId 
        : message.fromUserId;

    // Find existing conversation
    final index = conversations.indexWhere((c) => c.receiver.id == otherUserId);

    if (index != -1) {
      // Update existing conversation
      final existing = conversations[index];
      
      // Create updated conversation with latest message
      final updated = ConversationItemModel(
        id: message.id,
        fromUserId: message.fromUserId,
        toUserId: message.toUserId,
        lastMessage: message.messageContent,
        createdAt: message.createdAt,
        isRead: message.isRead,
        receiver: existing.receiver, // Keep existing receiver info
      );

      // Remove from current position and insert at top (newest first)
      conversations.removeAt(index);
      conversations.insert(0, updated);

      if (kDebugMode) {
        print('DEBUG InboxController: Updated conversation for user $otherUserId (moved to top)');
      }
    } else {
      // New conversation - refresh inbox to get full receiver data
      fetchInbox();
    }
  }

  /// Group conversations by receiver.id (deduplicate)
  /// Returns unique conversations with latest message per receiver
  List<ConversationItemModel> _groupByReceiver(List<ConversationItemModel> rawList) {
    final Map<int, ConversationItemModel> uniqueConversations = {};

    for (var item in rawList) {
      final receiverId = item.receiver.id;

      // If conversation exists, keep the one with latest message
      if (uniqueConversations.containsKey(receiverId)) {
        final existing = uniqueConversations[receiverId]!;
        if (item.createdAt.isAfter(existing.createdAt)) {
          uniqueConversations[receiverId] = item;
        }
      } else {
        uniqueConversations[receiverId] = item;
      }
    }

    // Convert to list and sort by createdAt DESC (newest first)
    final result = uniqueConversations.values.toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  /// Fetch inbox/conversation list
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
      errorMessage.value = 'User not logged in';
      isLoading.value = false;
      return;
    }

    if (kDebugMode) {
      print('✅ [fetchInbox] Token found (length: ${token.length})');
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (kDebugMode) {
        print('🔄 [fetchInbox] Calling MessageApiService.fetchInbox()...');
      }
      
      final rawList = await MessageApiService.fetchInbox(token: token);
      
      if (kDebugMode) {
        print('✅ [fetchInbox] API returned ${rawList.length} raw messages');
      }
      
      // Group by receiver.id to show ONE conversation per user
      final uniqueConversations = _groupByReceiver(rawList);
      
      if (kDebugMode) {
        print('✅ [fetchInbox] Grouped into ${uniqueConversations.length} unique conversations');
        for (var conv in uniqueConversations) {
          print('   - User ${conv.receiver.id} (${conv.receiver.fullname}): "${conv.lastMessage}"');
        }
      }
      
      conversations.value = uniqueConversations;

      if (kDebugMode) {
        print('✅ [fetchInbox] Conversations list updated (length: ${conversations.length})');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      errorMessage.value = e is MessageApiException 
          ? e.message 
          : 'Failed to load conversations';
      
      if (kDebugMode) {
        print('❌ [fetchInbox] Error: $e');
        print('   Stack trace: $stackTrace');
        print('═══════════════════════════════════════════════════════════');
      }
      
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull to refresh
  @override
  Future<void> refresh() async {
    await fetchInbox();
  }

  /// Navigate to conversation
  void openConversation(ConversationItemModel conversation) {
    Get.toNamed(
      AppRoutes.conversation,
      arguments: {
        'toUserId': conversation.receiver.id,
        'receiverName': conversation.receiver.fullname,
        'receiverAvatar': conversation.receiver.profileImage,
      },
    );
  }
}
