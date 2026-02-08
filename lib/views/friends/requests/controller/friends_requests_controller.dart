import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/friend_request_model.dart';

/// Controller for Friends Requests screen.
class FriendsRequestsController extends GetxController {
  /// Selected tab index: 0=সাজেশন, 1=বন্ধুরা, 2=রিকোয়েস্ট, 3=পাঠানো
  final RxInt selectedTab = 2.obs;

  /// Pending request items.
  final RxList<FriendRequestModel> requests = <FriendRequestModel>[].obs;

  /// Badge count on রিকোয়েস্ট tab.
  final RxInt requestBadgeCount = 3.obs;

  /// Total count for header pill (static/dummy).
  int get totalCount => 13;

  @override
  void onInit() {
    super.onInit();
    requests.assignAll(FriendRequestModel.dummyList);
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void onAccept(FriendRequestModel model) {
    requests.removeWhere((r) => r.id == model.id);
    if (requestBadgeCount.value > 0) {
      requestBadgeCount.value--;
    }
    Get.snackbar(
      'সফল',
      'বন্ধু হিসেবে যোগ করা হয়েছে',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF0d3a4a),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void onReject(FriendRequestModel model) {
    requests.removeWhere((r) => r.id == model.id);
    if (requestBadgeCount.value > 0) {
      requestBadgeCount.value--;
    }
    Get.snackbar(
      'সফল',
      'রিকোয়েস্ট প্রত্যাখ্যান হয়েছে',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF0d3a4a),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
