import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/controllers/app_controller.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';

class BottomNav extends StatelessWidget {
  final String activeScreen;
  final bool hideNav;

  const BottomNav({
    super.key,
    required this.activeScreen,
    this.hideNav = false,
  });

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    final isHome = activeScreen == AppRoutes.home;
    final isMessages = activeScreen == AppRoutes.messages;
    final isLocalCommunity = activeScreen == AppRoutes.localCommunity || activeScreen == AppRoutes.explore;
    final isProfile = activeScreen == AppRoutes.profile;

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
                  // Home Button
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: appController.t('home'),
                    isActive: isHome,
                    onTap: () => Get.offAllNamed(AppRoutes.home),
                  ),
                  
                  // Community Button
                  _buildNavItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    label: appController.language == AppLanguage.bn ? 'কমিউনিটি' : 'Community',
                    isActive: isLocalCommunity,
                    onTap: () => Get.offAllNamed(AppRoutes.localCommunity),
                  ),
                  
                  // Create Post Button (Center)
                  _buildCenterButton(),
                  
                  // Messages Button
                  _buildNavItem(
                    icon: Icons.message_outlined,
                    activeIcon: Icons.message,
                    label: appController.t('messages'),
                    isActive: isMessages,
                    onTap: () {
                      appController.resetMessageNotifications();
                      Get.offAllNamed(AppRoutes.messages);
                    },
                    badge: appController.messageNotificationCount > 0 
                        ? appController.messageNotificationCount 
                        : null,
                  ),
                  
                  // Profile Button
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: appController.t('profile'),
                    isActive: isProfile,
                    onTap: () => Get.offAllNamed(AppRoutes.profile),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
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
          );
        },
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.createPost),
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
