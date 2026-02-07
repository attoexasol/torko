import 'package:get/get.dart';
import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/comment_model.dart';
import 'package:torko/presentation/home/controllers/home_controller.dart';

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
      return;
    }

    currentPostId.value = postId;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = UserInfo.apiToken;
      final url = '${Urls.get_all_comment}?post_id=$postId';

      final response = await NetworkCaller.getRequest(
        url: url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          final data = response.body!['data'];
          if (data is List) {
            comments.value = data.map((json) => CommentModel.fromJson(json)).toList();
            errorMessage.value = '';
          } else {
            errorMessage.value = 'Invalid response format';
            comments.value = [];
          }
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to load comments';
          comments.value = [];
        }
      } else {
        // If GET fails, try POST as fallback
        final postResponse = await NetworkCaller.postRequest(
          url: Urls.get_all_comment,
          body: {
            'api_token': token ?? '',
            'post_id': postId,
          },
        );

        if (postResponse.isSuccess && postResponse.body != null) {
          if (postResponse.body!['status'] == true) {
            final data = postResponse.body!['data'];
            if (data is List) {
              comments.value = data.map((json) => CommentModel.fromJson(json)).toList();
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
          comments.value = [];
        }
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
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
          // Get updated comment count from API response if available
          final newCommentCount = response.body!['post_comment_count'];
          
          // Clear reply mode
          cancelReply();
          
          // Update post comment count in feed if HomeController exists
          if (Get.isRegistered<HomeController>()) {
            try {
              final homeController = Get.find<HomeController>();
              if (newCommentCount != null && newCommentCount is int) {
                // Use the count from API response (most accurate)
                homeController.updatePostCommentCount(postId, newCommentCount);
              } else {
                // Fallback: Increment by 1 (API didn't return count)
                final currentPost = homeController.posts.firstWhereOrNull((p) => p.id == postId);
                if (currentPost != null) {
                  final currentCount = homeController.getCommentCount(currentPost);
                  // Increment by 1 for the new comment (replies are counted separately)
                  homeController.updatePostCommentCount(postId, currentCount + 1);
                }
              }
            } catch (_) {}
          }
          
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

    // Store original state for rollback if API fails
    final List<CommentModel> originalComments = List.from(comments);
    final int originalCommentCount = commentCount;
    
    // INSTANT UI UPDATE: Remove from local list immediately (optimistic update)
    final initialLength = comments.length;
    comments.removeWhere((c) => c.id == commentId);
    bool foundInMain = comments.length < initialLength;
    
    // If not found in main, search in replies
    if (!foundInMain) {
      for (var comment in comments) {
        final replyIndex = comment.replies.indexWhere((r) => r.id == commentId);
        if (replyIndex != -1) {
          comment.replies.removeAt(replyIndex);
          break;
        }
        // Also check nested replies recursively
        if (_removeFromNestedReplies(comment.replies, commentId)) {
          break;
        }
      }
    }
    comments.refresh(); // Instant UI update
    
    // Update post comment count immediately (optimistic)
    if (currentPostId.value > 0 && Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        final currentPost = homeController.posts.firstWhereOrNull((p) => p.id == currentPostId.value);
        if (currentPost != null) {
          final currentCount = homeController.getCommentCount(currentPost);
          final updatedCount = (currentCount - 1).clamp(0, double.infinity).toInt();
          homeController.updatePostCommentCount(currentPostId.value, updatedCount);
        }
      } catch (_) {}
    }

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
          // Get the updated comment count from API response (most accurate)
          final newCommentCount = response.body!['post_comment_count'];
          
          // Update post comment count in feed if HomeController exists
          if (currentPostId.value > 0 && Get.isRegistered<HomeController>()) {
            try {
              final homeController = Get.find<HomeController>();
              if (newCommentCount != null && newCommentCount is int) {
                // Use API response count (most accurate - includes all nested replies)
                homeController.updatePostCommentCount(currentPostId.value, newCommentCount);
              } else {
                // Fallback: Calculate from current comment count
                final currentPost = homeController.posts.firstWhereOrNull((p) => p.id == currentPostId.value);
                if (currentPost != null) {
                  final currentCount = homeController.getCommentCount(currentPost);
                  // Decrement by 1 (the deleted comment, nested replies are handled by server)
                  final updatedCount = (currentCount - 1).clamp(0, double.infinity).toInt();
                  homeController.updatePostCommentCount(currentPostId.value, updatedCount);
                }
              }
            } catch (_) {}
          }
          
          // Reload comments to ensure sync with server (gets accurate count and structure)
          if (currentPostId.value > 0) {
            await loadComments(currentPostId.value);
            // Update feed with actual count from reloaded comments
            if (Get.isRegistered<HomeController>()) {
              try {
                final homeController = Get.find<HomeController>();
                final actualCount = commentCount;
                homeController.updatePostCommentCount(currentPostId.value, actualCount);
              } catch (_) {}
            }
          }
          
          isDeleting.value = false;
          return true;
        } else {
          // API returned false - rollback optimistic update
          comments.value = originalComments;
          comments.refresh();
          if (currentPostId.value > 0 && Get.isRegistered<HomeController>()) {
            try {
              final homeController = Get.find<HomeController>();
              final currentPost = homeController.posts.firstWhereOrNull((p) => p.id == currentPostId.value);
              if (currentPost != null) {
                homeController.updatePostCommentCount(currentPostId.value, originalCommentCount);
              }
            } catch (_) {}
          }
          errorMessage.value = response.body!['message'] ?? 'Failed to delete comment';
        }
      } else {
        // API call failed - rollback optimistic update
        comments.value = originalComments;
        comments.refresh();
        if (currentPostId.value > 0 && Get.isRegistered<HomeController>()) {
          try {
            final homeController = Get.find<HomeController>();
            final currentPost = homeController.posts.firstWhereOrNull((p) => p.id == currentPostId.value);
            if (currentPost != null) {
              homeController.updatePostCommentCount(currentPostId.value, originalCommentCount);
            }
          } catch (_) {}
        }
        errorMessage.value = response.errorMessage ?? 'Failed to delete comment';
      }
    } catch (e) {
      // Exception occurred - rollback optimistic update
      comments.value = originalComments;
      comments.refresh();
      if (currentPostId.value > 0 && Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          final currentPost = homeController.posts.firstWhereOrNull((p) => p.id == currentPostId.value);
          if (currentPost != null) {
            homeController.updatePostCommentCount(currentPostId.value, originalCommentCount);
          }
        } catch (_) {}
      }
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isDeleting.value = false;
    }
    return false;
  }

  /// Helper to remove comment from nested replies recursively
  bool _removeFromNestedReplies(List<CommentModel> replies, int commentId) {
    for (var reply in replies) {
      if (reply.id == commentId) {
        replies.remove(reply);
        return true;
      }
      if (_removeFromNestedReplies(reply.replies, commentId)) {
        return true;
      }
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

