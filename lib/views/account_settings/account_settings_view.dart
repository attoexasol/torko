import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({super.key});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  final appController = Get.find<AppController>();
  bool _isEditing = false;
  
  // Form data
  final TextEditingController _nameController = TextEditingController(text: 'রহিম আহমেদ');
  final TextEditingController _usernameController = TextEditingController(text: '@rahim_ahmed');
  final TextEditingController _emailController = TextEditingController(text: 'rahim@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '+880 1712-345678');
  final TextEditingController _bioController = TextEditingController(text: 'ঢাকায় থাকি। প্রযুক্তি এবং ফটোগ্রাফি পছন্দ করি।');
  final TextEditingController _locationController = TextEditingController(text: 'ঢাকা, বাংলাদেশ');

  void _handleSave() {
    setState(() {
      _isEditing = false;
    });
    // Save logic here
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
                        isBn ? 'অ্যাকাউন্ট সেটিংস' : 'Account Settings',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          height: 1.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_isEditing) {
                          _handleSave();
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isEditing
                              ? AppColors.lightPrimary
                              : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: _isEditing
                                  ? Colors.white
                                  : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isEditing
                                  ? (isBn ? 'সংরক্ষণ করুন' : 'Save')
                                  : (isBn ? 'সম্পাদনা' : 'Edit'),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _isEditing
                                    ? Colors.white
                                    : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                              ),
                            ),
                          ],
                        ),
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
                  children: [
                    // Profile Picture
                    Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.lightPrimary,
                                    AppColors.lightSecondary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.darkBackground : Colors.white,
                                      width: 4,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isBn ? 'প্রোফাইল ছবি পরিবর্তন করুন' : 'Change profile picture',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Form Fields
                    _buildFormField(
                      label: isBn ? 'নাম' : 'Name',
                      controller: _nameController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: isBn ? 'ইউজারনেম' : 'Username',
                      controller: _usernameController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: isBn ? 'ইমেইল' : 'Email',
                      controller: _emailController,
                      isDark: isDark,
                      prefixIcon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: isBn ? 'ফোন' : 'Phone',
                      controller: _phoneController,
                      isDark: isDark,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: isBn ? 'বায়ো' : 'Bio',
                      controller: _bioController,
                      isDark: isDark,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: isBn ? 'অবস্থান' : 'Location',
                      controller: _locationController,
                      isDark: isDark,
                      prefixIcon: Icons.location_on_outlined,
                    ),

                    // Danger Zone
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
                            isBn ? 'বিপজ্জনক জোন' : 'Danger Zone',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              // Delete account logic
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  isBn ? 'অ্যাকাউন্ট ডিলিট করুন' : 'Delete Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: maxLines > 1 ? null : 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: _isEditing,
            maxLines: maxLines,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? 0 : 16,
                vertical: maxLines > 1 ? 12 : 0,
              ),
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        prefixIcon,
                        size: 20,
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 48,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
