import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../services/network_caller.dart';
import '../../services/urls.dart';
import '../../services/user_info.dart';

class AccountSettingsController extends GetxController {
  final appController = Get.find<AppController>();

  // ==================== Text Controllers ====================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // ==================== Observable States ====================
  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Observable values for display
  final RxString name = ''.obs;
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString bio = ''.obs;
  final RxString location = ''.obs;
  final RxString profileImageUrl = ''.obs;

  // Saved values for cancel/revert
  String _savedName = '';
  String _savedUsername = '';
  String _savedEmail = '';
  String _savedPhone = '';
  String _savedBio = '';
  String _savedLocation = '';

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadUserFromLocal();
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.onClose();
  }

  // ==================== Load Data from UserInfo ====================
  void loadUserFromLocal() {
    isLoading.value = true;

    try {
      // Load from UserInfo (GetStorage)
      _savedName = UserInfo.fullname ?? '';
      _savedUsername = UserInfo.username ?? '';
      _savedEmail = UserInfo.email ?? '';
      _savedPhone = UserInfo.phone ?? '';
      _savedBio = UserInfo.bio ?? '';
      _savedLocation = UserInfo.address ?? '';

      // Update observables
      name.value = _savedName;
      username.value = _savedUsername;
      email.value = _savedEmail;
      phone.value = _savedPhone;
      bio.value = _savedBio;
      location.value = _savedLocation;
      profileImageUrl.value = UserInfo.profileImage ?? '';

      // Update text controllers
      nameController.text = _savedName;
      usernameController.text = _savedUsername;
      emailController.text = _savedEmail;
      phoneController.text = _savedPhone;
      bioController.text = _savedBio;
      locationController.text = _savedLocation;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Edit Mode ====================
  void enterEditMode() {
    // Refresh controllers with current saved values
    nameController.text = _savedName;
    usernameController.text = _savedUsername;
    emailController.text = _savedEmail;
    phoneController.text = _savedPhone;
    bioController.text = _savedBio;
    locationController.text = _savedLocation;
    isEditing.value = true;
  }

  void cancelEdit() {
    // Revert controllers to saved values
    nameController.text = _savedName;
    usernameController.text = _savedUsername;
    emailController.text = _savedEmail;
    phoneController.text = _savedPhone;
    bioController.text = _savedBio;
    locationController.text = _savedLocation;

    // Revert observables
    name.value = _savedName;
    username.value = _savedUsername;
    email.value = _savedEmail;
    phone.value = _savedPhone;
    bio.value = _savedBio;
    location.value = _savedLocation;

    isEditing.value = false;
  }

  // ==================== Toggle Edit/Save ====================
  void toggleEditSave() {
    if (isEditing.value) {
      saveProfile();
    } else {
      enterEditMode();
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

    // Get new values from controllers
    final newName = nameController.text.trim();
    final newUsername = usernameController.text.trim();
    final newEmail = emailController.text.trim();
    final newPhone = phoneController.text.trim();
    final newBio = bioController.text.trim();
    final newLocation = locationController.text.trim();

    // Optimistic UI update
    name.value = newName;
    username.value = newUsername;
    email.value = newEmail;
    phone.value = newPhone;
    bio.value = newBio;
    location.value = newLocation;
    isEditing.value = false;

    try {
      // Build request body with only changed fields + required token
      final Map<String, dynamic> body = {
        'api_token': token,
      };

      // Add fields that have values
      if (newName.isNotEmpty) body['fullname'] = newName;
      if (newUsername.isNotEmpty) body['username'] = newUsername;
      if (newEmail.isNotEmpty) body['email'] = newEmail;
      if (newPhone.isNotEmpty) body['phone'] = newPhone;
      if (newBio.isNotEmpty) body['bio'] = newBio;
      if (newLocation.isNotEmpty) body['address'] = newLocation;

      final response = await NetworkCaller.postRequest(
        url: Urls.update_users,
        body: body,
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          // Save to UserInfo from API response
          await UserInfo.saveUserProfile(data['data']);

          // Update saved values from response
          _savedName = data['data']['fullname'] ?? newName;
          _savedUsername = data['data']['username'] ?? newUsername;
          _savedEmail = data['data']['email'] ?? newEmail;
          _savedPhone = data['data']['phone'] ?? newPhone;
          _savedBio = data['data']['bio'] ?? newBio;
          _savedLocation = data['data']['address'] ?? newLocation;

          // Update observables with confirmed values
          name.value = _savedName;
          username.value = _savedUsername;
          email.value = _savedEmail;
          phone.value = _savedPhone;
          bio.value = _savedBio;
          location.value = _savedLocation;

          // Update profile image if returned
          if (data['data']['profile_image'] != null) {
            profileImageUrl.value = data['data']['profile_image'];
          }

          _showSuccessSnackbar('Profile updated successfully');
        } else {
          // Revert on API error
          _revertToSavedValues();
          _showErrorSnackbar(data['message'] ?? 'Failed to update profile');
        }
      } else {
        // Revert on request error
        _revertToSavedValues();
        _showErrorSnackbar(response.errorMessage ?? 'Failed to update profile');
      }
    } catch (e) {
      // Revert on exception
      _revertToSavedValues();
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  void _revertToSavedValues() {
    name.value = _savedName;
    username.value = _savedUsername;
    email.value = _savedEmail;
    phone.value = _savedPhone;
    bio.value = _savedBio;
    location.value = _savedLocation;

    nameController.text = _savedName;
    usernameController.text = _savedUsername;
    emailController.text = _savedEmail;
    phoneController.text = _savedPhone;
    bioController.text = _savedBio;
    locationController.text = _savedLocation;
  }

  // ==================== Delete Account ====================
  Future<void> deleteAccount() async {
    // Show confirmation dialog
    final isBn = appController.language == AppLanguage.bn;
    
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(isBn ? 'অ্যাকাউন্ট ডিলিট করুন?' : 'Delete Account?'),
        content: Text(
          isBn 
            ? 'এই ক্রিয়াটি পূর্বাবস্থায় ফেরানো যাবে না। আপনার সমস্ত ডেটা মুছে ফেলা হবে।'
            : 'This action cannot be undone. All your data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isBn ? 'ডিলিট করুন' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement delete account API call
      // For now, just clear local data and navigate to login
      await UserInfo.clear();
      Get.offAllNamed(AppRoutes.login);
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

