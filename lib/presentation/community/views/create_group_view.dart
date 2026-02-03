import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/community/controllers/community_groups_controller.dart';

class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _visibility = 'public';
  String _status = 'active';
  File? _coverImage;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final x = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (x != null) {
        setState(() => _coverImage = File(x.path));
      }
    } catch (e) {
      Get.snackbar(
        Get.find<AppController>().language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showValidationSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final location = _locationController.text.trim();
    final isBn = Get.find<AppController>().language == AppLanguage.bn;

    if (name.isEmpty) {
      _showValidationSnackbar(
        isBn ? 'প্রয়োজন' : 'Required',
        isBn ? 'গ্রুপের নাম দিন' : 'Group name is required.',
      );
      return;
    }
    if (bio.isEmpty) {
      _showValidationSnackbar(
        isBn ? 'প্রয়োজন' : 'Required',
        isBn ? 'বায়ো দিন' : 'Bio is required.',
      );
      return;
    }

    String? imageBase64;
    if (_coverImage != null) {
      final bytes = await _coverImage!.readAsBytes();
      imageBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }
    final c = Get.find<CommunityGroupsController>();
    await c.createNewGroup(
      name: name,
      bio: bio,
      visibility: _visibility,
      status: _status,
      location: location.isEmpty ? null : location,
      imageDataUri: imageBase64,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final isDark = appController.isDarkMode;
    final isBn = appController.language == AppLanguage.bn;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF052029) : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF052029) : AppColors.lightBackground,
        elevation: 0,
        leading: Obx(() {
          final creating = Get.find<CommunityGroupsController>().isCreating.value;
          return IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
            onPressed: creating ? null : () => Get.back(),
          );
        }),
        title: Text(
          isBn ? 'গ্রুপ তৈরি' : 'Create Group',
          style: GoogleFonts.notoSansBengali(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              controller: _nameController,
              label: isBn ? 'গ্রুপের নাম' : 'Group name',
              hint: isBn ? 'যেমন: লারাভেল ডেভেলপার্স' : 'e.g. Laravel Developers',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _bioController,
              label: isBn ? 'বায়ো' : 'Bio',
              hint: isBn ? 'গ্রুপের সংক্ষিপ্ত বিবরণ' : 'Short description',
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _locationController,
              label: isBn ? 'অবস্থান' : 'Location',
              hint: isBn ? 'যেমন: ঢাকা, বাংলাদেশ' : 'e.g. Dhaka, Bangladesh',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: isBn ? 'দৃশ্যমানতা' : 'Visibility',
              value: _visibility,
              items: ['public', 'private'],
              labels: isBn ? ['সার্বজনীন', 'ব্যক্তিগত'] : ['Public', 'Private'],
              isDark: isDark,
              onChanged: (v) => setState(() => _visibility = v!),
            ),
            const SizedBox(height: 24),
            Text(
              isBn ? 'কভার ছবি (ঐচ্ছিক)' : 'Cover image (optional)',
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFB8DED6) : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final c = Get.find<CommunityGroupsController>();
              final creating = c.isCreating.value;
              return GestureDetector(
                onTap: creating ? null : _pickImage,
                child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: _coverImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_coverImage!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.5) : Colors.grey,
                        ),
                      ),
                ),
              );
            }),
            const SizedBox(height: 32),
            Obx(() {
              final c = Get.find<CommunityGroupsController>();
              final creating = c.isCreating.value;
              return SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: creating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd97757),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: creating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isBn ? 'তৈরি করা হচ্ছে…' : 'Creating…',
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          isBn ? 'গ্রুপ তৈরি করুন' : 'Create Group',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansBengali(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFB8DED6) : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.notoSansBengali(
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSansBengali(
              color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.5) : Colors.grey,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0d3a4a) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required List<String> labels,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansBengali(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFB8DED6) : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0d3a4a) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFE5E7EB)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: isDark ? const Color(0xFF0a2f3d) : Colors.white,
            style: GoogleFonts.notoSansBengali(
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
            ),
            items: List.generate(items.length, (i) {
              return DropdownMenuItem(value: items[i], child: Text(labels[i]));
            }),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
