import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/conversation/controllers/chat_controller.dart';
import 'package:torko/presentation/main/controllers/navigation_controller.dart';
import 'package:torko/presentation/messages/controllers/inbox_controller.dart';
import 'package:torko/data/models/inbox_thread_model.dart';
import 'package:torko/data/models/search_message_result_model.dart';
import 'package:torko/core/widgets/bottom_nav.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late final InboxController inboxController;

  @override
  void initState() {
    super.initState();
    inboxController = Get.find<InboxController>();
    // Defer inbox stream to next frame - show UI first (performance)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) inboxController.startInboxStream();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().setCurrentScreen('messages');
      }
    });
  }

  @override
  void dispose() {
    // Controllers are permanent; do NOT delete here (cleaned up on logout).
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Stack(
          children: [
            // Main content
            RefreshIndicator(
              onRefresh: () => inboxController.refreshInbox(),
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: Text(
                      language == AppLanguage.bn ? 'বার্তা' : 'Messages',
                      style: TextStyle(
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildSearchBar(isDark, language),
                    ),
                  ),

                  // Body Content
                  Obx(() => _buildBody(isDark, language)),
                  
                  // Bottom padding for nav
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ),
            ),
            
            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNav(
                activeScreen: AppRoutes.messages,
                hideNav: appController.hideBottomNav,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar(bool isDark, AppLanguage language) {
    return Obx(() {
      final showClear = inboxController.isSearchMode.value || 
                      inboxController.searchEC.text.isNotEmpty;
      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark 
                ? AppColors.darkMutedForeground.withOpacity(0.1)
                : AppColors.lightMutedForeground.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: TextField(
          controller: inboxController.searchEC,
          style: TextStyle(
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            fontSize: 15,
          ),
          onSubmitted: (_) => inboxController.onSubmitSearch(),
          decoration: InputDecoration(
            hintText: language == AppLanguage.bn ? 'খুঁজুন...' : 'Search...',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
            prefixIcon: IconButton(
              onPressed: () => inboxController.onSubmitSearch(),
              icon: Icon(
                Icons.search,
                size: 20,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            suffixIcon: showClear
                ? IconButton(
                    onPressed: () => inboxController.clearSearch(),
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      );
    });
  }

  Widget _buildBody(bool isDark, AppLanguage language) {
    if (inboxController.isSearchMode.value) {
      // SEARCH MODE
      if (inboxController.searching.value) {
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.lightPrimary,
            ),
          ),
        );
      } else if (inboxController.searchError.isNotEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  inboxController.searchError.value,
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => inboxController.onSubmitSearch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(language == AppLanguage.bn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                ),
              ],
            ),
          ),
        );
      } else if (inboxController.searchResults.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  language == AppLanguage.bn ? 'কোন ফলাফল পাওয়া যায়নি' : 'No results found',
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final result = inboxController.searchResults[index];
              return _buildSearchResultItem(
                result: result,
                isDark: isDark,
                language: language,
                onTap: () => inboxController.openThreadFromSearch(result),
              );
            },
            childCount: inboxController.searchResults.length,
          ),
        );
      }
    } else {
      // INBOX MODE
      if (inboxController.loading.value) {
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.lightPrimary,
            ),
          ),
        );
      } else if (inboxController.error.isNotEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  inboxController.error.value,
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => inboxController.refreshInbox(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(language == AppLanguage.bn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                ),
              ],
            ),
          ),
        );
      } else if (inboxController.threads.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 64,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  language == AppLanguage.bn ? 'কোন কথোপকথন নেই' : 'No conversations',
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  language == AppLanguage.bn 
                      ? 'আপনার বার্তা এখানে প্রদর্শিত হবে'
                      : 'Your messages will appear here',
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final thread = inboxController.threads[index];
              return _buildThreadTile(
                thread: thread,
                isDark: isDark,
                language: language,
                onTap: () => inboxController.openThreadFromInbox(thread),
              );
            },
            childCount: inboxController.threads.length,
          ),
        );
      }
    }
  }

  Widget _buildThreadTile({
    required InboxThreadModel thread,
    required bool isDark,
    required AppLanguage language,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
                  backgroundImage: thread.otherAvatar != null && thread.otherAvatar!.isNotEmpty
                      ? CachedNetworkImageProvider(thread.otherAvatar!)
                      : null,
                  child: thread.otherAvatar == null || thread.otherAvatar!.isEmpty
                      ? Text(
                          thread.otherName.isNotEmpty ? thread.otherName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            color: AppColors.lightPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (thread.unreadCount > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        thread.unreadCount > 9 ? '9+' : thread.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Name and message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.otherName,
                          style: GoogleFonts.notoSansBengali(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 16,
                            fontWeight: thread.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        thread.formattedTime,
                        style: TextStyle(
                          color: thread.unreadCount > 0 
                              ? AppColors.lightPrimary 
                              : (isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                          fontSize: 12,
                          fontWeight: thread.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage,
                    style: GoogleFonts.notoSansBengali(
                      color: thread.unreadCount > 0 
                          ? (isDark ? AppColors.darkForeground : AppColors.lightForeground)
                          : (isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                      fontSize: 14,
                      fontWeight: thread.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultItem({
    required SearchMessageResultModel result,
    required bool isDark,
    required AppLanguage language,
    required VoidCallback onTap,
  }) {
    final user = result.user;
    final userName = user.fullname;
    final userAvatar = user.profileImage;
    final lastMessage = result.lastMessage;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
              backgroundImage: userAvatar != null && userAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(userAvatar)
                  : null,
              child: userAvatar == null || userAvatar.isEmpty
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: AppColors.lightPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Name and message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: GoogleFonts.notoSansBengali(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessage != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          lastMessage.formattedTime,
                          style: TextStyle(
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastMessage.messageContent,
                      style: GoogleFonts.notoSansBengali(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      language == AppLanguage.bn ? 'বার্তা পাঠাতে ট্যাপ করুন' : 'Tap to message',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
