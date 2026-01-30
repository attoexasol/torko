import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../services/message_api_service.dart';
import '../services/pusher_service.dart';
import '../services/user_info.dart';
import '../core/controllers/app_controller.dart';
import 'inbox_controller.dart';

// ⚠️ REALTIME RULE:
// DO NOT call API after Pusher events. STREAM-ONLY updates.
// API only: initChat (loadConversationOnce), sendMessage.
//
// ⚠️ PERMANENT CONTROLLER: stream listener attached ONCE in onInit.
class ChatController extends GetxController {
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isSending = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int? currentUserId;
  int? activeUserId;
  int? toUserId;
  String? receiverName;
  String? receiverAvatar;

  final Set<int> receivedMessageIds = <int>{};
  StreamSubscription<MessageModel>? _pusherSubscription;
  final Map<int, bool> _conversationLoaded = <int, bool>{};

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) debugPrint('[CHAT] onInit - attaching stream listener');
    _attachRealtimeListener();
  }

  /// Attach Pusher stream listener ONCE. Never call API from handler.
  void _attachRealtimeListener() {
    _pusherSubscription?.cancel();
    _pusherSubscription = null;

    _pusherSubscription = PusherService().incomingMessages.listen(
      (message) {
        if (kDebugMode) {
          debugPrint('[CHAT] REALTIME message | id=${message.id} from=${message.fromUserId} to=${message.toUserId}');
        }
        _handleIncomingMessage(message);
      },
      onError: (error) {
        if (kDebugMode) debugPrint('[CHAT] Stream error: $error');
      },
      cancelOnError: false,
    );

    if (kDebugMode) debugPrint('[CHAT] Stream listener attached');
  }

  @override
  void onClose() {
    if (kDebugMode) debugPrint('[CHAT] onClose (permanent, keeping state)');
    super.onClose();
  }

  /// Initialize chat for a specific user - protected against duplicate loads
  /// This method ensures API is called ONLY ONCE per conversation
  Future<void> initChat({
    required int toUserId,
    String? receiverName,
    String? receiverAvatar,
  }) async {
    final currentUser = UserInfo.userId;
    if (currentUser == null) {
      errorMessage.value = 'User not logged in';
      return;
    }

    if (activeUserId == toUserId && _conversationLoaded[toUserId] == true) {
      if (kDebugMode) {
        debugPrint('[CHAT] initChat skipped - already loaded for user $toUserId');
      }
      this.toUserId = toUserId;
      this.receiverName = receiverName;
      this.receiverAvatar = receiverAvatar;
      return;
    }

    final previousActiveUserId = activeUserId;
    currentUserId = currentUser;
    activeUserId = toUserId;
    this.toUserId = toUserId;
    this.receiverName = receiverName;
    this.receiverAvatar = receiverAvatar;

    errorMessage.value = '';

    if (previousActiveUserId != null && previousActiveUserId != toUserId) {
      messages.clear();
      receivedMessageIds.clear();
      if (kDebugMode) {
        debugPrint('[CHAT] switched conversation $previousActiveUserId -> $toUserId, cleared messages');
      }
    }

    // Load conversation ONLY if not already loaded
    if (_conversationLoaded[toUserId] != true) {
      await loadConversationOnce(toUserId);
      _conversationLoaded[toUserId] = true;
    }
    
    // Stream listener is already attached in constructor - no need to reconnect
  }

  /// Legacy init method - delegates to initChat for backward compatibility
  @Deprecated('Use initChat instead')
  Future<void> init({
    required int toUserId,
    String? receiverName,
    String? receiverAvatar,
  }) async {
    await initChat(
      toUserId: toUserId,
      receiverName: receiverName,
      receiverAvatar: receiverAvatar,
    );
  }

  /// Load conversation from API - called ONLY ONCE per conversation
  /// Protected by _conversationLoaded map
  Future<void> loadConversationOnce(int userId) async {
    if (kDebugMode) {
      debugPrint('[CHAT] loadConversationOnce for user $userId');
    }

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
        toUserId: userId,
      );

      final existingIds = receivedMessageIds.toSet();
      final newMessages = <MessageModel>[];
      
      for (var msg in history) {
        if (!existingIds.contains(msg.id)) {
          newMessages.add(msg);
          receivedMessageIds.add(msg.id);
        }
      }

      final allMessages = [...messages, ...newMessages];
      allMessages.sort((a, b) {
        final timeCompare = a.createdAt.compareTo(b.createdAt);
        if (timeCompare != 0) return timeCompare;
        return a.id.compareTo(b.id);
      });

      messages.value = allMessages;
      
      if (kDebugMode) {
        debugPrint('[CHAT] Conversation loaded - ${messages.length} messages');
      }
    } catch (e) {
      errorMessage.value = e is MessageApiException 
          ? e.message 
          : 'Failed to load conversation';
    } finally {
      isLoading.value = false;
    }
  }

  /// Legacy method - delegates to loadConversationOnce
  @Deprecated('Use loadConversationOnce instead')
  Future<void> loadConversation() async {
    if (toUserId == null) return;
    await loadConversationOnce(toUserId!);
  }

  /// Handle incoming message - INCREMENTAL UPDATE ONLY, NO API CALLS
  /// ⚠️ CRITICAL: This method MUST NEVER call loadConversation() or any API
  /// This is called from the permanent stream listener attached in constructor
  void _handleIncomingMessage(MessageModel message) {
    try {
      if (activeUserId == null || currentUserId == null) {
        // No active conversation - message will be handled by InboxController
        return;
      }
        
      // Filter: message must be for the active conversation
      final isIncomingMessage = message.fromUserId == activeUserId && message.toUserId == currentUserId;
      final isOutgoingMessage = message.fromUserId == currentUserId && message.toUserId == activeUserId;
      final isForThisConversation = isIncomingMessage || isOutgoingMessage;
      
      if (!isForThisConversation) {
        // Message is for a different conversation - ignore
        return;
      }
      
      if (receivedMessageIds.contains(message.id)) {
        if (kDebugMode) {
          debugPrint('[CHAT] Duplicate ignored: id=${message.id}');
        }
        return;
      }

      receivedMessageIds.add(message.id);

      if (!messages.any((m) => m.id == message.id)) {
        _addMessageSorted(message);
        messages.refresh();
        if (kDebugMode) {
          debugPrint('[CHAT] REALTIME message added | id=${message.id} total=${messages.length}');
        }
      }

      // Notify inbox
      _notifyInboxUpdate(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CHAT] Error handling message: $e');
      }
    }
  }

  void _addMessageSorted(MessageModel message) {
    int insertIndex = messages.length;
    
    for (int i = 0; i < messages.length; i++) {
      final existing = messages[i];
      final comparison = message.createdAt.compareTo(existing.createdAt);
      if (comparison < 0) {
        insertIndex = i;
        break;
      } else if (comparison == 0) {
        if (message.id < existing.id) {
          insertIndex = i;
          break;
        }
      }
    }

    final newMessages = List<MessageModel>.from(messages);
    newMessages.insert(insertIndex, message);
    messages.value = newMessages;
  }

  void _notifyInboxUpdate(MessageModel message) {
    try {
      if (Get.isRegistered<InboxController>()) {
        final inboxController = Get.find<InboxController>();
        inboxController.updateConversationFromMessage(message);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CHAT] Error notifying inbox: $e');
      }
    }
  }

  Future<bool> sendMessage(String content) async {
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

    if (toUserId == currentUserId) {
      errorMessage.value = 'Cannot send message to yourself';
      return false;
    }

    isSending.value = true;
    errorMessage.value = '';

    final tempMessage = MessageModel.temporary(
      fromUserId: currentUserId!,
      toUserId: toUserId!,
      messageContent: content.trim(),
    );

    messages.add(tempMessage);
    receivedMessageIds.add(tempMessage.id);
    messages.refresh();

    try {
      final sentMessage = await MessageApiService.sendMessage(
        token: token,
        toUserId: toUserId!,
        content: content.trim(),
      );

      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        messages[index] = sentMessage;
      } else {
        messages.add(sentMessage);
      }

      receivedMessageIds.remove(tempMessage.id);
      receivedMessageIds.add(sentMessage.id);
      messages.refresh();

      isSending.value = false;
      _notifyInboxUpdate(sentMessage);
      
      return true;
    } catch (e) {
      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        messages.removeAt(index);
        messages.refresh();
      }

      errorMessage.value = e is MessageApiException 
          ? e.message 
          : 'Failed to send message';
      
      isSending.value = false;
      
      final appController = Get.find<AppController>();
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  /// Clear chat state - only called on logout or explicit reset
  /// Does NOT cancel stream subscription (controller is permanent)
  void clearChat() {
    if (kDebugMode) {
      debugPrint('[CHAT] clearChat - clearing state, keeping stream listener');
    }
    // DO NOT cancel subscription - controller is permanent
    activeUserId = null;
    toUserId = null;
    receiverName = null;
    receiverAvatar = null;
    messages.clear();
    receivedMessageIds.clear();
    _conversationLoaded.clear();
    errorMessage.value = '';
    isSending.value = false;
    isLoading.value = false;
  }
  
  /// Reset conversation state for a specific user (switching conversations)
  void resetConversation() {
    activeUserId = null;
    toUserId = null;
    receiverName = null;
    receiverAvatar = null;
    // Keep messages and loaded state - user might come back
  }
}
