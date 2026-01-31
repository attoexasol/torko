import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/network_caller.dart';
import '../../services/urls.dart';
import '../../services/user_info.dart';
import '../../services/pusher_service.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/inbox_controller.dart';

class LoginController extends GetxController {
  // =========================
  // UI STATE
  // =========================

  final RxString step = 'phone'.obs; // phone | otp
  final RxString phoneNumber = ''.obs;
  final RxString otp = ''.obs;

  final RxBool cookiesAccepted = false.obs;
  final RxBool termsAccepted = false.obs;
  final RxBool showPhoneError = false.obs;
  final RxBool showOtpResentConfirm = false.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // =========================
  // RESEND OTP TIMER
  // =========================

  final RxInt resendTimer = 0.obs;
  final RxBool canResend = true.obs;

  // =========================
  // INPUT CONTROLLERS
  // =========================

  final TextEditingController phoneController = TextEditingController();

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();
    step.value = 'phone';
  }

  @override
  void onClose() {
    phoneController.dispose();

    for (final c in otpControllers) {
      c.dispose();
    }

    for (final n in otpFocusNodes) {
      n.dispose();
    }

    super.onClose();
  }

  // =========================
  // PHONE VALIDATION
  // =========================

  bool isValidPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 11) return false;
    if (!digits.startsWith('0')) return false;

    const validPrefixes = [
      '017',
      '018',
      '013',
      '012',
      '016',
      '014',
      '015',
      '019',
    ];

    return validPrefixes.contains(digits.substring(0, 3));
  }

  String get cleanPhone => phoneNumber.value.replaceAll(RegExp(r'\D'), '');

  bool get isPhoneValid => isValidPhoneNumber(phoneNumber.value);

  bool get canSubmitPhone =>
      isPhoneValid && termsAccepted.value && !isLoading.value;

  bool get canSubmitOtp =>
      otpControllers.every((c) => c.text.isNotEmpty) && !isLoading.value;

  // =========================
  // PHONE INPUT FORMAT
  // =========================

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

  // =========================
  // PHONE SUBMIT
  // =========================

  Future<void> handlePhoneSubmit() async {
    if (!isValidPhoneNumber(phoneNumber.value)) {
      showPhoneError.value = true;
      _showError('Invalid phone number');
      return;
    }

    if (!termsAccepted.value) {
      _showError('Please accept the terms and conditions');
      return;
    }

    isLoading.value = true;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.create_users,
        body: {'phone': cleanPhone},
      );

      if (!response.isSuccess || response.body == null) {
        _showError('Failed to send OTP');
        return;
      }

      final data = response.body!;

      if (data['status'] != true) {
        _showError(data['message'] ?? 'OTP request failed');
        return;
      }

      final payload = data['data'];

      final otpCode = payload['otp_code'];
      final token = payload['token'];
      final userId = payload['id'] ?? payload['user_id'];

      if (token != null) {
        await UserInfo.saveToken(token.toString());
      }

      if (userId != null) {
        await UserInfo.setUserId(int.parse(userId.toString()));
      }

      await UserInfo.setPhone(cleanPhone);

      step.value = 'otp';

      Get.snackbar(
        'OTP Sent',
        'Your OTP is: $otpCode',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      resendTimer.value = 0;
      canResend.value = true;
    } catch (e) {
      _showError('Network error');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // OTP INPUT
  // =========================

  void onOtpChanged(int index) {
    if (otpControllers[index].text.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }

    if (otpControllers.every((c) => c.text.isNotEmpty)) {
      handleOTPComplete();
    }

    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  // =========================
  // OTP VERIFY
  // =========================

  Future<void> handleOTPComplete() async {
    final fullOtp = otpControllers.map((e) => e.text).join();

    if (fullOtp.length != 6) return;

    final token = UserInfo.getToken();

    if (token == null || token.isEmpty) {
      _showError('Session expired');
      step.value = 'phone';
      return;
    }

    isLoading.value = true;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.verify_otp,
        body: {'api_token': token, 'otp_code': int.parse(fullOtp)},
      );

      if (!response.isSuccess || response.body == null) {
        _showError('OTP verification failed');
        _clearOtp();
        return;
      }

      final data = response.body!;

      if (data['status'] != true) {
        _showError(data['message'] ?? 'Invalid OTP');
        _clearOtp();
        return;
      }

      final payload = data['data'];

      final newToken = payload?['api_token'];
      final userId = payload?['id'] ?? payload?['user_id'];

      if (newToken != null) {
        await UserInfo.saveToken(newToken);
      }

      if (userId != null) {
        await UserInfo.setUserId(int.parse(userId.toString()));
      }

      await UserInfo.setVerified(true);

      // ===============================
      // INIT REALTIME SYSTEM
      // ===============================

      final currentUserId = UserInfo.userId;

      if (currentUserId != null) {
        if (!Get.isRegistered<InboxController>()) {
          Get.put(InboxController(), permanent: true);
        }

        if (!Get.isRegistered<ChatController>()) {
          Get.put(ChatController(), permanent: true);
        }

        await PusherService().disconnect();
        await PusherService().init(userId: currentUserId);

        if (kDebugMode) {
          debugPrint('[LOGIN] Realtime initialized for userId=$currentUserId');
        }
      }

      Get.offAllNamed(AppRoutes.profileData);
    } catch (e) {
      _showError('Network error');
      _clearOtp();
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // RESEND OTP
  // =========================

  Future<void> handleResendOTP() async {
    if (!canResend.value) return;

    isLoading.value = true;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.create_users,
        body: {'phone': cleanPhone},
      );

      if (!response.isSuccess || response.body == null) {
        _showError('Failed to resend OTP');
        return;
      }

      final data = response.body!;

      if (data['status'] != true) {
        _showError(data['message'] ?? 'Resend failed');
        return;
      }

      final payload = data['data'];

      final otpCode = payload['otp_code'];
      final token = payload['token'];

      if (token != null) {
        await UserInfo.saveToken(token.toString());
      }

      showOtpResentConfirm.value = true;

      resendTimer.value = 60;
      canResend.value = false;

      _startResendTimer();

      _clearOtp();

      Get.snackbar(
        'OTP Resent',
        'Your OTP is: $otpCode',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      Future.delayed(const Duration(seconds: 3), () {
        showOtpResentConfirm.value = false;
      });
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

  // =========================
  // HELPERS
  // =========================

  void _clearOtp() {
    for (final c in otpControllers) {
      c.clear();
    }
    otpFocusNodes.first.requestFocus();
  }

  void toggleTermsAccepted() {
    termsAccepted.value = !termsAccepted.value;
  }

  void acceptCookies() {
    cookiesAccepted.value = true;
  }

  void goBack() {
    Get.back();
  }

  void goBackToPhone() {
    step.value = 'phone';
    _clearOtp();
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }
}
