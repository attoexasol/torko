import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/navigation_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/community/stage_join_dialog.dart';

class LocalCommunityView extends StatefulWidget {
  const LocalCommunityView({super.key});

  @override
  State<LocalCommunityView> createState() => _LocalCommunityViewState();
}

class _LocalCommunityViewState extends State<LocalCommunityView> {
  String _activeTab = 'stages'; // 'stages' | 'groups'

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    // Sync navigation state
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().setCurrentScreen('localCommunity');
    }

    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;

      // Mock stage data matching screenshot
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

      // Mock group data matching screenshot
      final groups = [
        {
          'id': 1,
          'name': isBn ? 'বাংলাদেশ' : 'Bangladesh',
          'description': isBn
              ? 'প্রযুক্তি প্রেম ডিজিটাল ট্রেন্ড এবং সফটওয়্যার ডেভেলপমেন্ট নিয়ে আলোচনা'
              : 'Technology love digital trends and software development discussion',
          'members': isBn ? '২৫,০০০' : '25,000',
          'type': 'public',
          'image': 'https://images.unsplash.com/photo-1529209076408-5a115ec9f1c6?w=800',
        },
        {
          'id': 2,
          'name': isBn ? 'ঢাকা স্টার্টআপ হাব' : 'Dhaka Startup Hub',
          'description': isBn
              ? 'স্টার্টআপ উদ্যোক্তা ও বিনিয়োগকারীদের নেটওয়ার্ক - ব্যবসায়িক পরামর্শ, ফান্ডিং সুযোগ, এবং সহযোগিতার জন্য।'
              : 'Network for startup entrepreneurs and investors - for business advice, funding opportunities, and collaboration.',
          'members': isBn ? '১৮,৭০০' : '18,700',
          'type': 'public',
          'image': 'https://images.unsplash.com/photo-1629787177096-9fbe3e2ef6f3?w=800',
        },
        {
          'id': 3,
          'name': isBn ? 'বাংলা সাহিত্য প্রেমী' : 'Bangla Literature Lovers',
          'description': isBn
              ? 'বাংলা সাহিত্য নিয়ে আলোচনা ও শেয়ারিং - কবিতা, উপন্যাস, ছোটগল্প এবং সাহিত্যিক বিশ্লেষণ'
              : 'Discussion and sharing about Bangla literature - poetry, novels, short stories and literary analysis',
          'members': isBn ? '১২,৫০০' : '12,500',
          'type': 'public',
          'image': 'https://images.unsplash.com/photo-1695121435869-11f4791315b3?w=800',
        },
      ];

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF052029) : AppColors.lightBackground,
        body: Stack(
          children: [
            Column(
              children: [
                // Tab Bar
                _buildTabBar(isDark, isBn),
                // Content List
                Expanded(
                  child: _activeTab == 'stages'
                      ? _buildStagesView(stages, isDark, isBn)
                      : _buildGroupsView(groups, isDark, isBn),
                ),
              ],
            ),
            // Floating buttons based on active tab
            if (_activeTab == 'stages')
              Positioned(
                right: 20,
                top: MediaQuery.of(context).size.height * 0.5,
                child: _buildStageFloatingButton(isDark, isBn),
              ),
            if (_activeTab == 'groups')
              Positioned(
                right: 20,
                top: MediaQuery.of(context).size.height * 0.4,
                child: _buildFloatingAddButton(isDark, isBn),
              ),
            // Help "?" button (always visible, bottom-right)
            Positioned(
              right: 20,
              bottom: 100,
              child: _buildHelpButton(isDark),
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

  Widget _buildTabBar(bool isDark, bool isBn) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF052029) : AppColors.lightBackground,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFfafafa),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton('stages', isBn ? 'স্টেজ' : 'Stages', Icons.radio, isDark),
            ),
            Expanded(
              child: _buildTabButton('groups', isBn ? 'গ্রুপ' : 'Groups', Icons.people, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon, bool isDark) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFd97757) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.white
                  : (isDark ? const Color(0xFF9d9d9d) : const Color(0xFF9d9d9d)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.notoSansBengali(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : (isDark ? const Color(0xFF9d9d9d) : const Color(0xFF9d9d9d)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStagesView(List<Map<String, dynamic>> stages, bool isDark, bool isBn) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        return _buildStageCard(context, stages[index], isDark, isBn);
      },
    );
  }

  Widget _buildStageCard(BuildContext context, Map<String, dynamic> stage, bool isDark, bool isBn) {
    return GestureDetector(
      onTap: () {
        StageJoinDialog.show(context, stage);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFEBEBEB),
            width: 1,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Badge + Live Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(int.parse(stage['categoryColor'].toString().replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  stage['category'].toString(),
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              // Live Badge
              if (stage['isLive'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBn ? 'লাইভ' : 'LIVE',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            stage['title'].toString(),
            style: GoogleFonts.notoSansBengali(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Host Row
          Row(
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFd97757),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stage['hostName'].toString()[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Host Name + Meta Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage['hostName'].toString(),
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stage['joinedCount']} ${isBn ? 'শ্রোতা' : 'listeners'}',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '⊙',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stage['duration'].toString(),
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Join Stage Button
          GestureDetector(
            onTap: () {
              Get.snackbar(
                isBn ? 'স্টেজে যোগ দেওয়া হয়েছে' : 'Joined Stage',
                isBn ? '${stage['title']} স্টেজে যোগ দেওয়া হয়েছে' : 'Joined ${stage['title']} stage',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFd97757),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  isBn ? 'স্টেজে যোগ দিন' : 'Join Stage',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  Widget _buildGroupsView(List<Map<String, dynamic>> groups, bool isDark, bool isBn) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _buildGroupCard(groups[index], isDark, isBn);
      },
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, bool isDark, bool isBn) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.groupDetail,
          arguments: group,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFEBEBEB),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cover Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              group['image'].toString(),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFFd97757),
                child: const Center(
                  child: Icon(Icons.image, color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),
          // Bottom Content Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group['name'].toString(),
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isBn ? 'সার্বজনীন' : 'Public',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 11,
                          color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.8) : const Color(0xFF555e67),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  group['description'].toString(),
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.65) : const Color(0xFF555e67),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Bottom Row (Members + Join Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Members Count
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.8) : const Color(0xFF9D9D9D),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${group['members']} ${isBn ? 'সদস্য' : 'members'}',
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 12,
                                color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.8) : const Color(0xFF9D9D9D),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Join Button
                    GestureDetector(
                      onTap: () {
                        Get.snackbar(
                          isBn ? 'যোগ দেওয়া হয়েছে' : 'Joined',
                          isBn ? '${group['name']} গ্রুপে যোগ দেওয়া হয়েছে' : 'Joined ${group['name']} group',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        constraints: const BoxConstraints(
                          minHeight: 48,
                          minWidth: 80,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFd97757),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            isBn ? 'যোগ দিন' : 'Join',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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

  Widget _buildStageFloatingButton(bool isDark, bool isBn) {
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

  Widget _buildFloatingAddButton(bool isDark, bool isBn) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          isBn ? 'শীঘ্রই আসছে' : 'Coming Soon',
          isBn ? 'গ্রুপ তৈরি ফিচার শীঘ্রই আসছে' : 'Create group feature coming soon',
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
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildHelpButton(bool isDark) {
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
