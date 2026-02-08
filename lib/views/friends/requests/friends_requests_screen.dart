import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controller/friends_requests_controller.dart';
import 'widgets/friends_header.dart';
import 'widgets/friends_tabs.dart';
import 'widgets/request_card.dart';

/// Friends Requests screen colors (local).
class _FriendsRequestsColors {
  static const bgTop = Color(0xFF0a2f3d);
  static const bgBottom = Color(0xFF052029);
  static const textMuted = Color(0xA6FFFFFF);
}

/// Pixel-perfect Friends – Requests screen (রিকোয়েস্ট tab selected).
class FriendsRequestsScreen extends StatelessWidget {
  const FriendsRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FriendsRequestsController>()) {
      Get.put(FriendsRequestsController(), permanent: false);
    }
    final c = Get.find<FriendsRequestsController>();

    return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _FriendsRequestsColors.bgTop,
                  _FriendsRequestsColors.bgBottom,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FriendsHeader(totalCount: c.totalCount),
                  const FriendsTabs(),
                  Expanded(child: Obx(() => _buildBody(c))),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildBody(FriendsRequestsController c) {
    switch (c.selectedTab.value) {
      case 0:
        return _buildPlaceholder('সাজেশন');
      case 1:
        return _buildPlaceholder('বন্ধুরা');
      case 2:
        return _buildRequestsList(c);
      case 3:
        return _buildPlaceholder('পাঠানো');
      default:
        return _buildRequestsList(c);
    }
  }

  Widget _buildRequestsList(FriendsRequestsController c) {
    return Obx(() {
      if (c.requests.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        key: const PageStorageKey<String>('friends_requests_list'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: c.requests.length,
        itemBuilder: (context, index) {
          final model = c.requests[index];
          return RequestCard(model: model);
        },
      );
    });
  }

  Widget _buildPlaceholder(String tab) {
    return Center(
      child: Text(
        tab,
        style: GoogleFonts.notoSansBengali(
          fontSize: 14,
          color: _FriendsRequestsColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_alt_1,
              size: 64,
              color: _FriendsRequestsColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'কোনো রিকোয়েস্ট নেই',
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                color: _FriendsRequestsColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
