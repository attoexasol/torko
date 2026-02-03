/// Model class representing a comment on a post
class CommentModel {
  final int id;
  final int userId;
  final String comment;
  final int postId;
  final int? postedProfileId;
  final int? replyId;
  final String createdAt;
  final String updatedAt;
  final CommentUser? user;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.userId,
    required this.comment,
    required this.postId,
    this.postedProfileId,
    this.replyId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Parse replies if available
    List<CommentModel> repliesList = [];
    if (json['replies'] != null && json['replies'] is List) {
      repliesList = (json['replies'] as List)
          .map((reply) => CommentModel.fromJson(reply))
          .toList();
    }

    return CommentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      comment: json['comment'] ?? '',
      postId: json['post_id'] ?? 0,
      postedProfileId: json['posted_profile_id'],
      replyId: json['reply_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? CommentUser.fromJson(json['user']) : null,
      replies: repliesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'comment': comment,
      'post_id': postId,
      'posted_profile_id': postedProfileId,
      'reply_id': replyId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  /// Check if this comment is a reply to another comment
  bool get isReply => replyId != null;

  /// Get formatted time ago string
  String get timeAgo {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return '';
    }
  }
}

/// Model class representing a user who made a comment
class CommentUser {
  final int id;
  final String? fullname;
  final String? username;
  final String? email;
  final String? phone;
  final String? bio;
  final String? profileImage;
  final String? coverImage;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profileStatus;

  CommentUser({
    required this.id,
    this.fullname,
    this.username,
    this.email,
    this.phone,
    this.bio,
    this.profileImage,
    this.coverImage,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profileStatus,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'] ?? 0,
      fullname: json['fullname'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      bio: json['bio'],
      profileImage: json['profile_image'],
      coverImage: json['cover_image'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      address: json['address'],
      profileStatus: json['profile_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username,
      'email': email,
      'phone': phone,
      'bio': bio,
      'profile_image': profileImage,
      'cover_image': coverImage,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'profile_status': profileStatus,
    };
  }

  /// Get display name (fullname or username or 'User')
  String get displayName => fullname ?? username ?? 'User';

  /// Get first letter for avatar
  String get avatarLetter => displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
}

