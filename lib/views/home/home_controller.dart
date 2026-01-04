import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/post_model.dart';
import '../../services/network_caller.dart';
import '../../services/urls.dart';
import '../../services/user_info.dart';

class HomeController extends GetxController {
  final RxString activeTab = 'forYou'.obs;
  final RxBool showHeader = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxSet<int> savedPosts = <int>{}.obs;
  final RxSet<int> hiddenPosts = <int>{}.obs;
  final RxSet<int> likedPosts = <int>{}.obs;
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

      // Try GET first, if it fails, try POST with api_token
      var response = await NetworkCaller.getRequest(
        url: Urls.get_all_post,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // If GET fails, try POST with api_token in body
      if (!response.isSuccess) {
        response = await NetworkCaller.postRequest(
          url: Urls.get_all_post,
          body: {
            'api_token': token,
          },
        );
      }

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          final data = response.body!['data'];
          if (data is List) {
            posts.value = data.map((json) => PostModel.fromJson(json)).toList();
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

  void handleLike(int postId) {
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
    } else {
      likedPosts.add(postId);
    }
  }

  bool isPostLiked(int postId) => likedPosts.contains(postId);

  int getLikeCount(PostModel post) {
    final baseLikes = post.postLikeCount;
    if (likedPosts.contains(post.id)) {
      return baseLikes + 1;
    }
    return baseLikes;
  }

  void handleComment(int postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: {'postId': postId.toString()});
  }

  void handleShare(int postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    appController.showNotification(
      title: isBn ? 'শেয়ার' : 'Share',
      message: isBn ? 'শেয়ার ফিচার শীঘ্রই আসছে!' : 'Share feature coming soon!',
    );
  }

  void handleSavePost(int postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    if (savedPosts.contains(postId)) {
      savedPosts.remove(postId);
      appController.showNotification(
        title: isBn ? 'আনসেভ' : 'Unsaved',
        message: isBn ? 'পোস্ট আনসেভ করা হয়েছে' : 'Post unsaved',
      );
    } else {
      savedPosts.add(postId);
      appController.showNotification(
        title: isBn ? 'সেভ' : 'Saved',
        message: isBn ? 'পোস্ট সেভ করা হয়েছে' : 'Post saved',
      );
    }
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

  bool isPostSaved(int postId) => savedPosts.contains(postId);
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

