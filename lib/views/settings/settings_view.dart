import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
            language == AppLanguage.bn ? 'সেটিংস' : 'Settings',
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
            // Account Section
            _buildSectionTitle(language == AppLanguage.bn ? 'অ্যাকাউন্ট' : 'Account', isDark),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: language == AppLanguage.bn ? 'অ্যাকাউন্ট সেটিংস' : 'Account Settings',
              isDark: isDark,
              onTap: () => Get.toNamed(AppRoutes.accountSettings),
            ),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: language == AppLanguage.bn ? 'প্রাইভেসি' : 'Privacy',
              isDark: isDark,
              onTap: () => Get.toNamed(AppRoutes.privacySettings),
            ),
            const SizedBox(height: 24),
            
            // Notifications Section
            _buildSectionTitle(language == AppLanguage.bn ? 'বিজ্ঞপ্তি' : 'Notifications', isDark),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: language == AppLanguage.bn ? 'বিজ্ঞপ্তি সেটিংস' : 'Notification Settings',
              isDark: isDark,
              onTap: () => Get.toNamed(AppRoutes.notificationSettings),
            ),
            const SizedBox(height: 24),
            
            // Appearance Section
            _buildSectionTitle(language == AppLanguage.bn ? 'দৃশ্যমানতা' : 'Appearance', isDark),
            _buildSettingsItem(
              icon: isDark ? Icons.light_mode : Icons.dark_mode,
              title: language == AppLanguage.bn ? 'ডার্ক মোড' : 'Dark Mode',
              isDark: isDark,
              trailing: Switch(
                value: isDark,
                onChanged: (_) => appController.toggleTheme(),
                activeColor: AppColors.lightPrimary,
              ),
              onTap: () => appController.toggleTheme(),
            ),
            _buildSettingsItem(
              icon: Icons.language,
              title: language == AppLanguage.bn ? 'ভাষা' : 'Language',
              subtitle: language == AppLanguage.bn ? 'বাংলা' : 'English',
              isDark: isDark,
              onTap: () => appController.toggleLanguage(),
            ),
            const SizedBox(height: 24),
            
            // About Section
            _buildSectionTitle(language == AppLanguage.bn ? 'সম্পর্কে' : 'About', isDark),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: language == AppLanguage.bn ? 'সম্পর্কে' : 'About Torko',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: language == AppLanguage.bn ? 'সাহায্য' : 'Help & Support',
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            
            // Logout Button
            GestureDetector(
              onTap: () {
                Get.offAllNamed(AppRoutes.onboarding);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    language == AppLanguage.bn ? 'লগআউট' : 'Logout',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              size: 22,
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
            trailing ?? Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
