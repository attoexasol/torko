import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/home/controllers/post_controller.dart';
import 'package:torko/presentation/profile/controllers/profile_timeline_controller.dart';
import 'package:torko/core/services/post_api_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/post_model.dart';
import 'package:torko/data/models/timeline_item.dart';
import 'package:torko/presentation/home/controllers/home_controller.dart';

/// Controller for managing saved posts
class SavedPostsController extends GetxController {
  final RxList<PostModel> savedPosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get loadingSaved => isLoading.value;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('🔍 [SavedPostsController] onInit called');
    }
  }

  /// Fetch saved posts from API
  Future<void> fetchSaved() async {
    await _fetchSavedImpl();
  }

  /// Legacy alias
  Future<void> fetchSavedPosts() async {
    await _fetchSavedImpl();
  }

  /// Alias for fetchSaved (used by profile Saved tab)
  Future<void> loadSavedPosts() async {
    await _fetchSavedImpl();
  }

  Future<void> _fetchSavedImpl() async {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [fetchSavedPosts] fetchSavedPosts() called');
    }
    
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('❌ [fetchSavedPosts] Token is null or empty');
      }
      error.value = 'Session expired. Please login again.';
      isLoading.value = false;
      return;
    }

    if (kDebugMode) {
      print('✅ [fetchSavedPosts] Token found (length: ${token.length})');
    }

    isLoading.value = true;
    error.value = '';

    try {
      if (kDebugMode) {
        print('🔄 [fetchSavedPosts] Calling PostApiService.getSavedPosts()...');
      }
      
      final posts = await PostApiService.getSavedPosts();
      
      if (kDebugMode) {
        print('✅ [fetchSavedPosts] API returned ${posts.length} saved posts');
      }
      
      savedPosts.assignAll(posts);
      error.value = '';

      if (kDebugMode) {
        print('✅ [fetchSavedPosts] Saved posts list updated (length: ${savedPosts.length})');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      error.value = e is PostApiException 
          ? e.message 
          : 'Failed to load saved posts';
      
      savedPosts.clear();

      if (kDebugMode) {
        print('❌ [fetchSavedPosts] Error: $e');
        print('   Stack trace: $stackTrace');
        print('═══════════════════════════════════════════════════════════');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull to refresh saved posts
  Future<void> refreshSavedPosts() async {
    await _fetchSavedImpl();
  }

  /// Toggle save state: if saved -> unsave, else -> save. Updates UI only on API success.
  Future<void> toggleSave(PostModel post) async {
    final int postId = post.id is int ? post.id : int.parse(post.id.toString());
    try {
      if (post.saved) {
        await PostApiService.unsavePost(postId: postId);
        savedPosts.removeWhere((p) => p.id == postId);
        _updatePostSaveInSources(postId, 0);
        Get.snackbar(
          _isBn ? 'সংরক্ষণ তুলে নেওয়া হয়েছে' : 'Removed from Saved',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        await PostApiService.savePost(postId: postId);
        _updatePostSaveInSources(postId, 1);
        Get.snackbar(
          _isBn ? 'সংরক্ষিত' : 'Saved',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        await _fetchSavedImpl();
      }
    } catch (e) {
      Get.snackbar(
        _isBn ? 'ত্রুটি' : 'Error',
        e is PostApiException ? e.message : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  bool get _isBn =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().language == AppLanguage.bn;

  void _updatePostSaveInSources(int postId, int isSave) {
    if (Get.isRegistered<HomeController>()) {
      final c = Get.find<HomeController>();
      final i = c.posts.indexWhere((p) => p.id == postId);
      if (i >= 0) {
        c.posts[i] = c.posts[i].copyWith(isSave: isSave);
        c.posts.refresh();
      }
    }
    if (Get.isRegistered<PostController>()) {
      final c = Get.find<PostController>();
      final i = c.posts.indexWhere((p) => p.id == postId);
      if (i >= 0) {
        c.posts[i] = c.posts[i].copyWith(isSave: isSave);
        c.posts.refresh();
      }
    }
    if (Get.isRegistered<ProfileTimelineController>()) {
      final c = Get.find<ProfileTimelineController>();
      final idx = c.timeline.indexWhere((t) => t.post.id == postId);
      if (idx >= 0) {
        final it = c.timeline[idx];
        c.timeline[idx] = TimelineItem(
          type: it.type,
          timelineTime: it.timelineTime,
          sharedByUserId: it.sharedByUserId,
          sharedAt: it.sharedAt,
          post: it.post.copyWith(isSave: isSave),
        );
        c.timeline.refresh();
      }
    }
  }
}
