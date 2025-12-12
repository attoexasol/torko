import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

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
            language == AppLanguage.bn ? 'বিজ্ঞপ্তি সেটিংস' : 'Notification Settings',
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
              title: language == AppLanguage.bn ? 'পুশ বিজ্ঞপ্তি' : 'Push Notifications',
              subtitle: language == AppLanguage.bn ? 'সব বিজ্ঞপ্তি চালু/বন্ধ করুন' : 'Enable/disable all notifications',
              value: true,
              isDark: isDark,
              onChanged: (v) {},
            ),
            _buildSwitchItem(
              title: language == AppLanguage.bn ? 'লাইক' : 'Likes',
              subtitle: language == AppLanguage.bn ? 'কেউ আপনার পোস্টে লাইক দিলে' : 'When someone likes your post',
              value: true,
              isDark: isDark,
              onChanged: (v) {},
            ),
            _buildSwitchItem(
              title: language == AppLanguage.bn ? 'মন্তব্য' : 'Comments',
              subtitle: language == AppLanguage.bn ? 'কেউ মন্তব্য করলে' : 'When someone comments',
              value: true,
              isDark: isDark,
              onChanged: (v) {},
            ),
            _buildSwitchItem(
              title: language == AppLanguage.bn ? 'ফলোয়ার' : 'Followers',
              subtitle: language == AppLanguage.bn ? 'নতুন ফলোয়ার হলে' : 'When someone follows you',
              value: true,
              isDark: isDark,
              onChanged: (v) {},
            ),
            _buildSwitchItem(
              title: language == AppLanguage.bn ? 'বার্তা' : 'Messages',
              subtitle: language == AppLanguage.bn ? 'নতুন বার্তা এলে' : 'When you receive a message',
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
