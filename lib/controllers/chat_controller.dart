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
  StreamSubscription<Map<String, dynamic>>? _pusherSubscription;
  
  // Fallback polling timer (only if Pusher not connected)
  Timer? _pollTimer;

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
  Future<void> _connectPusher() async {
    if (currentUserId == null) return;

    try {
      final pusherService = PusherService();
      
      // Connect to Pusher if not already connected
      if (!pusherService.isConnected) {
        await pusherService.connect(currentUserId: currentUserId!);
      }

      // Listen to events
      _pusherSubscription = pusherService.onEventStream.listen((eventData) {
        _handlePusherEvent(eventData);
      });

      if (kDebugMode) {
        print('DEBUG ChatController: Pusher connected and listening');
      }

      // Start fallback polling ONLY if Pusher is not connected
      if (!pusherService.isConnected) {
        _startFallbackPolling();
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ChatController: Pusher connection error - $e');
      }
      // Start fallback polling if Pusher fails
      _startFallbackPolling();
    }
  }

  /// Start fallback polling timer (only if Pusher is not working)
  void _startFallbackPolling() {
    _pollTimer?.cancel();
    
    // Poll every 3 seconds while conversation is open
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (toUserId != null && !isLoading.value) {
        if (kDebugMode) {
          print('DEBUG ChatController: Fallback polling - checking for new messages');
        }
        await loadConversation();
      }
    });

    if (kDebugMode) {
      print('DEBUG ChatController: Fallback polling started (Pusher not available)');
    }
  }

  /// Stop fallback polling
  void _stopFallbackPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
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
        
        // Parse message from event data
        final message = MessageModel.fromJson(data);
        
        // Check if this message is for this conversation
        if (toUserId != null && 
            (message.toUserId == toUserId || message.fromUserId == toUserId)) {
          
          // Duplicate protection
          if (receivedMessageIds.contains(message.id)) {
            if (kDebugMode) {
              print('DEBUG ChatController: Duplicate message ignored (id: ${message.id})');
            }
            return;
          }

          receivedMessageIds.add(message.id);
          
          // Add message in sorted position (by createdAt asc)
          _addMessageSorted(message);

          if (kDebugMode) {
            print('DEBUG ChatController: Message received via Pusher - ID: ${message.id}, messages.length: ${messages.length}');
          }

          // Notify InboxController to update conversation preview
          _notifyInboxUpdate(message);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ChatController: Error handling Pusher event - $e');
      }
    }
  }

  /// Add message to list in sorted order (by createdAt asc, then id asc)
  void _addMessageSorted(MessageModel message) {
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

    messages.insert(insertIndex, message);
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
  void clearChat() {
    _stopFallbackPolling();
    _pusherSubscription?.cancel();
    _pusherSubscription = null;
    messages.clear();
    receivedMessageIds.clear();
    errorMessage.value = '';
    isSending.value = false;
    isLoading.value = false;
  }
}
