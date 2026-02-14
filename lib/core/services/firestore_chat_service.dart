import 'package:torko/core/ids/user_id.dart';
import 'package:torko/core/repositories/chat_repository.dart';
import 'package:torko/core/repositories/user_repository.dart';
import 'package:torko/data/models/firestore/firestore_conversation.dart';
import 'package:torko/data/models/firestore/firestore_message.dart';
import 'package:torko/data/models/firestore/firestore_user.dart';
import 'package:torko/data/models/inbox_thread_model.dart';
import 'package:torko/data/models/message_model.dart';
import 'package:torko/data/models/message_row_model.dart';

/// Firestore chat service: exposes realtime streams for conversation messages
/// and inbox. Maps Firestore docs to app models (MessageModel, InboxThreadModel).
///
/// - Messages: conversations/{groupId}/messages, orderBy createdAt ascending
/// - Inbox: conversations where members arrayContains currentUid, orderBy updatedAt desc
///
/// Send remains via REST (MessageApiService.sendMessage). Backend must write to Firestore.
class FirestoreChatService {
  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();

  /// Stream of messages for a conversation, oldest first (ascending).
  Stream<List<MessageModel>> messagesStream(String groupId) {
    return _chatRepo.watchMessages(groupId).map((list) {
      return list
          .map((m) => _firestoreMessageToMessageModel(m, groupId))
          .whereType<MessageModel>()
          .toList();
    });
  }

  /// Stream of inbox threads for current user.
  Stream<List<InboxThreadModel>> inboxStream(String currentUid) {
    return _chatRepo.watchMyConversations(currentUid).asyncMap((convs) async {
      final results = <InboxThreadModel>[];
      for (final c in convs) {
        try {
          final otherUid = _otherMember(c.members, currentUid);
          if (otherUid == null || otherUid.isEmpty) continue;

          final otherUserId = int.tryParse(otherUid) ?? 0;
          if (otherUserId <= 0) continue;

          FirestoreUser? user;
          try {
            user = await _userRepo.getUser(otherUid);
          } catch (_) {}

          final lastTime = c.lastMessageAt ?? c.updatedAt ?? c.createdAt ?? DateTime.now();
          final unreadCount = c.unreadFor(currentUid);
          final isRead = unreadCount <= 0 ? 1 : 0;
          final currentUserId = _parseInt(currentUid);
          final lastSenderIdInt = _parseInt(c.lastSenderId);
          final fromUserId = lastSenderIdInt == currentUserId ? currentUserId : otherUserId;
          final toUserId = lastSenderIdInt == currentUserId ? otherUserId : currentUserId;

          final lastRow = MessageRowModel(
            id: 0,
            fromUserId: fromUserId,
            toUserId: toUserId,
            content: c.lastMessage,
            isRead: isRead,
            createdAt: lastTime,
            sender: null,
            receiver: null,
          );

          results.add(InboxThreadModel(
            otherUserId: otherUserId,
            otherName: user?.fullname ?? otherUid,
            otherAvatar: user?.profileImage,
            lastMessage: c.lastMessage,
            lastTime: lastTime,
            unreadCount: unreadCount,
            lastRow: lastRow,
          ));
        } catch (_) {
          // Skip malformed
        }
      }
      return results;
    });
  }

  /// Ensure conversation doc exists (write-first). Returns conversationId.
  /// DO NOT write friend user doc (users/{friendUid}) - causes PERMISSION_DENIED.
  /// Friend profile is read-only; only owner writes on login.
  Future<String> ensureConversationExists(
    String myUidString,
    String friendUidString,
  ) async {
    return _chatRepo.ensureConversation(myUidString, friendUidString);
  }

  static int _parseInt(String s) {
    if (s.isEmpty) return 0;
    return int.tryParse(s) ?? 0;
  }

  static String? _otherMember(List<String> members, String myUid) {
    final norm = normalizeUserId(myUid);
    for (final m in members) {
      try {
        if (normalizeUserId(m) != norm) return m;
      } catch (_) {}
    }
    return null;
  }

  /// Map FirestoreMessage to MessageModel. Supports senderId (new) and fromId/toId (legacy).
  static MessageModel? _firestoreMessageToMessageModel(
    FirestoreMessage m,
    String conversationId,
  ) {
    final senderStr = m.senderId.isNotEmpty ? m.senderId : m.fromId;
    final fromId = _parseInt(senderStr);
    if (fromId <= 0) return null;

    final parts = conversationId.split('_');
    final toIdStr = parts.length == 2
        ? (parts[0] == senderStr ? parts[1] : parts[0])
        : m.toId;
    final toId = _parseInt(toIdStr);

    final createdAt = m.createdAt ?? DateTime.now();
    final msgId = int.tryParse(m.id) ?? m.id.hashCode.abs();
    final isRead = m.seenBy.isNotEmpty ? 1 : 0;

    return MessageModel(
      id: msgId,
      fromUserId: fromId,
      toUserId: toId > 0 ? toId : 0,
      messageContent: m.text,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: createdAt,
      sender: null,
      receiver: null,
    );
  }
}
