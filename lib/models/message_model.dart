import 'user_mini_model.dart';

/// Model class representing a message in a conversation
class MessageModel {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String messageContent;
  final int isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserMiniModel? sender;
  final UserMiniModel? receiver;
  final bool isSending; // For optimistic updates
  final bool isFailed; // For failed messages

  MessageModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.messageContent,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.isSending = false,
    this.isFailed = false,
  });

  /// Create a temporary message for optimistic updates
  factory MessageModel.temporary({
    required int fromUserId,
    required int toUserId,
    required String messageContent,
  }) {
    final now = DateTime.now();
    return MessageModel(
      id: -now.millisecondsSinceEpoch, // Negative ID for temporary messages
      fromUserId: fromUserId,
      toUserId: toUserId,
      messageContent: messageContent,
      isRead: 0,
      createdAt: now,
      updatedAt: now,
      isSending: true,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    DateTime updatedAt;
    
    try {
      if (json['created_at'] is String) {
        createdAt = DateTime.parse(json['created_at']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    try {
      if (json['updated_at'] is String) {
        updatedAt = DateTime.parse(json['updated_at']);
      } else {
        updatedAt = createdAt;
      }
    } catch (e) {
      updatedAt = createdAt;
    }

    return MessageModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,
      fromUserId: json['from_user_id'] is int 
          ? json['from_user_id'] 
          : int.tryParse(json['from_user_id'].toString()) ?? 0,
      toUserId: json['to_user_id'] is int 
          ? json['to_user_id'] 
          : int.tryParse(json['to_user_id'].toString()) ?? 0,
      messageContent: json['message_content']?.toString() ?? '',
      isRead: json['is_read'] is int 
          ? json['is_read'] 
          : (json['is_read'] == true ? 1 : 0),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sender: json['sender'] != null 
          ? UserMiniModel.fromJson(json['sender']) 
          : null,
      receiver: json['receiver'] != null 
          ? UserMiniModel.fromJson(json['receiver']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'message_content': messageContent,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
    };
  }

  /// Check if this message was sent by the current user
  bool isMine(int currentUserId) {
    return fromUserId == currentUserId;
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    int? id,
    int? fromUserId,
    int? toUserId,
    String? messageContent,
    int? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserMiniModel? sender,
    UserMiniModel? receiver,
    bool? isSending,
    bool? isFailed,
  }) {
    return MessageModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      messageContent: messageContent ?? this.messageContent,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      isSending: isSending ?? this.isSending,
      isFailed: isFailed ?? this.isFailed,
    );
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
