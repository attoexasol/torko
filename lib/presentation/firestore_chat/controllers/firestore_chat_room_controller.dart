import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/core/repositories/chat_repository.dart';
import 'package:torko/core/repositories/user_repository.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/firestore/firestore_message.dart';
import 'package:torko/core/utils/app_logger.dart';
import 'package:torko/data/models/firestore/firestore_user.dart';

/// Controller for Firestore chat room.
/// Manages selected conversationId, message stream, send message, mark seen.
class FirestoreChatRoomController extends GetxController {
  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();

  final RxString conversationId = ''.obs;
  final RxString otherUid = ''.obs;
  final Rx<FirestoreUser?> otherUser = Rx<FirestoreUser?>(null);
  final RxList<FirestoreMessage> messages = <FirestoreMessage>[].obs;
  final RxBool isSending = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<FirestoreMessage>>? _messagesSubscription;

  String? get myUid => UserInfo.myUidString;

  static String _maskUid(String? uid) =>
      uid == null || uid.isEmpty ? 'null' : 'len=${uid.length}';

  @override
  void onInit() {
    super.onInit();
  }

  /// Init chat with existing conversation (from list)
  void initChat(String cid, String peerUid) {
    final normalizedPeer = peerUid.isNotEmpty ? normalizeUserId(peerUid) : '';
    conversationId.value = cid;
    otherUid.value = normalizedPeer;
    error.value = '';
    _loadOtherUser(normalizedPeer);
    _subscribeMessages();
    _markSeen();
  }

  /// Init new chat with peer (creates conversation if needed)
  Future<void> initNewChat(String peerUid) async {
    final uid = myUid;
    if (uid == null) return;
    final normalizedPeer = normalizeUserId(peerUid);
    final cid = buildConversationId(uid, normalizedPeer);
    await _chatRepo.createConversationIfNotExists(uid, normalizedPeer);
    initChat(cid, normalizedPeer);
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    super.onClose();
  }

  void _loadOtherUser(String uid) async {
    if (uid.isEmpty) return;
    try {
      final u = await _userRepo.getUser(uid);
      otherUser.value = u;
    } catch (_) {
      otherUser.value = null;
    }
  }

  void _subscribeMessages() {
    final cid = conversationId.value;
    if (cid.isEmpty) return;

    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepo.messagesStream(cid).listen(
      (list) {
        if (!isClosed) {
          // Merge stream with optimistic messages (prevent duplicates)
          final merged = _mergeStreamWithOptimistic(list);
          _applyIncrementalUpdate(merged);
        }
      },
      onError: (e) {
        if (!isClosed) error.value = AppLogger.toUserMessage(e);
      },
    );
  }

  Future<void> _markSeen() async {
    final uid = myUid;
    final cid = conversationId.value;
    if (uid == null || cid.isEmpty) return;
    await _chatRepo.markConversationSeen(cid, uid);
  }

  Future<bool> sendMessage(String text) async {
    final t = text.trim();
    if (t.isEmpty) return false;

    final uid = myUid;
    final cid = conversationId.value;
    final toId = otherUid.value;

    if (uid == null || cid.isEmpty || toId.isEmpty) {
      error.value = 'Chat not initialized';
      return false;
    }

    isSending.value = true;
    error.value = '';

    try {
      await _chatRepo.createConversationIfNotExists(uid, toId);
      await _chatRepo.sendTextMessage(cid, uid, toId, t);
      // Optimistic update: add message immediately (stream may be delayed)
      final optimistic = FirestoreMessage.optimistic(
        fromId: uid,
        toId: toId,
        text: t,
      );
      messages.insert(0, optimistic);
      return true;
    } catch (e) {
      error.value = AppLogger.toUserMessage(e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Merge stream list with unmatched optimistic messages. Prevents duplicates when backend echo arrives.
  List<FirestoreMessage> _mergeStreamWithOptimistic(
      List<FirestoreMessage> streamList) {
    final optimistics = messages.where((m) => m.id.startsWith('temp_')).toList();
    if (optimistics.isEmpty) return streamList;
    final result = List<FirestoreMessage>.from(streamList);
    for (final opt in optimistics) {
      final hasMatch = result.any((m) => _matchesOptimistic(m, opt));
      if (!hasMatch) result.insert(0, opt);
    }
    result.sort((a, b) {
      final ta = a.createdAt ?? DateTime(0);
      final tb = b.createdAt ?? DateTime(0);
      return tb.compareTo(ta);
    });
    return result;
  }

  /// Only update when content changed (avoids full replace flicker).
  void _applyIncrementalUpdate(List<FirestoreMessage> merged) {
    if (merged.length == messages.length &&
        merged.every((m) => messages.any((e) =>
            e.id == m.id && e.text == m.text && e.fromId == m.fromId))) {
      return;
    }
    messages.assignAll(merged);
  }

  bool _matchesOptimistic(FirestoreMessage real, FirestoreMessage opt) {
    return real.fromId == opt.fromId &&
        real.text == opt.text &&
        (real.createdAt != null && opt.createdAt != null &&
            real.createdAt!.difference(opt.createdAt!).inSeconds.abs() < 15);
  }

  void clear() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    conversationId.value = '';
    otherUid.value = '';
    otherUser.value = null;
    messages.clear();
    error.value = '';
  }
}
