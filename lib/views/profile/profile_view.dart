import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
            CustomScrollView(
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    child: Column(
                      children: [
                        // Header row with settings
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              language == AppLanguage.bn ? 'প্রোফাইল' : 'Profile',
                              style: TextStyle(
                                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.settings_outlined,
                                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                  ),
                                  onPressed: () => Get.toNamed(AppRoutes.settings),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.2),
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: AppColors.lightPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name
                        Text(
                          language == AppLanguage.bn ? 'ব্যবহারকারী' : 'User Name',
                          style: TextStyle(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@username',
                          style: TextStyle(
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Bio
                        Text(
                          language == AppLanguage.bn 
                              ? 'জীবন সুন্দর! 🌟' 
                              : 'Life is beautiful! 🌟',
                          style: TextStyle(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(language == AppLanguage.bn ? 'পোস্ট' : 'Posts', '24', isDark),
                            _buildStatItem(language == AppLanguage.bn ? 'ফলোয়ার' : 'Followers', '1.2K', isDark),
                            _buildStatItem(language == AppLanguage.bn ? 'ফলোইং' : 'Following', '348', isDark),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Edit Profile Button
                        Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: Text(
                              language == AppLanguage.bn ? 'প্রোফাইল এডিট করুন' : 'Edit Profile',
                              style: TextStyle(
                                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Tabs
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.lightPrimary,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.grid_on,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Icon(
                                Icons.bookmark_outline,
                                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Icon(
                                Icons.favorite_outline,
                                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Posts Grid
                SliverPadding(
                  padding: const EdgeInsets.all(2),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        color: AppColors.lightPrimary.withValues(alpha: 0.1 + (index % 5) * 0.1),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: AppColors.lightPrimary.withValues(alpha: 0.3),
                            size: 32,
                          ),
                        ),
                      ),
                      childCount: 12,
                    ),
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
                activeScreen: AppRoutes.profile,
                hideNav: appController.hideBottomNav,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
