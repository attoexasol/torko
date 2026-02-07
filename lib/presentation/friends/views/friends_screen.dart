import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/friends/controllers/friends_controller.dart';
import 'package:torko/presentation/friends/widgets/empty_state.dart';
import 'package:torko/presentation/friends/widgets/friend_list_tile.dart';
import 'package:torko/presentation/friends/widgets/friend_request_card.dart';
import 'package:torko/presentation/friends/widgets/friend_suggestion_card.dart';
import 'package:torko/presentation/friends/widgets/loading_skeleton.dart';

/// Friends screen with segmented tabs: Suggestions, Friends, Requests.
class FriendsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FriendsScreen({super.key, this.onBack});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final appController = Get.find<AppController>();
  late FriendsController friendsController;
  final RxString activeTab = 'suggestions'.obs;

  @override
  void initState() {
    super.initState();
    friendsController = Get.put(FriendsController(), permanent: false);
  }

  bool get isDark => appController.isDarkMode;
  bool get isBn => appController.language == AppLanguage.bn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF052029) : const Color(0xFFf5f5f5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: Obx(() => _buildContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF052029) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe5e5e5),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: isDark ? Colors.white : const Color(0xFF0f1419),
            onPressed: widget.onBack ?? () => Get.back(),
          ),
          Expanded(
            child: Text(
              isBn ? 'বন্ধু' : 'Friends',
              style: GoogleFonts.notoSansBengali(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? const Color(0xFF052029) : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton('suggestions', Icons.person_add, isBn ? 'সাজেশন' : 'Suggestions'),
            const SizedBox(width: 8),
            _buildTabButton('friends', Icons.people, isBn ? 'বন্ধুরা' : 'Friends'),
            const SizedBox(width: 8),
            Obx(() => _buildTabButton(
                  'requests',
                  Icons.person_add_alt_1,
                  isBn ? 'রিকোয়েস্ট' : 'Requests',
                  badge: friendsController.pendingCount > 0 ? friendsController.pendingCount : null,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, IconData icon, String label, {int? badge}) {
    return Obx(() {
      final isActive = activeTab.value == tab;
      return GestureDetector(
        onTap: () => activeTab.value = tab,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.darkPrimary
                : (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf0f0f0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : (isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786)),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  color: isActive ? Colors.white : (isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786)),
                ),
              ),
              if (badge != null && badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.darkPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    if (activeTab.value == 'friends') {
      return _buildFriendsTab();
    } else if (activeTab.value == 'requests') {
      return _buildRequestsTab();
    } else {
      return _buildSuggestionsTab();
    }
  }

  Widget _buildSuggestionsTab() {
    return Obx(() {
      if (friendsController.isLoadingSuggestions.value) {
        return FriendsLoadingSkeleton(isDark: isDark);
      }
      if (friendsController.suggestions.isEmpty) {
        return FriendsEmptyState(
          icon: Icons.person_add,
          message: isBn ? 'কোনো সাজেশন নেই' : 'No suggestions',
          isDark: isDark,
        );
      }
      return RefreshIndicator(
        onRefresh: () => friendsController.loadSuggestions(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friendsController.suggestions.length,
          itemBuilder: (context, index) {
            final user = friendsController.suggestions[index];
            return FriendSuggestionCard(
              user: user,
              isDark: isDark,
              isBn: isBn,
            );
          },
        ),
      );
    });
  }

  Widget _buildFriendsTab() {
    return Obx(() {
      if (friendsController.isLoadingFriends.value) {
        return FriendsLoadingSkeleton(isDark: isDark);
      }
      if (friendsController.friends.isEmpty) {
        return FriendsEmptyState(
          icon: Icons.people,
          message: isBn ? 'এখনো কোনো বন্ধু নেই' : 'No friends yet',
          isDark: isDark,
        );
      }
      return RefreshIndicator(
        onRefresh: () => friendsController.loadFriends(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friendsController.friends.length,
          itemBuilder: (context, index) {
            final friend = friendsController.friends[index];
            return FriendListTile(
              user: friend,
              isDark: isDark,
              isBn: isBn,
            );
          },
        ),
      );
    });
  }

  Widget _buildRequestsTab() {
    return Obx(() {
      if (friendsController.isLoadingRequests.value) {
        return FriendsLoadingSkeleton(isDark: isDark);
      }
      if (friendsController.requests.isEmpty) {
        return FriendsEmptyState(
          icon: Icons.person_add_alt_1,
          message: isBn ? 'কোনো রিকোয়েস্ট নেই' : 'No requests',
          isDark: isDark,
        );
      }
      return RefreshIndicator(
        onRefresh: () => friendsController.loadRequests(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friendsController.requests.length,
          itemBuilder: (context, index) {
            final request = friendsController.requests[index];
            return FriendRequestCard(
              request: request,
              isDark: isDark,
              isBn: isBn,
            );
          },
        ),
      );
    });
  }
}
