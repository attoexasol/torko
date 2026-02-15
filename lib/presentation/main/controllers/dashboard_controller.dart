import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/app/theme/app_sizes.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/widgets/bottom_nav.dart';
import 'package:torko/core/widgets/post_card.dart';

class DashboardController extends GetxController {
  final RxString activeScreen = 'home'.obs;
  final RxBool showHeader = true.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[].obs;
  final ScrollController scrollController = ScrollController();
  double lastScrollY = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    _initializePosts();
  }

  @override
  void onClose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _handleScroll() {
    final appController = Get.find<AppController>();
    final currentScrollY = scrollController.offset;
    final scrollDelta = currentScrollY - lastScrollY;
    
    if (currentScrollY < 10) {
      showHeader.value = true;
      appController.setHideBottomNav(false);
    } else if (scrollDelta > 15 && currentScrollY > 20) {
      showHeader.value = false;
      appController.setHideBottomNav(true);
    } else if (scrollDelta < -5) {
      showHeader.value = true;
      appController.setHideBottomNav(false);
    }
    
    lastScrollY = currentScrollY;
  }

  void onNavigate(String screen) {
    activeScreen.value = screen;
    switch (screen) {
      case 'home':
        Get.offAllNamed(AppRoutes.home);
        break;
      case 'localCommunity':
        Get.offAllNamed(AppRoutes.localCommunity);
        break;
      case 'createPost':
        Get.toNamed(AppRoutes.createPost);
        break;
      case 'messages':
        final appController = Get.find<AppController>();
        appController.resetMessageNotifications();
        Get.offAllNamed(AppRoutes.messages);
        break;
      case 'profile':
        Get.offAllNamed(AppRoutes.profile);
        break;
    }
  }

  void _initializePosts() {
    // Sample data similar to the React component
    posts.value = [
      {
        'id': '1',
        'author': 'Sarah Johnson',
        'username': '@sarah_j',
        'avatar': null,
        'timestamp': '2h',
        'content': 'আজকের দিনটা সত্যিই অসাধারণ ছিল! 🌟',
        'type': 'text',
        'likes': 67,
        'comments': 23,
        'isLiked': false,
      },
      {
        'id': '2',
        'author': 'আবদুল কাদের',
        'username': '@abdul_k',
        'avatar': null,
        'timestamp': '4h',
        'content': 'জীবনে স্বপ্ন দেখতে কখনো ভুলে যেও না।',
        'type': 'text',
        'likes': 124,
        'comments': 45,
        'isLiked': true,
      },
      {
        'id': '3',
        'author': 'Emma Williams',
        'username': '@emma_w',
        'avatar': null,
        'timestamp': '6h',
        'content': 'Weekend vibes with friends! মজা করলাম অনেক',
        'type': 'text',
        'likes': 89,
        'comments': 31,
        'isLiked': false,
      },
      {
        'id': '4',
        'author': 'নাজমুল হাসান',
        'username': '@nazmu_h',
        'avatar': null,
        'timestamp': '8h',
        'content': 'New cafe discover করলাম Dhanmondi তে, must try!',
        'type': 'text',
        'likes': 156,
        'comments': 67,
        'isLiked': false,
      },
      {
        'id': '5',
        'author': 'তানিয়া আফরিন',
        'username': '@tania_a',
        'avatar': null,
        'timestamp': '12h',
        'content': "Cox's Bazar sunset দেখছি, breathtaking view!",
        'type': 'text',
        'likes': 234,
        'comments': 89,
        'isLiked': true,
      },
    ];
  }

  void onLikePost(String postId) {
    final postIndex = posts.indexWhere((post) => post['id'] == postId);
    if (postIndex != -1) {
      final post = posts[postIndex];
      final isLiked = post['isLiked'] as bool;
      post['isLiked'] = !isLiked;
      post['likes'] = isLiked ? post['likes'] - 1 : post['likes'] + 1;
      posts.refresh();
    }
  }

  void onCommentPost(String postId) {
    // Handle comment action
    final appController = Get.find<AppController>();
    appController.showNotification(
      title: 'Coming Soon',
      message: 'Comment feature will be available soon!',
    );
  }

  void onSharePost(String postId) {
    // Handle share action
    final appController = Get.find<AppController>();
    appController.showNotification(
      title: 'Coming Soon',
      message: 'Share feature will be available soon!',
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    // Initialize dashboard controller if not already initialized
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    final dashboardController = Get.find<DashboardController>();

    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: Stack(
          children: [
            // Main content
            CustomScrollView(
              controller: dashboardController.scrollController,
              slivers: [
                // Space for header
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 60,
                  ),
                ),
                
                // Header Section
                SliverToBoxAdapter(
                  child: _buildDashboardHeader(isDark, language, appController),
                ),
                
                // Posts
                Obx(() => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = dashboardController.posts[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: PostCard(
                          author: post['author'],
                          username: post['username'],
                          timestamp: post['timestamp'],
                          content: post['content'],
                          type: post['type'],
                          likes: post['likes'],
                          comments: post['comments'],
                          isLiked: post['isLiked'],
                          onLike: () => dashboardController.onLikePost(post['id']),
                          onComment: () => dashboardController.onCommentPost(post['id']),
                          onShare: () => dashboardController.onSharePost(post['id']),
                        ),
                      );
                    },
                    childCount: dashboardController.posts.length,
                  ),
                )),
                
                // Bottom padding for nav
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
            
            // Fixed Header at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Obx(() => AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: dashboardController.showHeader.value ? Offset.zero : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: dashboardController.showHeader.value ? 1.0 : 0.0,
                  child: Container(
                    color: isDark ? AppColors.darkBackground : Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: _buildTopHeader(isDark, language, appController),
                    ),
                  ),
                ),
              )),
            ),
            
            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: DashboardBottomNav(
                activeScreen: 'dashboard',
                hideNav: appController.hideBottomNav,
                onNavigate: dashboardController.onNavigate,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTopHeader(bool isDark, AppLanguage language, AppController appController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // App Logo/Title
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language == AppLanguage.bn ? 'ড্যাশবোর্ড' : 'Dashboard',
                  style: TextStyle(
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
          
          // Settings
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(bool isDark, AppLanguage language, AppController appController) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [AppColors.darkCard, AppColors.darkMuted]
            : [AppColors.lightPrimary.withOpacity(0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == AppLanguage.bn 
                        ? 'স্বাগতম ফিরে!' 
                        : 'Welcome Back!',
                      style: TextStyle(
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language == AppLanguage.bn 
                        ? 'আপনার কমিউনিটির সাথে যুক্ত থাকুন'
                        : 'Stay connected with your community',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.waving_hand,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.create,
                  label: language == AppLanguage.bn ? 'পোস্ট করুন' : 'Create Post',
                  onTap: () => Get.toNamed(AppRoutes.createPost),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.people,
                  label: language == AppLanguage.bn ? 'কমিউনিটি' : 'Community',
                  onTap: () => Get.toNamed(AppRoutes.localCommunity),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.message,
                  label: language == AppLanguage.bn ? 'মেসেজ' : 'Messages',
                  onTap: () => Get.toNamed(AppRoutes.messages),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.lightPrimary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Bottom Navigation for Dashboard
class DashboardBottomNav extends StatelessWidget {
  final String activeScreen;
  final bool hideNav;
  final Function(String) onNavigate;

  const DashboardBottomNav({
    super.key,
    required this.activeScreen,
    this.hideNav = false,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    final isDashboard = activeScreen == 'dashboard';
    final isHome = activeScreen == 'home';
    final isMessages = activeScreen == 'messages';
    final isLocalCommunity = activeScreen == 'localCommunity';
    final isProfile = activeScreen == 'profile';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0, hideNav ? 100 : 0, 0),
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxScreenWidth, minWidth: AppSizes.minScreenWidth),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Container(
              height: AppSizes.bottomNavHeight,
              decoration: BoxDecoration(
                color: AppColors.bottomNavBackground,
                borderRadius: BorderRadius.circular(75),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Dashboard Button (replacing Home)
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: appController.language == AppLanguage.bn ? 'ড্যাশবোর্ড' : 'Dashboard',
                    isActive: isDashboard,
                    onTap: () {
                      // Stay on dashboard
                    },
                  ),
                  
                  // Home Button  
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: appController.t('home'),
                    isActive: isHome,
                    onTap: () => onNavigate('home'),
                  ),
                  
                  // Create Post Button (Center)
                  _buildCenterButton(),
                  
                  // Messages Button (badge removed - no overlay)
                  _buildNavItem(
                    icon: Icons.message_outlined,
                    activeIcon: Icons.message,
                    label: appController.t('messages'),
                    isActive: isMessages,
                    onTap: () => onNavigate('messages'),
                  ),
                  
                  // Profile Button
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: appController.t('profile'),
                    isActive: isProfile,
                    onTap: () => onNavigate('profile'),
                  ),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: AppSizes.bottomNavItemSize,
                height: AppSizes.bottomNavItemSize,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.bottomNavActive : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.bottomNavActive.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: Colors.white,
                  size: isActive ? AppSizes.bottomNavIconSizeActive : AppSizes.bottomNavIconSize,
                ),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.bottomNavNotificationBadge,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        badge > 99 ? '99+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(isActive ? 1.0 : 0.7),
              fontSize: AppSizes.bottomNavTextSize,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => onNavigate('createPost'),
      child: Transform.translate(
        offset: const Offset(0, -4),
        child: Container(
          width: AppSizes.bottomNavCenterButtonSize,
          height: AppSizes.bottomNavCenterButtonSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.bottomNavBackground,
            size: 22,
          ),
        ),
      ),
    );
  }
}