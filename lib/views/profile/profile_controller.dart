import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/network_caller.dart';
import '../../services/urls.dart';
import '../../services/user_info.dart';

class ProfileController extends GetxController {
  final appController = Get.find<AppController>();
  final ImagePicker _imagePicker = ImagePicker();

  // ==================== Text Controllers ====================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // ==================== Observable States ====================
  // Edit mode
  final RxBool isEditMode = false.obs;
  final RxBool isBioEditing = false.obs; // Separate state for bio-only editing
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isSavingBio = false.obs; // Separate state for bio saving
  final RxBool isUploadingProfile = false.obs;
  final RxBool isUploadingCover = false.obs;

  // Profile data
  final RxString name = 'Thomas R.'.obs;
  final RxString address = 'Dhaka, Bangladesh'.obs;
  final RxString bio = ''.obs;
  final Rx<File?> profileFile = Rx<File?>(null);
  final Rx<File?> coverFile = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxString coverImageUrl = ''.obs;

  // Saved values for cancel/revert
  String _savedName = 'Thomas R.';
  String _savedAddress = 'Dhaka, Bangladesh';
  String _savedBio = '';

  // Profile completion steps
  final RxBool hasProfilePhoto = false.obs;
  final RxBool hasBio = false.obs;
  final RxBool hasCoverPhoto = false.obs;
  final RxBool hasFirstPost = false.obs;

  // Tab state
  final RxString activeTab = 'post'.obs;

  // Like states
  final RxSet<int> likedPosts = <int>{}.obs;
  final RxSet<int> likedPolls = <int>{}.obs;
  final RxSet<int> likedSaved = <int>{}.obs;

  // ==================== Computed Properties ====================
  int get currentStep {
    if (!hasProfilePhoto.value) return 1;
    if (!hasBio.value) return 2;
    if (!hasCoverPhoto.value) return 3;
    if (!hasFirstPost.value) return 4;
    return 4;
  }

  int get completedItems {
    int count = 0;
    if (hasProfilePhoto.value) count++;
    if (hasBio.value) count++;
    if (hasCoverPhoto.value) count++;
    if (hasFirstPost.value) count++;
    return count;
  }

  int get completionPercentage => completedItems * 25;
  bool get isProfileComplete => completionPercentage == 100;

  bool canAccessStep(int stepNumber) => stepNumber <= currentStep;

  List<Map<String, dynamic>> get profileCompletionItems {
    final isBn = appController.language == AppLanguage.bn;
    return [
      {
        'id': 'profile_photo',
        'step': 1,
        'completed': hasProfilePhoto.value,
        'label': isBn ? 'প্রোফাইল ছবি আপলোড করুন' : 'Upload a profile photo',
        'action': 'upload_profile',
      },
      {
        'id': 'bio',
        'step': 2,
        'completed': hasBio.value,
        'label': isBn ? 'বায়ো যোগ করুন' : 'Add a bio',
        'action': 'add_bio',
      },
      {
        'id': 'cover_photo',
        'step': 3,
        'completed': hasCoverPhoto.value,
        'label': isBn ? 'কভার ছবি যোগ করুন' : 'Add a cover photo',
        'action': 'upload_cover',
      },
      {
        'id': 'first_post',
        'step': 4,
        'completed': hasFirstPost.value,
        'label': isBn ? 'প্রথম পোস্ট তৈরি করুন' : 'Create first post',
        'action': 'create_post',
      },
    ];
  }

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadUserFromLocal();
    _checkFromWelcome();
  }

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    bioController.dispose();
    super.onClose();
  }

  // ==================== Load Data ====================
  Future<void> loadUserFromLocal() async {
    isLoading.value = true;

    try {
      // Load from UserInfo (GetStorage)
      final storedName = UserInfo.fullname ?? '';
      final storedAddress = UserInfo.address ?? '';
      final storedBio = UserInfo.bio ?? '';
      final storedProfileImage = UserInfo.profileImage ?? '';
      final storedCoverImage = UserInfo.coverImage ?? '';

      // Load completion states from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hasProfile = prefs.getBool('torko_profile_step_1') ?? false;
      final hasBioStep = prefs.getBool('torko_profile_step_2') ?? false;
      final hasCover = prefs.getBool('torko_profile_step_3') ?? false;
      final hasPost = prefs.getBool('torko_profile_step_4') ?? false;

      // Load local image paths
      final profileImagePath = prefs.getString('torko_profile_image_path');
      final coverImagePath = prefs.getString('torko_cover_image_path');
      final localBio = prefs.getString('torko_profile_bio') ?? '';

      // Also check legacy profile JSON
      final profileStr = prefs.getString('torko_user_profile');
      if (profileStr != null) {
        try {
          final profile = jsonDecode(profileStr);
          if (storedName.isEmpty && profile['name'] != null) {
            _savedName = profile['name'];
          }
          if (storedAddress.isEmpty && profile['location'] != null) {
            _savedAddress = profile['location'];
          }
          if (storedBio.isEmpty && profile['bio'] != null) {
            _savedBio = profile['bio'];
          }
        } catch (_) {}
      }

      // Use stored values or fallback to legacy
      _savedName = storedName.isNotEmpty ? storedName : _savedName;
      _savedAddress = storedAddress.isNotEmpty ? storedAddress : _savedAddress;
      _savedBio = storedBio.isNotEmpty ? storedBio : (localBio.isNotEmpty ? localBio : _savedBio);

      // Update observables
      name.value = _savedName;
      address.value = _savedAddress;
      bio.value = _savedBio;
      profileImageUrl.value = storedProfileImage;
      coverImageUrl.value = storedCoverImage;
      // Update AppController for reactive updates in drawer
      if (storedProfileImage.isNotEmpty) {
        appController.updateProfileImageUrl(storedProfileImage);
      }

      // Update text controllers
      nameController.text = _savedName;
      locationController.text = _savedAddress;
      bioController.text = _savedBio;

      // Load local files if they exist
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        final file = File(profileImagePath);
        if (await file.exists()) {
          profileFile.value = file;
        }
      }

      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        final file = File(coverImagePath);
        if (await file.exists()) {
          coverFile.value = file;
        }
      }

      // Update completion states
      hasProfilePhoto.value = hasProfile || profileFile.value != null || storedProfileImage.isNotEmpty;
      hasBio.value = hasBioStep || _savedBio.isNotEmpty;
      hasCoverPhoto.value = hasCover || coverFile.value != null || storedCoverImage.isNotEmpty;
      hasFirstPost.value = hasPost;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkFromWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    final fromWelcome = prefs.getString('torko_from_welcome');
    if (fromWelcome == 'complete_profile') {
      isEditMode.value = true;
    }
  }

  // ==================== Edit Mode ====================
  void enterEditMode() {
    nameController.text = _savedName;
    locationController.text = _savedAddress;
    bioController.text = _savedBio;
    isEditMode.value = true;
  }

  void cancelEdit() {
    nameController.text = _savedName;
    locationController.text = _savedAddress;
    bioController.text = _savedBio;
    isEditMode.value = false;
  }

  // ==================== Bio-Only Editing ====================
  void enterBioEditMode() {
    bioController.text = _savedBio;
    isBioEditing.value = true;
  }

  void cancelBioEdit() {
    bioController.text = _savedBio;
    isBioEditing.value = false;
  }

  Future<bool> saveBio() async {
    if (isSavingBio.value) return false;

    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please login again.');
      Get.offAllNamed(AppRoutes.login);
      return false;
    }

    isSavingBio.value = true;

    // Get new bio value
    final newBio = bioController.text.trim();

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.update_users,
        body: {
          'api_token': token,
          'bio': newBio,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          // Save to UserInfo from API response
          await UserInfo.saveUserProfile(data['data']);

          // Update saved bio
          _savedBio = newBio;

          // Optimistic UI update - only after successful save
          bio.value = newBio;
          isBioEditing.value = false;

          // Also save to SharedPreferences for legacy support
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('torko_profile_bio', newBio);
          
          // Update profile JSON
          final profileStr = prefs.getString('torko_user_profile');
          if (profileStr != null) {
            try {
              final profile = jsonDecode(profileStr);
              profile['bio'] = newBio;
              await prefs.setString('torko_user_profile', jsonEncode(profile));
            } catch (_) {}
          }

          // Mark bio step completed if bio is not empty
          if (newBio.isNotEmpty) {
            await _markStepCompleted(2);
          }

          _showSuccessSnackbar('Bio updated successfully');
          
          isSavingBio.value = false;
          return true; // Return true on success
        } else {
          // Revert on API error
          bioController.text = _savedBio;
          _showErrorSnackbar(data['message'] ?? 'Failed to update bio');
          isSavingBio.value = false;
          return false; // Return false on error
        }
      } else {
        // Revert on request error
        bioController.text = _savedBio;
        _showErrorSnackbar(response.errorMessage ?? 'Failed to update bio');
        isSavingBio.value = false;
        return false; // Return false on error
      }
    } catch (e) {
      // Revert on exception
      bioController.text = _savedBio;
      _showErrorSnackbar('Network error: ${e.toString()}');
      isSavingBio.value = false;
      return false; // Return false on error
    }
  }

  // ==================== Save Profile ====================
  Future<void> saveProfile() async {
    if (isSaving.value) return;

    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please login again.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isSaving.value = true;

    // Optimistic UI update
    final newName = nameController.text.trim();
    final newAddress = locationController.text.trim();
    final newBio = bioController.text.trim();

    name.value = newName;
    address.value = newAddress;
    bio.value = newBio;
    isEditMode.value = false;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.update_users,
        body: {
          'api_token': token,
          'fullname': newName,
          'address': newAddress,
          'bio': newBio,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          // Save to UserInfo from API response
          await UserInfo.saveUserProfile(data['data']);

          // Update saved values
          _savedName = newName;
          _savedAddress = newAddress;
          _savedBio = newBio;

          // Also save to SharedPreferences for legacy support
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('torko_profile_bio', newBio);
          await prefs.setString('torko_user_profile', jsonEncode({
            'name': newName,
            'location': newAddress,
            'bio': newBio,
          }));

          // Mark bio step completed if bio is not empty
          if (newBio.isNotEmpty) {
            await _markStepCompleted(2);
          }

          _showSuccessSnackbar('Profile updated successfully');
        } else {
          // Revert on API error
          _revertProfileValues();
          _showErrorSnackbar(data['message'] ?? 'Failed to update profile');
        }
      } else {
        // Revert on request error
        _revertProfileValues();
        _showErrorSnackbar(response.errorMessage ?? 'Failed to update profile');
      }
    } catch (e) {
      // Revert on exception
      _revertProfileValues();
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  void _revertProfileValues() {
    name.value = _savedName;
    address.value = _savedAddress;
    bio.value = _savedBio;
    nameController.text = _savedName;
    locationController.text = _savedAddress;
    bioController.text = _savedBio;
  }

  // ==================== Image Picking ====================
  Future<void> pickProfileImage() async {
    await _showImageSourceSheet(isProfile: true);
  }

  Future<void> pickCoverImage() async {
    await _showImageSourceSheet(isProfile: false);
  }

  Future<void> _showImageSourceSheet({required bool isProfile}) async {
    final isBn = appController.language == AppLanguage.bn;
    final isDark = appController.isDarkMode;

    await Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'ছবি নির্বাচন করুন' : 'Choose photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0f1419),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.lightPrimary),
                ),
                title: Text(
                  isBn ? 'ক্যামেরা' : 'Camera',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera, isProfile: isProfile);
                },
              ),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.lightPrimary),
                ),
                title: Text(
                  isBn ? 'গ্যালারি' : 'Gallery',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery, isProfile: isProfile);
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickImage(ImageSource source, {required bool isProfile}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: isProfile ? 500 : 1200,
        maxHeight: isProfile ? 500 : 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final prefs = await SharedPreferences.getInstance();

        if (isProfile) {
          profileFile.value = file;
          await prefs.setString('torko_profile_image_path', pickedFile.path);
          await _markStepCompleted(1);
          // Upload to server
          await uploadProfileImage(file);
        } else {
          coverFile.value = file;
          await prefs.setString('torko_cover_image_path', pickedFile.path);
          await _markStepCompleted(3);
          // Upload to server
          await uploadCoverImage(file);
        }
      }
    } catch (e) {
      final isBn = appController.language == AppLanguage.bn;
      _showErrorSnackbar(isBn ? 'ছবি নির্বাচন করতে সমস্যা হয়েছে' : 'Failed to pick image');
    }
  }

  // ==================== Upload Images ====================
  Future<void> uploadProfileImage(File file) async {
    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please login again.');
      return;
    }

    isUploadingProfile.value = true;

    try {
      // Convert to base64
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final imageData = 'data:image/jpeg;base64,$base64Image';

      final response = await NetworkCaller.postRequest(
        url: Urls.profile_image,
        body: {
          'api_token': token,
          'profile_image': imageData,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true) {
          // Update local storage with URL from response
          final imageUrl = data['data']?['profile_image'] ?? '';
          if (imageUrl.isNotEmpty) {
            await UserInfo.setProfileImage(imageUrl);
            profileImageUrl.value = imageUrl;
            // Update AppController for reactive updates in drawer
            appController.updateProfileImageUrl(imageUrl);
          }
          _showSuccessSnackbar('Profile photo updated');
        } else {
          _showErrorSnackbar(data['message'] ?? 'Failed to upload profile photo');
        }
      } else {
        _showErrorSnackbar(response.errorMessage ?? 'Failed to upload profile photo');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      isUploadingProfile.value = false;
    }
  }

  Future<void> uploadCoverImage(File file) async {
    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please login again.');
      return;
    }

    isUploadingCover.value = true;

    try {
      // Convert to base64
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final imageData = 'data:image/jpeg;base64,$base64Image';

      final response = await NetworkCaller.postRequest(
        url: Urls.cover_image,
        body: {
          'api_token': token,
          'cover_image': imageData,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true) {
          // Update local storage with URL from response
          final imageUrl = data['data']?['cover_image'] ?? '';
          if (imageUrl.isNotEmpty) {
            await UserInfo.setCoverImage(imageUrl);
            coverImageUrl.value = imageUrl;
          }
          _showSuccessSnackbar('Cover photo updated');
        } else {
          _showErrorSnackbar(data['message'] ?? 'Failed to upload cover photo');
        }
      } else {
        _showErrorSnackbar(response.errorMessage ?? 'Failed to upload cover photo');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      isUploadingCover.value = false;
    }
  }

  // ==================== Step Completion ====================
  Future<void> _markStepCompleted(int step) async {
    switch (step) {
      case 1:
        hasProfilePhoto.value = true;
        break;
      case 2:
        hasBio.value = true;
        break;
      case 3:
        hasCoverPhoto.value = true;
        break;
      case 4:
        hasFirstPost.value = true;
        break;
    }

    await _saveCompletionState();

    final isBn = appController.language == AppLanguage.bn;
    final progress = completedItems * 25;

    Get.snackbar(
      isBn ? 'ধাপ সম্পূর্ণ!' : 'Step Completed!',
      isBn ? 'অগ্রগতি: $progress%' : 'Progress: $progress%',
      backgroundColor: AppColors.lightPrimary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _saveCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('torko_profile_step_1', hasProfilePhoto.value);
    await prefs.setBool('torko_profile_step_2', hasBio.value);
    await prefs.setBool('torko_profile_step_3', hasCoverPhoto.value);
    await prefs.setBool('torko_profile_step_4', hasFirstPost.value);
  }

  // ==================== Step Actions ====================
  void handleStepAction(String action, int stepNumber) {
    if (!canAccessStep(stepNumber)) {
      final isBn = appController.language == AppLanguage.bn;
      Get.snackbar(
        isBn ? 'ধাপ সম্পূর্ণ করুন' : 'Complete Previous Steps',
        isBn ? 'পূর্ববর্তী ধাপগুলো আগে সম্পূর্ণ করুন' : 'Please complete previous steps first',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    switch (action) {
      case 'upload_profile':
        pickProfileImage();
        break;
      case 'add_bio':
        enterEditMode();
        break;
      case 'upload_cover':
        pickCoverImage();
        break;
      case 'create_post':
        handleCreatePost();
        break;
    }
  }

  Future<void> handleCreatePost() async {
    final result = await Get.toNamed(AppRoutes.createPost);
    if (result == true) {
      await _markStepCompleted(4);
    }
  }

  // ==================== Navigation ====================
  Future<void> handleBack() async {
    final prefs = await SharedPreferences.getInstance();
    final fromWelcome = prefs.getString('torko_from_welcome');

    if (fromWelcome == 'complete_profile') {
      await prefs.remove('torko_from_welcome');
      Get.offNamed(AppRoutes.welcomeProfile);
    } else {
      Get.back();
    }
  }

  // ==================== Tab Management ====================
  void setActiveTab(String tab) {
    activeTab.value = tab;
  }

  // ==================== Post Status for Profile Completion ====================
  /// Updates hasFirstPost based on whether user has any posts
  void updateFirstPostStatus(bool hasPosts) {
    if (hasPosts && !hasFirstPost.value) {
      hasFirstPost.value = true;
      _saveCompletionState();
    }
  }

  // ==================== Snackbar Helpers ====================
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }
}

