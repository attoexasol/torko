import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/core/repositories/chat_repository.dart';
import 'package:torko/core/services/firestore_chat_service.dart';
import 'package:torko/core/services/message_api_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/message_model.dart';

/// Realtime chat controller via Firestore snapshots.
/// - Messages: stream from conversations/{groupId}/messages
/// - Send: REST POST /api/messages/send (backend writes to Firestore)
/// - No manual reload; Firestore listener updates UI
class ChatController extends GetxController {
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxInt messagesVersion = 0.obs;
  final RxBool isSending = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int? currentUserId;
  int? activeUserId;
  int? toUserId;
  String? receiverName;
  String? receiverAvatar;
  String? _activeGroupId;

  final FirestoreChatService _firestoreChat = FirestoreChatService();
  final ChatRepository _chatRepo = ChatRepository();
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _cancelMessagesSubscription();
    super.onClose();
  }

  void _cancelMessagesSubscription() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _activeGroupId = null;
  }

  /// Open conversation: subscribe to Firestore messages stream.
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
    final groupId = buildConversationId(currentUser.toString(), toUserId.toString());
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'User not logged in';
      return;
    }

    // Same chat already active
    if (activeUserId == toUserId && _activeGroupId == groupId) {
      this.toUserId = toUserId;
      this.receiverName = receiverName;
      this.receiverAvatar = receiverAvatar;
      return;
    }

    final previousGroupId = _activeGroupId;
    _cancelMessagesSubscription();

    activeUserId = toUserId;
    this.toUserId = toUserId;
    this.receiverName = receiverName;
    this.receiverAvatar = receiverAvatar;
    errorMessage.value = '';

    if (previousGroupId != null && previousGroupId != groupId) {
      messages.clear();
      messagesVersion.value++;
    }

    isLoading.value = true;
    _activeGroupId = groupId;

    _messagesSubscription = _firestoreChat.messagesStream(groupId).listen(
      (list) {
        // Merge stream data with optimistic messages (keep optimistic until backend echo)
        final merged = _mergeStreamWithOptimistic(list);
        messages.assignAll(merged);
        messagesVersion.value++;
        isLoading.value = false;
      },
      onError: (e) {
        errorMessage.value = 'Failed to load messages';
        isLoading.value = false;
      },
      cancelOnError: false,
    );
  }

  /// Send via REST. Optimistic update: add message immediately so UI shows it without waiting for stream.
  Future<bool> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty) {
      errorMessage.value = 'Message cannot be empty';
      return false;
    }

    final tId = toUserId;
    final cId = currentUserId;
    final token = UserInfo.apiToken;

    if (tId == null || cId == null || token == null || token.isEmpty) {
      errorMessage.value = 'Chat not initialized';
      return false;
    }

    isSending.value = true;
    errorMessage.value = '';

    try {
      await MessageApiService.sendMessage(
        token: token,
        toUserId: tId,
        content: text,
      );
      // Optimistic update: add message to list immediately (stream may be delayed)
      final optimistic = MessageModel.temporary(
        fromUserId: cId,
        toUserId: tId,
        messageContent: text,
      ).copyWith(isSending: false);
      messages.add(optimistic);
      messagesVersion.value++;

      // Dual-write to Firestore: ensures User B receives in real-time via Firestore stream.
      // REST persists to Laravel DB; Firestore propagates to all listeners on same conversation.
      final groupId = _activeGroupId ?? buildConversationId(cId.toString(), tId.toString());
      if (groupId.isNotEmpty) {
        try {
          await _chatRepo.createConversationIfNotExists(cId.toString(), tId.toString());
          await _chatRepo.sendTextMessage(groupId, cId.toString(), tId.toString(), text);
        } catch (_) {
          // Optimistic already shown; Firestore write failure does not block sender
        }
      }
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to send message';
      Get.snackbar(
        Get.find<AppController>().language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Merge stream list with unmatched optimistic messages. Prevents duplicates when backend echo arrives.
  /// Deduplicates stream messages (e.g. if both Laravel and Flutter write to Firestore).
  List<MessageModel> _mergeStreamWithOptimistic(List<MessageModel> streamList) {
    final deduped = _deduplicateStreamMessages(streamList);
    final optimistics = messages.where((m) => m.id < 0).toList();
    if (optimistics.isEmpty) return deduped;
    final result = List<MessageModel>.from(deduped);
    for (final opt in optimistics) {
      final hasMatch = result.any((m) => _matchesOptimistic(m, opt));
      if (!hasMatch) result.add(opt);
    }
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }

  /// Deduplicate stream messages (same content+from+createdAt within 2s) - handles dual-write from Laravel+Flutter.
  List<MessageModel> _deduplicateStreamMessages(List<MessageModel> list) {
    if (list.length <= 1) return list;
    final result = <MessageModel>[];
    for (final m in list) {
      final isDup = result.any((r) =>
          r.fromUserId == m.fromUserId &&
          r.messageContent == m.messageContent &&
          r.createdAt.difference(m.createdAt).inSeconds.abs() < 2);
      if (!isDup) result.add(m);
    }
    return result;
  }

  bool _matchesOptimistic(MessageModel real, MessageModel opt) {
    return real.fromUserId == opt.fromUserId &&
        real.messageContent == opt.messageContent &&
        real.createdAt.difference(opt.createdAt).inSeconds.abs() < 15;
  }

  void clearChat() {
    _cancelMessagesSubscription();
    activeUserId = null;
    toUserId = null;
    receiverName = null;
    receiverAvatar = null;
    messages.clear();
    errorMessage.value = '';
    isSending.value = false;
    isLoading.value = false;
    messagesVersion.value++;
  }
}
