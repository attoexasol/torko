import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../requests/widgets/friends_header.dart';
import 'controller/sent_requests_controller.dart';
import 'widgets/friends_tabs.dart';
import 'widgets/sent_request_card.dart';

/// Sent Requests screen colors (local).
class _SentScreenColors {
  static const bgTop = Color(0xFF0a2f3d);
  static const bgBottom = Color(0xFF052029);
  static const primary = Color(0xFFd97757);
  static const textMuted = Color(0xA6FFFFFF);
}

/// Pixel-perfect Friends – Sent Requests screen (পাঠানো tab).
class SentRequestsScreen extends StatelessWidget {
  const SentRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SentRequestsController>()) {
      Get.put(SentRequestsController(), permanent: false);
    }
    final c = Get.find<SentRequestsController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _SentScreenColors.bgTop,
              _SentScreenColors.bgBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FriendsHeader(totalCount: c.totalCount),
              const SentFriendsTabs(),
              Expanded(
                child: Obx(() => c.sentRequests.isEmpty
                    ? _buildEmptyState(c)
                    : _buildList(c)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(SentRequestsController c) {
    return ListView.builder(
      key: const PageStorageKey<String>('sent_requests_list'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: c.sentRequests.length,
      itemBuilder: (context, index) {
        return SentRequestCard(model: c.sentRequests[index]);
      },
    );
  }

  Widget _buildEmptyState(SentRequestsController c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_outlined,
              size: 80,
              color: _SentScreenColors.textMuted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'কোনো পাঠানো রিকোয়েস্ট নেই',
              style: GoogleFonts.notoSansBengali(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'নতুন বন্ধু খুঁজতে সাজেশন ট্যাব দেখুন',
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                color: _SentScreenColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () => c.goToSuggestions(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _SentScreenColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'সাজেশন দেখুন',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
