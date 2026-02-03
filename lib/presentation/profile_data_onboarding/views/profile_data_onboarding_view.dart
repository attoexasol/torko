import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/profile_data_onboarding/controllers/profile_data_onboarding_controller.dart';

class ProfileDataOnboardingView extends StatelessWidget {
  const ProfileDataOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final controller = Get.put(ProfileDataOnboardingController());

    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;

      final genderOptions = [
        {'value': 'male', 'label': appController.t('male')},
        {'value': 'female', 'label': appController.t('female')},
        {'value': 'other', 'label': appController.t('other')},
        {'value': 'prefer-not-to-say', 'label': appController.t('preferNotToSay')},
      ];

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 350 ? 20.0 : 32.0;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      appController.t('completeProfile'),
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.9,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      appController.t('completeProfileDesc'),
                      style: TextStyle(
                        color: isDark ? const Color(0xFF9B9B9B) : const Color(0xFF6B6B6B),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    _buildLabel(appController.t('fullName'), isDark),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.nameController,
                      hint: appController.t('enterFullName'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    // Date of Birth
                    _buildLabel(appController.t('dateOfBirth'), isDark),
                    const SizedBox(height: 8),
                    _buildDatePicker(context, isDark, language, appController, controller),
                    const SizedBox(height: 24),

                    // Gender
                    _buildLabel(appController.t('gender'), isDark),
                    const SizedBox(height: 8),
                    _buildGenderSelector(context, isDark, genderOptions, appController, controller),
                    const SizedBox(height: 40),

                    // Submit Button
                    Obx(() => GestureDetector(
                      onTap: controller.isFormValid && !controller.isLoading.value
                          ? controller.handleSubmit
                          : null,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary.withOpacity(
                            controller.isFormValid && !controller.isLoading.value ? 1.0 : 0.4,
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
                                appController.t('letsGo'),
                                style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 16),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward, color: Color(0xFFF5F5F5), size: 20),
                            ],
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withOpacity(0.1),
          width: 0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintText: hint,
                hintStyle: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          Obx(() {
            final ctrl = Get.find<ProfileDataOnboardingController>();
            // Use reactive nameText instead of nameController.text
            final hasValue = ctrl.nameText.value.trim().isNotEmpty;
            if (hasValue) {
              return Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 16),
                decoration: const BoxDecoration(
                  color: AppColors.lightSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF1A1A1A), size: 14),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    bool isDark,
    AppLanguage language,
    AppController appController,
    ProfileDataOnboardingController controller,
  ) {
    return Obx(() => GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate.value ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          controller.setDate(date);
        }
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                controller.selectedDate.value != null
                    ? controller.formatDate(controller.selectedDate.value!)
                    : appController.t('selectDate'),
                style: TextStyle(
                  color: controller.selectedDate.value != null
                      ? (isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E))
                      : (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.selectedDate.value != null)
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.lightSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF1A1A1A), size: 14),
                  ),
                Icon(
                  Icons.calendar_today,
                  color: isDark ? const Color(0xFF9B9B9B) : const Color(0xFF6B6B6B),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildGenderSelector(
    BuildContext context,
    bool isDark,
    List<Map<String, String>> options,
    AppController appController,
    ProfileDataOnboardingController controller,
  ) {
    return Obx(() => GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                final isSelected = controller.selectedGender.value == option['value'];
                return GestureDetector(
                  onTap: () {
                    controller.setGender(option['value']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightSecondary.withOpacity(isDark ? 0.15 : 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option['label']!,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.lightSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Color(0xFF1A1A1A), size: 12),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                controller.selectedGender.value.isNotEmpty
                    ? options.firstWhere(
                        (o) => o['value'] == controller.selectedGender.value,
                        orElse: () => {'label': appController.t('selectGender')},
                      )['label']!
                    : appController.t('selectGender'),
                style: TextStyle(
                  color: controller.selectedGender.value.isNotEmpty
                      ? (isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E))
                      : (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.selectedGender.value.isNotEmpty)
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.lightSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF1A1A1A), size: 14),
                  ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? const Color(0xFF9B9B9B) : const Color(0xFF6B6B6B),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
