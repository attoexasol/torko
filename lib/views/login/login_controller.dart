import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/network_caller.dart';
import '../../services/urls.dart';
import '../../services/user_info.dart';

class LoginController extends GetxController {
  // State variables
  final RxString step = 'phone'.obs; // 'phone' or 'otp'
  final RxString phoneNumber = ''.obs;
  final RxString otp = ''.obs;
  final RxInt resendTimer = 0.obs;
  final RxBool canResend = true.obs;
  final RxBool cookiesAccepted = false.obs;
  final RxBool showPhoneError = false.obs;
  final RxBool termsAccepted = false.obs;
  final RxBool showOtpResentConfirm = false.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // TextEditingControllers
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void onInit() {
    super.onInit();
    // Ensure we start on phone step
    step.value = 'phone';
  }

  @override
  void onClose() {
    phoneController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  bool isValidPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return false;
    if (!digits.startsWith('0')) return false;

    final validPrefixes = [
      '017',
      '018',
      '013',
      '012',
      '016',
      '014',
      '015',
      '019',
    ];
    final prefix = digits.substring(0, 3);

    return validPrefixes.contains(prefix);
  }

  /// Get clean phone number (digits only)
  String get cleanPhoneNumber => phoneNumber.value.replaceAll(RegExp(r'\D'), '');

  /// Handle phone submit - calls create_users API
  Future<void> handlePhoneSubmit() async {
    // Validate phone number
    if (!isValidPhoneNumber(phoneNumber.value)) {
      showPhoneError.value = true;
      _showErrorSnackbar('Invalid phone number');
      return;
    }

    if (!termsAccepted.value) {
      _showErrorSnackbar('Please accept the terms and conditions');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.create_users,
        body: {'phone': cleanPhoneNumber},
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          final responseData = data['data'];

          final otpCode = responseData['otp_code'];
          final apiToken = responseData['token'];

          // Save token + OTP
          await UserInfo.saveToken(apiToken?.toString() ?? '');
          await UserInfo.saveOtp(otpCode);
          await UserInfo.setPhone(cleanPhoneNumber);

          // Navigate to OTP screen
          step.value = 'otp';

          // Show snackbar with OTP
          Get.snackbar(
            "OTP Sent",
            "Your OTP is: $otpCode",
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          );

          resendTimer.value = 0;
          canResend.value = true;
          showPhoneError.value = false;
        } else {
          _showErrorSnackbar(data['message'] ?? 'Failed to create user');
        }
      } else {
        _showErrorSnackbar(response.errorMessage ?? 'Failed to create user');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle OTP verification - calls verify_otp API
  Future<void> handleOTPComplete() async {
    final fullOtp = otpControllers.map((c) => c.text).join();
    if (fullOtp.length != 6) return;

    final token = UserInfo.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackbar('Session expired. Please try again.');
      step.value = 'phone';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.verify_otp,
        body: {
          'api_token': token,
          'otp_code': int.tryParse(fullOtp) ?? 0,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true) {
          // Save verification response
          final newToken = data['data']?['api_token'];
          if (newToken != null) {
            await UserInfo.saveToken(newToken);
          }
          await UserInfo.setVerified(true);

          // Navigate to profile data screen
          Get.offAllNamed(AppRoutes.profileData);
        } else {
          errorMessage.value = data['message'] ?? 'OTP verification failed';
          _showErrorSnackbar(errorMessage.value);
          _clearOtpFields();
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'OTP verification failed';
        _showErrorSnackbar(errorMessage.value);
        _clearOtpFields();
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      _showErrorSnackbar(errorMessage.value);
      _clearOtpFields();
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP - calls same create_users API
  Future<void> handleResendOTP() async {
    if (!canResend.value) return;

    isLoading.value = true;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.create_users,
        body: {'phone': cleanPhoneNumber},
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        if (data['status'] == true && data['data'] != null) {
          final responseData = data['data'];

          final otpCode = responseData['otp_code'];
          final apiToken = responseData['token'];

          await UserInfo.saveToken(apiToken?.toString() ?? '');
          await UserInfo.saveOtp(otpCode);

          // Start resend timer
          resendTimer.value = 60;
          canResend.value = false;
          otp.value = '';
          _clearOtpFields();
          showOtpResentConfirm.value = true;

          // Start countdown timer
          _startResendTimer();

          // Show new OTP in snackbar
          Get.snackbar(
            'OTP Resent',
            'Your OTP is: $otpCode',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          );

          // Hide confirmation after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            showOtpResentConfirm.value = false;
          });
        } else {
          _showErrorSnackbar(data['message'] ?? 'Failed to resend OTP');
        }
      } else {
        _showErrorSnackbar(response.errorMessage ?? 'Failed to resend OTP');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      } else {
        canResend.value = true;
        return false;
      }
    });
  }

  void _clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes[0].requestFocus();
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

  void goBack() {
    Get.back();
  }

  void goBackToPhone() {
    step.value = 'phone';
    _clearOtpFields();
  }

  void toggleTermsAccepted() {
    termsAccepted.value = !termsAccepted.value;
  }

  void acceptCookies() {
    cookiesAccepted.value = true;
  }

  void onPhoneChanged(String value) {
    final digitsOnly = value.replaceAll('-', '');
    if (digitsOnly.length > 5) {
      phoneController.text =
          '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5)}';
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length),
      );
    }
    phoneNumber.value = phoneController.text;
    if (showPhoneError.value) showPhoneError.value = false;
    if (errorMessage.value.isNotEmpty) errorMessage.value = '';
  }

  void onOtpChanged(int index) {
    if (otpControllers[index].text.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
    if (otpControllers.every((c) => c.text.isNotEmpty)) {
      handleOTPComplete();
    }
    if (errorMessage.value.isNotEmpty) errorMessage.value = '';
  }

  bool get isPhoneValid => isValidPhoneNumber(phoneNumber.value);
  bool get canSubmitPhone => isPhoneValid && termsAccepted.value && !isLoading.value;
  bool get canSubmitOtp => otpControllers.every((c) => c.text.isNotEmpty) && !isLoading.value;
}
