import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class PrivacySettingsView extends StatelessWidget {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            language == AppLanguage.bn ? 'প্রাইভেসি' : 'Privacy',
            style: TextStyle(
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSwitchItem(
              title: language == AppLanguage.bn ? 'প্রোফাইল গোপন রাখুন' : 'Private Profile',
              subtitle: language == AppLanguage.bn ? 'শুধুমাত্র অনুমোদিত ব্যক্তিরা দেখতে পারবে' : 'Only approved followers can see',
              value: false,
              isDark: isDark,
              onChanged: (v) {},
            ),
            _buildSwitchItem(
              title: language == AppLanguage.bn ? 'অনলাইন স্ট্যাটাস' : 'Online Status',
              subtitle: language == AppLanguage.bn ? 'অন্যরা দেখতে পারবে আপনি অনলাইন কিনা' : 'Others can see when you\'re online',
              value: true,
              isDark: isDark,
              onChanged: (v) {},
            ),
            _buildSwitchItem(
              title: language == AppLanguage.bn ? 'পঠন রিসিপ্ট' : 'Read Receipts',
              subtitle: language == AppLanguage.bn ? 'অন্যরা দেখতে পারবে আপনি মেসেজ পড়েছেন কিনা' : 'Others can see when you\'ve read messages',
              value: true,
              isDark: isDark,
              onChanged: (v) {},
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.lightPrimary,
          ),
        ],
      ),
    );
  }
}
