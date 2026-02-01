import 'package:flutter/foundation.dart';

import 'network_caller.dart';
import 'urls.dart';

/// Result of creating a group post.
class GroupPostCreateResult {
  final int postId;
  final int groupPostId;
  final List<String> postImages;
  final String approvedByAdmin;

  GroupPostCreateResult({
    required this.postId,
    required this.groupPostId,
    required this.postImages,
    required this.approvedByAdmin,
  });
}

/// Community group post API: POST create group post.
class CommunityGroupPostService {
  /// POST group-posts/create. Body: api_token (auto), group_id, post_title, post_description, base64_images.
  static Future<GroupPostCreateResult> createGroupPost({
    required int groupId,
    required String title,
    required String description,
    required List<String> base64Images,
  }) async {
    final body = <String, dynamic>{
      'group_id': groupId,
      'post_title': title,
      'post_description': description,
      'base64_images': base64Images,
    };

    if (kDebugMode) {
      debugPrint('[CommunityGroupPostService] createGroupPost groupId=$groupId images=${base64Images.length}');
    }

    final res = await NetworkCaller.postAuth(url: Urls.create_Group_post, body: body);

    if (kDebugMode) {
      debugPrint('[CommunityGroupPostService] createGroupPost status=${res.body?['status']} message=${res.body?['message']}');
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

    final post = data['post'] as Map<String, dynamic>?;
    final groupPost = data['group_post'] as Map<String, dynamic>?;
    final postId = _toInt(post?['id']);
    final groupPostId = _toInt(groupPost?['group_post_id'] ?? groupPost?['id']);
    final approvedByAdmin = groupPost?['approved_by_admin']?.toString() ?? 'pending';

    List<String> images = [];
    final imgs = post?['post_images'];
    if (imgs is List) {
      images = imgs.map((e) => e.toString()).toList();
    } else if (imgs is String) {
      images = [imgs];
    }

    return GroupPostCreateResult(
      postId: postId,
      groupPostId: groupPostId,
      postImages: images,
      approvedByAdmin: approvedByAdmin,
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
