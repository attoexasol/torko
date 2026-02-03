import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/community/controllers/community_groups_controller.dart';
import 'package:torko/presentation/local_community/controllers/local_community_controller.dart';
import 'package:torko/presentation/main/controllers/navigation_controller.dart';
import 'package:torko/core/widgets/bottom_nav.dart';
import 'package:torko/core/widgets/community/community_tabs.dart';
import 'package:torko/core/widgets/community/stages_tab_view.dart';
import 'package:torko/core/widgets/community/groups_tab_view.dart';
import 'package:torko/presentation/community/controllers/community_controller.dart';

class LocalCommunityView extends StatefulWidget {
  const LocalCommunityView({super.key});

  @override
  State<LocalCommunityView> createState() => _LocalCommunityViewState();
}

class _LocalCommunityViewState extends State<LocalCommunityView> {
  late final LocalCommunityController controller;
  late final CommunityGroupsController groupsController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LocalCommunityController());
    groupsController = Get.put(CommunityGroupsController());
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().setCurrentScreen('localCommunity');
    }

    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;

      final stages = [
        {
          'id': 1,
          'category': isBn ? 'ব্যবসা' : 'Business',
          'categoryColor': '#B8DED6',
          'isLive': true,
          'title': isBn ? 'স্টার্টআপ সাফল্যের গোপন কথা' : 'Startup Success Secrets',
          'hostName': 'Rifat Hassan',
          'hostAvatar': null,
          'joinedCount': isBn ? '২৩৪' : '234',
          'duration': isBn ? '৪৫ মিনিট' : '45 min',
        },
        {
          'id': 2,
          'category': isBn ? 'প্রযুক্তি' : 'Technology',
          'categoryColor': '#B8DED6',
          'isLive': true,
          'title': isBn ? 'AI এবং মেশিন লার্নিং এর ভবিষ্যৎ' : 'Future of AI and Machine Learning',
          'hostName': 'Mehedi Hasan',
          'hostAvatar': null,
          'joinedCount': isBn ? '৫৬৭' : '567',
          'duration': isBn ? '১ ঘণ্টা' : '1 hour',
        },
        {
          'id': 3,
          'category': isBn ? 'সাহিত্য' : 'Literature',
          'categoryColor': '#B8DED6',
          'isLive': true,
          'title': isBn ? 'বাংলা কবিতা পাঠ ও আলোচনা' : 'Bangla Poetry Reading & Discussion',
          'hostName': 'Nusrat Jahan',
          'hostAvatar': null,
          'joinedCount': isBn ? '১২৩' : '123',
          'duration': isBn ? '৩০ মিনিট' : '30 min',
        },
      ];

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF052029) : AppColors.lightBackground,
        body: Stack(
          children: [
            Obx(
              () => Column(
                children: [
                  CommunityTabs(
                    activeTab: controller.activeTab.value,
                    onChange: (tab) => controller.activeTab.value = tab,
                    isDark: isDark,
                    isBn: isBn,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: controller.activeTab.value == CommunityTab.stages
                        ? StagesTabView(stages: stages, isDark: isDark, isBn: isBn)
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
                child: _buildFloatingAddButton(isBn),
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

  Widget _buildFloatingAddButton(bool isBn) {
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
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

}
