import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../services/message_api_service.dart';
import '../services/pusher_service.dart';
import '../services/user_info.dart';
import '../core/controllers/app_controller.dart';
import 'inbox_controller.dart';

/// Controller for managing chat/conversation state and real-time messaging
class ChatController extends GetxController {
  // State
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isSending = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // User IDs
  int? currentUserId;
  int? toUserId;
  String? receiverName;
  String? receiverAvatar;

  // Duplicate protection
  final Set<int> receivedMessageIds = <int>{};
  
  // Stream subscription
  StreamSubscription<MessageModel>? _pusherSubscription;
  
  // CRITICAL: NO polling timer - removed completely
  // Realtime updates come ONLY from Pusher

  @override
  void onClose() {
    _pusherSubscription?.cancel();
    messages.clear();
    receivedMessageIds.clear();
    super.onClose();
  }

  /// Initialize chat with target user and load conversation history
  /// 
  /// [toUserId] - ID of user to chat with
  /// [receiverName] - Display name of receiver (optional)
  /// [receiverAvatar] - Avatar URL of receiver (optional)
  Future<void> init({
    required int toUserId,
    String? receiverName,
    String? receiverAvatar,
  }) async {
    final currentUser = UserInfo.userId;
    if (currentUser == null) {
      errorMessage.value = 'User not logged in';
      return;
    }

    currentUserId = currentUser;
    this.toUserId = toUserId;
    this.receiverName = receiverName;
    this.receiverAvatar = receiverAvatar;

    errorMessage.value = '';
    messages.clear();
    receivedMessageIds.clear();

    // Load conversation history
    await loadConversation();

    // Connect to Pusher and subscribe to real-time events
    await _connectPusher();
  }

  /// Load conversation history from API
  /// 
  /// CRITICAL: Called ONCE on init
  /// CRITICAL: Never called again (Pusher handles new messages)
  /// Merges with existing messages without duplicates
  Future<void> loadConversation() async {
    if (toUserId == null) return;

    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'User not logged in';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final history = await MessageApiService.fetchConversation(
        token: token,
        toUserId: toUserId!,
      );

      // Merge with existing messages (avoid duplicates)
      final existingIds = receivedMessageIds.toSet();
      final newMessages = <MessageModel>[];
      
      for (var msg in history) {
        if (!existingIds.contains(msg.id)) {
          newMessages.add(msg);
          receivedMessageIds.add(msg.id);
        }
      }

      // Combine existing and new messages, then sort
      final allMessages = [...messages, ...newMessages];
      allMessages.sort((a, b) {
        final timeCompare = a.createdAt.compareTo(b.createdAt);
        if (timeCompare != 0) return timeCompare;
        return a.id.compareTo(b.id);
      });

      messages.value = allMessages;

      if (kDebugMode) {
        print('DEBUG ChatController.loadConversation: Loaded ${history.length} messages, ${newMessages.length} new, total: ${allMessages.length}');
      }
    } catch (e) {
      errorMessage.value = e is MessageApiException 
          ? e.message 
          : 'Failed to load conversation';
      
      if (kDebugMode) {
        print('DEBUG ChatController.loadConversation: Error - $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Connect to Pusher and set up event listeners
  /// 
  /// CRITICAL: NO fallback polling
  /// CRITICAL: If Pusher fails, app continues without real-time (graceful degradation)
  Future<void> _connectPusher() async {
    if (currentUserId == null) {
      if (kDebugMode) {
        print('DEBUG ChatController._connectPusher: ❌ currentUserId is null - cannot connect');
      }
      return;
    }

    try {
      final pusherService = PusherService();
      
      if (kDebugMode) {
        print('DEBUG ChatController._connectPusher: Connecting to Pusher for user $currentUserId');
        print('DEBUG ChatController._connectPusher: Pusher isConnected: ${pusherService.isConnected}');
      }
      
      // Connect to Pusher if not already connected
      if (!pusherService.isConnected) {
        if (kDebugMode) {
          print('DEBUG ChatController._connectPusher: Pusher not connected - calling connect()');
        }
        await pusherService.connect(currentUserId: currentUserId!);
      } else {
        if (kDebugMode) {
          print('DEBUG ChatController._connectPusher: Pusher already connected');
        }
      }

      // CRITICAL: Cancel previous subscription if exists
      if (_pusherSubscription != null) {
        if (kDebugMode) {
          print('DEBUG ChatController._connectPusher: Cancelling previous subscription');
        }
        await _pusherSubscription?.cancel();
        _pusherSubscription = null;
      }

      // Listen to Pusher incoming messages (MessageModel stream)
      if (kDebugMode) {
        print('DEBUG ChatController._connectPusher: Setting up message listener');
        print('   Using incomingMessages stream (MessageModel objects)');
      }
      
      _pusherSubscription = pusherService.incomingMessages.listen(
        (message) {
          if (kDebugMode) {
            print('═══════════════════════════════════════════════════════════');
            print('📨 [CHECKPOINT 4] ✅ MESSAGE RECEIVED IN ChatController LISTENER');
            print('   Message ID: ${message.id}');
            print('   From User ID: ${message.fromUserId}');
            print('   To User ID: ${message.toUserId}');
            print('   Content: ${message.messageContent.length > 50 ? message.messageContent.substring(0, 50) + "..." : message.messageContent}');
            print('═══════════════════════════════════════════════════════════');
          }
          _handleIncomingMessage(message);
        },
        onError: (error) {
          if (kDebugMode) {
            print('DEBUG ChatController._connectPusher: ❌ Stream error: $error');
          }
        },
        onDone: () {
          if (kDebugMode) {
            print('DEBUG ChatController._connectPusher: ⚠️ Stream closed');
          }
        },
        cancelOnError: false, // Keep listening even on error
      );

      if (kDebugMode) {
        print('DEBUG ChatController._connectPusher: ✅ Pusher connected and listening for user $currentUserId, conversation with user $toUserId');
      }
      
      // CRITICAL: NO fallback polling - removed completely
      // Realtime updates come ONLY from Pusher
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('DEBUG ChatController._connectPusher: ❌ Pusher connection error - $e');
        print('DEBUG ChatController._connectPusher: Stack trace: $stackTrace');
      }
      // CRITICAL: Do NOT start polling - graceful degradation
      // User can manually refresh if needed
    }
  }

  /// Handle incoming message from Pusher
  /// 
  /// CRITICAL: Filters messages to show ONLY messages for this conversation
  /// Message is shown if:
  /// - FROM other user TO current user (incoming)
  /// - FROM current user TO other user (outgoing)
  void _handleIncomingMessage(MessageModel message) {
    try {
      if (kDebugMode) {
        print('🔍 [CHECKPOINT 5] Processing incoming message');
        print('   Message ID: ${message.id}');
        print('   From User ID: ${message.fromUserId}');
        print('   To User ID: ${message.toUserId}');
        print('   Current User ID: $currentUserId');
        print('   Other User ID (toUserId): $toUserId');
      }
        
      // CRITICAL: Check if this message is for THIS conversation
      // Message must be between currentUserId and toUserId
      if (toUserId == null || currentUserId == null) {
        if (kDebugMode) {
          print('❌ [CHECKPOINT 5] ❌ Conversation not initialized (toUserId: $toUserId, currentUserId: $currentUserId)');
        }
        return;
      }
        
      // Message is for this conversation if:
      // 1. FROM other user TO current user (incoming message)
      // 2. FROM current user TO other user (outgoing message we sent)
      final isIncomingMessage = message.fromUserId == toUserId && message.toUserId == currentUserId;
      final isOutgoingMessage = message.fromUserId == currentUserId && message.toUserId == toUserId;
      final isForThisConversation = isIncomingMessage || isOutgoingMessage;
      
      if (kDebugMode) {
        print('   isIncomingMessage: $isIncomingMessage (fromUserId==toUserId && toUserId==currentUserId)');
        print('   isOutgoingMessage: $isOutgoingMessage (fromUserId==currentUserId && toUserId==toUserId)');
        print('   isForThisConversation: $isForThisConversation');
      }
      
      if (!isForThisConversation) {
        if (kDebugMode) {
          print('❌ [CHECKPOINT 6] ❌ Message NOT for this conversation - IGNORING');
          print('   This message is for a different conversation');
        }
        return;
      }
      
      if (kDebugMode) {
        print('✅ [CHECKPOINT 6] ✅ Message IS for this conversation');
        print('   Type: ${isIncomingMessage ? "INCOMING" : "OUTGOING"}');
      }
      
      // Duplicate protection
      if (receivedMessageIds.contains(message.id)) {
        if (kDebugMode) {
          print('⏭️  [CHECKPOINT 6] Duplicate message - already received (id: ${message.id})');
        }
        return;
      }

      receivedMessageIds.add(message.id);
      
      // Add message in sorted position (by createdAt asc)
      _addMessageSorted(message);

      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('🎉 [CHECKPOINT 7] ✅✅✅ MESSAGE ADDED SUCCESSFULLY ✅✅✅');
        print('   Message ID: ${message.id}');
        print('   Type: ${isIncomingMessage ? "INCOMING" : "OUTGOING"}');
        print('   Total messages: ${messages.length}');
        print('   ⚠️  UI should rebuild now via Obx');
        print('═══════════════════════════════════════════════════════════');
      }

      // Notify InboxController to update conversation preview
      _notifyInboxUpdate(message);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('DEBUG ChatController._handleIncomingMessage: ❌ Error handling message - $e');
        print('DEBUG ChatController._handleIncomingMessage: Stack trace: $stackTrace');
      }
    }
  }

  /// Add message to list in sorted order (by createdAt asc, then id asc)
  /// 
  /// CRITICAL: Uses messages.insert() which triggers Obx rebuild
  void _addMessageSorted(MessageModel message) {
    if (kDebugMode) {
      print('🔄 [CHECKPOINT 7] Adding message to list');
      print('   Message ID: ${message.id}');
      print('   Current messages.length: ${messages.length}');
    }
    
    // Find insertion index (sorted by createdAt asc, then id asc)
    int insertIndex = messages.length; // Default to end if newer than all
    
    for (int i = 0; i < messages.length; i++) {
      final existing = messages[i];
      final comparison = message.createdAt.compareTo(existing.createdAt);
      if (comparison < 0) {
        // message is older, insert before existing
        insertIndex = i;
        break;
      } else if (comparison == 0) {
        // Same timestamp, compare IDs
        if (message.id < existing.id) {
          // message has smaller ID, insert before existing
          insertIndex = i;
          break;
        }
      }
    }

    // CRITICAL: Use insert() which triggers Obx rebuild
    messages.insert(insertIndex, message);
    
    if (kDebugMode) {
      print('✅ [CHECKPOINT 7] ✅ Message added to list');
      print('   Inserted at index: $insertIndex');
      print('   New messages.length: ${messages.length}');
      print('   ⚠️  Obx should detect change and rebuild UI');
    }
  }

  /// Notify InboxController to update conversation preview
  void _notifyInboxUpdate(MessageModel message) {
    try {
      if (Get.isRegistered<InboxController>()) {
        final inboxController = Get.find<InboxController>();
        inboxController.updateConversationFromMessage(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ChatController: Error notifying inbox: $e');
      }
    }
  }

  /// Handle incoming message from real-time (hook for Pusher integration)
  /// 
  /// TODO: Backend must broadcast Pusher event to channel "private-user.{userId}" or similar
  /// Flutter should subscribe using key+cluster only (no secret in Flutter)
  void onIncomingMessage(MessageModel message) {
    if (receivedMessageIds.contains(message.id)) {
      return; // Duplicate
    }

    receivedMessageIds.add(message.id);
    _addMessageSorted(message);
    _notifyInboxUpdate(message);
  }

  /// Send a message
  /// 
  /// [content] - Message content
  /// 
  /// Returns true on success, false on failure
  Future<bool> sendMessage(String content) async {
    if (kDebugMode) {
      print('DEBUG ChatController.sendMessage: Starting - content: "$content"');
      print('DEBUG ChatController.sendMessage: toUserId: $toUserId, currentUserId: $currentUserId');
    }
    
    if (content.trim().isEmpty) {
      errorMessage.value = 'Message cannot be empty';
      return false;
    }

    if (toUserId == null || currentUserId == null) {
      errorMessage.value = 'Chat not initialized';
      return false;
    }

    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'User not logged in';
      return false;
    }

    // Prevent sending to self
    if (toUserId == currentUserId) {
      errorMessage.value = 'Cannot send message to yourself';
      return false;
    }

    isSending.value = true;
    errorMessage.value = '';

    // Create temporary message for optimistic update
    final tempMessage = MessageModel.temporary(
      fromUserId: currentUserId!,
      toUserId: toUserId!,
      messageContent: content.trim(),
    );

    // Add temporary message to end of list
    messages.add(tempMessage);
    receivedMessageIds.add(tempMessage.id);

    try {
      // Send via REST API
      final sentMessage = await MessageApiService.sendMessage(
        token: token,
        toUserId: toUserId!,
        content: content.trim(),
      );

      // Replace temporary message with confirmed message
      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        messages[index] = sentMessage;
      } else {
        // If not found, add as new
        messages.add(sentMessage);
      }

      // Update received IDs
      receivedMessageIds.remove(tempMessage.id);
      receivedMessageIds.add(sentMessage.id);

      isSending.value = false;
      
      if (kDebugMode) {
        print('DEBUG ChatController.sendMessage: Success - message ID: ${sentMessage.id}, messages.length: ${messages.length}');
      }

      // Notify InboxController to update conversation preview
      _notifyInboxUpdate(sentMessage);
      
      return true;
    } catch (e) {
      // Remove failed message
      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        messages.removeAt(index);
      }

      errorMessage.value = e is MessageApiException 
          ? e.message 
          : 'Failed to send message';
      
      isSending.value = false;
      
      // Show error to user
      final appController = Get.find<AppController>();
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  /// Clear chat state
  /// 
  /// CRITICAL: Called on screen dispose
  void clearChat() {
    _pusherSubscription?.cancel();
    _pusherSubscription = null;
    messages.clear();
    receivedMessageIds.clear();
    errorMessage.value = '';
    isSending.value = false;
    isLoading.value = false;
  }
}
