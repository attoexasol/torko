import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/friend_suggestion_model.dart';
import 'widgets/friend_suggestion_card.dart';
import 'widgets/friends_tabs.dart';

/// Friends module colors (local, no global theme change).
class _FriendsScreenColors {
  static const bg = Color(0xFF052029);
  static const card = Color(0xFF0a2f3d);
  static const primary = Color(0xFFd97757);
  static const textWhite = Color(0xFFF9FAFB);
  static const textMuted = Color(0xFF9e9e9e);
}

/// Pixel-perfect Friends screen: বন্ধুরা title, 4 tabs, suggestion cards.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final RxString _selectedTab = 'suggestions'.obs;

  /// Total count for top-right pill (dummy: 13).
  int get _totalCount => 13;

  /// Badge count for রিকোয়েস্ট tab (dummy: 3).
  int get _requestBadgeCount => 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FriendsScreenColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            FriendsTabs(
              selectedTab: _selectedTab,
              requestBadgeCount: _requestBadgeCount,
            ),
            Expanded(child: Obx(() => _buildContent())),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _FriendsScreenColors.bg,
        border: Border(
          bottom: BorderSide(
            color: _FriendsScreenColors.card.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _FriendsScreenColors.textWhite,
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              'বন্ধুরা',
              style: GoogleFonts.notoSansBengali(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _FriendsScreenColors.textWhite,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _FriendsScreenColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalCount জন',
              style: GoogleFonts.notoSansBengali(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab.value) {
      case 'suggestions':
        return _buildSuggestionsList();
      case 'friends':
        return _buildEmptyTab('এখনো কোনো বন্ধু নেই');
      case 'requests':
        return _buildEmptyTab('কোনো রিকোয়েস্ট নেই');
      case 'sent':
        return _buildEmptyTab('কোনো পাঠানো রিকোয়েস্ট নেই');
      default:
        return _buildSuggestionsList();
    }
  }

  Widget _buildSuggestionsList() {
    final list = FriendSuggestionModel.dummyList;
    return ListView.builder(
      key: const PageStorageKey<String>('friends_suggestions_list'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return FriendSuggestionCard(model: list[index]);
      },
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: _FriendsScreenColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                color: _FriendsScreenColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
