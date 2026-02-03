import 'user_mini_model.dart';

/// Model for conversation list item (inbox)
class ConversationItemModel {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String lastMessage;
  final DateTime createdAt;
  final int isRead;
  final UserMiniModel receiver;

  ConversationItemModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.lastMessage,
    required this.createdAt,
    required this.isRead,
    required this.receiver,
  });

  factory ConversationItemModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      if (json['created_at'] is String) {
        createdAt = DateTime.parse(json['created_at']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    return ConversationItemModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,
      fromUserId: json['from_user_id'] is int 
          ? json['from_user_id'] 
          : int.tryParse(json['from_user_id'].toString()) ?? 0,
      toUserId: json['to_user_id'] is int 
          ? json['to_user_id'] 
          : int.tryParse(json['to_user_id'].toString()) ?? 0,
      lastMessage: json['message_content']?.toString() ?? '',
      createdAt: createdAt,
      isRead: json['is_read'] is int 
          ? json['is_read'] 
          : (json['is_read'] == true ? 1 : 0),
      receiver: json['receiver'] != null 
          ? UserMiniModel.fromJson(json['receiver']) 
          : UserMiniModel(id: 0, fullname: 'Unknown User'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'message_content': lastMessage,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'receiver': receiver.toJson(),
    };
  }

  /// Format time for display
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
