import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/presentation/main/controllers/navigation_controller.dart';
import 'package:torko/presentation/saved_posts/controllers/saved_posts_controller.dart';
import 'package:torko/data/models/post_model.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/core/services/post_api_service.dart';
import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/user_info.dart';

class HomeController extends GetxController {
  final RxString activeTab = 'forYou'.obs;
  final RxBool showHeader = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxSet<int> hiddenPosts = <int>{}.obs;
  final RxSet<int> likedPosts = <int>{}.obs;
  final RxMap<int, int> postLikeCounts = <int, int>{}.obs;
  final RxMap<int, int> postShareCounts = <int, int>{}.obs;
  final RxSet<int> likingInProgress = <int>{}.obs;
  final RxSet<int> sharingInProgress = <int>{}.obs;
  final RxSet<String> followingUsers = <String>{}.obs;
  
  final ScrollController scrollController = ScrollController();
  double lastScrollY = 0;

  // Report dialog state
  final RxBool reportDialogOpen = false.obs;
  final RxInt reportingPostId = 0.obs;
  final RxInt reportStep = 1.obs;
  final RxString reportReason = ''.obs;
  final RxString reportSubReason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    _initializeFollowingUsers();
    loadAllPosts();
    
    // Set navigation state to home
    _navController.setCurrentScreen('home');
  }

  @override
  void onClose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _initializeFollowingUsers() {
    // Initialize with some default following users (can be loaded from API later)
    followingUsers.addAll(['Michael Chen', 'David Rodriguez', 'James Park']);
  }

  void _handleScroll() {
    final appController = Get.find<AppController>();
    final currentScrollY = scrollController.offset;
    final scrollDelta = currentScrollY - lastScrollY;
    
    if (currentScrollY < 10) {
      showHeader.value = true;
      appController.setHideBottomNav(false);
    } else if (scrollDelta > 15 && currentScrollY > 20) {
      showHeader.value = false;
      appController.setHideBottomNav(true);
    } else if (scrollDelta < -5) {
      showHeader.value = true;
      appController.setHideBottomNav(false);
    }
    
    lastScrollY = currentScrollY;
  }

  // ==================== Load All Posts from API ====================
  Future<void> loadAllPosts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = UserInfo.apiToken;
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login first';
        isLoading.value = false;
        return;
      }

      // Backend requires POST with api_token
      final response = await NetworkCaller.postRequest(
        url: Urls.get_all_post,
        body: {'api_token': token},
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          final data = response.body!['data'];
          if (data is List) {
            posts.value = data.map((json) {
              final post = PostModel.fromJson(json);
              if (kDebugMode) {
                print('DEBUG loadAllPosts: postId=${post.id} is_like=${post.isLike} isLiked=${post.isLiked}');
              }
              return post;
            }).toList();
            errorMessage.value = '';
          } else {
            errorMessage.value = 'Invalid response format';
          }
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to load posts';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load posts';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    await loadAllPosts();
  }

  // Get filtered posts based on active tab
  List<PostModel> get filteredPosts {
    final visiblePosts = posts.where((post) => !hiddenPosts.contains(post.id)).toList();
    
    switch (activeTab.value) {
      case 'following':
        return visiblePosts.where((post) {
          final authorName = post.createdBy?.name ?? '';
          return followingUsers.contains(authorName);
        }).toList();
      case 'trending':
        final sorted = List<PostModel>.from(visiblePosts);
        sorted.sort((a, b) {
          final aScore = a.postLikeCount + a.postCommentCount + a.postShareCount;
          final bScore = b.postLikeCount + b.postCommentCount + b.postShareCount;
          return bScore.compareTo(aScore);
        });
        return sorted;
      case 'forYou':
      default:
        return visiblePosts;
    }
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
  }

  /// Handle like button tap with API call and optimistic update
  Future<void> handleLike(int postId) async {
    // Prevent rapid taps - if already processing, ignore
    if (likingInProgress.contains(postId)) return;
    
    // Get token
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      final appController = Get.find<AppController>();
      final isBn = appController.language == AppLanguage.bn;
      appController.showNotification(
        title: isBn ? 'ত্রুটি' : 'Error',
        message: isBn ? 'অনুগ্রহ করে আগে লগইন করুন' : 'Please login first',
      );
      return;
    }
    
    // Store original state for rollback
    final bool wasLiked = likedPosts.contains(postId);
    final int? originalCount = postLikeCounts[postId];
    
    // Optimistic update
    likingInProgress.add(postId);
    if (wasLiked) {
      likedPosts.remove(postId);
      if (postLikeCounts.containsKey(postId)) {
        postLikeCounts[postId] = (postLikeCounts[postId] ?? 1) - 1;
      }
    } else {
      likedPosts.add(postId);
      final post = posts.firstWhereOrNull((p) => p.id == postId);
      final currentCount = postLikeCounts[postId] ?? post?.postLikeCount ?? 0;
      postLikeCounts[postId] = currentCount + 1;
    }
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    try {
      // Make API call
      final response = await NetworkCaller.postRequest(
        url: Urls.like_create,
        body: {
          'api_token': token,
          'post_id': postId,
        },
      );
      
      print('DEBUG handleLike: Response = ${response.body}');
      
      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Sync with API response
          final int likeStatus = response.body!['like'] ?? (likedPosts.contains(postId) ? 1 : 0);
          final int serverLikeCount = response.body!['post_like_count'] ?? postLikeCounts[postId] ?? 0;
          
          // Update state based on server response
          if (likeStatus == 1) {
            likedPosts.add(postId);
          } else {
            likedPosts.remove(postId);
          }
          postLikeCounts[postId] = serverLikeCount;
          
          // Update the post model's isLike field to sync with server
          final postIndex = posts.indexWhere((p) => p.id == postId);
          if (postIndex != -1) {
            posts[postIndex] = posts[postIndex].copyWith(isLike: likeStatus);
          }
          
          print('DEBUG handleLike: Success - liked=$likeStatus, count=$serverLikeCount');
        } else {
          // API returned false status - rollback
          _rollbackLike(postId, wasLiked, originalCount);
          print('DEBUG handleLike: API returned false - ${response.body!['message']}');
        }
      } else {
        // API call failed - rollback
        _rollbackLike(postId, wasLiked, originalCount);
        print('DEBUG handleLike: API failed - ${response.errorMessage}');
      }
    } catch (e) {
      // Exception - rollback
      _rollbackLike(postId, wasLiked, originalCount);
      print('DEBUG handleLike: Exception - $e');
    } finally {
      likingInProgress.remove(postId);
    }
  }
  
  /// Rollback like state on failure
  void _rollbackLike(int postId, bool wasLiked, int? originalCount) {
    if (wasLiked) {
      likedPosts.add(postId);
    } else {
      likedPosts.remove(postId);
    }
    if (originalCount != null) {
      postLikeCounts[postId] = originalCount;
    } else {
      postLikeCounts.remove(postId);
    }
    HapticFeedback.heavyImpact();
  }

  /// Check if a post is liked
  /// Uses the is_like field from API response (post.isLiked) as primary source
  /// Falls back to likedPosts set for optimistic updates
  bool isPostLiked(int postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post != null) {
      // Use the isLiked getter from PostModel (based on is_like field from API)
      // This is the source of truth from the API
      return post.isLiked;
    }
    // Fallback to likedPosts set (for optimistic updates during like action)
    return likedPosts.contains(postId);
  }
  
  /// Check if like action is in progress for a post
  bool isLiking(int postId) => likingInProgress.contains(postId);

  int getLikeCount(PostModel post) {
    // Use tracked count if available, otherwise use original from API
    if (postLikeCounts.containsKey(post.id)) {
      return postLikeCounts[post.id] ?? post.postLikeCount;
    }
    return post.postLikeCount;
  }

  // Track updated comment counts
  final RxMap<int, int> postCommentCounts = <int, int>{}.obs;

  /// Update post comment count in the feed
  void updatePostCommentCount(int postId, int newCount) {
    postCommentCounts[postId] = newCount;
    
    // Trigger reactive update - UI will use getCommentCount which checks postCommentCounts
    posts.refresh();
  }

  /// Get current comment count for a post (uses tracked count if available)
  int getCommentCount(PostModel post) {
    if (postCommentCounts.containsKey(post.id)) {
      return postCommentCounts[post.id] ?? post.postCommentCount;
    }
    return post.postCommentCount;
  }

  void handleComment(int postId) {
    // Find the post and pass full data
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post != null) {
      final appController = Get.find<AppController>();
      appController.openPostDetail({
        'id': post.id,
        'post_title': post.postTitle,
        'post_description': post.postDescription,
        'post_images': post.postImages,
        'post_like_count': post.postLikeCount,
        'post_comment_count': post.postCommentCount,
        'createdBy': {
          'name': post.createdBy?.name ?? 'User',
        },
        'created_at': post.createdAt,
      });
    }
    Get.toNamed(AppRoutes.postDetail, arguments: {'postId': postId.toString()});
  }

  Future<void> handleShare(int postId) async {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'সেশন শেষ। আবার লগইন করুন।' : 'Session expired. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (sharingInProgress.contains(postId)) return;
    sharingInProgress.add(postId);
    try {
      await PostApiService.sharePost(postId: postId);
      final post = posts.firstWhereOrNull((p) => p.id == postId);
      final current = postShareCounts[postId] ?? post?.postShareCount ?? 0;
      postShareCounts[postId] = current + 1;
      posts.refresh();
      Get.snackbar(
        isBn ? 'শেয়ার হয়েছে' : 'Post shared successfully',
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        e is PostApiException ? e.message : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      sharingInProgress.remove(postId);
    }
  }

  int getShareCount(PostModel post) {
    if (postShareCounts.containsKey(post.id)) {
      return postShareCounts[post.id] ?? post.postShareCount;
    }
    return post.postShareCount;
  }

  void handleSavePost(int postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;
    if (!Get.isRegistered<SavedPostsController>()) {
      Get.put(SavedPostsController());
    }
    Get.find<SavedPostsController>().toggleSave(post);
  }

  void handleHidePost(int postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    hiddenPosts.add(postId);
    posts.refresh();
    
    appController.showNotification(
      title: isBn ? 'লুকানো' : 'Hidden',
      message: isBn ? 'পোস্ট লুকানো হয়েছে' : 'Post hidden',
    );
  }

  void handleFollowUser(String author) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    if (followingUsers.contains(author)) {
      followingUsers.remove(author);
      appController.showNotification(
        title: isBn ? 'আনফলো' : 'Unfollowed',
        message: isBn ? '$author কে আনফলো করা হয়েছে' : 'Unfollowed $author',
      );
    } else {
      followingUsers.add(author);
      appController.showNotification(
        title: isBn ? 'ফলো' : 'Following',
        message: isBn ? '$author কে ফলো করা হয়েছে' : 'Following $author',
      );
    }
  }

  void handleReportPost(int postId) {
    reportingPostId.value = postId;
    reportDialogOpen.value = true;
    reportStep.value = 1;
    reportReason.value = '';
    reportSubReason.value = '';
  }

  void handleCopyLink(int postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    appController.showNotification(
      title: isBn ? 'কপি' : 'Copied',
      message: isBn ? 'লিংক কপি করা হয়েছে' : 'Link copied',
    );
  }

  void submitReport() {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    reportDialogOpen.value = false;
    reportStep.value = 1;
    reportReason.value = '';
    reportSubReason.value = '';
    reportingPostId.value = 0;
    
    appController.showNotification(
      title: isBn ? 'রিপোর্ট' : 'Reported',
      message: isBn ? 'আপনার রিপোর্ট জমা দেওয়া হয়েছে। ধন্যবাদ!' : 'Your report has been submitted. Thank you!',
    );
  }

  void cancelReport() {
    reportDialogOpen.value = false;
    reportStep.value = 1;
    reportReason.value = '';
    reportSubReason.value = '';
    reportingPostId.value = 0;
  }

  void setReportStep(int step) {
    reportStep.value = step;
  }

  void setReportReason(String reason) {
    reportReason.value = reason;
  }

  void setReportSubReason(String subReason) {
    reportSubReason.value = subReason;
  }

  bool isPostSaved(int postId) =>
      posts.firstWhereOrNull((p) => p.id == postId)?.saved ?? false;
  bool isFollowing(String author) => followingUsers.contains(author);

  NavigationController get _navController {
    if (Get.isRegistered<NavigationController>()) {
      return Get.find<NavigationController>();
    } else {
      return Get.put(NavigationController(), permanent: true);
    }
  }

  void onNavigate(String screen) {
    _navController.navigateTo(screen);
  }

  // Helper to format timestamp
  String formatTimestamp(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      final appController = Get.find<AppController>();
      final isBn = appController.language == AppLanguage.bn;
      
      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}${isBn ? 'দি' : 'd'}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}${isBn ? 'ঘ' : 'h'}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}${isBn ? 'মি' : 'm'}';
      } else {
        return isBn ? 'এখনই' : 'now';
      }
    } catch (e) {
      return '';
    }
  }

  // Get full image URL
  String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return 'https://torko.attoexasolutions.com/$imagePath';
  }
}

