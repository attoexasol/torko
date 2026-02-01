import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/community_group_model.dart';
import 'network_caller.dart';
import 'urls.dart';

/// Parses post_images from API (List, JSON string, or single string).
List<String> parsePostImages(dynamic v) {
  if (v == null) return [];
  if (v is List) return v.map((e) => e.toString()).toList();
  if (v is String) {
    if (v.isEmpty) return [];
    try {
      final decoded = jsonDecode(v.replaceAll(r'\/', '/'));
      if (decoded is List) return List<String>.from(decoded.map((e) => e.toString()));
      return [v];
    } catch (_) {
      return [v];
    }
  }
  return [];
}

/// Result of creating a group post.
class GroupPostCreateResult {
  final CommunityGroupPostModel post;
  final GroupPostLink groupPost;

  GroupPostCreateResult({required this.post, required this.groupPost});
}

/// Link between group and post.
class GroupPostLink {
  final int id;
  final int groupId;
  final int postId;
  final int userId;
  final String approvedByAdmin;
  final String createdAt;
  final String updatedAt;

  GroupPostLink({
    required this.id,
    required this.groupId,
    required this.postId,
    required this.userId,
    required this.approvedByAdmin,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Group post CRUD service: create, update, delete.
class GroupPostService {
  /// POST group-posts/create.
  static Future<GroupPostCreateResult> createGroupPost({
    required int groupId,
    required String title,
    required String description,
    List<String> base64Images = const [],
  }) async {
    final body = <String, dynamic>{
      'group_id': groupId,
      'post_title': title,
      'post_description': description,
    };
    if (base64Images.isNotEmpty) body['base64_images'] = base64Images;

    if (kDebugMode) {
      debugPrint('[GroupPostService] createGroupPost groupId=$groupId images=${base64Images.length}');
    }

    final res = await NetworkCaller.postAuth(url: Urls.create_Group_post, body: body);

    if (kDebugMode) {
      debugPrint('[GroupPostService] createGroupPost status=${res.body?['status']} message=${res.body?['message']}');
    }

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Failed to create post');
    }
    if (res.body!['status'] != true) {
      throw Exception(res.body!['message']?.toString() ?? 'Failed to create post');
    }

    final data = res.body!['data'];
    if (data == null || data is! Map) {
      throw Exception(res.body!['message']?.toString() ?? 'Invalid create response');
    }

    final postJson = data['post'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
    final groupPostJson = data['group_post'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final post = _postFromCreateResponse(postJson, groupPostJson);
    final groupPost = _groupPostLinkFromJson(groupPostJson, post.postId);

    return GroupPostCreateResult(post: post, groupPost: groupPost);
  }

  /// POST update_post. Uses id (matches existing post_controller).
  static Future<CommunityGroupPostModel> updatePost({
    required int postId,
    required String title,
    required String description,
    List<String> base64Images = const [],
  }) async {
    final body = <String, dynamic>{
      'id': postId,
      'post_id': postId,
      'post_title': title,
      'post_description': description,
    };
    if (base64Images.isNotEmpty) body['base64_images'] = base64Images;

    if (kDebugMode) {
      debugPrint('[GroupPostService] updatePost postId=$postId');
    }

    final res = await NetworkCaller.postAuth(url: Urls.update_Group_post_post, body: body);

    if (kDebugMode) {
      debugPrint('[GroupPostService] updatePost status=${res.body?['status']} message=${res.body?['message']}');
    }

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Failed to update post');
    }
    if (res.body!['status'] != true) {
      throw Exception(res.body!['message']?.toString() ?? 'Failed to update post');
    }

    final data = res.body!['data'];
    final postJson = data is Map ? (data['post'] as Map<String, dynamic>? ?? data as Map<String, dynamic>) : null;
    if (postJson == null) {
      throw Exception('Invalid update response');
    }
    return _postFromJson(postJson);
  }

  /// POST delete_post.
  static Future<void> deletePost({required int postId}) async {
    final body = <String, dynamic>{'id': postId, 'post_id': postId};

    if (kDebugMode) {
      debugPrint('[GroupPostService] deletePost postId=$postId');
    }

    final res = await NetworkCaller.postAuth(url: Urls.delete_Group_post_post, body: body);

    if (kDebugMode) {
      debugPrint('[GroupPostService] deletePost status=${res.body?['status']} message=${res.body?['message']}');
    }

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Failed to delete post');
    }
    if (res.body!['status'] != true) {
      throw Exception(res.body!['message']?.toString() ?? 'Failed to delete post');
    }
  }

  static CommunityGroupPostModel _postFromJson(Map<String, dynamic> json) {
    final images = parsePostImages(json['post_images']);
    return CommunityGroupPostModel(
      groupPostId: _toInt(json['group_post_id'] ?? json['id']),
      postId: _toInt(json['post_id'] ?? json['id']),
      approvedByAdmin: json['approved_by_admin']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      postTitle: json['post_title']?.toString() ?? '',
      postDescription: json['post_description']?.toString() ?? '',
      postImages: images,
      user: json['user'] != null && json['user'] is Map
          ? CommunityGroupUser.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  static CommunityGroupPostModel _postFromCreateResponse(
    Map<String, dynamic> postJson,
    Map<String, dynamic> groupPostJson,
  ) {
    final images = parsePostImages(postJson['post_images']);
    final postId = _toInt(postJson['post_id'] ?? postJson['id']);
    final groupPostId = _toInt(groupPostJson['group_post_id'] ?? groupPostJson['id']);
    return CommunityGroupPostModel(
      groupPostId: groupPostId,
      postId: postId,
      approvedByAdmin: groupPostJson['approved_by_admin']?.toString() ?? 'pending',
      createdAt: postJson['created_at']?.toString() ?? '',
      postTitle: postJson['post_title']?.toString() ?? '',
      postDescription: postJson['post_description']?.toString() ?? '',
      postImages: images,
      user: postJson['user'] != null && postJson['user'] is Map
          ? CommunityGroupUser.fromJson(Map<String, dynamic>.from(postJson['user'] as Map))
          : null,
    );
  }

  static GroupPostLink _groupPostLinkFromJson(Map<String, dynamic> json, int postId) {
    return GroupPostLink(
      id: _toInt(json['group_post_id'] ?? json['id']),
      groupId: _toInt(json['group_id'] ?? 0),
      postId: postId,
      userId: _toInt(json['user_id'] ?? 0),
      approvedByAdmin: json['approved_by_admin']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
