import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:torko/core/ids/user_id.dart';

/// Firestore message: conversations/{conversationId}/messages/{messageId}
/// Schema: senderId, text, type, createdAt. Backward compat: fromId/toId.
class FirestoreMessage {
  final String id;
  final String senderId;
  final String text;
  final String type;
  final DateTime? createdAt;
  final String fromId;
  final String toId;
  final List<String> seenBy;

  const FirestoreMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.createdAt,
    this.fromId = '',
    this.toId = '',
    this.seenBy = const [],
  });

  /// Backward compat: fromId for isMine/UI.
  String get effectiveFromId => fromId.isNotEmpty ? fromId : senderId;

  /// Optimistic message for instant UI before stream echo.
  factory FirestoreMessage.optimistic({
    required String fromId,
    required String toId,
    required String text,
  }) {
    final now = DateTime.now();
    return FirestoreMessage(
      id: 'temp_${now.millisecondsSinceEpoch}',
      senderId: fromId,
      text: text,
      fromId: fromId,
      toId: toId,
      createdAt: now,
    );
  }

  factory FirestoreMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    String normId(String s) {
      if (s.isEmpty) return s;
      try {
        return normalizeUserId(s);
      } catch (_) {
        return s;
      }
    }
    final senderRaw = d['senderId']?.toString() ?? d['fromId']?.toString() ?? '';
    final fromRaw = d['fromId']?.toString() ?? senderRaw;
    final toRaw = d['toId']?.toString() ?? '';
    final seenList = d['seenBy'];
    final seenBy = seenList is List
        ? seenList.map((e) => normId(e.toString().trim())).where((s) => s.isNotEmpty).toList()
        : <String>[];
    Timestamp? ts = d['createdAt'];
    return FirestoreMessage(
      id: doc.id,
      senderId: normId(senderRaw),
      text: d['text']?.toString() ?? '',
      type: d['type']?.toString() ?? 'text',
      createdAt: ts?.toDate(),
      fromId: normId(fromRaw),
      toId: normId(toRaw),
      seenBy: seenBy,
    );
  }

  bool isMine(String myUid) {
    try {
      final norm = normalizeUserId(myUid);
      return senderId == norm || fromId == norm || effectiveFromId == norm;
    } catch (_) {
      return senderId == myUid || fromId == myUid;
    }
  }

  String get formattedTime {
    final dt = createdAt;
    if (dt == null) return '';
    final now = DateTime.now();
    final d = now.difference(dt);
    if (d.inMinutes < 1) return 'now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
