import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/community_groups_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/community/community_tabs.dart';
import '../../../widgets/community/groups_tab_view.dart';
import '../../../views/community/stages/stage_list_view.dart';
import '../controllers/community_controller.dart';
import '../stages/screens/start_stage_sheet.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final communityController = Get.find<CommunityController>();
    final groupsController = Get.find<CommunityGroupsController>();

    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().setCurrentScreen('localCommunity');
    }

    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;
      final isStagesTab = communityController.activeTab.value == CommunityTab.stages;

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF052029) : AppColors.lightBackground,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  CommunityTabs(
                    activeTab: communityController.activeTab.value,
                    onChange: (tab) => communityController.setTab(tab),
                    isDark: isDark,
                    isBn: isBn,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: isStagesTab
                        ? StageListView(isDark: isDark, isBn: isBn)
                        : GroupsTabView(
                            controller: groupsController,
                            isDark: isDark,
                            isBn: isBn,
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 100,
              child: SafeArea(
                child: isStagesTab
                    ? _buildStageFAB(isBn)
                    : _buildGroupsFAB(isBn),
              ),
            ),
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

  Widget _buildStageFAB(bool isBn) {
    return GestureDetector(
      onTap: () => StartStageSheet.show(isBn: isBn),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFd97757),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFd97757).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.radio, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildGroupsFAB(bool isBn) {
    return GestureDetector(
      onTap: () async {
        await Get.toNamed(AppRoutes.createGroup);
        if (Get.isRegistered<CommunityGroupsController>()) {
          Get.find<CommunityGroupsController>().loadGroups();
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFd97757),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFd97757).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
