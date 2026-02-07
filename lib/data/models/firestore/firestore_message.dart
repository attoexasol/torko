import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:torko/core/ids/user_id.dart';

/// Firestore message document: conversations/{conversationId}/messages/{messageId}
/// fromId, toId, seenBy are normalized to numeric strings.
class FirestoreMessage {
  final String id;
  final String fromId;
  final String toId;
  final String text;
  final String type;
  final String status;
  final List<String> seenBy;
  final DateTime? createdAt;

  const FirestoreMessage({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.text,
    this.type = 'text',
    this.status = 'sent',
    this.seenBy = const [],
    this.createdAt,
  });

  /// Creates an optimistic message for instant UI feedback before stream echo.
  factory FirestoreMessage.optimistic({
    required String fromId,
    required String toId,
    required String text,
  }) {
    final now = DateTime.now();
    return FirestoreMessage(
      id: 'temp_${now.millisecondsSinceEpoch}',
      fromId: fromId,
      toId: toId,
      text: text,
      type: 'text',
      status: 'sent',
      seenBy: [fromId],
      createdAt: now,
    );
  }

  factory FirestoreMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final _norm = (String s) {
      if (s.isEmpty) return s;
      try {
        return normalizeUserId(s);
      } catch (_) {
        return s;
      }
    };
    final fromRaw = d['fromId']?.toString() ?? '';
    final toRaw = d['toId']?.toString() ?? '';
    final seenList = d['seenBy'];
    final seenBy = seenList is List
        ? seenList.map((e) => _norm(e.toString().trim())).where((s) => s.isNotEmpty).toList()
        : <String>[];
    Timestamp? ts = d['createdAt'];
    return FirestoreMessage(
      id: doc.id,
      fromId: _norm(fromRaw),
      toId: _norm(toRaw),
      text: d['text']?.toString() ?? '',
      type: d['type']?.toString() ?? 'text',
      status: d['status']?.toString() ?? 'sent',
      seenBy: seenBy,
      createdAt: ts?.toDate(),
    );
  }

  bool isMine(String myUid) {
    try {
      return fromId == normalizeUserId(myUid);
    } catch (_) {
      return fromId == myUid;
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
