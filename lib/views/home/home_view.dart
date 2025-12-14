import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/home_header.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final appController = Get.find<AppController>();
  final scrollController = ScrollController();
  bool showHeader = true;
  double lastScrollY = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final currentScrollY = scrollController.offset;
    final scrollDelta = currentScrollY - lastScrollY;
    
    if (currentScrollY < 10) {
      setState(() => showHeader = true);
      appController.setHideBottomNav(false);
    } else if (scrollDelta > 15 && currentScrollY > 20) {
      setState(() => showHeader = false);
      appController.setHideBottomNav(true);
    } else if (scrollDelta < -5) {
      setState(() => showHeader = true);
      appController.setHideBottomNav(false);
    }
    
    lastScrollY = currentScrollY;
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: Stack(
          children: [
            // Main content
            CustomScrollView(
              controller: scrollController,
              slivers: [
                // Space for header
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 60,
                  ),
                ),
                
                // Posts
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPostCard(index, isDark, language),
                    childCount: 20,
                  ),
                ),
                
                // Bottom padding for nav
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
            
            // Fixed Header at top (positioned after scroll view to be on top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: showHeader ? Offset.zero : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: showHeader ? 1.0 : 0.0,
                  child: Container(
                    color: isDark ? AppColors.darkBackground : Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: const HomeHeader(),
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNav(
                activeScreen: AppRoutes.home,
                hideNav: appController.hideBottomNav,
              ),
            ),
          ],
        ),
      );
    });
  }


  Widget _buildPostCard(int index, bool isDark, AppLanguage language) {
    final authors = [
      'Sarah Johnson', 'Michael Chen', 'Emma Williams', 'David Rodriguez',
      'আবদুল কাদের', 'নাজমুল হাসান', 'তানিয়া আফরিন', 'সাবিহা আক্তার',
    ];
    
    final contents = [
      'আজকের দিনটা সত্যিই অসাধারণ ছিল! 🌟',
      'জীবনে স্বপ্ন দেখতে কখনো ভুলে যেও না।',
      'Weekend vibes with friends! মজা করলাম অনেক',
      'New cafe discover করলাম Dhanmondi তে, must try!',
      'Cox\'s Bazar এ sunset দেখছি, breathtaking view!',
      'প্রতিদিন নিয়ে আসে নতুন সম্ভাবনা।',
      'Morning walk করে এলাম, feeling refreshed ☀️',
      'Traffic jam এ আটকে আছি, typical Dhaka 🚗',
    ];
    
    final author = authors[index % authors.length];
    final content = contents[index % contents.length];
    final likes = 50 + (index * 17) % 200;
    final comments = 10 + (index * 7) % 50;
    final hours = 1 + (index % 24);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder.withOpacity(0.3) : AppColors.lightBorder.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
                child: Text(
                  author[0],
                  style: TextStyle(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          author,
                          style: TextStyle(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified, color: AppColors.lightPrimary, size: 14),
                      ],
                    ),
                    Text(
                      language == AppLanguage.bn ? '$hoursঘ' : '${hours}h',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Content
          Text(
            content,
            style: TextStyle(
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // Actions Row
          Row(
            children: [
              _buildActionButton(
                icon: Icons.favorite_outline,
                label: likes.toString(),
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: comments.toString(),
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: '',
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
