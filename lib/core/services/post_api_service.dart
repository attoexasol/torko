import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/data/models/post_model.dart';
import 'package:torko/data/models/timeline_item.dart';

/// Exception class for post API errors
class PostApiException implements Exception {
  final String message;
  final int? statusCode;
  
  PostApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'PostApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Service for post-related API calls
class PostApiService {
  /// Save a post. Uses postAuth (Authorization header + api_token in body).
  /// Returns is_save from response (1 on success). Updates UI only on success.
  static Future<int> savePost({required int postId}) async {
    final int safePostId = postId is int ? postId : int.parse(postId.toString());
    if (kDebugMode) print('SAVE postId=$safePostId');

    try {
      final response = await NetworkCaller.postAuth(
        url: Urls.save_post,
        body: {'post_id': safePostId},
      );

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        if (body['status'] == true) {
          final data = body['data'];
          int isSave = 1;
          if (data is Map) {
            // API uses is_saved (primary), fallback to is_save for backward compatibility
            final savedValue = data['is_saved'] ?? data['is_save'];
            if (savedValue != null) {
              if (savedValue is int) {
                isSave = savedValue as int;
              } else {
                isSave = savedValue == 1 || savedValue == '1' ? 1 : 0;
              }
            }
          }
          return isSave;
        }
        final msg = body['message']?.toString() ?? 'Failed to save post';
        throw PostApiException(msg, response.statusCode);
      }

      _throwFromAuthResponse(response, 'Failed to save post');
    } on NetworkAuthException catch (e) {
      throw PostApiException(e.message);
    } on PostApiException {
      rethrow;
    } catch (e) {
      throw PostApiException('Unexpected error: ${e.toString()}');
    }
  }

  static Never _throwFromAuthResponse(NetworkResponse res, String fallback) {
    final msg = (res.body is Map ? (res.body as Map)['message'] : null)?.toString() ??
        res.errorMessage ??
        fallback;
    final m = msg.toLowerCase();
    if (res.statusCode == 401 || res.statusCode == 403 || m.contains('not authorized')) {
      throw PostApiException('Session expired, please login again.', res.statusCode);
    }
    if (m.contains('post not found')) {
      throw PostApiException('This post is no longer available.', res.statusCode);
    }
    throw PostApiException(msg, res.statusCode);
  }

  /// Unsave a post. Uses postAuth (Authorization header + api_token in body).
  static Future<int> unsavePost({required int postId}) async {
    final int safePostId = postId is int ? postId : int.parse(postId.toString());
    if (kDebugMode) print('UNSAVE postId=$safePostId');

    try {
      final response = await NetworkCaller.postAuth(
        url: Urls.unsave_post,
        body: {'post_id': safePostId},
      );

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        if (body['status'] == true) {
          final data = body['data'];
          int isSave = 0;
          if (data is Map) {
            // API uses is_saved (primary), fallback to is_save for backward compatibility
            final savedValue = data['is_saved'] ?? data['is_save'];
            if (savedValue != null) {
              if (savedValue is int) {
                isSave = savedValue as int;
              } else {
                isSave = savedValue == 1 || savedValue == '1' ? 1 : 0;
              }
            }
          }
          return isSave;
        }
        final msg = body['message']?.toString() ?? 'Failed to unsave post';
        throw PostApiException(msg, response.statusCode);
      }

      _throwFromAuthResponse(response, 'Failed to unsave post');
    } on NetworkAuthException catch (e) {
      throw PostApiException(e.message);
    } on PostApiException {
      rethrow;
    } catch (e) {
      throw PostApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Get saved posts. Uses postAuth (Authorization header + api_token in body).
  static Future<List<PostModel>> getSavedPosts() async {
    try {
      final response = await NetworkCaller.postAuth(
        url: Urls.get_save_post,
        body: <String, dynamic>{},
      );

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        if (body['status'] == true && body.containsKey('data') && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          final list = dataList
              .map((item) {
                try {
                  return PostModel.fromJson(item);
                } catch (e) {
                  if (kDebugMode) {
                    print('DEBUG PostApiService.getSavedPosts: Error parsing post: $e');
                    print('   Item: ${jsonEncode(item)}');
                  }
                  return null;
                }
              })
              .whereType<PostModel>()
              .toList();
          if (kDebugMode) print('GET SAVED count=${list.length}');
          return list;
        }
        if (kDebugMode) print('DEBUG PostApiService.getSavedPosts: No "data" array or status != true, returning []');
        return [];
      }
      _throwFromAuthResponse(response, 'Failed to load saved posts');
    } on NetworkAuthException catch (e) {
      throw PostApiException(e.message);
    } on PostApiException {
      rethrow;
    } catch (e) {
      throw PostApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Share a post. Uses postAuth.
  static Future<void> sharePost({required int postId}) async {
    try {
      final res = await NetworkCaller.postAuth(
        url: Urls.share_post,
        body: {'post_id': postId is int ? postId : int.parse(postId.toString())},
      );
      if (!res.isSuccess || res.body == null) {
        _throwFromAuthResponse(res, 'Failed to share post');
      }
      final data = res.body!;
      if (data['status'] != true) {
        throw PostApiException(
          data['message']?.toString() ?? 'Failed to share post',
          res.statusCode,
        );
      }
    } on NetworkAuthException catch (e) {
      throw PostApiException(e.message);
    } on PostApiException {
      rethrow;
    } catch (e) {
      throw PostApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Delete a shared post. Uses postAuth.
  static Future<void> deleteSharedPost({required int postId}) async {
    try {
      final res = await NetworkCaller.postAuth(
        url: Urls.delete_share_post,
        body: {'post_id': postId is int ? postId : int.parse(postId.toString())},
      );
      if (!res.isSuccess || res.body == null) {
        _throwFromAuthResponse(res, 'Failed to delete shared post');
      }
      final data = res.body!;
      if (data['status'] != true) {
        throw PostApiException(
          data['message']?.toString() ?? 'Failed to delete shared post',
          res.statusCode,
        );
      }
    } on NetworkAuthException catch (e) {
      throw PostApiException(e.message);
    } on PostApiException {
      rethrow;
    } catch (e) {
      throw PostApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// User own timeline (own posts + shared posts). Uses postAuth.
  static Future<List<TimelineItem>> getUserOwnTimeline() async {
    try {
      final res = await NetworkCaller.postAuth(url: Urls.user_own_posts, body: <String, dynamic>{});
      if (!res.isSuccess || res.body == null) {
        _throwFromAuthResponse(res, 'Failed to load timeline');
      }
      final data = res.body!;
      if (data['status'] != true) {
        throw PostApiException(
          data['message']?.toString() ?? 'Failed to load timeline',
          res.statusCode,
        );
      }
      final list = data['data'];
      if (list == null || list is! List) return [];
      final items = <TimelineItem>[];
      for (final e in list) {
        try {
          if (e is! Map) continue;
          final item = TimelineItem.fromJson(Map<String, dynamic>.from(e as Map));
          items.add(item);
          if (kDebugMode) print('DEBUG timeline item type=${item.type} postId=${item.post.id}');
        } catch (err) {
          if (kDebugMode) print('DEBUG timeline parse error: $err');
        }
      }
      return items;
    } on NetworkAuthException catch (e) {
      throw PostApiException(e.message);
    } on PostApiException {
      rethrow;
    } catch (e) {
      throw PostApiException('Unexpected error: ${e.toString()}');
    }
  }
}
