import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/controllers/app_controller.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/community_group_model.dart';
import '../services/community_group_service.dart';

class CommunityGroupsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString error = ''.obs;
  final RxList<CommunityGroupModel> groups = <CommunityGroupModel>[].obs;

  static const String _baseImageUrl = 'https://torko.attoexasolutions.com/';

  /// Stored payload for Retry after create failure.
  Map<String, dynamic>? _lastCreatePayload;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading.value = true;
    error.value = '';
    try {
      final list = await CommunityGroupService.fetchAllGroups();
      groups.assignAll(list);
      if (kDebugMode) debugPrint('[CommunityGroupsController] loadGroups count=${groups.length}');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      error.value = msg;
      groups.clear();
      if (kDebugMode) debugPrint('[CommunityGroupsController] loadGroups error: $msg');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create group via API, then refresh list. Shows success/error snackbars, closes create screen on success.
  Future<void> createNewGroup({
    required String name,
    required String bio,
    String visibility = 'public',
    String status = 'active',
    String? location,
    double? lat,
    double? lng,
    String? imageDataUri,
  }) async {
    isCreating.value = true;
    error.value = '';
    _lastCreatePayload = {
      'name': name,
      'bio': bio,
      'visibility': visibility,
      'status': status,
      'location': location,
      'lat': lat,
      'lng': lng,
      'imageDataUri': imageDataUri,
    };
    try {
      final created = await CommunityGroupService.createGroup(
        name: name,
        bio: bio,
        visibility: visibility,
        status: status,
        location: location,
        lat: lat,
        lng: lng,
        imageDataUri: imageDataUri,
      );
      await loadGroups();
      _showSuccess(created.name, created.id);
      Get.back();
    } catch (e) {
      final msg = _mapErrorMessage(e);
      error.value = msg;
      _showError(msg);
      if (kDebugMode) debugPrint('[CommunityGroupsController] createNewGroup error: $msg');
    } finally {
      isCreating.value = false;
    }
  }

  /// Retry last failed create. No-op if no payload stored.
  Future<void> retryCreateGroup() async {
    final p = _lastCreatePayload;
    if (p == null) return;
    await createNewGroup(
      name: p['name'] as String,
      bio: p['bio'] as String,
      visibility: p['visibility'] as String? ?? 'public',
      status: p['status'] as String? ?? 'active',
      location: p['location'] as String?,
      lat: p['lat'] as double?,
      lng: p['lng'] as double?,
      imageDataUri: p['imageDataUri'] as String?,
    );
  }

  /// Alias for create flow. Forwards to createNewGroup.
  Future<void> submitCreateGroup({
    required String name,
    required String bio,
    String visibility = 'public',
    String status = 'active',
    String? location,
    double? lat,
    double? lng,
    String? imageBase64,
  }) async =>
      createNewGroup(
        name: name,
        bio: bio,
        visibility: visibility,
        status: status,
        location: location,
        lat: lat,
        lng: lng,
        imageDataUri: imageBase64,
      );

  String _mapErrorMessage(Object e) {
    final s = e.toString().replaceFirst('Exception: ', '').toLowerCase();
    if (s.contains('401') || s.contains('session expired') || s.contains('login again')) {
      return 'Session expired. Please login again.';
    }
    if (s.contains('500') || s.contains('server error')) {
      return 'Server error. Try again later.';
    }
    if (s.contains('422') || s.contains('400') || s.contains('validation')) {
      return s.isEmpty ? 'Invalid input. Please check the form.' : s;
    }
    return s.isEmpty ? 'Please try again.' : s;
  }

  void _showSuccess(String groupName, int groupId) {
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;
    final title = isBn ? '✅ গ্রুপ তৈরি হয়েছে' : '✅ Group Created';
    final message = isBn
        ? 'আপনার গ্রুপ \'$groupName\' এখন লাইভ।'
        : 'Your group \'$groupName\' is live now.';
    final viewLabel = isBn ? 'গ্রুপ দেখুন' : 'View Group';
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          Get.toNamed(AppRoutes.groupDetail, arguments: {'id': groupId});
        },
        child: Text(viewLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showError(String msg) {
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;
    final title = isBn ? '⚠️ গ্রুপ তৈরি হয়নি' : '⚠️ Couldn\'t create group';
    final retryLabel = isBn ? 'আবার চেষ্টা করুন' : 'Retry';
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: AppColors.lightDestructive,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          retryCreateGroup();
        },
        child: Text(retryLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  /// Cover image URL: prefer group.coverImage, else empty (UI uses placeholder).
  String coverImageUrl(CommunityGroupModel group) {
    final c = group.coverImage;
    if (c == null || c.isEmpty) return '';
    return c.startsWith('http') ? c : '$_baseImageUrl$c';
  }
}
