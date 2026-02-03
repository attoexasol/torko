import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      // Sample notifications
      final notifications = [
        {
          'type': 'like',
          'user': 'Sarah Johnson',
          'action': language == AppLanguage.bn ? 'আপনার পোস্টে লাইক দিয়েছেন' : 'liked your post',
          'time': '2m',
          'read': false,
        },
        {
          'type': 'comment',
          'user': 'Michael Chen',
          'action': language == AppLanguage.bn ? 'মন্তব্য করেছেন' : 'commented on your post',
          'time': '15m',
          'read': false,
        },
        {
          'type': 'follow',
          'user': 'আবদুল কাদের',
          'action': language == AppLanguage.bn ? 'আপনাকে ফলো করেছেন' : 'started following you',
          'time': '1h',
          'read': true,
        },
        {
          'type': 'mention',
          'user': 'Emma Williams',
          'action': language == AppLanguage.bn ? 'আপনাকে উল্লেখ করেছেন' : 'mentioned you',
          'time': '3h',
          'read': true,
        },
      ];
      
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
            language == AppLanguage.bn ? 'বিজ্ঞপ্তি' : 'Notifications',
            style: TextStyle(
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                language == AppLanguage.bn ? 'সব পঠিত' : 'Mark all read',
                style: TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationItem(
              type: notification['type'] as String,
              user: notification['user'] as String,
              action: notification['action'] as String,
              time: notification['time'] as String,
              isRead: notification['read'] as bool,
              isDark: isDark,
            );
          },
        ),
      );
    });
  }

  Widget _buildNotificationItem({
    required String type,
    required String user,
    required String action,
    required String time,
    required bool isRead,
    required bool isDark,
  }) {
    IconData icon;
    Color iconColor;
    
    switch (type) {
      case 'like':
        icon = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        icon = Icons.chat_bubble;
        iconColor = Colors.blue;
        break;
      case 'follow':
        icon = Icons.person_add;
        iconColor = AppColors.lightPrimary;
        break;
      case 'mention':
        icon = Icons.alternate_email;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead 
            ? Colors.transparent 
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: user,
                        style: TextStyle(
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' $action',
                        style: TextStyle(
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
