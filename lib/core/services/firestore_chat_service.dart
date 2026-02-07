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
  /// groupId format: "65_81" (buildConversationId).
  Stream<List<MessageModel>> messagesStream(String groupId) {
    return _chatRepo
        .messagesStream(groupId)
        .map((list) {
          // ChatRepository returns desc; reverse for ascending (oldest first)
          final reversed = list.reversed.toList();
          return reversed
              .map((m) => _firestoreMessageToMessageModel(m))
              .whereType<MessageModel>()
              .toList();
        });
  }

  /// Stream of inbox threads for current user.
  /// currentUid: numeric string e.g. "65".
  Stream<List<InboxThreadModel>> inboxStream(String currentUid) {
    return _chatRepo.conversationsStream(currentUid).asyncMap((convs) async {
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

  /// Map FirestoreMessage to MessageModel (int ids for compatibility with UI).
  static MessageModel? _firestoreMessageToMessageModel(FirestoreMessage m) {
    final fromId = _parseInt(m.fromId);
    final toId = _parseInt(m.toId);
    if (fromId <= 0 || toId <= 0) return null;

    final createdAt = m.createdAt ?? DateTime.now();
    final msgId = int.tryParse(m.id) ?? m.id.hashCode.abs();
    final isRead = m.seenBy.isNotEmpty ? 1 : 0;

    return MessageModel(
      id: msgId,
      fromUserId: fromId,
      toUserId: toId,
      messageContent: m.text,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: createdAt,
      sender: null,
      receiver: null,
    );
  }
}
