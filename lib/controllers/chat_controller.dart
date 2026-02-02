import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/message_model.dart';
import '../services/message_api_service.dart';
import '../services/reverb_service.dart';
import '../services/user_info.dart';
import '../core/controllers/app_controller.dart';
import 'inbox_controller.dart';

/// PRODUCTION REALTIME CHAT CONTROLLER (FIXED)
///
/// Fixes included:
/// ✅ Prevent duplicate Reverb callback registration
/// ✅ Proper cleanup in onClose()
/// ✅ Safer conversation switching + load-once per user
/// ✅ Stronger de-duplication (temp ids vs real ids)
/// ✅ Less refresh spam (assignAll / insert + sort only when needed)
/// ✅ Inbox notify remains incremental
///
/// NOTE:
/// - If you want this controller to be "permanent", register with:
///   Get.put(ChatController(), permanent: true);
class ChatController extends GetxController {
  // =========================
  // Reactive State
  // =========================
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  /// If your UI relies on this, keep it. Otherwise you can remove it.
  final RxInt messagesVersion = 0.obs;

  final RxBool isSending = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // =========================
  // Chat Session State
  // =========================
  int? currentUserId;
  int? activeUserId; // chat partner
  int? toUserId;

  String? receiverName;
  String? receiverAvatar;

  /// Dedupe for realtime + history + optimistic send.
  /// Store both real ids and temporary ids.
  final Set<int> receivedMessageIds = <int>{};

  /// Track which conversations were loaded at least once
  final Map<int, bool> _conversationLoaded = <int, bool>{};

  final ReverbService _reverb = ReverbService();

  bool _callbackRegistered = false;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    _registerRealtimeCallbackOnce();

    if (kDebugMode) {
      debugPrint('[CHAT] onInit | instance=$hashCode');
    }
  }

  void _registerRealtimeCallbackOnce() {
    if (_callbackRegistered) return;
    _callbackRegistered = true;

    if (kDebugMode) debugPrint('[CHAT] registering realtime callback');

    _reverb.onMessageReceived = (message) {
      if (kDebugMode) {
        debugPrint('[CHAT] REALTIME callback | id=${message.id}');
      }
      _handleIncomingMessage(message);
    };
  }

  // =========================
  // CHAT INITIALIZATION
  // =========================
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

    currentUserId = currentUser;

    // same chat already active + already loaded
    if (activeUserId == toUserId && _conversationLoaded[toUserId] == true) {
      this.toUserId = toUserId;
      this.receiverName = receiverName;
      this.receiverAvatar = receiverAvatar;
      return;
    }

    final previousUser = activeUserId;

    activeUserId = toUserId;
    this.toUserId = toUserId;
    this.receiverName = receiverName;
    this.receiverAvatar = receiverAvatar;

    errorMessage.value = '';

    // switching conversation -> clear visible list + dedupe set
    if (previousUser != null && previousUser != toUserId) {
      messages.clear();
      receivedMessageIds.clear();
      messagesVersion.value++;

      if (kDebugMode) {
        debugPrint('[CHAT] switched conversation $previousUser → $toUserId');
      }
    }

    // load conversation only once per user
    if (_conversationLoaded[toUserId] != true) {
      final ok = await _loadConversationOnce(toUserId);
      if (ok) {
        _conversationLoaded[toUserId] = true;
      }
    }
  }

  // =========================
  // INITIAL HISTORY LOAD
  // =========================
  Future<bool> _loadConversationOnce(int userId) async {
    final token = UserInfo.apiToken;

    if (token == null || token.isEmpty) {
      errorMessage.value = 'User not logged in';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final history = await MessageApiService.fetchConversation(
        token: token,
        toUserId: userId,
      );

      // dedupe store
      for (final msg in history) {
        receivedMessageIds.add(msg.id);
      }

      // Ensure consistent ordering
      history.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      messages.assignAll(history);
      messagesVersion.value++;

      if (kDebugMode) {
        debugPrint('[CHAT] history loaded: ${messages.length}');
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to load conversation';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // REALTIME MESSAGE HANDLER
  // =========================
  void _handleIncomingMessage(MessageModel message) {
    final aId = activeUserId;
    final cId = currentUserId;

    if (aId == null || cId == null) return;

    final bool isIncoming =
        message.fromUserId == aId && message.toUserId == cId;
    final bool isOutgoing =
        message.fromUserId == cId && message.toUserId == aId;

    // ignore other conversations
    if (!isIncoming && !isOutgoing) return;

    // Prevent duplicates
    if (receivedMessageIds.contains(message.id)) {
      if (kDebugMode) debugPrint('[CHAT] duplicate ignored: ${message.id}');
      return;
    }

    receivedMessageIds.add(message.id);

    messages.add(message);

    // Keep sorted by createdAt (cheap enough for chat sizes)
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    messagesVersion.value++;

    if (kDebugMode) {
      debugPrint('[CHAT] message added realtime: ${message.id}');
    }

    _notifyInbox(message);
  }

  // =========================
  // SEND MESSAGE
  // =========================
  Future<bool> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty) {
      errorMessage.value = 'Message cannot be empty';
      return false;
    }

    final tId = toUserId;
    final cId = currentUserId;

    if (tId == null || cId == null) {
      errorMessage.value = 'Chat not initialized';
      return false;
    }

    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'User not logged in';
      return false;
    }

    isSending.value = true;
    errorMessage.value = '';

    // Optimistic UI message (temporary id)
    final temp = MessageModel.temporary(
      fromUserId: cId,
      toUserId: tId,
      messageContent: text,
    );

    messages.add(temp);
    receivedMessageIds.add(temp.id);
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    messagesVersion.value++;

    try {
      final sent = await MessageApiService.sendMessage(
        token: token,
        toUserId: tId,
        content: text,
      );

      // Replace temp with real message if temp still exists
      final tempIndex = messages.indexWhere((m) => m.id == temp.id);
      if (tempIndex != -1) {
        messages[tempIndex] = sent;
      } else {
        // if temp is missing for some reason, just add
        messages.add(sent);
      }

      // Update dedupe set
      receivedMessageIds.remove(temp.id);
      receivedMessageIds.add(sent.id);

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      messagesVersion.value++;

      _notifyInbox(sent);

      return true;
    } catch (e) {
      // rollback optimistic
      messages.removeWhere((m) => m.id == temp.id);
      receivedMessageIds.remove(temp.id);

      messagesVersion.value++;

      errorMessage.value = 'Failed to send message';

      final appController = Get.find<AppController>();

      Get.snackbar(
        appController.language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isSending.value = false;
    }
  }

  // =========================
  // INBOX UPDATE
  // =========================
  void _notifyInbox(MessageModel message) {
    if (!Get.isRegistered<InboxController>()) return;
    final inbox = Get.find<InboxController>();
    inbox.updateConversationFromMessage(message);
  }

  // =========================
  // CLEAR STATE (LOGOUT)
  // =========================
  void clearChat() {
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
    messagesVersion.value++;
  }

  // =========================
  // CLEANUP
  // =========================
  @override
  void onClose() {
    if (kDebugMode) debugPrint('[CHAT] onClose - cleanup');

    // prevent callback leak (especially when controller is recreated)
    if (_reverb.onMessageReceived != null) {
      _reverb.onMessageReceived = null;
    }

    super.onClose();
  }
}
