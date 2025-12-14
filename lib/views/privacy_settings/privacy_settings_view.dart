import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class PrivacySettingsView extends StatefulWidget {
  const PrivacySettingsView({super.key});

  @override
  State<PrivacySettingsView> createState() => _PrivacySettingsViewState();
}

class _PrivacySettingsViewState extends State<PrivacySettingsView> {
  final appController = Get.find<AppController>();
  
  // Privacy settings state
  bool _privateAccount = false;
  bool _showOnlineStatus = true;
  bool _allowMessages = true;
  bool _showReadReceipts = true;
  bool _showTypingIndicator = true;
  bool _allowTagging = true;
  bool _showActivity = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      final privacySections = [
        _PrivacySection(
          title: isBn ? 'অ্যাকাউন্ট গোপনীয়তা' : 'Account Privacy',
          items: [
            _PrivacyItem(
              icon: Icons.lock_outline,
              label: isBn ? 'ব্যক্তিগত অ্যাকাউন্ট' : 'Private Account',
              description: isBn
                  ? 'শুধুমাত্র অনুমোদিত ফলোয়াররা আপনার পোস্ট দেখতে পারবে'
                  : 'Only approved followers can see your posts',
              value: _privateAccount,
              onChanged: (v) => setState(() => _privateAccount = v),
            ),
            _PrivacyItem(
              icon: Icons.visibility_outlined,
              label: isBn ? 'অনলাইন স্ট্যাটাস দেখান' : 'Show Online Status',
              description: isBn
                  ? 'অন্যরা দেখতে পারবে আপনি অনলাইনে আছেন কিনা'
                  : 'Let others see when you\'re online',
              value: _showOnlineStatus,
              onChanged: (v) => setState(() => _showOnlineStatus = v),
            ),
            _PrivacyItem(
              icon: Icons.people_outline,
              label: isBn ? 'কার্যকলাপ দেখান' : 'Show Activity',
              description: isBn
                  ? 'আপনার লাইক এবং কমেন্ট দেখান'
                  : 'Show your likes and comments',
              value: _showActivity,
              onChanged: (v) => setState(() => _showActivity = v),
            ),
          ],
        ),
        _PrivacySection(
          title: isBn ? 'মেসেজিং' : 'Messaging',
          items: [
            _PrivacyItem(
              icon: Icons.message_outlined,
              label: isBn ? 'যে কেউ মেসেজ পাঠাতে পারবে' : 'Allow Messages from Anyone',
              description: isBn
                  ? 'সকলের কাছ থেকে মেসেজ গ্রহণ করুন'
                  : 'Accept messages from everyone',
              value: _allowMessages,
              onChanged: (v) => setState(() => _allowMessages = v),
            ),
            _PrivacyItem(
              icon: Icons.visibility_outlined,
              label: isBn ? 'রিড রিসিট দেখান' : 'Show Read Receipts',
              description: isBn
                  ? 'প্রেরক জানতে পারবে আপনি মেসেজ পড়েছেন'
                  : 'Let senders know you\'ve read their messages',
              value: _showReadReceipts,
              onChanged: (v) => setState(() => _showReadReceipts = v),
            ),
            _PrivacyItem(
              icon: Icons.message_outlined,
              label: isBn ? 'টাইপিং ইন্ডিকেটর' : 'Typing Indicator',
              description: isBn
                  ? 'দেখান যখন আপনি টাইপ করছেন'
                  : 'Show when you\'re typing',
              value: _showTypingIndicator,
              onChanged: (v) => setState(() => _showTypingIndicator = v),
            ),
          ],
        ),
        _PrivacySection(
          title: isBn ? 'ইন্টারঅ্যাকশন' : 'Interactions',
          items: [
            _PrivacyItem(
              icon: Icons.people_outline,
              label: isBn ? 'অন্যরা আমাকে ট্যাগ করতে পারবে' : 'Allow Others to Tag Me',
              description: isBn
                  ? 'পোস্ট এবং কমেন্টে ট্যাগ করার অনুমতি দিন'
                  : 'Allow tagging in posts and comments',
              value: _allowTagging,
              onChanged: (v) => setState(() => _allowTagging = v),
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
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Banner
                    Container(
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
                    ),

                    // Privacy Sections
                    ...privacySections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(top: index > 0 ? 32 : 0),
                        child: _buildSection(section, isDark),
                      );
                    }),

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

  Widget _buildSection(_PrivacySection section, bool isDark) {
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
        ...section.items.map((item) => _buildPrivacyCard(item, isDark)),
      ],
    );
  }

  Widget _buildPrivacyCard(_PrivacyItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
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

class _PrivacySection {
  final String title;
  final List<_PrivacyItem> items;

  _PrivacySection({
    required this.title,
    required this.items,
  });
}

class _PrivacyItem {
  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final Function(bool) onChanged;

  _PrivacyItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });
}
