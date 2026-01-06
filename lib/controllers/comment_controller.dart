import 'package:get/get.dart';
import '../models/comment_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import '../services/user_info.dart';

/// Controller for handling all comment-related operations
class CommentController extends GetxController {
  // State
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CommentModel?> selectedComment = Rx<CommentModel?>(null);
  
  // Current post ID for comments
  final RxInt currentPostId = 0.obs;
  
  // Reply state
  final RxBool isReplyMode = false.obs;
  final Rx<CommentModel?> replyingTo = Rx<CommentModel?>(null);
  
  // Edit state
  final RxBool isEditMode = false.obs;
  final Rx<CommentModel?> editingComment = Rx<CommentModel?>(null);

  // ==================== Get All Comments for a Post ====================
  Future<void> loadComments(int postId) async {
    if (postId <= 0) {
      errorMessage.value = 'Invalid post ID';
      print('DEBUG loadComments: Invalid post ID = $postId');
      return;
    }

    currentPostId.value = postId;
    isLoading.value = true;
    errorMessage.value = '';

    print('DEBUG loadComments: Loading comments for post_id = $postId');

    try {
      final token = UserInfo.apiToken;
      
      print('DEBUG loadComments: Using api_token = ${token != null && token.length > 10 ? '${token.substring(0, 10)}...' : token}');
      
      // Try using GET request with query parameter (similar to get_all_post)
      final url = '${Urls.get_all_comment}?post_id=$postId';
      print('DEBUG loadComments: URL = $url');
      
      final response = await NetworkCaller.getRequest(
        url: url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      print('DEBUG loadComments: Response success = ${response.isSuccess}');
      print('DEBUG loadComments: Response statusCode = ${response.statusCode}');
      print('DEBUG loadComments: Response body = ${response.body}');
      print('DEBUG loadComments: Response errorMessage = ${response.errorMessage}');

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          final data = response.body!['data'];
          if (data is List) {
            comments.value = data.map((json) => CommentModel.fromJson(json)).toList();
            print('DEBUG loadComments: Loaded ${comments.length} comments');
            errorMessage.value = '';
          } else {
            errorMessage.value = 'Invalid response format';
            print('DEBUG loadComments: Invalid data format - ${data.runtimeType}');
            comments.value = [];
          }
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to load comments';
          print('DEBUG loadComments: API returned false status - ${response.body!['message']}');
          comments.value = [];
        }
      } else {
        // If GET fails, try POST as fallback
        print('DEBUG loadComments: GET failed, trying POST...');
        final postResponse = await NetworkCaller.postRequest(
          url: Urls.get_all_comment,
          body: {
            'api_token': token ?? '',
            'post_id': postId,
          },
        );
        
        print('DEBUG loadComments: POST Response success = ${postResponse.isSuccess}');
        print('DEBUG loadComments: POST Response statusCode = ${postResponse.statusCode}');
        print('DEBUG loadComments: POST Response body = ${postResponse.body}');
        
        if (postResponse.isSuccess && postResponse.body != null) {
          if (postResponse.body!['status'] == true) {
            final data = postResponse.body!['data'];
            if (data is List) {
              comments.value = data.map((json) => CommentModel.fromJson(json)).toList();
              print('DEBUG loadComments: Loaded ${comments.length} comments via POST');
              errorMessage.value = '';
            } else {
              errorMessage.value = 'Invalid response format';
              comments.value = [];
            }
          } else {
            errorMessage.value = postResponse.body!['message'] ?? 'Failed to load comments';
            comments.value = [];
          }
        } else {
          errorMessage.value = response.errorMessage ?? 'Failed to load comments';
          print('DEBUG loadComments: Both GET and POST failed');
          comments.value = [];
        }
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      print('DEBUG loadComments: Exception - $e');
      comments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Get Single Comment ====================
  Future<CommentModel?> getSingleComment(int commentId) async {
    if (commentId <= 0) {
      errorMessage.value = 'Invalid comment ID';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.single_comment,
        body: {
          'comment_id': commentId,
        },
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          final data = response.body!['data'];
          final comment = CommentModel.fromJson(data);
          selectedComment.value = comment;
          isLoading.value = false;
          return comment;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to load comment';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load comment';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  // ==================== Create Comment ====================
  Future<bool> createComment({
    required int postId,
    required String comment,
    int? replyId,
  }) async {
    if (comment.trim().isEmpty) {
      errorMessage.value = 'Comment cannot be empty';
      return false;
    }

    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Please login first';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final body = <String, dynamic>{
        'api_token': token,
        'post_id': postId,
        'comment': comment.trim(),
      };
      
      // Add reply_id if this is a reply
      if (replyId != null) {
        body['reply_id'] = replyId;
      }

      final response = await NetworkCaller.postRequest(
        url: Urls.create_comment,
        body: body,
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Clear reply mode
          cancelReply();
          
          // Reload comments to get fresh data with user info
          await loadComments(postId);
          
          isSubmitting.value = false;
          return true;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to create comment';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to create comment';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  // ==================== Update Comment ====================
  Future<bool> updateComment({
    required int commentId,
    required String comment,
  }) async {
    if (comment.trim().isEmpty) {
      errorMessage.value = 'Comment cannot be empty';
      return false;
    }

    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Please login first';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.update_comment,
        body: {
          'api_token': token,
          'comment_id': commentId,
          'comment': comment.trim(),
        },
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Clear edit mode
          cancelEdit();
          
          // Reload comments to get fresh data
          if (currentPostId.value > 0) {
            await loadComments(currentPostId.value);
          }
          
          isSubmitting.value = false;
          return true;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to update comment';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to update comment';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  // ==================== Delete Comment ====================
  Future<bool> deleteComment(int commentId) async {
    if (commentId <= 0) {
      errorMessage.value = 'Invalid comment ID';
      return false;
    }

    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Please login first';
      return false;
    }

    isDeleting.value = true;
    errorMessage.value = '';

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.delete_comment,
        body: {
          'api_token': token,
          'comment_id': commentId,
        },
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Remove from local list
          comments.removeWhere((c) => c.id == commentId);
          
          // Also remove from any replies
          for (var comment in comments) {
            comment.replies.removeWhere((r) => r.id == commentId);
          }
          comments.refresh();
          
          isDeleting.value = false;
          return true;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to delete comment';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to delete comment';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isDeleting.value = false;
    }
    return false;
  }

  // ==================== Reply Mode ====================
  void startReply(CommentModel comment) {
    isReplyMode.value = true;
    replyingTo.value = comment;
    cancelEdit(); // Cancel any ongoing edit
  }

  void cancelReply() {
    isReplyMode.value = false;
    replyingTo.value = null;
  }

  // ==================== Edit Mode ====================
  void startEdit(CommentModel comment) {
    isEditMode.value = true;
    editingComment.value = comment;
    cancelReply(); // Cancel any ongoing reply
  }

  void cancelEdit() {
    isEditMode.value = false;
    editingComment.value = null;
  }

  // ==================== Utility ====================
  /// Check if current user can edit/delete a comment
  bool canModifyComment(CommentModel comment) {
    final currentUserId = UserInfo.userId;
    return currentUserId != null && comment.userId == currentUserId;
  }

  /// Get comment count
  int get commentCount {
    int count = comments.length;
    for (var comment in comments) {
      count += comment.replies.length;
    }
    return count;
  }

  /// Clear all comments
  void clearComments() {
    comments.clear();
    currentPostId.value = 0;
    cancelReply();
    cancelEdit();
    errorMessage.value = '';
  }
}

