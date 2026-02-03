import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/user_info.dart';

class LocationOnboardingController extends GetxController {
  // State variables
  final RxString selectedDivision = ''.obs;
  final RxString selectedDivisionBn = ''.obs;
  final RxString selectedDistrict = ''.obs;
  final RxString selectedDistrictBn = ''.obs;
  final RxString selectedUpazila = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Form validation
  bool get isFormValid => 
      selectedDivision.value.isNotEmpty && 
      selectedDistrict.value.isNotEmpty && 
      selectedUpazila.value.isNotEmpty;

  /// Build address string from selected values
  String get fullAddress {
    if (!isFormValid) return '';
    return '$selectedUpazila, $selectedDistrict, $selectedDivision';
  }

  /// Set division
  void setDivision(String nameEn, String nameBn) {
    selectedDivision.value = nameEn;
    selectedDivisionBn.value = nameBn;
    // Reset district and upazila when division changes
    selectedDistrict.value = '';
    selectedDistrictBn.value = '';
    selectedUpazila.value = '';
  }

  /// Set district
  void setDistrict(String nameEn, String nameBn) {
    selectedDistrict.value = nameEn;
    selectedDistrictBn.value = nameBn;
    // Reset upazila when district changes
    selectedUpazila.value = '';
  }

  /// Set upazila
  void setUpazila(String name) {
    selectedUpazila.value = name;
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
      // Build address string: "Upazila, District, Division"
      final address = '${selectedUpazila.value}, ${selectedDistrict.value}, ${selectedDivision.value}';

      final response = await NetworkCaller.postRequest(
        url: Urls.update_users,
        body: {
          'api_token': token,
          'address': address,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          // Save user profile data to UserInfo
          await UserInfo.saveUserProfile(data['data']);
          
          // Save to SharedPreferences for local access
          await _saveLocationToPrefs();
          
          // Mark registration as completed
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('torko_registration_completed', true);
          await prefs.setBool('torko_onboarding_completed', true);
          
          // Navigate to profile
          Get.offAllNamed(AppRoutes.profile);
        } else {
          final message = data['message'] ?? 'Failed to update location';
          errorMessage.value = message;
          _showErrorSnackbar(message);
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to update location';
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Skip location and navigate to profile
  Future<void> handleSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('torko_registration_completed', true);
    await prefs.setBool('torko_onboarding_completed', true);
    Get.offAllNamed(AppRoutes.profile);
  }

  /// Save location data to SharedPreferences
  Future<void> _saveLocationToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('torko_user_division', selectedDivision.value);
    await prefs.setString('torko_user_division_bn', selectedDivisionBn.value);
    await prefs.setString('torko_user_district', selectedDistrict.value);
    await prefs.setString('torko_user_district_bn', selectedDistrictBn.value);
    await prefs.setString('torko_user_upazila', selectedUpazila.value);
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

