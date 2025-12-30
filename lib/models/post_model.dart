import 'dart:convert';

class PostModel {
  final int id;
  final int userId;
  final String postTitle;
  final String postDescription;
  final List<String> postImages;
  final int postLikeCount;
  final int postCommentCount;
  final int postShareCount;
  final CreatedBy? createdBy;
  final UpdatedBy? updatedBy;
  final String createdAt;
  final String updatedAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.postTitle,
    required this.postDescription,
    required this.postImages,
    required this.postLikeCount,
    required this.postCommentCount,
    required this.postShareCount,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle post_images - can be string (JSON) or List
    List<String> images = [];
    if (json['post_images'] != null) {
      if (json['post_images'] is String) {
        // Parse JSON string
        try {
          final decoded = jsonDecode(json['post_images'].replaceAll('\\/', '/'));
          if (decoded is List) {
            images = List<String>.from(decoded);
          }
        } catch (e) {
          images = [];
        }
      } else if (json['post_images'] is List) {
        images = List<String>.from(json['post_images']);
      }
    }

    return PostModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      postTitle: json['post_title'] ?? '',
      postDescription: json['post_description'] ?? '',
      postImages: images,
      postLikeCount: json['post_like_count'] ?? 0,
      postCommentCount: json['post_comment_count'] ?? 0,
      postShareCount: json['post_share_count'] ?? 0,
      createdBy: json['created_by'] != null
          ? (json['created_by'] is Map
              ? CreatedBy.fromJson(json['created_by'])
              : null)
          : null,
      updatedBy: json['updated_by'] != null
          ? (json['updated_by'] is Map
              ? UpdatedBy.fromJson(json['updated_by'])
              : null)
          : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_title': postTitle,
      'post_description': postDescription,
      'post_images': postImages,
      'post_like_count': postLikeCount,
      'post_comment_count': postCommentCount,
      'post_share_count': postShareCount,
      'created_by': createdBy?.toJson(),
      'updated_by': updatedBy?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CreatedBy {
  final int id;
  final String name;

  CreatedBy({required this.id, required this.name});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class UpdatedBy {
  final int id;
  final String name;

  UpdatedBy({required this.id, required this.name});

  factory UpdatedBy.fromJson(Map<String, dynamic> json) {
    return UpdatedBy(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

