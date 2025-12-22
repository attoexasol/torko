import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/network_caller.dart';
import '../../services/urls.dart';
import '../../services/user_info.dart';

class ProfileDataOnboardingController extends GetxController {
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  
  // State variables
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedGender = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Reactive name text for Obx validation
  final RxString nameText = ''.obs;

  // Form validation - using reactive nameText
  bool get isFormValid => 
      nameText.value.trim().isNotEmpty && 
      selectedDate.value != null && 
      selectedGender.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    // Listen to name changes and update reactive variable
    nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    nameText.value = nameController.text;
  }

  @override
  void onClose() {
    nameController.removeListener(_onNameChanged);
    nameController.dispose();
    super.onClose();
  }

  /// Format date for display (Bengali)
  String formatDate(DateTime date) {
    final monthNames = [
      'জানুয়ারী', 'ফেব্রুয়ারী', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  /// Format date for API (YYYY-MM-DD)
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Set selected date
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  /// Set selected gender
  void setGender(String gender) {
    selectedGender.value = gender;
  }

  /// Handle form submission - calls update_users API
  Future<void> handleSubmit() async {
    if (!isFormValid) return;

    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please login again.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.update_users,
        body: {
          'api_token': token,
          'fullname': nameController.text.trim(),
          'date_of_birth': formatDateForApi(selectedDate.value!),
          'gender': selectedGender.value,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          // Save user profile data to UserInfo
          await UserInfo.saveUserProfile(data['data']);
          
          // Navigate to location onboarding
          Get.offNamed(AppRoutes.locationData);
        } else {
          final message = data['message'] ?? 'Failed to update profile';
          errorMessage.value = message;
          _showErrorSnackbar(message);
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to update profile';
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
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

