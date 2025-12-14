import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final appController = Get.find<AppController>();
  bool _showNearby = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

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
                        margin: const EdgeInsets.only(right: 16),
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
                    Text(
                      appController.t('settings'),
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        height: 1.4,
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
                    // Account Section
                    _buildSection(
                      title: isBn ? 'অ্যাকাউন্ট' : 'Account',
                      isDark: isDark,
                      items: [
                        _SettingsItem(
                          icon: Icons.person_outline,
                          label: isBn ? 'অ্যাকাউন্ট সেটিংস' : 'Account Settings',
                          onTap: () => Get.toNamed(AppRoutes.accountSettings),
                        ),
                        _SettingsItem(
                          icon: Icons.lock_outline,
                          label: isBn ? 'গোপনীয়তা সেটিংস' : 'Privacy Settings',
                          onTap: () => Get.toNamed(AppRoutes.privacySettings),
                        ),
                        _SettingsItem(
                          icon: Icons.notifications_outlined,
                          label: isBn ? 'নোটিফিকেশন সেটিংস' : 'Notification Settings',
                          onTap: () => Get.toNamed(AppRoutes.notificationSettings),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Location & Privacy Section
                    _buildSection(
                      title: isBn ? 'লোকেশন ও গোপনীয়তা' : 'Location & Privacy',
                      isDark: isDark,
                      items: [
                        _SettingsItem(
                          icon: Icons.location_on_outlined,
                          label: isBn ? 'আমাকে কাছাকাছি লোকদের কাছে দেখান' : 'Show me to nearby people',
                          description: isBn
                              ? 'আপনার লোকেশন শেয়ার করুন এবং কাছাকাছি কমিউনিটি আবিষ্কার করুন'
                              : 'Share your location and discover nearby communities',
                          hasSwitch: true,
                          switchValue: _showNearby,
                          onSwitchChanged: (value) {
                            setState(() {
                              _showNearby = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Preferences Section
                    _buildSection(
                      title: isBn ? 'পছন্দসমূহ' : 'Preferences',
                      isDark: isDark,
                      items: [
                        _SettingsItem(
                          icon: Icons.language,
                          label: isBn ? 'ভাষা' : 'Language',
                          value: isBn ? 'বাংলা' : 'English',
                          onTap: () => appController.toggleLanguage(),
                        ),
                        _SettingsItem(
                          icon: isDark ? Icons.dark_mode : Icons.light_mode,
                          label: isBn ? 'থিম' : 'Theme',
                          description: isDark
                              ? (isBn ? 'ডার্ক মোড' : 'Dark Mode')
                              : (isBn ? 'লাইট মোড' : 'Light Mode'),
                          hasSwitch: true,
                          switchValue: isDark,
                          onSwitchChanged: (_) => appController.toggleTheme(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Support Section
                    _buildSection(
                      title: isBn ? 'সহায়তা' : 'Support',
                      isDark: isDark,
                      items: [
                        _SettingsItem(
                          icon: Icons.help_outline,
                          label: isBn ? 'সাহায্য কেন্দ্র' : 'Help Center',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.description_outlined,
                          label: isBn ? 'শর্তাবলী' : 'Terms of Service',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.shield_outlined,
                          label: isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                          onTap: () {},
                        ),
                      ],
                    ),

                    // App Version
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          '${isBn ? 'সংস্করণ' : 'Version'} 1.0.0',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: GestureDetector(
                        onTap: () => Get.offAllNamed(AppRoutes.onboarding),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                appController.t('logout'),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
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

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildSettingsCard(item, isDark)),
      ],
    );
  }

  Widget _buildSettingsCard(_SettingsItem item, bool isDark) {
    if (item.hasSwitch) {
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
                    if (item.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.description!,
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
                value: item.switchValue ?? false,
                onChanged: item.onSwitchChanged,
                activeThumbColor: AppColors.lightPrimary,
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
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
                    if (item.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.value!,
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
              Icon(
                Icons.chevron_right,
                size: 20,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? description;
  final String? value;
  final bool hasSwitch;
  final bool? switchValue;
  final VoidCallback? onTap;
  final Function(bool)? onSwitchChanged;

  _SettingsItem({
    required this.icon,
    required this.label,
    this.description,
    this.value,
    this.hasSwitch = false,
    this.switchValue,
    this.onTap,
    this.onSwitchChanged,
  });
}
