import 'user_mini_model.dart';

/// Model for a raw message row from API (inbox endpoint)
class MessageRowModel {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final int isRead;
  final DateTime createdAt;
  final UserMiniModel? sender;
  final UserMiniModel? receiver;

  MessageRowModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory MessageRowModel.fromJson(Map<String, dynamic> json) {
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

    return MessageRowModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,
      fromUserId: json['from_user_id'] is int 
          ? json['from_user_id'] 
          : int.tryParse(json['from_user_id'].toString()) ?? 0,
      toUserId: json['to_user_id'] is int 
          ? json['to_user_id'] 
          : int.tryParse(json['to_user_id'].toString()) ?? 0,
      content: json['message_content']?.toString() ?? '',
      isRead: json['is_read'] is int 
          ? json['is_read'] 
          : (json['is_read'] == true ? 1 : 0),
      createdAt: createdAt,
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
      'message_content': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
    };
  }

  /// Determine the other user in this conversation
  /// Returns the user who is NOT the current user
  UserMiniModel? getOtherUser(int currentUserId) {
    if (fromUserId == currentUserId) {
      return receiver;
    } else {
      return sender;
    }
  }

  /// Get the other user ID
  int getOtherUserId(int currentUserId) {
    if (fromUserId == currentUserId) {
      return toUserId;
    } else {
      return fromUserId;
    }
  }
}
