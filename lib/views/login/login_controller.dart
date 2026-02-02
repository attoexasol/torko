import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';
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

  /// Persisted from create_users: true = returning user, false = new user
  bool _userExists = false;

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
    errorMessage.value = '';

    try {
      final res = await AuthService().createUsers(phone: cleanPhone);

      await UserInfo.setApiToken(res.token);
      await UserInfo.setPhone(cleanPhone);
      _userExists = res.exist;

      if (kDebugMode && res.otpCode != null) {
        Get.snackbar(
          'OTP Sent',
          'Your OTP is: ${res.otpCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } else {
        Get.snackbar(
          'OTP Sent',
          'Please check your phone for the verification code.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }

      step.value = 'otp';
      resendTimer.value = 0;
      canResend.value = true;
    } on Exception catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
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

    final token = UserInfo.getApiToken();

    if (token == null || token.isEmpty) {
      _showError('Session expired');
      step.value = 'phone';
      return;
    }

    final otpInt = int.tryParse(fullOtp);
    if (otpInt == null) {
      _showError('Invalid OTP');
      return;
    }

    isLoading.value = true;

    try {
      final res = await AuthService().verifyOtp(apiToken: token, otp: otpInt);

      await AuthService().onLoginSuccess(res.apiToken);

      if (kDebugMode) {
        debugPrint('[LOGIN] ok exist=$_userExists tokenLen=${res.apiToken.length}');
      }

      // Refresh AppController so Drawer + Home header show correct name/photo immediately
      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().refreshUserProfile();
      }

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

      if (_userExists) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.profileData);
      }
    } on Exception catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
      _clearOtp();
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
      final res = await AuthService().createUsers(phone: cleanPhone);

      await UserInfo.setApiToken(res.token);
      _userExists = res.exist;

      showOtpResentConfirm.value = true;
      resendTimer.value = 60;
      canResend.value = false;
      _startResendTimer();
      _clearOtp();

      if (kDebugMode && res.otpCode != null) {
        Get.snackbar(
          'OTP Resent',
          'Your OTP is: ${res.otpCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } else {
        Get.snackbar(
          'OTP Resent',
          'Please check your phone for the verification code.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }

      Future.delayed(const Duration(seconds: 3), () {
        showOtpResentConfirm.value = false;
      });
    } on Exception catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      _showError('Failed to resend OTP');
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
    _userExists = false;
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
