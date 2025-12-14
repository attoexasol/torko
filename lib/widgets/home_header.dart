import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/controllers/app_controller.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';

class HomeHeader extends StatefulWidget {
  final VoidCallback? onMenuOpen;

  const HomeHeader({super.key, this.onMenuOpen});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final appController = Get.find<AppController>();
  int unreadCount = 5;

  void _openDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Drawer',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _AppDrawer(
          animation: animation,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _openSearch() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _SearchDialog(
          animation: animation,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _openNotifications() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _NotificationDialog(
          animation: animation,
          onClose: () => Navigator.of(context).pop(),
          unreadCount: unreadCount,
          onUnreadCountChanged: (count) {
            setState(() => unreadCount = count);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;

      return Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo - Clickable to open menu
            GestureDetector(
              onTap: _openDrawer,
              child: SizedBox(
                height: 45,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Right Side - Search and Notification
            Row(
              children: [
                // Search Icon
                _HeaderIconButton(
                  icon: Icons.search,
                  onTap: _openSearch,
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
                // Notification Icon with Badge
                _HeaderIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: _openNotifications,
                  isDark: isDark,
                  badgeCount: unreadCount,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final int badgeCount;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
            if (badgeCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// App Drawer Widget
class _AppDrawer extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onClose;

  const _AppDrawer({
    required this.animation,
    required this.onClose,
  });

  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  final appController = Get.find<AppController>();
  Map<String, dynamic> userProfile = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('torko_user_profile');
    if (profileStr != null) {
      try {
        setState(() {
          userProfile = jsonDecode(profileStr);
        });
      } catch (e) {
        // Ignore parse errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;

      final userName = userProfile['name'] ?? (isBn ? 'আপনার নাম' : 'Your Name');

      final menuItems = [
        _MenuItem(
          icon: Icons.home_outlined,
          label: isBn ? 'হোম' : 'Home',
          onTap: () {
            widget.onClose();
            Get.offAllNamed(AppRoutes.home);
          },
        ),
        _MenuItem(
          icon: Icons.people_outline,
          label: isBn ? 'লোকাল কমিউনিটি' : 'Local Community',
          onTap: () {
            widget.onClose();
            Get.toNamed(AppRoutes.localCommunity);
          },
        ),
        _MenuItem(
          icon: Icons.bookmark_outline,
          label: isBn ? 'সেভ করা' : 'Saved',
          onTap: () {
            widget.onClose();
            // Navigate to saved
          },
        ),
        _MenuItem(
          icon: Icons.chat_bubble_outline,
          label: isBn ? 'মেসেজ' : 'Messages',
          onTap: () {
            widget.onClose();
            Get.toNamed(AppRoutes.messages);
          },
        ),
        _MenuItem(
          icon: Icons.notifications_outlined,
          label: isBn ? 'বিজ্ঞপ্তি' : 'Notifications',
          onTap: () {
            widget.onClose();
            Get.toNamed(AppRoutes.notifications);
          },
        ),
        _MenuItem(
          icon: Icons.person_outline,
          label: isBn ? 'প্রোফাইল' : 'Profile',
          onTap: () {
            widget.onClose();
            Get.toNamed(AppRoutes.profile);
          },
        ),
        _MenuItem(
          icon: Icons.settings_outlined,
          label: isBn ? 'সেটিংস' : 'Settings',
          onTap: () {
            widget.onClose();
            Get.toNamed(AppRoutes.settings);
          },
        ),
      ];

      return Stack(
        children: [
          // Backdrop (handled by barrier)
          
          // Drawer
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: widget.animation,
                curve: Curves.easeOutCubic,
              )),
              child: Material(
                color: isDark ? AppColors.darkBackground : Colors.white,
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isBn ? 'মেনু' : 'Menu',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.onClose,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Divider(
                          height: 1,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),

                        // User Info Section
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.lightPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkForeground
                                            : AppColors.lightForeground,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@username',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.darkMutedForeground
                                            : AppColors.lightMutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Divider(
                          height: 1,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),

                        // Menu Items
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: menuItems.map((item) {
                              return _MenuItemWidget(
                                icon: item.icon,
                                label: item.label,
                                onTap: item.onTap,
                                isDark: isDark,
                              );
                            }).toList(),
                          ),
                        ),

                        // Divider
                        Divider(
                          height: 1,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),

                        // Logout
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _MenuItemWidget(
                            icon: Icons.logout,
                            label: isBn ? 'লগ আউট' : 'Logout',
                            onTap: () {
                              widget.onClose();
                              // Handle logout
                            },
                            isDark: isDark,
                            isDestructive: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _MenuItemWidget({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: isDestructive
            ? Colors.red.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Colors.red
                    : (isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? Colors.red
                      : (isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search Dialog Widget
class _SearchDialog extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onClose;

  const _SearchDialog({
    required this.animation,
    required this.onClose,
  });

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final appController = Get.find<AppController>();
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;

      final trendingSearches = [
        isBn ? 'ঢাকা ট্রাফিক' : 'Dhaka Traffic',
        isBn ? 'বাংলাদেশ ক্রিকেট' : 'Bangladesh Cricket',
        isBn ? 'টেক স্টার্টআপ' : 'Tech Startup',
        isBn ? 'রমজান ২০২৫' : 'Ramadan 2025',
        isBn ? 'চট্টগ্রাম ইভেন্ট' : 'Chittagong Events',
      ];

      return Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: widget.animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: widget.animation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: isDark ? AppColors.darkBackground : Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 20,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                autofocus: true,
                                onChanged: (value) {
                                  setState(() => searchQuery = value);
                                },
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                                decoration: InputDecoration(
                                  hintText: isBn ? 'খুঁজুন...' : 'Search...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? AppColors.darkMutedForeground
                                        : AppColors.lightMutedForeground,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onClose,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Trending Searches
                              Text(
                                isBn ? 'ট্রেন্ডিং সার্চ' : 'TRENDING SEARCHES',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...trendingSearches.map((term) {
                                return GestureDetector(
                                  onTap: () {
                                    searchController.text = term;
                                    setState(() => searchQuery = term);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          size: 16,
                                          color: AppColors.lightPrimary,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          term,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isDark
                                                ? AppColors.darkForeground
                                                : AppColors.lightForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              // Search Results
                              if (searchQuery.trim().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Divider(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isBn ? 'ফলাফল' : 'RESULTS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: isDark
                                        ? AppColors.darkMutedForeground
                                        : AppColors.lightMutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: Text(
                                    isBn
                                        ? '"$searchQuery" এর জন্য কোন ফলাফল নেই'
                                        : 'No results for "$searchQuery"',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkMutedForeground
                                          : AppColors.lightMutedForeground,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Notification Dialog Widget
class _NotificationDialog extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onClose;
  final int unreadCount;
  final ValueChanged<int> onUnreadCountChanged;

  const _NotificationDialog({
    required this.animation,
    required this.onClose,
    required this.unreadCount,
    required this.onUnreadCountChanged,
  });

  @override
  State<_NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<_NotificationDialog> {
  final appController = Get.find<AppController>();
  late int unreadCount;

  @override
  void initState() {
    super.initState();
    unreadCount = widget.unreadCount;
  }

  void _handleNotificationClick(int id) {
    setState(() {
      unreadCount = (unreadCount - 1).clamp(0, 99);
    });
    widget.onUnreadCountChanged(unreadCount);
    widget.onClose();
  }

  void _markAllAsRead() {
    setState(() => unreadCount = 0);
    widget.onUnreadCountChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;

      final notifications = [
        _NotificationItem(
          id: 1,
          user: isBn ? 'আহমেদ রহমান' : 'Ahmed Rahman',
          action: isBn ? 'আপনার পোস্ট লাইক করেছে' : 'liked your post',
          time: isBn ? '৫ মিনিট আগে' : '5 min ago',
          unread: true,
          avatar: '🙂',
        ),
        _NotificationItem(
          id: 2,
          user: isBn ? 'ফাতিমা খান' : 'Fatima Khan',
          action: isBn ? 'আপনার পোস্টে মন্তব্য করেছে' : 'commented on your post',
          time: isBn ? '১৫ মিনিট আগে' : '15 min ago',
          unread: true,
          avatar: '👩',
        ),
        _NotificationItem(
          id: 3,
          user: isBn ? 'মাহমুদ হাসান' : 'Mahmud Hasan',
          action: isBn ? 'আপনাকে ফলো করতে শুরু করেছে' : 'started following you',
          time: isBn ? '১ ঘণ্টা আগে' : '1 hour ago',
          unread: true,
          avatar: '👨',
        ),
        _NotificationItem(
          id: 4,
          user: isBn ? 'নাফিসা আক্তার' : 'Nafisa Akter',
          action: isBn ? 'আপনাকে একটি মেসেজ পাঠিয়েছে' : 'sent you a message',
          time: isBn ? '২ ঘণ্টা আগে' : '2 hours ago',
          unread: false,
          avatar: '👩‍💼',
        ),
        _NotificationItem(
          id: 5,
          user: isBn ? 'রাকিব ইসলাম' : 'Rakib Islam',
          action: isBn ? 'আপনার মন্তব্য লাইক করেছে' : 'liked your comment',
          time: isBn ? '৩ ঘণ্টা আগে' : '3 hours ago',
          unread: false,
          avatar: '🧑',
        ),
      ];

      return Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: widget.animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: widget.animation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: isDark ? AppColors.darkBackground : Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 20,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isBn ? 'বিজ্ঞপ্তি' : 'Notifications',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                            const Spacer(),
                            if (unreadCount > 0)
                              GestureDetector(
                                onTap: _markAllAsRead,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isBn ? 'সব পড়া হয়েছে' : 'Mark all read',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.lightPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: widget.onClose,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),

                      // Notifications List
                      Flexible(
                        child: notifications.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(48),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_outlined,
                                      size: 48,
                                      color: isDark
                                          ? AppColors.darkMutedForeground.withValues(alpha: 0.3)
                                          : AppColors.lightMutedForeground.withValues(alpha: 0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      isBn ? 'কোন বিজ্ঞপ্তি নেই' : 'No notifications',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.darkMutedForeground
                                            : AppColors.lightMutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = notifications[index];
                                  return _NotificationTile(
                                    notification: notification,
                                    isDark: isDark,
                                    index: index,
                                    animation: widget.animation,
                                    onTap: () => _handleNotificationClick(notification.id),
                                  );
                                },
                              ),
                      ),

                      // Footer
                      if (notifications.isNotEmpty) ...[
                        Divider(
                          height: 1,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: GestureDetector(
                            onTap: () {
                              widget.onClose();
                              Get.toNamed(AppRoutes.notifications);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  isBn ? 'সব বিজ্ঞপ্তি দেখুন' : 'View all notifications',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.lightPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NotificationItem {
  final int id;
  final String user;
  final String action;
  final String time;
  final bool unread;
  final String avatar;

  _NotificationItem({
    required this.id,
    required this.user,
    required this.action,
    required this.time,
    required this.unread,
    required this.avatar,
  });
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem notification;
  final bool isDark;
  final int index;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.index,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.1 + (index * 0.05),
          1.0,
          curve: Curves.easeOut,
        ),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.1 + (index * 0.05),
            1.0,
            curve: Curves.easeOut,
          ),
        ),
        child: Material(
          color: notification.unread
              ? (isDark
                  ? AppColors.darkMuted.withValues(alpha: 0.3)
                  : AppColors.lightMuted.withValues(alpha: 0.3))
              : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: notification.unread
                          ? const Color(0xFFd6775c)
                          : const Color(0xFF8B8B8B),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        notification.avatar,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                            children: [
                              TextSpan(
                                text: notification.user,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ' ${notification.action}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unread Indicator
                  if (notification.unread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

