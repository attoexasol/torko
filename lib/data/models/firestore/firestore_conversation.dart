import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:torko/core/ids/user_id.dart';

/// Firestore conversation document: conversations/{conversationId}
/// Members and unread keys are normalized to numeric strings.
class FirestoreConversation {
  final String id;
  final List<String> members;
  final String lastMessage;
  final String lastMessageType;
  final String lastSenderId;
  final DateTime? lastMessageAt;
  final Map<String, int> unread;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FirestoreConversation({
    required this.id,
    required this.members,
    this.lastMessage = '',
    this.lastMessageType = 'text',
    this.lastSenderId = '',
    this.lastMessageAt,
    this.unread = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory FirestoreConversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final membersList = d['members'];
    final members = membersList is List
        ? membersList.map((e) {
            final s = e.toString().trim();
            if (s.isEmpty) return s;
            try {
              return normalizeUserId(s);
            } catch (_) {
              return s;
            }
          }).toList()
        : <String>[];
    final unreadMap = d['unread'];
    Map<String, int> unread = {};
    if (unreadMap is Map) {
      for (final e in unreadMap.entries) {
        final v = e.value;
        final key = e.key.toString().trim();
        if (key.isEmpty) continue;
        try {
          final normKey = normalizeUserId(key);
          if (v is int) {
            unread[normKey] = v;
          } else if (v != null) {
            unread[normKey] = int.tryParse(v.toString()) ?? 0;
          }
        } catch (_) {
          if (v is int) unread[key] = v;
        }
      }
    }
    Timestamp? tsLast = d['lastMessageAt'];
    Timestamp? tsCreated = d['createdAt'];
    Timestamp? tsUpdated = d['updatedAt'];
    return FirestoreConversation(
      id: doc.id,
      members: members,
      lastMessage: d['lastMessage']?.toString() ?? '',
      lastMessageType: d['lastMessageType']?.toString() ?? 'text',
      lastSenderId: d['lastSenderId']?.toString() ?? '',
      lastMessageAt: tsLast?.toDate(),
      unread: unread,
      createdAt: tsCreated?.toDate(),
      updatedAt: tsUpdated?.toDate(),
    );
  }

  int unreadFor(String uid) {
    try {
      final norm = normalizeUserId(uid);
      return unread[norm] ?? unread[uid] ?? 0;
    } catch (_) {
      return unread[uid] ?? 0;
    }
  }
}
