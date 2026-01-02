import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import 'account_settings_controller.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final controller = Get.put(AccountSettingsController());

    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Column(
          children: [
            // Header
            _buildHeader(controller, isDark, isBn),

            // Content
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        children: [
                          // Profile Picture
                          _buildProfilePicture(controller, isDark, isBn),

                          const SizedBox(height: 32),

                          // Form Fields
                          _buildFormField(
                            label: isBn ? 'নাম' : 'Name',
                            controller: controller.nameController,
                            isDark: isDark,
                            isEditing: controller.isEditing.value,
                          ),
                          const SizedBox(height: 24),

                          _buildFormField(
                            label: isBn ? 'ইউজারনেম' : 'Username',
                            controller: controller.usernameController,
                            isDark: isDark,
                            isEditing: controller.isEditing.value,
                          ),
                          const SizedBox(height: 24),

                          _buildFormField(
                            label: isBn ? 'ইমেইল' : 'Email',
                            controller: controller.emailController,
                            isDark: isDark,
                            isEditing: controller.isEditing.value,
                            prefixIcon: Icons.mail_outline,
                          ),
                          const SizedBox(height: 24),

                          _buildFormField(
                            label: isBn ? 'ফোন' : 'Phone',
                            controller: controller.phoneController,
                            isDark: isDark,
                            isEditing: controller.isEditing.value,
                            prefixIcon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 24),

                          _buildFormField(
                            label: isBn ? 'বায়ো' : 'Bio',
                            controller: controller.bioController,
                            isDark: isDark,
                            isEditing: controller.isEditing.value,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          _buildFormField(
                            label: isBn ? 'অবস্থান' : 'Location',
                            controller: controller.locationController,
                            isDark: isDark,
                            isEditing: controller.isEditing.value,
                            prefixIcon: Icons.location_on_outlined,
                          ),

                          // Cancel button when editing
                          if (controller.isEditing.value) ...[
                            const SizedBox(height: 24),
                            _buildCancelButton(controller, isDark, isBn),
                          ],

                          // Danger Zone
                          _buildDangerZone(controller, isDark, isBn),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(AccountSettingsController controller, bool isDark, bool isBn) {
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
              onTap: () {
                if (controller.isEditing.value) {
                  controller.cancelEdit();
                }
                Get.back();
              },
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
            Obx(() => GestureDetector(
                  onTap: controller.isSaving.value ? null : controller.toggleEditSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: controller.isEditing.value
                          ? AppColors.lightPrimary
                          : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (controller.isSaving.value)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(
                            controller.isEditing.value ? Icons.check : Icons.edit,
                            size: 16,
                            color: controller.isEditing.value
                                ? Colors.white
                                : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          controller.isEditing.value
                              ? (isBn ? 'সংরক্ষণ করুন' : 'Save')
                              : (isBn ? 'সম্পাদনা' : 'Edit'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: controller.isEditing.value
                                ? Colors.white
                                : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(AccountSettingsController controller, bool isDark, bool isBn) {
    return Obx(() => Column(
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
                  child: ClipOval(
                    child: controller.profileImageUrl.value.isNotEmpty
                        ? Image.network(
                            controller.profileImageUrl.value,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                  ),
                ),
                if (controller.isEditing.value)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement profile image picker
                        Get.snackbar(
                          isBn ? 'শীঘ্রই আসছে' : 'Coming Soon',
                          isBn ? 'প্রোফাইল ছবি পরিবর্তন করার বৈশিষ্ট্য শীঘ্রই আসছে' : 'Profile picture change feature coming soon',
                          backgroundColor: Colors.blue.shade100,
                          colorText: Colors.blue.shade800,
                        );
                      },
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
        ));
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required bool isEditing,
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
          ),
          child: TextField(
            controller: controller,
            enabled: isEditing,
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
              // border: InputBorder.none,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildCancelButton(AccountSettingsController controller, bool isDark, bool isBn) {
    return GestureDetector(
      onTap: controller.cancelEdit,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            isBn ? 'বাতিল করুন' : 'Cancel',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone(AccountSettingsController controller, bool isDark, bool isBn) {
    return Container(
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
            onTap: controller.deleteAccount,
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
    );
  }
}
