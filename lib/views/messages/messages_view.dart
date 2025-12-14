import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      // Sample conversations data
      final conversations = [
        {
          'name': 'Sarah Johnson',
          'lastMessage': 'Hey! How are you?',
          'time': '2m',
          'unread': 2,
          'online': true,
        },
        {
          'name': 'Michael Chen',
          'lastMessage': 'The project looks great!',
          'time': '15m',
          'unread': 0,
          'online': true,
        },
        {
          'name': 'আবদুল কাদের',
          'lastMessage': 'আমি আসছি',
          'time': '1h',
          'unread': 5,
          'online': false,
        },
        {
          'name': 'Emma Williams',
          'lastMessage': 'See you tomorrow 👋',
          'time': '3h',
          'unread': 0,
          'online': false,
        },
        {
          'name': 'নাজমুল হাসান',
          'lastMessage': 'ধন্যবাদ!',
          'time': '1d',
          'unread': 0,
          'online': true,
        },
      ];
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Stack(
          children: [
            CustomScrollView(
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
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                      onPressed: () {},
                    ),
                  ],
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
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search,
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              style: TextStyle(
                                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: language == AppLanguage.bn ? 'খুঁজুন...' : 'Search...',
                                hintStyle: TextStyle(
                                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Conversations List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final conversation = conversations[index];
                      return _buildConversationItem(
                        name: conversation['name'] as String,
                        lastMessage: conversation['lastMessage'] as String,
                        time: conversation['time'] as String,
                        unread: conversation['unread'] as int,
                        online: conversation['online'] as bool,
                        isDark: isDark,
                        onTap: () {
                          appController.openConversation(conversation);
                        },
                      );
                    },
                    childCount: conversations.length,
                  ),
                ),
                
                // Bottom padding for nav
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
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
    required String name,
    required String lastMessage,
    required String time,
    required int unread,
    required bool online,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.2),
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: AppColors.lightPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (online)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          width: 2,
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
                          name,
                          style: TextStyle(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 16,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
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
                          lastMessage,
                          style: TextStyle(
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
