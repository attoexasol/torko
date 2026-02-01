import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/controllers/app_controller.dart';
import 'group_detail_controller.dart';
import '../services/group_post_service.dart';

class GroupPostsController extends GetxController {
  final RxBool isSubmitting = false.obs;
  final RxList<String> selectedBase64Images = <String>[].obs;
  final RxString titleError = ''.obs;
  final RxString descError = ''.obs;

  static const int maxImages = 5;
  static const int maxTitleLen = 120;
  static const int minTitleLen = 3;
  static const int maxDescLen = 2000;

  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  final _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    titleCtrl = TextEditingController();
    descCtrl = TextEditingController();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> pickImages() async {
    if (selectedBase64Images.length >= maxImages) return;
    try {
      final list = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        imageQuality: 85,
      );
      for (final x in list) {
        if (selectedBase64Images.length >= maxImages) break;
        final bytes = await File(x.path).readAsBytes();
        final ext = x.path.toLowerCase();
        final isPng = ext.endsWith('.png');
        final mime = isPng ? 'image/png' : 'image/jpeg';
        final prefix = 'data:$mime;base64,';
        final b64 = base64Encode(bytes);
        selectedBase64Images.add('$prefix$b64');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[GroupPostsController] pickImages error: $e');
      Get.snackbar(
        _isBn ? 'ত্রুটি' : 'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedBase64Images.length) {
      selectedBase64Images.removeAt(index);
    }
  }

  bool get _isBn =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().language == AppLanguage.bn;

  bool validateForm() {
    final title = titleCtrl.text.trim();
    final desc = descCtrl.text.trim();

    titleError.value = '';
    descError.value = '';

    if (title.isEmpty) {
      titleError.value = _isBn ? 'শিরোনাম প্রয়োজন' : 'Post title is required';
      return false;
    }
    if (title.length < minTitleLen) {
      titleError.value =
          _isBn ? 'অন্তত ৩ অক্ষর প্রয়োজন' : 'Title must be at least 3 characters';
      return false;
    }
    if (title.length > maxTitleLen) {
      titleError.value =
          _isBn ? 'সর্বোচ্চ ১২০ অক্ষর' : 'Title max 120 characters';
      return false;
    }
    if (desc.isEmpty) {
      descError.value = _isBn ? 'বিবরণ প্রয়োজন' : 'Description is required';
      return false;
    }
    if (desc.length > maxDescLen) {
      descError.value =
          _isBn ? 'সর্বোচ্চ ২০০০ অক্ষর' : 'Description max 2000 characters';
      return false;
    }
    return true;
  }

  Future<bool> submit(int groupId) async {
    if (!validateForm()) return false;
    if (selectedBase64Images.isEmpty) {
      Get.snackbar(
        _isBn ? 'চিত্র প্রয়োজন' : 'Images required',
        _isBn ? 'অন্তত একটি ছবি যোগ করুন' : 'Please add at least one image',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      if (Get.isRegistered<GroupDetailController>()) {
        await Get.find<GroupDetailController>().createGroupPostUI(
          groupId: groupId,
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          base64Images: selectedBase64Images.toList(),
        );
      } else {
        await GroupPostService.createGroupPost(
          groupId: groupId,
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          base64Images: selectedBase64Images.toList(),
        );
        _showSuccess();
      }
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        _isBn ? '⚠️ পোস্ট তৈরি হয়নি' : '⚠️ Failed to create post',
        msg.isNotEmpty ? msg : 'Failed to create post',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccess() {
    Get.snackbar(
      _isBn ? '✅ জমা হয়েছে' : '✅ Post submitted',
      _isBn ? 'পোস্ট সফলভাবে জমা হয়েছে (অনুমোদনের জন্য অপেক্ষা করছে)' : 'Post submitted successfully (Pending approval)',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void reset() {
    titleCtrl.clear();
    descCtrl.clear();
    selectedBase64Images.clear();
    titleError.value = '';
    descError.value = '';
  }
}
