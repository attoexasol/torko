import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:torko/core/services/friends_api_service.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/core/services/user_info.dart';

import '../model/friend_request_model.dart';

/// Controller for Friends Requests screen. Uses real API.
class FriendsRequestsController extends GetxController {
  /// Selected tab index: 0=সাজেশন, 1=বন্ধুরা, 2=রিকোয়েস্ট, 3=পাঠানো
  final RxInt selectedTab = 2.obs;

  /// Pending request items (from API).
  final RxList<FriendRequestModel> requests = <FriendRequestModel>[].obs;

  /// Badge count on রিকোয়েস্ট tab.
  final RxInt requestBadgeCount = 0.obs;

  final RxBool isLoading = false.obs;
  final RxSet<int> acceptingIds = <int>{}.obs;
  final RxSet<int> rejectingIds = <int>{}.obs;

  int get totalCount => requests.length;

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  Future<void> loadRequests() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    isLoading.value = true;
    try {
      final list = await FriendsApiService.fetchIncomingRequests(token);
      requests.assignAll(list.map((e) => FriendRequestModel.fromRequestItem(e)));
      requestBadgeCount.value = requests.length;
    } on FriendsApiException catch (e) {
      if (kDebugMode) debugPrint('[FriendsRequests] loadRequests: ${e.message}');
    } catch (e) {
      if (kDebugMode) debugPrint('[FriendsRequests] loadRequests error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: isError ? const Color(0xFF8B0000) : const Color(0xFF0d3a4a),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  Future<void> onAccept(FriendRequestModel model) async {
    if (acceptingIds.contains(model.requestId)) return;
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      _showSnackbar('ত্রুটি', 'Session expired. Please login again.', isError: true);
      return;
    }

    acceptingIds.add(model.requestId);
    acceptingIds.refresh();

    if (kDebugMode) {
      debugPrint('ACCEPT payload: token=*** request_id=${model.requestId}');
    }

    try {
      final (success, message, _) =
          await FriendsApiService.acceptRequest(token, model.requestId);

      _showSnackbar(success ? 'সফল' : 'ত্রুটি', message, isError: !success);

      if (success) {
        requests.removeWhere((r) => r.requestId == model.requestId);
        requestBadgeCount.value = requests.length;
      }
    } on FriendsApiException catch (e) {
      _showSnackbar('ত্রুটি', e.message, isError: true);
    } on NetworkAuthException catch (e) {
      _showSnackbar('ত্রুটি', e.message, isError: true);
    } catch (e) {
      if (kDebugMode) debugPrint('[FriendsRequests] onAccept error: $e');
      _showSnackbar(
        'ত্রুটি',
        e.toString().contains('timeout') || e.toString().contains('Timeout')
            ? 'Request timed out.'
            : 'Failed to accept request.',
        isError: true,
      );
    } finally {
      acceptingIds.remove(model.requestId);
      acceptingIds.refresh();
    }
  }

  Future<void> onReject(FriendRequestModel model) async {
    if (rejectingIds.contains(model.requestId)) return;
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      _showSnackbar('ত্রুটি', 'Session expired. Please login again.', isError: true);
      return;
    }

    rejectingIds.add(model.requestId);
    rejectingIds.refresh();

    try {
      final (success, message) =
          await FriendsApiService.rejectRequest(token, model.requestId);

      _showSnackbar(success ? 'সফল' : 'ত্রুটি', message, isError: !success);

      if (success) {
        requests.removeWhere((r) => r.requestId == model.requestId);
        requestBadgeCount.value = requests.length;
      }
    } on FriendsApiException catch (e) {
      _showSnackbar('ত্রুটি', e.message, isError: true);
    } on NetworkAuthException catch (e) {
      _showSnackbar('ত্রুটি', e.message, isError: true);
    } catch (e) {
      if (kDebugMode) debugPrint('[FriendsRequests] onReject error: $e');
      _showSnackbar(
        'ত্রুটি',
        e.toString().contains('timeout') || e.toString().contains('Timeout')
            ? 'Request timed out.'
            : 'Failed to reject request.',
        isError: true,
      );
    } finally {
      rejectingIds.remove(model.requestId);
      rejectingIds.refresh();
    }
  }
}
