import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class ProfileDataOnboardingView extends StatefulWidget {
  const ProfileDataOnboardingView({super.key});

  @override
  State<ProfileDataOnboardingView> createState() => _ProfileDataOnboardingViewState();
}

class _ProfileDataOnboardingViewState extends State<ProfileDataOnboardingView> {
  final appController = Get.find<AppController>();
  final nameController = TextEditingController();
  
  DateTime? selectedDate;
  String? selectedGender;
  
  bool get isFormValid => 
      nameController.text.trim().isNotEmpty && 
      selectedDate != null && 
      selectedGender != null;

  Future<void> handleSubmit() async {
    if (isFormValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('torko_user_profile', '''
        {"fullName": "${nameController.text}", "dateOfBirth": "${selectedDate?.toIso8601String()}", "gender": "$selectedGender"}
      ''');
      Get.offNamed(AppRoutes.locationData);
    }
  }

  String formatDate(DateTime date) {
    final monthNames = ['জানুয়ারী', 'ফেব্রুয়ারী', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 
                        'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
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
                  controller: nameController,
                  hint: appController.t('enterFullName'),
                  isDark: isDark,
                  hasValue: nameController.text.trim().isNotEmpty,
                ),
                const SizedBox(height: 24),
                
                // Date of Birth
                _buildLabel(appController.t('dateOfBirth'), isDark),
                const SizedBox(height: 8),
                _buildDatePicker(isDark, language),
                const SizedBox(height: 24),
                
                // Gender
                _buildLabel(appController.t('gender'), isDark),
                const SizedBox(height: 8),
                _buildGenderSelector(isDark, genderOptions),
                const SizedBox(height: 40),
                
                // Submit Button
                GestureDetector(
                  onTap: isFormValid ? handleSubmit : null,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withValues(alpha: isFormValid ? 1.0 : 0.4),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appController.t('letsGo'),
                          style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, color: Color(0xFFF5F5F5), size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
    required bool hasValue,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withValues(alpha: 0.1),
          width: 2,
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
                hintText: hint,
                hintStyle: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (hasValue)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.lightSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Color(0xFF1A1A1A), size: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(bool isDark, AppLanguage language) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => selectedDate = date);
        }
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null ? formatDate(selectedDate!) : appController.t('selectDate'),
              style: TextStyle(
                color: selectedDate != null
                    ? (isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E))
                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                if (selectedDate != null)
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
    );
  }

  Widget _buildGenderSelector(bool isDark, List<Map<String, String>> options) {
    return GestureDetector(
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
                final isSelected = selectedGender == option['value'];
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedGender = option['value']);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightSecondary.withValues(alpha: isDark ? 0.15 : 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option['label']!,
                          style: TextStyle(
                            color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
                            fontSize: 16,
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
            color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedGender != null
                  ? options.firstWhere((o) => o['value'] == selectedGender)['label']!
                  : appController.t('selectGender'),
              style: TextStyle(
                color: selectedGender != null
                    ? (isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E))
                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                if (selectedGender != null)
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
    );
  }
}
