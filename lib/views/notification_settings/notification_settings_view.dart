import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final appController = Get.find<AppController>();
  
  // Notification settings state
  bool _pushNotifications = true;
  bool _likes = true;
  bool _comments = true;
  bool _newFollowers = true;
  bool _mentions = true;
  bool _messages = true;
  bool _communityUpdates = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      final notificationSections = [
        _NotificationSection(
          title: isBn ? 'পুশ নোটিফিকেশন' : 'Push Notifications',
          items: [
            _NotificationItem(
              icon: Icons.notifications_outlined,
              label: isBn ? 'পুশ নোটিফিকেশন চালু করুন' : 'Enable Push Notifications',
              description: isBn
                  ? 'আপনার ডিভাইসে নোটিফিকেশন পান'
                  : 'Receive notifications on your device',
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
              isHighlighted: true,
            ),
          ],
        ),
        _NotificationSection(
          title: isBn ? 'কার্যকলাপ' : 'Activity',
          items: [
            _NotificationItem(
              icon: Icons.favorite_outline,
              label: isBn ? 'লাইক' : 'Likes',
              description: isBn
                  ? 'যখন কেউ আপনার পোস্ট লাইক করে'
                  : 'When someone likes your post',
              value: _likes,
              onChanged: (v) => setState(() => _likes = v),
            ),
            _NotificationItem(
              icon: Icons.message_outlined,
              label: isBn ? 'কমেন্ট' : 'Comments',
              description: isBn
                  ? 'যখন কেউ আপনার পোস্টে কমেন্ট করে'
                  : 'When someone comments on your post',
              value: _comments,
              onChanged: (v) => setState(() => _comments = v),
            ),
            _NotificationItem(
              icon: Icons.alternate_email,
              label: isBn ? 'মেনশন' : 'Mentions',
              description: isBn
                  ? 'যখন কেউ আপনাকে ট্যাগ করে'
                  : 'When someone mentions you',
              value: _mentions,
              onChanged: (v) => setState(() => _mentions = v),
            ),
          ],
        ),
        _NotificationSection(
          title: isBn ? 'সামাজিক' : 'Social',
          items: [
            _NotificationItem(
              icon: Icons.people_outline,
              label: isBn ? 'নতুন ফলোয়ার' : 'New Followers',
              description: isBn
                  ? 'যখন কেউ আপনাকে ফলো করে'
                  : 'When someone follows you',
              value: _newFollowers,
              onChanged: (v) => setState(() => _newFollowers = v),
            ),
            _NotificationItem(
              icon: Icons.message_outlined,
              label: isBn ? 'মেসেজ' : 'Messages',
              description: isBn
                  ? 'নতুন ডাইরেক্ট মেসেজ'
                  : 'New direct messages',
              value: _messages,
              onChanged: (v) => setState(() => _messages = v),
            ),
          ],
        ),
        _NotificationSection(
          title: isBn ? 'কমিউনিটি' : 'Community',
          items: [
            _NotificationItem(
              icon: Icons.campaign_outlined,
              label: isBn ? 'কমিউনিটি আপডেট' : 'Community Updates',
              description: isBn
                  ? 'আপনার কমিউনিটি থেকে আপডেট'
                  : 'Updates from your communities',
              value: _communityUpdates,
              onChanged: (v) => setState(() => _communityUpdates = v),
            ),
          ],
        ),
        _NotificationSection(
          title: isBn ? 'অন্যান্য' : 'Other',
          items: [
            _NotificationItem(
              icon: Icons.notifications_outlined,
              label: isBn ? 'ইমেইল নোটিফিকেশন' : 'Email Notifications',
              description: isBn
                  ? 'ইমেইলে নোটিফিকেশন পান'
                  : 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (v) => setState(() => _emailNotifications = v),
            ),
          ],
        ),
      ];

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Column(
          children: [
            // Header
            Container(
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
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Sections
                    ...notificationSections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(top: index > 0 ? 32 : 0),
                        child: _buildSection(section, isDark),
                      );
                    }),

                    // Quiet Hours
                    Container(
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
                            onTap: () {
                              // Set quiet hours
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
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
                                  Text(
                                    isBn ? 'বন্ধ' : 'Off',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection(_NotificationSection section, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ...section.items.map((item) => _buildNotificationCard(item, isDark)),
      ],
    );
  }

  Widget _buildNotificationCard(_NotificationItem item, bool isDark) {
    final isHighlighted = item.isHighlighted ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.lightPrimary.withValues(alpha: 0.05)
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
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
                item.icon,
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
                    item.label,
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
                      item.description,
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
            Switch(
              value: item.value,
              onChanged: item.onChanged,
              activeThumbColor: AppColors.lightPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSection {
  final String title;
  final List<_NotificationItem> items;

  _NotificationSection({
    required this.title,
    required this.items,
  });
}

class _NotificationItem {
  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final Function(bool) onChanged;
  final bool? isHighlighted;

  _NotificationItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    this.isHighlighted,
  });
}
