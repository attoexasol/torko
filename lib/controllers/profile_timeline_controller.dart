import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';
import '../models/timeline_item.dart';
import '../services/post_api_service.dart';
import '../services/user_info.dart';

class ProfileTimelineController extends GetxController {
  final RxList<TimelineItem> timeline = <TimelineItem>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchTimeline() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      error.value = 'Session expired. Please login again.';
      if (kDebugMode) print('DEBUG ProfileTimelineController: token null/empty');
      return;
    }
    loading.value = true;
    error.value = '';
    try {
      final list = await PostApiService.getUserOwnTimeline();
      timeline.assignAll(list);
      if (kDebugMode) print('DEBUG ProfileTimelineController: timeline loaded ${list.length}');
    } catch (e) {
      error.value = e is PostApiException ? e.message : 'Failed to load timeline';
      timeline.clear();
      if (kDebugMode) print('DEBUG ProfileTimelineController: error $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> onSharePressed(PostModel post) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Session expired. Please login again.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      await PostApiService.sharePost(postId: post.id);
      Get.snackbar('Success', 'Post shared successfully', snackPosition: SnackPosition.BOTTOM);
      await fetchTimeline();
    } catch (e) {
      Get.snackbar('Error', e is PostApiException ? e.message : e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> onDeleteSharePressed(PostModel post) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Session expired. Please login again.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete shared post?'),
        content: const Text('This will remove the shared post from your timeline.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await PostApiService.deleteSharedPost(postId: post.id);
      Get.snackbar('Success', 'Shared post deleted', snackPosition: SnackPosition.BOTTOM);
      await fetchTimeline();
    } catch (e) {
      Get.snackbar('Error', e is PostApiException ? e.message : e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
