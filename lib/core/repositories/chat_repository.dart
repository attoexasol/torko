import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/data/models/firestore/firestore_conversation.dart';
import 'package:torko/data/models/firestore/firestore_message.dart';

/// Firestore chat repository.
/// Paths: conversations/{conversationId}, conversations/{id}/messages/{messageId}
/// All IDs are numeric strings (e.g. "65").
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// conversations collection - NOT conversations/{id}
  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  /// Stable conversation ID: sorted uids joined with "_"
  static String conversationId(String uid1, String uid2) =>
      buildConversationId(uid1, uid2);

  /// Ensure conversation doc exists. Tries transaction first; falls back to write-first
  /// if tx.get fails (e.g. PERMISSION_DENIED on non-existent doc).
  /// Path: collection('conversations').doc(conversationId) - NOT collection('conversations/$id').
  Future<String> ensureConversationExists(
    String myUidString,
    String friendUidString,
  ) async {
    final myUid = normalizeUserId(myUidString).toString();
    final friendUid = normalizeUserId(friendUidString).toString();
    final a = myUid;
    final b = friendUid;
    final cid = (a.compareTo(b) < 0) ? '${a}_$b' : '${b}_$a';
    final docRef = _conversations.doc(cid);

    if (kDebugMode) {
      debugPrint('[ChatRepo] ensureConversation path: conversations/$cid my=$myUid friend=$friendUid');
    }

    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) {
          tx.set(docRef, {
            'members': [myUid, friendUid],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'lastMessage': '',
            'lastMessageAt': FieldValue.serverTimestamp(),
            'lastMessageType': 'text',
            'lastSenderId': myUid,
            'unread': {myUid: 0, friendUid: 0},
          });
        } else {
          tx.update(docRef, {
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (_) {
      await docRef.set({
        'members': FieldValue.arrayUnion([myUid, friendUid]),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageType': 'text',
        'lastSenderId': myUid,
        'unread.$myUid': 0,
        'unread.$friendUid': 0,
      }, SetOptions(merge: true));
    }

    return cid;
  }

  /// Alias.
  Future<String> ensureConversation(String myUid, String friendUid) =>
      ensureConversationExists(myUid, friendUid);

  /// Create conversation if it does not exist (legacy).
  Future<void> createConversationIfNotExists(String uid1, String uid2) async {
    await ensureConversationExists(uid1, uid2);
  }

  /// Watch my conversations: members arrayContains myUid, orderBy updatedAt desc.
  Stream<List<FirestoreConversation>> watchMyConversations(String myUid) {
    final uid = normalizeUserId(myUid);
    final query = _conversations
        .where('members', arrayContains: uid)
        .orderBy('updatedAt', descending: true);

    if (kDebugMode) {
      debugPrint('[ChatRepo] inbox: collection(conversations) where members arrayContains $uid orderBy updatedAt desc');
    }

    return query.snapshots().map((snap) {
      final list = <FirestoreConversation>[];
      for (final d in snap.docs) {
        try {
          list.add(FirestoreConversation.fromDoc(d));
        } catch (_) {}
      }
      return list;
    });
  }

  /// Legacy alias for conversationsStream.
  Stream<List<FirestoreConversation>> conversationsStream(String myUid) =>
      watchMyConversations(myUid);

  /// Watch messages: orderBy createdAt asc (oldest first for chat UI).
  /// Path: conversations/{conversationId}/messages (subcollection).
  Stream<List<FirestoreMessage>> watchMessages(String conversationId) {
    final convRef = _conversations.doc(conversationId);
    final messagesRef = convRef.collection('messages');

    if (kDebugMode) {
      debugPrint('[ChatRepo] messages collection path: ${messagesRef.path}');
    }

    return messagesRef
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
      final list = <FirestoreMessage>[];
      for (final d in snap.docs) {
        try {
          final m = FirestoreMessage.fromDoc(d);
          if (m.createdAt != null) list.add(m);
        } catch (_) {}
      }
      return list;
    });
  }

  /// Legacy: messagesStream returns desc, reversed in service.
  Stream<List<FirestoreMessage>> messagesStream(String conversationId) {
    return watchMessages(conversationId);
  }

  /// Send text message. Schema: senderId, text, type, createdAt.
  /// Updates conversation: lastMessage, lastMessageAt, lastSenderId, unread[friendUid]+1, unread[myUid]=0.
  Future<void> sendTextMessage(
    String conversationId,
    String myUid,
    String friendUid,
    String text,
  ) async {
    final fid = normalizeUserId(myUid);
    final tid = normalizeUserId(friendUid);
    final convRef = _conversations.doc(conversationId);
    final messagesRef = convRef.collection('messages');
    final msgRef = messagesRef.doc();

    if (kDebugMode) {
      debugPrint('[ChatRepo] sendTextMessage msgRef path: ${msgRef.path}');
    }

    final batch = _firestore.batch();
    batch.set(msgRef, {
      'senderId': fid,
      'text': text,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(convRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageType': 'text',
      'lastSenderId': fid,
      'unread.$tid': FieldValue.increment(1),
      'unread.$fid': 0,
    });
    await batch.commit();
  }

  /// Mark conversation read for myUid: unread[myUid] = 0.
  Future<void> markConversationRead(
    String conversationId,
    String myUid,
  ) async {
    final uid = normalizeUserId(myUid);
    await _conversations.doc(conversationId).update({
      'unread.$uid': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Legacy alias.
  Future<void> markConversationSeen(String conversationId, String myUid) =>
      markConversationRead(conversationId, myUid);
}
