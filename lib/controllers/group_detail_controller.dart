import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/controllers/app_controller.dart';
import '../models/community_group_model.dart';
import '../services/community_group_api_service.dart';
import '../services/group_post_service.dart';

class GroupDetailController extends GetxController {
  final Rx<CommunityGroupModel?> group = Rx<CommunityGroupModel?>(null);
  final RxBool loading = true.obs;
  final RxString error = ''.obs;
  final RxBool isCreatingPost = false.obs;
  final RxBool isUpdatingPost = false.obs;
  final RxBool isDeletingPost = false.obs;

  Future<void> fetchGroup(int id) async {
    loading.value = true;
    error.value = '';
    group.value = null;
    try {
      final g = await CommunityGroupApiService.fetchSingleGroup(id);
      group.value = g;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  bool get _isBn =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().language == AppLanguage.bn;

  Future<void> createGroupPostUI({
    required int groupId,
    required String title,
    required String description,
    List<String> base64Images = const [],
  }) async {
    isCreatingPost.value = true;
    try {
      final result = await GroupPostService.createGroupPost(
        groupId: groupId,
        title: title,
        description: description,
        base64Images: base64Images,
      );
      _insertPostAtTop(result.post);
      _showSuccess(_isBn ? 'পোস্ট জমা হয়েছে (অনুমোদনের জন্য অপেক্ষা করছে)' : 'Submitted to group. Pending admin approval.');
    } catch (e) {
      _showError(e, _isBn ? 'পোস্ট তৈরি হয়নি' : 'Failed to create post');
      rethrow;
    } finally {
      isCreatingPost.value = false;
    }
  }

  Future<void> updateGroupPostUI({
    required int postId,
    required String title,
    required String description,
    List<String> base64Images = const [],
    CommunityGroupPostModel? existingPost,
  }) async {
    isUpdatingPost.value = true;
    try {
      final updated = await GroupPostService.updatePost(
        postId: postId,
        title: title,
        description: description,
        base64Images: base64Images,
      );
      final merged = existingPost != null
          ? CommunityGroupPostModel(
              groupPostId: existingPost.groupPostId,
              postId: updated.postId,
              approvedByAdmin: existingPost.approvedByAdmin,
              createdAt: updated.createdAt,
              postTitle: updated.postTitle,
              postDescription: updated.postDescription,
              postImages: updated.postImages,
              user: updated.user ?? existingPost.user,
            )
          : updated;
      _replacePost(merged);
      _showSuccess(_isBn ? 'পোস্ট আপডেট হয়েছে' : 'Post updated');
    } catch (e) {
      _showError(e, _isBn ? 'আপডেট হয়নি' : 'Update failed');
      rethrow;
    } finally {
      isUpdatingPost.value = false;
    }
  }

  Future<void> deleteGroupPostUI({required int postId}) async {
    isDeletingPost.value = true;
    try {
      await GroupPostService.deletePost(postId: postId);
      _removePost(postId);
      _showSuccess(_isBn ? 'পোস্ট মুছে ফেলা হয়েছে' : 'Post deleted');
    } catch (e) {
      _showError(e, _isBn ? 'মুছে ফেলা যায়নি' : 'Delete failed');
      rethrow;
    } finally {
      isDeletingPost.value = false;
    }
  }

  void _insertPostAtTop(CommunityGroupPostModel post) {
    final g = group.value;
    if (g == null) return;
    final list = List<CommunityGroupPostModel>.from(g.posts ?? []);
    list.insert(0, post);
    group.value = CommunityGroupModel(
      id: g.id,
      name: g.name,
      username: g.username,
      bio: g.bio,
      visibility: g.visibility,
      status: g.status,
      role: g.role,
      membersCount: g.membersCount,
      location: g.location,
      lat: g.lat,
      lng: g.lng,
      createdAt: g.createdAt,
      updatedAt: g.updatedAt,
      coverImage: g.coverImage,
      user: g.user,
      createdBy: g.createdBy,
      updatedBy: g.updatedBy,
      posts: list,
    );
  }

  void _replacePost(CommunityGroupPostModel post) {
    final g = group.value;
    if (g == null) return;
    final list = List<CommunityGroupPostModel>.from(g.posts ?? []);
    final idx = list.indexWhere((p) => p.postId == post.postId);
    if (idx >= 0) list[idx] = post;
    group.value = CommunityGroupModel(
      id: g.id,
      name: g.name,
      username: g.username,
      bio: g.bio,
      visibility: g.visibility,
      status: g.status,
      role: g.role,
      membersCount: g.membersCount,
      location: g.location,
      lat: g.lat,
      lng: g.lng,
      createdAt: g.createdAt,
      updatedAt: g.updatedAt,
      coverImage: g.coverImage,
      user: g.user,
      createdBy: g.createdBy,
      updatedBy: g.updatedBy,
      posts: list,
    );
  }

  void _removePost(int postId) {
    final g = group.value;
    if (g == null) return;
    final list = (g.posts ?? []).where((p) => p.postId != postId).toList();
    group.value = CommunityGroupModel(
      id: g.id,
      name: g.name,
      username: g.username,
      bio: g.bio,
      visibility: g.visibility,
      status: g.status,
      role: g.role,
      membersCount: g.membersCount,
      location: g.location,
      lat: g.lat,
      lng: g.lng,
      createdAt: g.createdAt,
      updatedAt: g.updatedAt,
      coverImage: g.coverImage,
      user: g.user,
      createdBy: g.createdBy,
      updatedBy: g.updatedBy,
      posts: list,
    );
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      '✅',
      msg,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(Object e, String title) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    Get.snackbar(
      title,
      msg.isNotEmpty ? msg : 'Something went wrong. Please try again.',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFFD32F2F),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
