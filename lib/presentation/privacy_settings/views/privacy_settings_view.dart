import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/privacy_settings/controllers/privacy_settings_controller.dart';

class PrivacySettingsView extends StatelessWidget {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final controller = Get.put(PrivacySettingsController());

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
                          // Info Banner
                          _buildInfoBanner(isDark, isBn),

                          // Account Privacy Section
                          _buildSectionTitle(
                            isBn ? 'অ্যাকাউন্ট গোপনীয়তা' : 'Account Privacy',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildPrivacyCard(
                            controller: controller,
                            icon: Icons.lock_outline,
                            label: isBn ? 'ব্যক্তিগত অ্যাকাউন্ট' : 'Private Account',
                            description: isBn
                                ? 'শুধুমাত্র অনুমোদিত ফলোয়াররা আপনার পোস্ট দেখতে পারবে'
                                : 'Only approved followers can see your posts',
                            value: controller.privateAccount.value,
                            settingName: 'privateAccount',
                            onChanged: controller.onPrivateAccountChanged,
                            isDark: isDark,
                          ),
                          _buildPrivacyCard(
                            controller: controller,
                            icon: Icons.visibility_outlined,
                            label: isBn ? 'অনলাইন স্ট্যাটাস দেখান' : 'Show Online Status',
                            description: isBn
                                ? 'অন্যরা দেখতে পারবে আপনি অনলাইনে আছেন কিনা'
                                : 'Let others see when you\'re online',
                            value: controller.showOnlineStatus.value,
                            settingName: 'showOnlineStatus',
                            onChanged: controller.onShowOnlineStatusChanged,
                            isDark: isDark,
                          ),
                          _buildPrivacyCard(
                            controller: controller,
                            icon: Icons.people_outline,
                            label: isBn ? 'কার্যকলাপ দেখান' : 'Show Activity',
                            description: isBn
                                ? 'আপনার লাইক এবং কমেন্ট দেখান'
                                : 'Show your likes and comments',
                            value: controller.showActivity.value,
                            settingName: 'showActivity',
                            onChanged: controller.onShowActivityChanged,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

                          // Messaging Section
                          _buildSectionTitle(
                            isBn ? 'মেসেজিং' : 'Messaging',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildPrivacyCard(
                            controller: controller,
                            icon: Icons.message_outlined,
                            label: isBn ? 'যে কেউ মেসেজ পাঠাতে পারবে' : 'Allow Messages from Anyone',
                            description: isBn
                                ? 'সকলের কাছ থেকে মেসেজ গ্রহণ করুন'
                                : 'Accept messages from everyone',
                            value: controller.allowMessages.value,
                            settingName: 'allowMessages',
                            onChanged: controller.onAllowMessagesChanged,
                            isDark: isDark,
                          ),
                          _buildPrivacyCard(
                            controller: controller,
                            icon: Icons.visibility_outlined,
                            label: isBn ? 'রিড রিসিট দেখান' : 'Show Read Receipts',
                            description: isBn
                                ? 'প্রেরক জানতে পারবে আপনি মেসেজ পড়েছেন'
                                : 'Let senders know you\'ve read their messages',
                            value: controller.showReadReceipts.value,
                            settingName: 'showReadReceipts',
                            onChanged: controller.onShowReadReceiptsChanged,
                            isDark: isDark,
                          ),
                          _buildPrivacyCard(
                            controller: controller,
                            icon: Icons.message_outlined,
                            label: isBn ? 'টাইপিং ইন্ডিকেটর' : 'Typing Indicator',
                            description: isBn
                                ? 'দেখান যখন আপনি টাইপ করছেন'
                                : 'Show when you\'re typing',
                            value: controller.showTypingIndicator.value,
                            settingName: 'showTypingIndicator',
                            onChanged: controller.onShowTypingIndicatorChanged,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

                          // Interactions Section
                          _buildSectionTitle(
                            isBn ? 'ইন্টারঅ্যাকশন' : 'Interactions',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildPrivacyCard(
                            controller: controller,
                            icon: Icons.people_outline,
                            label: isBn ? 'অন্যরা আমাকে ট্যাগ করতে পারবে' : 'Allow Others to Tag Me',
                            description: isBn
                                ? 'পোস্ট এবং কমেন্টে ট্যাগ করার অনুমতি দিন'
                                : 'Allow tagging in posts and comments',
                            value: controller.allowTagging.value,
                            settingName: 'allowTagging',
                            onChanged: controller.onAllowTaggingChanged,
                            isDark: isDark,
                          ),

                          // Blocked Users
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to blocked users
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
                                      isBn ? 'ব্লক করা ব্যবহারকারী' : 'Blocked Users',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Text(
                                      '0',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                isBn ? 'গোপনীয়তা সেটিংস' : 'Privacy Settings',
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

  Widget _buildInfoBanner(bool isDark, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.lightSecondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 20,
            color: AppColors.lightSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isBn
                  ? 'আপনার গোপনীয়তা নিয়ন্ত্রণ করুন এবং আপনার তথ্য কে দেখতে পারবে তা সিদ্ধান্ত নিন।'
                  : 'Control your privacy and decide who can see your information.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
          ),
        ],
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

  Widget _buildPrivacyCard({
    required PrivacySettingsController controller,
    required IconData icon,
    required String label,
    required String description,
    required bool value,
    required String settingName,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Obx(() {
      final isUpdating = controller.isSettingUpdating(settingName);

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUpdating
                ? AppColors.lightPrimary.withOpacity(0.5)
                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
}
