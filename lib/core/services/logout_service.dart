import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torko/presentation/conversation/controllers/chat_controller.dart';
import 'package:torko/presentation/post_detail/controllers/comment_controller.dart';
import 'package:torko/presentation/community/controllers/community_groups_controller.dart';
import 'package:torko/presentation/messages/controllers/inbox_controller.dart';
import 'package:torko/presentation/home/controllers/post_controller.dart';
import 'package:torko/presentation/saved_posts/controllers/saved_posts_controller.dart';
import 'package:torko/core/services/reverb_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/presentation/home/controllers/home_controller.dart';
import 'package:torko/presentation/profile/controllers/profile_controller.dart';

/// Centralized logout service that clears all user data from the app.
/// Order is critical: disconnect Reverb first, then storage/caches, then controllers.
class LogoutService {
  /// Clear all user-related data from the app.
  /// 1. Disconnect Reverb (unsubscribe, disconnect, reset state).
  /// 2. Clear GetStorage (UserInfo), SharedPreferences, image cache.
  /// 3. Clear GetX controller states.
  /// 4. Delete registered controllers (except permanent Chat/Inbox).
  static Future<void> clearAllData() async {
    try {
      await ReverbService().disconnect();
      await UserInfo.eraseAll();
      // 3. Clear SharedPreferences (profile completion steps, local paths, etc.)
      await _clearSharedPreferences();

      // 4. Clear image cache (CachedNetworkImage)
      await _clearImageCache();

      // 5. Clear GetX controller states
      _clearControllerStates();

      // 6. Delete registered controllers so they get fresh instances on next login
      _deleteControllers();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LogoutService.clearAllData error: $e');
      }
      // Even if some clearing fails, continue with the rest
    }
  }

  /// Clear all torko-related SharedPreferences data
  static Future<void> _clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all keys and remove those starting with 'torko_'
      final keys = prefs.getKeys().toList();
      for (final key in keys) {
        if (key.startsWith('torko_')) {
          await prefs.remove(key);
        }
      }
      
      // Also delete local image files if they exist
      await _deleteLocalImageFiles(prefs);
      
    } catch (e) {
      if (kDebugMode) debugPrint('[LogoutService] _clearSharedPreferences error: $e');
    }
  }
  
  /// Delete any locally saved image files
  static Future<void> _deleteLocalImageFiles(SharedPreferences prefs) async {
    try {
      // Try to delete profile image file
      final profilePath = prefs.getString('torko_profile_image_path');
      if (profilePath != null && profilePath.isNotEmpty) {
        final file = File(profilePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Try to delete cover image file
      final coverPath = prefs.getString('torko_cover_image_path');
      if (coverPath != null && coverPath.isNotEmpty) {
        final file = File(coverPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[LogoutService] _deleteLocalImageFiles error: $e');
    }
  }
  
  /// Clear CachedNetworkImage cache
  static Future<void> _clearImageCache() async {
    try {
      // Clear the default cache manager used by CachedNetworkImage
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      if (kDebugMode) debugPrint('[LogoutService] _clearImageCache error: $e');
    }
  }
  
  /// Clear state in registered controllers
  static void _clearControllerStates() {
    try {
      // Clear PostController if registered
      if (Get.isRegistered<PostController>()) {
        final postController = Get.find<PostController>();
        postController.clearPosts();
        postController.clearForm();
      }
      
      // Clear ProfileController if registered
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.name.value = '';
        profileController.address.value = '';
        profileController.bio.value = '';
        profileController.profileFile.value = null;
        profileController.coverFile.value = null;
        profileController.profileImageUrl.value = '';
        profileController.coverImageUrl.value = '';
        profileController.hasProfilePhoto.value = false;
        profileController.hasBio.value = false;
        profileController.hasCoverPhoto.value = false;
        profileController.hasFirstPost.value = false;
        profileController.likedPosts.clear();
        profileController.likedPolls.clear();
        profileController.likedSaved.clear();
      }
      
      // Clear HomeController if registered
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.posts.clear();
        homeController.hiddenPosts.clear();
        homeController.likedPosts.clear();
        homeController.followingUsers.clear();
        homeController.errorMessage.value = '';
      }

      // Clear SavedPostsController if registered
      if (Get.isRegistered<SavedPostsController>()) {
        Get.find<SavedPostsController>().savedPosts.clear();
      }
      
      // Clear CommentController if registered
      if (Get.isRegistered<CommentController>()) {
        final commentController = Get.find<CommentController>();
        commentController.clearComments();
      }
      
      // Clear CommunityGroupsController state (groups are user-specific)
      if (Get.isRegistered<CommunityGroupsController>()) {
        final gc = Get.find<CommunityGroupsController>();
        gc.groups.clear();
        gc.error.value = '';
        gc.isLoading.value = false;
      }

      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().clearChat();
      }
      if (Get.isRegistered<InboxController>()) {
        final inboxController = Get.find<InboxController>();
        inboxController.threads.clear();
        inboxController.searchResults.clear();
        inboxController.searchEC.clear();
        inboxController.isSearchMode.value = false;
        inboxController.searching.value = false;
        inboxController.searchError.value = '';
        inboxController.error.value = '';
        inboxController.loading.value = false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[LogoutService] _clearControllerStates error: $e');
    }
  }
  
  /// Delete GetX controllers so they are re-created fresh on next login
  static void _deleteControllers() {
    try {
      if (Get.isRegistered<PostController>()) {
        Get.delete<PostController>(force: true);
      }
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>(force: true);
      }
      if (Get.isRegistered<CommentController>()) {
        Get.delete<CommentController>(force: true);
      }
      if (Get.isRegistered<ChatController>()) {
        Get.delete<ChatController>(force: true);
      }
      if (Get.isRegistered<InboxController>()) {
        Get.delete<InboxController>(force: true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[LogoutService] _deleteControllers error: $e');
    }
  }
}

