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
  final int? isSave; // 0 = not saved, 1 = saved, null -> 0
  final int isLike; // 0 = not liked, 1 = liked

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
    this.isSave = 0,
    this.isLike = 0,
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

    // Handle is_saved field (primary) or is_save (backward compatibility)
    // API uses is_saved, but some endpoints may still use is_save
    int? isSaveValue;
    final savedValue = json['is_saved'] ?? json['is_save'];
    if (savedValue != null) {
      if (savedValue is int) {
        isSaveValue = savedValue as int;
      } else if (savedValue is bool) {
        isSaveValue = savedValue == true ? 1 : 0;
      } else if (savedValue is String) {
        isSaveValue = savedValue == '1' ? 1 : 0;
      } else {
        isSaveValue = savedValue == true || savedValue == '1' ? 1 : 0;
      }
    }

    // Handle is_like field (can be null, int, bool, or string)
    // null -> 0, 0 -> 0, 1 -> 1, true -> 1, false -> 0
    int isLikeValue = 0;
    if (json['is_like'] != null) {
      if (json['is_like'] is int) {
        isLikeValue = json['is_like'];
      } else if (json['is_like'] is bool) {
        isLikeValue = json['is_like'] ? 1 : 0;
      } else if (json['is_like'] is String) {
        isLikeValue = json['is_like'] == '1' ? 1 : 0;
      }
    }
    // If is_like is null, it defaults to 0 (already set above)

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
      isSave: isSaveValue ?? 0,
      isLike: isLikeValue,
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
      'is_saved': isSave ?? 0,
      'is_like': isLike,
    };
  }

  /// Computed getter: returns true if post is saved (isSave == 1)
  bool get saved => (isSave ?? 0) == 1;

  /// Computed getter: returns true if post is liked (isLike == 1)
  bool get isLiked => isLike == 1;

  /// Create a copy with updated fields
  PostModel copyWith({
    int? id,
    int? userId,
    String? postTitle,
    String? postDescription,
    List<String>? postImages,
    int? postLikeCount,
    int? postCommentCount,
    int? postShareCount,
    CreatedBy? createdBy,
    UpdatedBy? updatedBy,
    String? createdAt,
    String? updatedAt,
    int? isSave,
    int? isLike,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postTitle: postTitle ?? this.postTitle,
      postDescription: postDescription ?? this.postDescription,
      postImages: postImages ?? this.postImages,
      postLikeCount: postLikeCount ?? this.postLikeCount,
      postCommentCount: postCommentCount ?? this.postCommentCount,
      postShareCount: postShareCount ?? this.postShareCount,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSave: isSave ?? this.isSave,
      isLike: isLike ?? this.isLike,
    );
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

