import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import '../services/user_info.dart';
import 'package:flutter/services.dart';

class PostController extends GetxController {
  // State
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<PostModel?> selectedPost = Rx<PostModel?>(null);

  // Create/Update state
  final RxString postTitle = ''.obs;
  final RxString postDescription = ''.obs;
  final RxList<File> selectedImages = <File>[].obs;
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;

  // Track current user ID to detect user changes
  int? _lastUserId;

  @override
  void onInit() {
    super.onInit();
    _lastUserId = UserInfo.userId;
    // Don't auto-load posts on init - let views decide when to load
  }

  // ==================== Helper: Fetch User ID ====================
  /// Fetches user ID from API if not stored locally
  Future<int?> _ensureUserId() async {
    // If we already have userId, return it
    if (UserInfo.userId != null) {
      print('DEBUG _ensureUserId: Already have userId = ${UserInfo.userId}');
      return UserInfo.userId;
    }

    print('DEBUG _ensureUserId: No userId stored, fetching from API...');
    
    // Try to fetch user profile from update_users API
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      print('DEBUG _ensureUserId: No token available');
      return null;
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.update_users,
        body: {
          'api_token': token,
        },
      );

      print('DEBUG _ensureUserId: API response success = ${response.isSuccess}');
      
      if (response.isSuccess && response.body != null) {
        final data = response.body!;
        print('DEBUG _ensureUserId: Response data = $data');
        
        if (data['status'] == true && data['data'] != null) {
          final userData = data['data'];
          final userId = userData['id'];
          print('DEBUG _ensureUserId: Found userId = $userId (type: ${userId.runtimeType})');
          
          if (userId != null) {
            if (userId is int) {
              await UserInfo.setUserId(userId);
              return userId;
            } else if (userId is String) {
              final parsedId = int.tryParse(userId) ?? 0;
              await UserInfo.setUserId(parsedId);
              return parsedId;
            }
          }
        }
      }
    } catch (e) {
      print('DEBUG _ensureUserId: Error = $e');
    }
    return null;
  }

  // ==================== Get All Posts ====================
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

  // ==================== Get User Posts (Profile-specific) ====================
  /// Loads only posts created by the currently logged-in user
  /// This is used for the Profile page to show user-specific posts
  Future<void> loadUserPosts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = UserInfo.apiToken;
      
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login first';
        isLoading.value = false;
        posts.value = []; // Clear posts if not logged in
        return;
      }

      // Try to get userId, fetch from API if not available
      int? currentUserId = UserInfo.userId;
      print('DEBUG loadUserPosts: Initial userId from storage = $currentUserId');
      
      if (currentUserId == null) {
        print('DEBUG loadUserPosts: userId is null, calling _ensureUserId()');
        currentUserId = await _ensureUserId();
        print('DEBUG loadUserPosts: After _ensureUserId(), userId = $currentUserId');
      }

      if (currentUserId == null) {
        print('DEBUG loadUserPosts: userId is still null, returning empty');
        errorMessage.value = 'User ID not found';
        isLoading.value = false;
        posts.value = []; // Clear posts if user ID is missing
        _lastUserId = null;
        return;
      }
      
      print('DEBUG loadUserPosts: Using userId = $currentUserId for filtering');

      // Clear posts if user has changed (new login)
      if (_lastUserId != null && _lastUserId != currentUserId) {
        posts.value = [];
      }
      _lastUserId = currentUserId;

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
            // Filter posts by current user's ID
            final allPosts = data.map((json) => PostModel.fromJson(json)).toList();
            print('DEBUG loadUserPosts: Total posts from API = ${allPosts.length}');
            print('DEBUG loadUserPosts: Post userIds = ${allPosts.map((p) => p.userId).toList()}');
            print('DEBUG loadUserPosts: Filtering for userId = $currentUserId');
            
            posts.value = allPosts.where((post) => post.userId == currentUserId).toList();
            print('DEBUG loadUserPosts: Filtered posts count = ${posts.length}');
            errorMessage.value = '';
          } else {
            errorMessage.value = 'Invalid response format';
            posts.value = [];
          }
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to load posts';
          posts.value = [];
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load posts';
        posts.value = [];
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      posts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Get Single Post ====================
  Future<PostModel?> getSinglePost(int postId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = UserInfo.apiToken;
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login first';
        isLoading.value = false;
        return null;
      }

      final response = await NetworkCaller.postRequest(
        url: Urls.single_post,
        body: {
          'api_token': token,
          'id': postId,
        },
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          final data = response.body!['data'];
          final post = PostModel.fromJson(data);
          selectedPost.value = post;
          isLoading.value = false;
          return post;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to load post';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load post';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  // ==================== Create Post ====================
  Future<bool> createPost({
    required String title,
    required String description,
    required List<File> images,
    File? video,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final token = UserInfo.apiToken;
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login first';
        isCreating.value = false;
        return false;
      }

      // Convert images to base64
      List<String> base64Images = [];
      for (var image in images) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Images.add('data:image/jpeg;base64,$base64String');
      }

      // Convert video to base64 if provided
      if (video != null) {
        final bytes = await video.readAsBytes();
        final base64String = base64Encode(bytes);
        // Determine video MIME type (default to mp4, but could be detected from file extension)
        final videoExtension = video.path.split('.').last.toLowerCase();
        final mimeType = videoExtension == 'mp4' 
            ? 'video/mp4' 
            : videoExtension == 'mov' 
                ? 'video/quicktime'
                : 'video/mp4'; // default
        base64Images.add('data:$mimeType;base64,$base64String');
      }

      final response = await NetworkCaller.postRequest(
        url: Urls.create_post,
        body: {
          'api_token': token,
          'post_title': title,
          'post_description': description,
          'base64_images': base64Images,
        },
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Reload user's posts only
          await loadUserPosts();
          // Clear form
          postTitle.value = '';
          postDescription.value = '';
          selectedImages.clear();
          selectedVideo.value = null;
          isCreating.value = false;
          return true;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to create post';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to create post';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isCreating.value = false;
    }
    return false;
  }

  // ==================== Update Post ====================
  Future<bool> updatePost({
    required int postId,
    required String title,
    required String description,
    required List<File> images,
    List<String>? existingImageUrls, // URLs of existing images to keep
  }) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final token = UserInfo.apiToken;
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login first';
        isUpdating.value = false;
        return false;
      }

      // Convert images to base64
      List<String> base64Images = [];
      
      // First, add existing images (download and convert to base64)
      if (existingImageUrls != null && existingImageUrls.isNotEmpty) {
        for (var imageUrl in existingImageUrls) {
          try {
            final fullUrl = imageUrl.startsWith('http') 
                ? imageUrl 
                : 'https://torko.attoexasolutions.com/$imageUrl';
            final base64String = await _downloadAndConvertToBase64(fullUrl);
            if (base64String != null) {
              base64Images.add(base64String);
            }
          } catch (e) {
            print('Error downloading existing image $imageUrl: $e');
            // Continue with other images even if one fails
          }
        }
      }
      
      // Then, add new images
      for (var image in images) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Images.add('data:image/jpeg;base64,$base64String');
      }

      final response = await NetworkCaller.postRequest(
        url: Urls.update_post,
        body: {
          'api_token': token,
          'id': postId,
          'post_title': title,
          'post_description': description,
          'base64_images': base64Images,
        },
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Reload user's posts only
          await loadUserPosts();
          // Clear form
          postTitle.value = '';
          postDescription.value = '';
          selectedImages.clear();
          isUpdating.value = false;
          return true;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to update post';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to update post';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isUpdating.value = false;
    }
    return false;
  }

  // Helper method to download image from URL and convert to base64
  Future<String?> _downloadAndConvertToBase64(String imageUrl) async {
    HttpClient? httpClient;
    try {
      httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(imageUrl));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final bytes = <int>[];
        await for (var data in response) {
          bytes.addAll(data);
        }
        final base64String = base64Encode(bytes);
        httpClient.close();
        return 'data:image/jpeg;base64,$base64String';
      }
      httpClient.close();
      return null;
    } catch (e) {
      print('Error downloading image $imageUrl: $e');
      httpClient?.close();
      return null;
    }
  }

  // ==================== Delete Post ====================
  Future<bool> deletePost(int postId) async {
    isDeleting.value = true;
    errorMessage.value = '';

    try {
      final token = UserInfo.apiToken;
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login first';
        isDeleting.value = false;
        return false;
      }

      final response = await NetworkCaller.postRequest(
        url: Urls.delete_post,
        body: {
          'api_token': token,
          'id': postId,
        },
      );

      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Remove from list
          posts.removeWhere((post) => post.id == postId);
          isDeleting.value = false;
          return true;
        } else {
          errorMessage.value = response.body!['message'] ?? 'Failed to delete post';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to delete post';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isDeleting.value = false;
    }
    return false;
  }

  // ==================== Image Picker ====================
  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        selectedImages.value = pickedFiles.map((file) => File(file.path)).toList();
      }
    } catch (e) {
      errorMessage.value = 'Error picking images: ${e.toString()}';
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void clearForm() {
    postTitle.value = '';
    postDescription.value = '';
    selectedImages.clear();
    selectedVideo.value = null;
  }

  void removeVideo() {
    selectedVideo.value = null;
  }

  /// Clear all posts (useful when user logs out or changes)
  void clearPosts() {
    posts.value = [];
    _lastUserId = null;
    errorMessage.value = '';
  }
}

