import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/community/controllers/community_groups_controller.dart';
import 'package:torko/presentation/community/controllers/group_detail_controller.dart';
import 'package:torko/data/models/community_group_model.dart';

const String _baseImageUrl = 'https://torko.attoexasolutions.com/';

/// Edit Group bottom sheet - pre-filled form, update API.
class GroupEditSheet extends StatefulWidget {
  final CommunityGroupModel group;

  const GroupEditSheet({super.key, required this.group});

  static void show(CommunityGroupModel group) {
    Get.bottomSheet(
      GroupEditSheet(group: group),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  State<GroupEditSheet> createState() => _GroupEditSheetState();
}

class _GroupEditSheetState extends State<GroupEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late String _visibility;
  File? _coverImage;
  String? _nameError;
  String? _bioError;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final g = widget.group;
    _nameController = TextEditingController(text: g.name);
    _bioController = TextEditingController(text: g.bio ?? '');
    _locationController = TextEditingController(text: g.location ?? '');
    _visibility = g.visibility ?? 'public';
  }

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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final location = _locationController.text.trim();
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;

    setState(() {
      _nameError = name.isEmpty ? (isBn ? 'গ্রুপের নাম প্রয়োজন' : 'Group name is required') : null;
      _bioError = bio.isEmpty ? (isBn ? 'বায়ো প্রয়োজন' : 'Bio is required') : null;
    });
    if (_nameError != null || _bioError != null) return;

    if (bio.length > 1000) {
      _showValidationSnackbar(
        isBn ? 'দীর্ঘ' : 'Too long',
        isBn ? 'বায়ো সর্বোচ্চ ১০০০ অক্ষর' : 'Bio max 1000 characters',
      );
      return;
    }

    try {
      String? imageDataUri;
      if (_coverImage != null) {
        final bytes = await _coverImage!.readAsBytes();
        imageDataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final groupsCtrl = Get.find<CommunityGroupsController>();
      await groupsCtrl.updateGroupFromUI(
        widget.group,
        name: name,
        bio: bio,
        visibility: _visibility,
        location: location.isEmpty ? null : location,
        imageDataUri: imageDataUri,
      );
    } catch (_) {
      // Controller shows error snackbar; keep sheet open for retry
    }
  }

  @override
  Widget build(BuildContext context) {
    const isDark = true;
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0a2f3d),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isBn ? 'গ্রুপ সম্পাদনা' : 'Edit Group',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _field(
                  controller: _nameController,
                  label: isBn ? 'গ্রুপের নাম' : 'Group name',
                  hint: isBn ? 'যেমন: লারাভেল ডেভেলপার্স' : 'e.g. Laravel Developers',
                  error: _nameError,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _field(
                  controller: _bioController,
                  label: isBn ? 'বায়ো' : 'Bio',
                  hint: isBn ? 'গ্রুপের সংক্ষিপ্ত বিবরণ' : 'Short description',
                  error: _bioError,
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
                  items: const ['public', 'private', 'members'],
                  labels: isBn ? ['সার্বজনীন', 'ব্যক্তিগত', 'সদস্য'] : ['Public', 'Private', 'Members'],
                  isDark: isDark,
                  onChanged: (v) => setState(() => _visibility = v!),
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'কভার ছবি (ঐচ্ছিক)' : 'Cover image (optional)',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB8DED6),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => GestureDetector(
                  onTap: Get.find<CommunityGroupsController>().isUpdating.value ? null : _pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0d3a4a),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF0d3a4a)),
                    ),
                    child: _coverImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_coverImage!, fit: BoxFit.cover, width: double.infinity),
                          )
                        : _buildCoverPreview(),
                  ),
                )),
                const SizedBox(height: 24),
                Obx(() {
                  final c = Get.find<CommunityGroupsController>();
                  final updating = c.isUpdating.value;
                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: updating ? null : () => Get.back(),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0d3a4a),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Center(
                            child: Text(
                              isBn ? 'বাতিল' : 'Cancel',
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: updating ? null : _save,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFd97757),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: updating
                                ? const Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      isBn ? 'সংরক্ষণ' : 'Save Changes',
                                      style: GoogleFonts.notoSansBengali(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPreview() {
    final cover = widget.group.coverImage;
    final url = cover != null && cover.isNotEmpty
        ? (cover.startsWith('http') ? cover : '$_baseImageUrl$cover')
        : null;
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 48,
        color: const Color(0xFFB8DED6).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    String? error,
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
            color: const Color(0xFFB8DED6),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.notoSansBengali(fontSize: 15, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSansBengali(
              color: const Color(0xFFB8DED6).withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: const Color(0xFF0d3a4a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : const Color(0xFF0d3a4a),
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: GoogleFonts.notoSansBengali(
              fontSize: 12,
              color: Colors.orange.shade300,
            ),
          ),
        ],
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
            color: const Color(0xFFB8DED6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0d3a4a),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0d3a4a),
              items: List.generate(items.length, (i) {
                return DropdownMenuItem(
                  value: items[i],
                  child: Text(
                    labels[i],
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
