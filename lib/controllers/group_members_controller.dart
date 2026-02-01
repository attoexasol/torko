import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/controllers/app_controller.dart';
import '../models/group_member_model.dart';
import '../services/group_member_service.dart';

class GroupMembersController extends GetxController {
  GroupMembersController(this.groupId);

  final int groupId;

  final members = <GroupMemberModel>[].obs;
  final totalMembers = 0.obs;
  final isLoading = false.obs;
  final isApprovingIds = <int>[].obs;
  final isDeletingIds = <int>[].obs;

  bool get _isBn =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().language == AppLanguage.bn;

  Future<void> loadMembers() async {
    isLoading.value = true;
    try {
      final response = await GroupMemberService.getAllMembers(groupId: groupId);
      members.assignAll(response.members);
      totalMembers.value = response.totalMembers > 0
          ? response.totalMembers
          : response.members.length;
    } catch (e) {
      _showError(e, _isBn ? 'সদস্য লোড হয়নি' : 'Failed to load members');
      members.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve(int memberId) async {
    isApprovingIds.add(memberId);
    try {
      await GroupMemberService.approveMember(memberId: memberId);
      final idx = members.indexWhere((m) => m.id == memberId);
      if (idx >= 0) {
        members[idx] = GroupMemberModel(
          id: members[idx].id,
          status: 'approved',
          createdAt: members[idx].createdAt,
          group: members[idx].group,
          user: members[idx].user,
        );
        members.refresh();
      }
      _showSuccess(_isBn ? 'অনুমোদিত' : 'Approved');
    } catch (e) {
      _showError(e, _isBn ? 'অনুমোদন হয়নি' : 'Approve failed');
      rethrow;
    } finally {
      isApprovingIds.remove(memberId);
    }
  }

  Future<void> remove(int memberId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(_isBn ? 'সদস্য সরান' : 'Remove Member'),
        content: Text(
          _isBn
              ? 'আপনি কি নিশ্চিত যে আপনি এই সদস্যকে গ্রুপ থেকে সরাতে চান?'
              : 'Are you sure you want to remove this member from the group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(_isBn ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_isBn ? 'সরান' : 'Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isDeletingIds.add(memberId);
    try {
      await GroupMemberService.deleteMember(groupId: groupId, memberId: memberId);
      members.removeWhere((m) => m.id == memberId);
      totalMembers.value = (totalMembers.value - 1).clamp(0, 9999);
      _showSuccess(_isBn ? 'সরানো হয়েছে' : 'Removed');
    } catch (e) {
      _showError(e, _isBn ? 'সরানো যায়নি' : 'Remove failed');
      rethrow;
    } finally {
      isDeletingIds.remove(memberId);
    }
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
