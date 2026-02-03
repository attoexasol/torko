import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/presentation/community/controllers/group_detail_controller.dart';
import 'package:torko/presentation/community/controllers/group_posts_controller.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'widgets/group_post_text_field.dart';
import 'widgets/image_picker_strip.dart';

class CreateGroupPostScreen extends StatefulWidget {
  final int groupId;
  final String? groupName;

  const CreateGroupPostScreen({
    super.key,
    required this.groupId,
    this.groupName,
  });

  @override
  State<CreateGroupPostScreen> createState() => _CreateGroupPostScreenState();
}

class _CreateGroupPostScreenState extends State<CreateGroupPostScreen> {
  @override
  void initState() {
    super.initState();
    final c = Get.put(GroupPostsController(), permanent: false);
    c.reset();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GroupPostsController>();
    final appController = Get.find<AppController>();
    final isDark = appController.isDarkMode;
    final isBn = appController.language == AppLanguage.bn;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF052029) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF052029) : Colors.white,
        elevation: 0,
        leading: Obx(() {
          final submitting = c.isSubmitting.value;
          return IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
            onPressed: submitting ? null : () => _onCancel(context, c),
          );
        }),
        title: Text(
          isBn ? 'পোস্ট তৈরি' : 'Create Post',
          style: GoogleFonts.notoSansBengali(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Obx(() {
            final submitting = c.isSubmitting.value;
            final valid = _isValid(c);
            return TextButton(
              onPressed: (submitting || !valid) ? null : () => _onPost(c),
              child: submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFd97757)),
                    )
                  : Text(
                      isBn ? 'পোস্ট' : 'Post',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: valid ? const Color(0xFFd97757) : Colors.grey,
                      ),
                    ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => GroupPostTextField(
                    controller: c.titleCtrl,
                    label: isBn ? 'পোস্টের শিরোনাম' : 'Post Title',
                    hint: isBn ? 'শিরোনাম লিখুন...' : 'Write a title...',
                    error: c.titleError.value.isEmpty ? null : c.titleError.value,
                    maxLength: GroupPostsController.maxTitleLen,
                  )),
              const SizedBox(height: 16),
              Obx(() => GroupPostTextField(
                    controller: c.descCtrl,
                    label: isBn ? 'বিবরণ' : 'Description',
                    hint: isBn ? 'কিছু লিখুন...' : 'Write something...',
                    error: c.descError.value.isEmpty ? null : c.descError.value,
                    maxLines: 4,
                    maxLength: GroupPostsController.maxDescLen,
                  )),
              const SizedBox(height: 20),
              Obx(() => ImagePickerStrip(
                    base64Images: c.selectedBase64Images.toList(),
                    onAddTap: c.pickImages,
                    onRemove: c.removeImage,
                    maxCount: GroupPostsController.maxImages,
                    disabled: c.isSubmitting.value,
                  )),
              const SizedBox(height: 8),
              Text(
                isBn ? 'ছবি গ্রুপ অ্যাডমিনের অনুমোদনের জন্য জমা দেওয়া হবে।' : 'Images will be submitted to group admin for approval.',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 12,
                  color: const Color(0xFFB8DED6).withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final submitting = c.isSubmitting.value;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: submitting ? null : () => _onCancel(context, c),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFd97757)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          isBn ? 'বাতিল' : 'Cancel',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFd97757),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submitting ? null : () => _onPost(c),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd97757),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isBn ? 'জমা দিন' : 'Submit',
                                style: GoogleFonts.notoSansBengali(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValid(GroupPostsController c) {
    final title = c.titleCtrl.text.trim();
    final desc = c.descCtrl.text.trim();
    return title.length >= GroupPostsController.minTitleLen &&
        title.length <= GroupPostsController.maxTitleLen &&
        desc.isNotEmpty &&
        desc.length <= GroupPostsController.maxDescLen &&
        c.selectedBase64Images.isNotEmpty;
  }

  void _onCancel(BuildContext context, GroupPostsController c) {
    c.reset();
    Get.back();
  }

  Future<void> _onPost(GroupPostsController c) async {
    final ok = await c.submit(widget.groupId);
    if (ok) {
      c.reset();
      Get.back();
      if (Get.isRegistered<GroupDetailController>()) {
        Get.find<GroupDetailController>().fetchGroup(widget.groupId);
      }
    }
  }
}
