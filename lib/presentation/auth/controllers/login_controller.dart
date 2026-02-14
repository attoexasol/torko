import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/debug/auth_self_check.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/core/services/auth_service.dart';
import 'package:torko/core/services/user_profile_sync_service.dart';
import 'package:torko/core/services/firebase_auth_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/core/utils/app_logger.dart';

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

  /// Persisted from create_users: exist=true = returning user (go Home after OTP)
  final RxBool userExists = false.obs;

  /// Firebase custom token from create_users (do NOT persist - memory only)
  String? _firebaseCustomToken;
  String? _firebaseUid;

  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

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

      final rawFirebaseUid = res.firebaseUid;
      final normalizedUid = rawFirebaseUid != null && rawFirebaseUid.isNotEmpty
          ? normalizeUserId(rawFirebaseUid)
          : null;

      await UserInfo.saveToken(res.token);
      await UserInfo.setPhone(cleanPhone);
      userExists.value = res.exist;
      _firebaseCustomToken = res.firebaseCustomToken;
      _firebaseUid = normalizedUid;

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
          'Check your phone for the verification code.',
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

    final token = UserInfo.getToken();

    if (token == null || token.isEmpty) {
      _showError('Session expired');
      step.value = 'phone';
      return;
    }

    final otpInt = int.tryParse(fullOtp);
    if (otpInt == null) {
      _showError('Invalid OTP format');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final res = await AuthService().verifyOtp(apiToken: token, otp: otpInt);

      await UserInfo.saveApiToken(res.apiToken);

      // Firebase flow: sign in with custom token, save firebase_uid, upsert user doc
      if (_firebaseCustomToken != null &&
          _firebaseCustomToken!.isNotEmpty &&
          _firebaseUid != null &&
          _firebaseUid!.isNotEmpty) {
        if (kDebugMode) AppLogger.auth('Firebase sign-in with custom token');
        await _firebaseAuth.signInWithCustomToken(_firebaseCustomToken!);
        final authUid = FirebaseAuth.instance.currentUser?.uid;
        if (kDebugMode) AppLogger.auth('Signed in (uid=${authUid != null ? "present" : "null"})');
        String finalUid = _firebaseUid!;
        if (authUid != null && authUid.isNotEmpty) {
          final normalizedAuth = normalizeUserId(authUid);
          if (normalizedAuth != _firebaseUid) {
            if (kDebugMode) AppLogger.auth('UID mismatch, using Firebase uid');
            finalUid = normalizedAuth;
          }
        }
        await UserInfo.setFirebaseUid(finalUid);
        if (kDebugMode) AppLogger.auth('Auth state: SIGNED IN');
        await UserProfileSyncService.syncMe();
        _firebaseCustomToken = null;
        runAuthSelfCheck();
        // Same as Laravel flow: load profile, then Home (never Chat as initial route)
        final profileOk = await AuthService().onLoginSuccess(res.apiToken);
        if (!profileOk) {
          Get.snackbar(
            'Logged in',
            'Syncing profile…',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
        if (Get.isRegistered<AppController>()) {
          Get.find<AppController>().refreshUserProfile();
        }
        if (kDebugMode) AppLogger.nav('Post-login → ${userExists.value ? "Home" : "ProfileData"}');
        if (userExists.value) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.profileData);
        }
        return;
      }

      final profileOk = await AuthService().onLoginSuccess(res.apiToken);
      if (!profileOk) {
        Get.snackbar(
          'Logged in',
          'Syncing profile…',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }

      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().refreshUserProfile();
      }

      if (kDebugMode) AppLogger.nav('Post-login → ${userExists.value ? "Home" : "ProfileData"}');
      if (userExists.value) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.profileData);
      }
    } on Exception catch (e) {
      if (kDebugMode) AppLogger.err('Login OTP verify failed', error: e);
      _showError(e.toString().replaceFirst('Exception: ', ''));
      _clearOtp();
    } catch (e) {
      if (kDebugMode) AppLogger.err('Login failed (network)', error: e);
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

      await UserInfo.saveToken(res.token);
      userExists.value = res.exist;
      _firebaseCustomToken = res.firebaseCustomToken;
      _firebaseUid = res.firebaseUid != null && res.firebaseUid!.isNotEmpty
          ? normalizeUserId(res.firebaseUid!)
          : res.firebaseUid;

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
          'Check your phone for the verification code.',
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
    userExists.value = false;
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
