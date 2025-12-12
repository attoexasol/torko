import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

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
            language == AppLanguage.bn ? 'অ্যাকাউন্ট সেটিংস' : 'Account Settings',
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
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: language == AppLanguage.bn ? 'প্রোফাইল তথ্য' : 'Profile Information',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.email_outlined,
              title: language == AppLanguage.bn ? 'ইমেইল' : 'Email',
              subtitle: 'user@email.com',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.phone_outlined,
              title: language == AppLanguage.bn ? 'ফোন নম্বর' : 'Phone Number',
              subtitle: '+880 1XXX-XXXXXX',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: language == AppLanguage.bn ? 'পাসওয়ার্ড পরিবর্তন' : 'Change Password',
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {},
              child: Text(
                language == AppLanguage.bn ? 'অ্যাকাউন্ট মুছে ফেলুন' : 'Delete Account',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
            const SizedBox(width: 16),
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
                  if (subtitle != null)
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
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
