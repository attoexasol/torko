import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import 'notification_settings_controller.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final controller = Get.put(NotificationSettingsController());

    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Column(
          children: [
            // Header
            _buildHeader(isDark, isBn),

            // Content
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Push Notifications Section
                          _buildSectionTitle(
                            isBn ? 'পুশ নোটিফিকেশন' : 'Push Notifications',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.notifications_outlined,
                            label: isBn ? 'পুশ নোটিফিকেশন চালু করুন' : 'Enable Push Notifications',
                            description: isBn
                                ? 'আপনার ডিভাইসে নোটিফিকেশন পান'
                                : 'Receive notifications on your device',
                            value: controller.pushNotifications.value,
                            settingName: 'pushNotifications',
                            onChanged: controller.onPushNotificationsChanged,
                            isDark: isDark,
                            isHighlighted: true,
                          ),

                          const SizedBox(height: 32),

                          // Activity Section
                          _buildSectionTitle(
                            isBn ? 'কার্যকলাপ' : 'Activity',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.favorite_outline,
                            label: isBn ? 'লাইক' : 'Likes',
                            description: isBn
                                ? 'যখন কেউ আপনার পোস্ট লাইক করে'
                                : 'When someone likes your post',
                            value: controller.likes.value,
                            settingName: 'likes',
                            onChanged: controller.onLikesChanged,
                            isDark: isDark,
                          ),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.message_outlined,
                            label: isBn ? 'কমেন্ট' : 'Comments',
                            description: isBn
                                ? 'যখন কেউ আপনার পোস্টে কমেন্ট করে'
                                : 'When someone comments on your post',
                            value: controller.comments.value,
                            settingName: 'comments',
                            onChanged: controller.onCommentsChanged,
                            isDark: isDark,
                          ),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.alternate_email,
                            label: isBn ? 'মেনশন' : 'Mentions',
                            description: isBn
                                ? 'যখন কেউ আপনাকে ট্যাগ করে'
                                : 'When someone mentions you',
                            value: controller.mentions.value,
                            settingName: 'mentions',
                            onChanged: controller.onMentionsChanged,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

                          // Social Section
                          _buildSectionTitle(
                            isBn ? 'সামাজিক' : 'Social',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.people_outline,
                            label: isBn ? 'নতুন ফলোয়ার' : 'New Followers',
                            description: isBn
                                ? 'যখন কেউ আপনাকে ফলো করে'
                                : 'When someone follows you',
                            value: controller.newFollowers.value,
                            settingName: 'newFollowers',
                            onChanged: controller.onNewFollowersChanged,
                            isDark: isDark,
                          ),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.message_outlined,
                            label: isBn ? 'মেসেজ' : 'Messages',
                            description: isBn
                                ? 'নতুন ডাইরেক্ট মেসেজ'
                                : 'New direct messages',
                            value: controller.messages.value,
                            settingName: 'messages',
                            onChanged: controller.onMessagesChanged,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

                          // Community Section
                          _buildSectionTitle(
                            isBn ? 'কমিউনিটি' : 'Community',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.campaign_outlined,
                            label: isBn ? 'কমিউনিটি আপডেট' : 'Community Updates',
                            description: isBn
                                ? 'আপনার কমিউনিটি থেকে আপডেট'
                                : 'Updates from your communities',
                            value: controller.communityUpdates.value,
                            settingName: 'communityUpdates',
                            onChanged: controller.onCommunityUpdatesChanged,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

                          // Other Section
                          _buildSectionTitle(
                            isBn ? 'অন্যান্য' : 'Other',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationCard(
                            controller: controller,
                            icon: Icons.email_outlined,
                            label: isBn ? 'ইমেইল নোটিফিকেশন' : 'Email Notifications',
                            description: isBn
                                ? 'ইমেইলে নোটিফিকেশন পান'
                                : 'Receive notifications via email',
                            value: controller.emailNotifications.value,
                            settingName: 'emailNotifications',
                            onChanged: controller.onEmailNotificationsChanged,
                            isDark: isDark,
                          ),

                          // Quiet Hours
                          _buildQuietHoursSection(controller, isDark, isBn, context),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark, bool isBn) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Expanded(
              child: Text(
                isBn ? 'নোটিফিকেশন সেটিংস' : 'Notification Settings',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  height: 1.4,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
        height: 1.4,
      ),
    );
  }

  Widget _buildNotificationCard({
    required NotificationSettingsController controller,
    required IconData icon,
    required String label,
    required String description,
    required bool value,
    required String settingName,
    required Function(bool) onChanged,
    required bool isDark,
    bool isHighlighted = false,
  }) {
    return Obx(() {
      final isUpdating = controller.isSettingUpdating(settingName);

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.lightPrimary.withValues(alpha: 0.05)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUpdating
                ? AppColors.lightPrimary
                : isHighlighted
                    ? AppColors.lightPrimary
                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? AppColors.lightPrimary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isHighlighted ? 12 : 8,
              offset: Offset(0, isHighlighted ? 4 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isUpdating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.lightPrimary,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuietHoursSection(
    NotificationSettingsController controller,
    bool isDark,
    bool isBn,
    BuildContext context,
  ) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(top: 32),
          padding: const EdgeInsets.only(top: 32),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'নিরব সময়' : 'Quiet Hours',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showQuietHoursPicker(controller, context, isDark, isBn),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.isSettingUpdating('quietHours')
                          ? AppColors.lightPrimary
                          : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'নিরব সময় সেট করুন' : 'Set Quiet Hours',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (controller.isSettingUpdating('quietHours'))
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Text(
                          controller.hasQuietHours
                              ? controller.quietHoursDisplay
                              : (isBn ? 'বন্ধ' : 'Off'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: controller.hasQuietHours
                                ? AppColors.lightPrimary
                                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _showQuietHoursPicker(
    NotificationSettingsController controller,
    BuildContext context,
    bool isDark,
    bool isBn,
  ) {
    TimeOfDay startTime = TimeOfDay(
      hour: int.tryParse(controller.silentStartTime.value.split(':')[0]) ?? 22,
      minute: int.tryParse(controller.silentStartTime.value.split(':')[1]) ?? 0,
    );
    TimeOfDay endTime = TimeOfDay(
      hour: int.tryParse(controller.silentEndTime.value.split(':')[0]) ?? 6,
      minute: int.tryParse(controller.silentEndTime.value.split(':')[1]) ?? 0,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'নিরব সময় সেট করুন' : 'Set Quiet Hours',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (time != null) {
                          setState(() => startTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'শুরু' : 'Start',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              startTime.format(context),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (time != null) {
                          setState(() => endTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'শেষ' : 'End',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              endTime.format(context),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isBn ? 'বাতিল' : 'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final startStr =
                            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                        final endStr =
                            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
                        controller.updateQuietHours(startStr, endStr);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isBn ? 'সংরক্ষণ' : 'Save',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
