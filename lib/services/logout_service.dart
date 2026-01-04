import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/post_controller.dart';
import '../views/profile/profile_controller.dart';
import '../views/home/home_controller.dart';
import 'user_info.dart';

/// Centralized logout service that clears all user data from the app
class LogoutService {
  /// Clear all user-related data from the app
  /// This includes:
  /// - GetStorage (UserInfo)
  /// - SharedPreferences (profile completion, local image paths, etc.)
  /// - CachedNetworkImage cache
  /// - GetX controller states
  static Future<void> clearAllData() async {
    try {
      // 1. Clear GetStorage (UserInfo - token, profile data, etc.)
      await UserInfo.eraseAll();
      
      // 2. Clear SharedPreferences (profile completion steps, local paths, etc.)
      await _clearSharedPreferences();
      
      // 3. Clear image cache (CachedNetworkImage)
      await _clearImageCache();
      
      // 4. Clear GetX controller states
      _clearControllerStates();
      
      // 5. Delete registered controllers so they get fresh instances on next login
      _deleteControllers();
      
    } catch (e) {
      print('LogoutService.clearAllData error: $e');
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
      print('LogoutService._clearSharedPreferences error: $e');
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
      print('LogoutService._deleteLocalImageFiles error: $e');
    }
  }
  
  /// Clear CachedNetworkImage cache
  static Future<void> _clearImageCache() async {
    try {
      // Clear the default cache manager used by CachedNetworkImage
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      print('LogoutService._clearImageCache error: $e');
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
        homeController.savedPosts.clear();
        homeController.hiddenPosts.clear();
        homeController.likedPosts.clear();
        homeController.followingUsers.clear();
        homeController.errorMessage.value = '';
      }
    } catch (e) {
      print('LogoutService._clearControllerStates error: $e');
    }
  }
  
  /// Delete GetX controllers so they are re-created fresh on next login
  static void _deleteControllers() {
    try {
      // Delete controllers that store user-specific data
      if (Get.isRegistered<PostController>()) {
        Get.delete<PostController>(force: true);
      }
      
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
      }
      
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>(force: true);
      }
    } catch (e) {
      print('LogoutService._deleteControllers error: $e');
    }
  }
}

