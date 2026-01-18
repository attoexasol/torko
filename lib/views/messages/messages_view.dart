import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../models/conversation_item_model.dart';
import '../../widgets/bottom_nav.dart';
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
    if (kDebugMode) {
      print('🔍 [MessagesView] MessagesView opened');
    }
    
    // Get or create InboxController
    inboxController = Get.put(InboxController(), permanent: false);
    
    // Ensure inbox is loaded
    if (inboxController.conversations.isEmpty && !inboxController.isLoading.value) {
      if (kDebugMode) {
        print('🔄 [MessagesView] Calling fetchInbox() from initState');
      }
      inboxController.fetchInbox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    // Sync navigation state
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().setCurrentScreen('messages');
    }
    
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => inboxController.refresh(),
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
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: language == AppLanguage.bn ? 'খুঁজুন...' : 'Search...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Loading State
                  if (inboxController.isLoading.value)
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    )
                  // Empty State
                  else if (inboxController.conversations.isEmpty && inboxController.errorMessage.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          language == AppLanguage.bn ? 'কোন কথোপকথন নেই' : 'No conversations',
                          style: TextStyle(
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          ),
                        ),
                      ),
                    )
                  // Conversations List
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final conversation = inboxController.conversations[index];
                          return _buildConversationItem(
                            conversation: conversation,
                            isDark: isDark,
                            language: language,
                            onTap: () => inboxController.openConversation(conversation),
                          );
                        },
                        childCount: inboxController.conversations.length,
                      ),
                    ),
                  
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

  Widget _buildConversationItem({
    required ConversationItemModel conversation,
    required bool isDark,
    required AppLanguage language,
    required VoidCallback onTap,
  }) {
    final unread = conversation.isRead == 0 ? 1 : 0;
    final receiver = conversation.receiver;
    final receiverName = receiver.fullname;
    final receiverAvatar = receiver.profileImage;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
              backgroundImage: receiverAvatar != null && receiverAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(receiverAvatar)
                  : null,
              child: receiverAvatar == null || receiverAvatar.isEmpty
                  ? Text(
                      receiverName.isNotEmpty ? receiverName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: AppColors.lightPrimary,
                        fontSize: 18,
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
                          receiverName,
                          style: GoogleFonts.notoSansBengali(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 16,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation.formattedTime,
                        style: TextStyle(
                          color: unread > 0 
                              ? AppColors.lightPrimary 
                              : (isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: GoogleFonts.notoSansBengali(
                            color: unread > 0 
                                ? (isDark ? AppColors.darkForeground : AppColors.lightForeground)
                                : (isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                            fontSize: 14,
                            fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
