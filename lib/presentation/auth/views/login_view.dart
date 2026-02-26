import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/auth/controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final controller = Get.put(LoginController());

    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;

      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: isDark
            ? AppColors.darkBackground
            : const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(
                      bottom: bottomInset + (controller.cookiesAccepted.value ? 24 : 160),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Obx(
                          () => controller.step.value == 'phone'
                              ? _buildPhoneStep(
                                  isDark,
                                  language,
                                  appController,
                                  controller,
                                )
                              : _buildOtpStep(
                                  isDark,
                                  language,
                                  appController,
                                  controller,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              if (!controller.cookiesAccepted.value)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: _buildCookieNotice(
                      isDark,
                      language,
                      appController,
                      controller,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPhoneStep(
    bool isDark,
    AppLanguage language,
    AppController appController,
    LoginController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button & Theme Toggle Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: controller.goBack,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: isDark
                          ? const Color(0xFF9B9B9B)
                          : const Color(0xFF6B6B6B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appController.t('back'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF6B6B6B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Theme Toggle
              GestureDetector(
                onTap: () => appController.toggleTheme(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0a2f3d)
                        : const Color(0xFFFAFAF8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0d3a4a)
                          : Colors.black.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny : Icons.nightlight_round,
                    color: isDark
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFF2C2C2E),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Title
              Text(
                appController.t('enterPhone'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.11,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                appController.t('sendOTPDescription'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9B9B9B)
                      : const Color(0xFF6B6B6B),
                  fontSize: 16,
                  height: 1.63,
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number Label
              Text(
                appController.t('phoneNumberLabel'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Phone Input Row
              Row(
                children: [
                  // Country Code
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0a2f3d)
                          : const Color(0xFFFAFAF8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF0d3a4a)
                            : Colors.black.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: isDark
                              ? const Color(0xFF9B9B9B)
                              : const Color(0xFF6B6B6B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+88',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF9B9B9B)
                                : const Color(0xFF6B6B6B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Phone Input
                  Expanded(
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0a2f3d)
                            : const Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF0d3a4a)
                              : Colors.black.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFF5F5F5)
                                    : const Color(0xFF2C2C2E),
                                fontSize: 16,
                              ),

                              decoration: InputDecoration(
                                hintText: '01XXX-XXXXXX',
                                hintStyle: TextStyle(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withOpacity(0.3),
                                ),

                                filled: false,

                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                              ),

                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9-]'),
                                ),
                                LengthLimitingTextInputFormatter(12),
                              ],
                              onChanged: controller.onPhoneChanged,
                            ),
                          ),
                          Obx(
                            () => controller.isPhoneValid
                                ? Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Error or Example Text
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  controller.showPhoneError.value
                      ? appController.t('invalidPhone')
                      : appController.t('phoneExample'),
                  style: TextStyle(
                    color: controller.showPhoneError.value
                        ? Colors.red
                        : (isDark
                              ? const Color(0xFF9B9B9B)
                              : const Color(0xFF6B6B6B)),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Terms Checkbox
              GestureDetector(
                onTap: controller.toggleTermsAccepted,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: controller.termsAccepted.value
                              ? AppColors.lightPrimary
                              : (isDark
                                    ? const Color(0xFF0a2f3d)
                                    : const Color(0xFFFAFAF8)),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: controller.termsAccepted.value
                                ? AppColors.lightPrimary
                                : (isDark
                                      ? const Color(0xFF0d3a4a)
                                      : Colors.black.withOpacity(0.2)),
                            width: 2,
                          ),
                        ),
                        child: controller.termsAccepted.value
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF9B9B9B)
                                : const Color(0xFF6B6B6B),
                            fontSize: 13,
                          ),
                          children: language == AppLanguage.bn
                              ? [
                                  const TextSpan(text: 'আমি '),
                                  TextSpan(
                                    text: 'শর্তাবলী',
                                    style: TextStyle(
                                      color: AppColors.lightPrimary,
                                    ),
                                  ),
                                  const TextSpan(text: ' এবং '),
                                  TextSpan(
                                    text: 'গোপনীয়তা নীতিতে',
                                    style: TextStyle(
                                      color: AppColors.lightPrimary,
                                    ),
                                  ),
                                  const TextSpan(text: ' সম্মত আছি'),
                                ]
                              : [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color: AppColors.lightPrimary,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.lightPrimary,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button
              Obx(
                () => GestureDetector(
                  onTap: controller.canSubmitPhone
                      ? controller.handlePhoneSubmit
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withOpacity(
                        controller.canSubmitPhone ? 1.0 : 0.4,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (controller.isLoading.value)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFF5F5F5),
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          Text(
                            appController.t('continue'),
                            style: const TextStyle(
                              color: Color(0xFFF5F5F5),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFF5F5F5),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(
    bool isDark,
    AppLanguage language,
    AppController appController,
    LoginController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button & Theme Toggle Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: controller.goBackToPhone,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: isDark
                          ? const Color(0xFF9B9B9B)
                          : const Color(0xFF6B6B6B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appController.t('back'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF6B6B6B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => appController.toggleTheme(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0a2f3d)
                        : const Color(0xFFFAFAF8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0d3a4a)
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny : Icons.nightlight_round,
                    color: isDark
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFF2C2C2E),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                appController.t('verifyOTP'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 8),

              Obx(
                () => Text(
                  '+88 ${controller.phoneNumber.value} ${appController.t('otpSentTo')}',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9B9B9B)
                        : const Color(0xFF6B6B6B),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                        3,
                        (i) => _buildOtpBox(i, isDark, controller),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF9B9B9B)
                                : const Color(0xFF6B6B6B),
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ...List.generate(
                        3,
                        (i) => _buildOtpBox(i + 3, isDark, controller),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: Column(
                  children: [
                    Text(
                      appController.t('didntGetCode'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF6B6B6B),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => GestureDetector(
                        onTap:
                            controller.canResend.value &&
                                !controller.isLoading.value
                            ? controller.handleResendOTP
                            : null,
                        child: Text(
                          controller.canResend.value
                              ? appController.t('resendOTP')
                              : '${appController.t('resendOTP')} (${controller.resendTimer.value ~/ 60}:${(controller.resendTimer.value % 60).toString().padLeft(2, '0')})',
                          style: TextStyle(
                            color:
                                controller.canResend.value &&
                                    !controller.isLoading.value
                                ? AppColors.lightPrimary
                                : (isDark
                                      ? const Color(0xFF9B9B9B)
                                      : const Color(0xFF6B6B6B)),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Obx(
                () => controller.showOtpResentConfirm.value
                    ? Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.lightSecondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Color(0xFF1A1A1A),
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                appController.t('otpResent'),
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.lightSecondary
                                      : const Color(0xFF7BC3B8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Continue Button
              Obx(
                () => GestureDetector(
                  onTap: controller.canSubmitOtp
                      ? controller.handleOTPComplete
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withOpacity(
                        controller.canSubmitOtp ? 1.0 : 0.4,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (controller.isLoading.value)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFF5F5F5),
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          Text(
                            appController.t('continue'),
                            style: const TextStyle(
                              color: Color(0xFFF5F5F5),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFF5F5F5),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index, bool isDark, LoginController controller) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? const Color(0xFF0d3a4a)
              : Colors.black.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller.otpControllers[index],
          focusNode: controller.otpFocusNodes[index],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2C2C2E),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          cursorColor: isDark ? Colors.white : const Color(0xFF2C2C2E),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => controller.onOtpChanged(index),
        ),
      ),
    );
  }

  Widget _buildCookieNotice(
    bool isDark,
    AppLanguage language,
    AppController appController,
    LoginController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF052029).withOpacity(0.95)
            : const Color(0xFFE8E8E8).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF0d3a4a)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍪', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Text(
                appController.t('cookiesAbout'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appController.t('cookiesDescription'),
            style: TextStyle(
              color: isDark ? const Color(0xFF9B9B9B) : const Color(0xFF6B6B6B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: controller.acceptCookies,
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  appController.t('acceptCookies'),
                  style: const TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
