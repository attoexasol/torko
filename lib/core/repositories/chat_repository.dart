import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/data/models/firestore/firestore_conversation.dart';
import 'package:torko/data/models/firestore/firestore_message.dart';

/// Firestore chat repository.
/// conversations/{conversationId}, conversations/{id}/messages/{messageId}
/// All IDs are numeric strings (e.g. "65").
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  /// Stable conversation ID: sort two uids (normalized to numeric) then join with "_"
  /// e.g. "65" + "81" => "65_81"
  static String conversationId(String uid1, String uid2) {
    return buildConversationId(uid1, uid2);
  }

  /// Create conversation if it does not exist.
  Future<void> createConversationIfNotExists(String uid1, String uid2) async {
    final u1 = normalizeUserId(uid1);
    final u2 = normalizeUserId(uid2);
    final cid = buildConversationId(u1, u2);
    final ref = _conversations.doc(cid);
    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'members': [u1, u2],
      'lastMessage': '',
      'lastMessageType': 'text',
      'lastSenderId': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread': <String, int>{},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Inbox query: conversations where members arrayContains myUidString, orderBy updatedAt desc.
  /// myUid must be numeric string (e.g. "65"). Members in docs are List<String>.
  Stream<List<FirestoreConversation>> conversationsStream(String myUid) {
    final myUidString = normalizeUserId(myUid);
    return _conversations
        .where('members', arrayContains: myUidString)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
      final list = <FirestoreConversation>[];
      for (final d in snap.docs) {
        try {
          list.add(FirestoreConversation.fromDoc(d));
        } catch (_) {
          // Skip malformed docs
        }
      }
      return list;
    });
  }

  /// Stream messages orderBy createdAt desc. Handles null createdAt safely.
  Stream<List<FirestoreMessage>> messagesStream(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final list = <FirestoreMessage>[];
      for (final d in snap.docs) {
        try {
          list.add(FirestoreMessage.fromDoc(d));
        } catch (_) {
          // Skip malformed docs
        }
      }
      // Filter out docs with null createdAt (serverTimestamp not yet written)
      list.removeWhere((m) => m.createdAt == null);
      return list;
    });
  }

  /// Send text message: batch write:
  /// 1) create message doc with serverTimestamp
  /// 2) update conversation metadata
  /// 3) increment unread.toId
  Future<void> sendTextMessage(
    String conversationId,
    String fromId,
    String toId,
    String text,
  ) async {
    final fid = normalizeUserId(fromId);
    final tid = normalizeUserId(toId);
    final batch = _firestore.batch();

    final convRef = _conversations.doc(conversationId);
    final messagesRef = convRef.collection('messages');

    final msgRef = messagesRef.doc();

    batch.set(msgRef, {
      'fromId': fid,
      'toId': tid,
      'text': text,
      'type': 'text',
      'status': 'sent',
      'seenBy': [fid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(convRef, {
      'lastMessage': text,
      'lastMessageType': 'text',
      'lastSenderId': fid,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'unread.$tid': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Mark conversation seen for myUid: set unread.myUid = 0
  Future<void> markConversationSeen(String conversationId, String myUid) async {
    final uid = normalizeUserId(myUid);
    await _conversations.doc(conversationId).update({
      'unread.$uid': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark message seen: arrayUnion myUid to seenBy
  Future<void> markMessageSeen(
    DocumentReference<Map<String, dynamic>> msgRef,
    String myUid,
  ) async {
    final uid = normalizeUserId(myUid);
    await msgRef.update({
      'seenBy': FieldValue.arrayUnion([uid]),
    });
  }
}
