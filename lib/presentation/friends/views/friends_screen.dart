import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/friends/controllers/friends_controller.dart';
import 'package:torko/presentation/friends/widgets/empty_state.dart';
import 'package:torko/presentation/friends/widgets/friend_list_tile.dart';
import 'package:torko/presentation/friends/widgets/friend_request_card.dart';
import 'package:torko/presentation/friends/widgets/suggestion_card.dart';
import 'package:torko/presentation/friends/widgets/sent_request_card.dart';
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
            _buildSearchBar(),
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
          Obx(() {
            final count = friendsController.pendingCount;
            if (count <= 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final hintText = isBn ? 'বন্ধু খুঁজুন…' : 'Search friends…';
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF657786);
    final searchBg = isDark ? const Color(0xFF0a2f3d) : Colors.white;
    final searchBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFe0e0e0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: searchBorder, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: friendsController.searchController,
                    onChanged: friendsController.setSearchQuery,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0f1419),
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        color: hintColor,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 0,
                      ),
                      isDense: true,
                      suffixIcon: Obx(() {
                        if (friendsController.searchQuery.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: hintColor,
                          ),
                          onPressed: friendsController.clearSearch,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: AppColors.darkPrimary,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                onTap: () => FocusScope.of(context).unfocus(),
                borderRadius: BorderRadius.circular(11),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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
            const SizedBox(width: 8),
            Obx(() => _buildTabButton(
                  'sent',
                  Icons.send,
                  isBn ? 'পাঠানো' : 'Send',
                  badge: friendsController.sentCount > 0 ? friendsController.sentCount : null,
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
    } else if (activeTab.value == 'sent') {
      return _buildSentTab();
    } else {
      return _buildSuggestionsTab();
    }
  }

  Widget _buildSuggestionsTab() {
    return Obx(() {
      if (friendsController.isLoadingSuggestions.value &&
          friendsController.suggestions.isEmpty) {
        return FriendsLoadingSkeleton(isDark: isDark);
      }
      if (friendsController.hasErrorSuggestions.value &&
          friendsController.suggestions.isEmpty) {
        return _buildInlineRetry(
          onRetry: () => friendsController.loadSuggestions(),
          isBn: isBn,
        );
      }
      final list = friendsController.filteredSuggestions;
      if (list.isEmpty) {
        final hasQuery = friendsController.searchQuery.value.isNotEmpty;
        return FriendsEmptyState(
          icon: Icons.person_add,
          message: hasQuery
              ? (isBn ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found')
              : (isBn ? 'কোনো সাজেশন নেই' : 'No suggestions'),
          isDark: isDark,
        );
      }
      return RefreshIndicator(
        onRefresh: () => friendsController.loadSuggestions(),
        child: ListView.builder(
          key: const PageStorageKey<String>('friends_suggestions_list'),
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final user = list[index];
            return SuggestionCard(
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
      if (friendsController.isLoadingFriends.value &&
          friendsController.friends.isEmpty) {
        return FriendsLoadingSkeleton(isDark: isDark);
      }
      if (friendsController.hasErrorFriends.value &&
          friendsController.friends.isEmpty) {
        return _buildInlineRetry(
          onRetry: () => friendsController.loadFriends(),
          isBn: isBn,
        );
      }
      final list = friendsController.filteredFriends;
      if (list.isEmpty) {
        final hasQuery = friendsController.searchQuery.value.isNotEmpty;
        return FriendsEmptyState(
          icon: Icons.people,
          message: hasQuery
              ? (isBn ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found')
              : (isBn ? 'এখনো কোনো বন্ধু নেই' : 'No friends yet'),
          isDark: isDark,
        );
      }
      return RefreshIndicator(
        onRefresh: () => friendsController.loadFriends(),
        child: ListView.builder(
          key: const PageStorageKey<String>('friends_list'),
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final friend = list[index];
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
      if (friendsController.isLoadingRequests.value &&
          friendsController.requests.isEmpty) {
        return FriendsLoadingSkeleton(isDark: isDark);
      }
      if (friendsController.hasErrorRequests.value &&
          friendsController.requests.isEmpty) {
        return _buildInlineRetry(
          onRetry: () => friendsController.loadRequests(),
          isBn: isBn,
        );
      }
      final list = friendsController.filteredRequests;
      if (list.isEmpty) {
        final hasQuery = friendsController.searchQuery.value.isNotEmpty;
        return FriendsEmptyState(
          icon: Icons.person_add_alt_1,
          message: hasQuery
              ? (isBn ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found')
              : (isBn ? 'কোনো রিকোয়েস্ট নেই' : 'No requests'),
          isDark: isDark,
        );
      }
      return RefreshIndicator(
        onRefresh: () => friendsController.loadRequests(),
        child: ListView.builder(
          key: const PageStorageKey<String>('friends_requests_list'),
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final request = list[index];
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

  Widget _buildSentTab() {
    return Obx(() {
      if (friendsController.isLoadingSent.value &&
          friendsController.sentRequests.isEmpty) {
        return FriendsLoadingSkeleton(isDark: isDark);
      }
      if (friendsController.hasErrorSent.value &&
          friendsController.sentRequests.isEmpty) {
        return _buildInlineRetry(
          onRetry: () => friendsController.loadSentRequests(),
          isBn: isBn,
        );
      }
      final list = friendsController.filteredSentRequests;
      if (list.isEmpty) {
        final hasQuery = friendsController.searchQuery.value.isNotEmpty;
        return FriendsEmptyState(
          icon: Icons.send,
          message: hasQuery
              ? (isBn ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found')
              : (isBn ? 'কোনো রিকোয়েস্ট পাঠানো হয়নি' : 'No sent requests'),
          isDark: isDark,
        );
      }
      return RefreshIndicator(
        onRefresh: () => friendsController.loadSentRequests(),
        child: ListView.builder(
          key: const PageStorageKey<String>('friends_sent_list'),
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final request = list[index];
            return SentRequestCard(
              request: request,
              isDark: isDark,
              isBn: isBn,
            );
          },
        ),
      );
    });
  }

  Widget _buildInlineRetry({
    required VoidCallback onRetry,
    required bool isBn,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 48,
              color: isDark
                  ? const Color(0xFF0d3a4a)
                  : const Color(0xFFd0d0d0),
            ),
            const SizedBox(height: 16),
            Text(
              isBn ? 'লোড করতে ব্যর্থ হয়েছে' : 'Failed to load',
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                    : const Color(0xFF657786),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(isBn ? 'আবার চেষ্টা করুন' : 'Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
