import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:torko/app/routes/app_routes.dart';
import '../model/sent_request_model.dart';

/// Controller for Friends Sent Requests screen (পাঠানো tab).
class SentRequestsController extends GetxController {
  final RxList<SentRequestModel> sentRequests = <SentRequestModel>[].obs;
  final RxInt sentBadgeCount = 2.obs;
  int get totalCount => 13;

  /// Selected tab: 0=সাজেশন, 1=বন্ধুরা, 2=রিকোয়েস্ট, 3=পাঠানো
  final RxInt selectedTab = 3.obs;

  @override
  void onInit() {
    super.onInit();
    sentRequests.assignAll(SentRequestModel.dummyList);
  }

  void selectTab(int index) {
    if (index == 3) return; // Already on Sent
    selectedTab.value = index;
    if (index == 2) {
      Get.offNamed(AppRoutes.friendsRequests);
    } else {
      Get.offNamed(AppRoutes.friends);
    }
  }

  Future<void> onCancelRequest(SentRequestModel model) async {
    final confirmed = await _showCancelDialog();
    if (confirmed != true) return;

    sentRequests.removeWhere((r) => r.id == model.id);
    if (sentBadgeCount.value > 0) sentBadgeCount.value--;

    Get.snackbar(
      'সফল',
      'রিকোয়েস্ট বাতিল হয়েছে',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF0d3a4a),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  Future<bool?> _showCancelDialog() async {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF0d3a4a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'রিকোয়েস্ট বাতিল করবেন?',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          'আপনি কি নিশ্চিতভাবে এই পাঠানো রিকোয়েস্টটি বাতিল করতে চান?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'বাতিল',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'নিশ্চিত',
              style: TextStyle(color: Color(0xFFff4d4f), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void goToSuggestions() {
    Get.offNamed(AppRoutes.friends);
  }
}
