import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

class LocalCommunityView extends StatelessWidget {
  const LocalCommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      // Sample communities data
      final communities = [
        {
          'name': language == AppLanguage.bn ? 'ঢাকা ফুড লাভার্স' : 'Dhaka Food Lovers',
          'members': '12.5K',
          'posts': '234',
          'icon': Icons.restaurant,
        },
        {
          'name': language == AppLanguage.bn ? 'বাংলাদেশ ট্রাভেল' : 'Bangladesh Travel',
          'members': '8.2K',
          'posts': '156',
          'icon': Icons.travel_explore,
        },
        {
          'name': language == AppLanguage.bn ? 'টেক কমিউনিটি BD' : 'Tech Community BD',
          'members': '15.3K',
          'posts': '512',
          'icon': Icons.computer,
        },
        {
          'name': language == AppLanguage.bn ? 'বই পড়ুয়া' : 'Book Readers',
          'members': '5.8K',
          'posts': '89',
          'icon': Icons.book,
        },
        {
          'name': language == AppLanguage.bn ? 'ফিটনেস বাংলাদেশ' : 'Fitness BD',
          'members': '9.1K',
          'posts': '198',
          'icon': Icons.fitness_center,
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
                    language == AppLanguage.bn ? 'কমিউনিটি' : 'Communities',
                    style: TextStyle(
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
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
                                hintText: language == AppLanguage.bn ? 'কমিউনিটি খুঁজুন...' : 'Search communities...',
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
                
                // Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      language == AppLanguage.bn ? 'জনপ্রিয় কমিউনিটি' : 'Popular Communities',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                // Communities List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final community = communities[index];
                      return _buildCommunityItem(
                        name: community['name'] as String,
                        members: community['members'] as String,
                        posts: community['posts'] as String,
                        icon: community['icon'] as IconData,
                        isDark: isDark,
                        language: language,
                        onTap: () {},
                      );
                    },
                    childCount: communities.length,
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
                activeScreen: AppRoutes.localCommunity,
                hideNav: appController.hideBottomNav,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommunityItem({
    required String name,
    required String members,
    required String posts,
    required IconData icon,
    required bool isDark,
    required AppLanguage language,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Community Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.lightPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Community Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$members ${language == AppLanguage.bn ? 'সদস্য' : 'members'}',
                            style: TextStyle(
                              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 14,
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$posts ${language == AppLanguage.bn ? 'পোস্ট' : 'posts'}',
                            style: TextStyle(
                              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Join Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                language == AppLanguage.bn ? 'যোগ দিন' : 'Join',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
