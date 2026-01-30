import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/community_groups_controller.dart';
import '../../controllers/local_community_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/community/community_tabs.dart';
import '../../widgets/community/stages_tab_view.dart';
import '../../widgets/community/groups_tab_view.dart';

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
            Obx(
              () => controller.activeTab.value == CommunityTab.stages
                  ? Positioned(
                      right: 20,
                      top: MediaQuery.of(context).size.height * 0.5,
                      child: _buildStageFloatingButton(isBn),
                    )
                  : Positioned(
                      right: 20,
                      top: MediaQuery.of(context).size.height * 0.4,
                      child: _buildFloatingAddButton(isBn),
                    ),
            ),
            Positioned(
              right: 20,
              bottom: 100,
              child: _buildHelpButton(),
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

  Widget _buildStageFloatingButton(bool isBn) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          isBn ? 'শীঘ্রই আসছে' : 'Coming Soon',
          isBn ? 'স্টেজ তৈরি ফিচার শীঘ্রই আসছে' : 'Create stage feature coming soon',
          snackPosition: SnackPosition.BOTTOM,
        );
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
          Icons.radio,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
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

  Widget _buildHelpButton() {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Help',
          'Help feature coming soon',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.help_outline,
          color: Color(0xFF052029),
          size: 20,
        ),
      ),
    );
  }
}
