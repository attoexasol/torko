import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:torko/presentation/community/controllers/group_detail_controller.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/data/models/community_group_model.dart';
import 'widgets/group_post_text_field.dart';
import 'widgets/image_picker_strip.dart';

class EditGroupPostSheet extends StatefulWidget {
  final CommunityGroupPostModel post;

  const EditGroupPostSheet({super.key, required this.post});

  static void show({required CommunityGroupPostModel post}) {
    Get.bottomSheet(
      EditGroupPostSheet(post: post),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<EditGroupPostSheet> createState() => _EditGroupPostSheetState();
}

class _EditGroupPostSheetState extends State<EditGroupPostSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  final RxList<String> _base64Images = <String>[].obs;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.post.postTitle);
    _descCtrl = TextEditingController(text: widget.post.postDescription);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_base64Images.length >= 5) return;
    try {
      final list = await _imagePicker.pickMultiImage(maxWidth: 1200, imageQuality: 85);
      for (final x in list) {
        if (_base64Images.length >= 5) break;
        final bytes = await File(x.path).readAsBytes();
        final ext = x.path.toLowerCase();
        final mime = ext.endsWith('.png') ? 'image/png' : 'image/jpeg';
        _base64Images.add('data:$mime;base64,${base64Encode(bytes)}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final isBn = Get.find<AppController>().language == AppLanguage.bn;

    if (title.isEmpty) {
      Get.snackbar(isBn ? 'প্রয়োজন' : 'Required', isBn ? 'শিরোনাম প্রয়োজন' : 'Title is required');
      return;
    }
    if (title.length < 3) {
      Get.snackbar(isBn ? 'প্রয়োজন' : 'Required', isBn ? 'অন্তত ৩ অক্ষর' : 'Title min 3 characters');
      return;
    }
    if (desc.isEmpty) {
      Get.snackbar(isBn ? 'প্রয়োজন' : 'Required', isBn ? 'বিবরণ প্রয়োজন' : 'Description is required');
      return;
    }

    final c = Get.find<GroupDetailController>();
    try {
      await c.updateGroupPostUI(
        postId: widget.post.postId,
        title: title,
        description: desc,
        base64Images: _base64Images.toList(),
        existingPost: widget.post,
      );
      Get.back();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Get.find<AppController>().language == AppLanguage.bn;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Color(0xFF0a2f3d),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isBn ? 'পোস্ট সম্পাদনা' : 'Edit Post',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              GroupPostTextField(
                controller: _titleCtrl,
                label: isBn ? 'শিরোনাম' : 'Title',
                hint: isBn ? 'শিরোনাম লিখুন...' : 'Write a title...',
                maxLength: 120,
              ),
              const SizedBox(height: 16),
              GroupPostTextField(
                controller: _descCtrl,
                label: isBn ? 'বিবরণ' : 'Description',
                hint: isBn ? 'কিছু লিখুন...' : 'Write something...',
                maxLines: 4,
                maxLength: 2000,
              ),
              const SizedBox(height: 16),
              Obx(() => ImagePickerStrip(
                    base64Images: _base64Images.toList(),
                    onAddTap: _pickImages,
                    onRemove: (i) => _base64Images.removeAt(i),
                    maxCount: 5,
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFd97757)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isBn ? 'বাতিল' : 'Cancel',
                        style: GoogleFonts.notoSansBengali(color: Color(0xFFd97757), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final updating = Get.find<GroupDetailController>().isUpdatingPost.value;
                      return ElevatedButton(
                        onPressed: updating ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd97757),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: updating
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isBn ? 'সংরক্ষণ' : 'Save',
                                style: GoogleFonts.notoSansBengali(fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
