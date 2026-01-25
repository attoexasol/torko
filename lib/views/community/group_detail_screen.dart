import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/routes/app_routes.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String _activeTab = 'post'; // 'post' | 'about'

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final group = Get.arguments as Map<String, dynamic>? ?? {};

    // Mock data for posts
    final List<Map<String, dynamic>> mockPosts = [
      {
        'authorName': 'ক্রিশ্চিয়ান রামিরেজ',
        'avatar': 'C',
        'timeAgo': '১ বছর',
        'content': 'হ্যালো গেমাররা। ঢাকায় পাওয়া এই দুর্দান্ত গেমিং চ্যানেলটি দেখুন। কে কে খেলতে আগ্রহী?',
        'likeCount': '1.2k',
        'commentCount': '89',
      },
      {
        'authorName': 'সারা আহমেদ',
        'avatar': 'স',
        'timeAgo': '২ দিন',
        'content': 'আগামীকাল কে সন্ধ্যা ৭টায় বোর্ড গেম নাইটের জন্য প্রস্তুত? আমি কিছু নতুন গেম এনেছি! সবাইকে স্বাগতম।',
        'likeCount': '245',
        'commentCount': '12',
      },
      {
        'authorName': 'আহমেদ হাসান',
        'avatar': 'আ',
        'timeAgo': '৩ দিন',
        'content': 'এই সপ্তাহে আমাদের গ্রুপ মিটআপ হবে। কে কে আসবেন?',
        'likeCount': '567',
        'commentCount': '34',
      },
    ];

    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF052029) : Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Cover Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 280,
                child: Image.network(
                  group['image']?.toString() ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    height: 280,
                    width: double.infinity,
                    color: const Color(0xFFd97757),
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.white54, size: 64),
                    ),
                  ),
                ),
              ),
              // Scrollable Content Panel
              Positioned(
                top: 220,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          group['name']?.toString() ?? 'বাংলাদেশ টেক কমিউনিটি',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Meta Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                      : const Color(0xFF9D9D9D),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${group['members'] ?? '২৫,০০০'} ${isBn ? 'সদস্য' : 'members'}',
                                  style: GoogleFonts.notoSansBengali(
                                    fontSize: 13,
                                    color: isDark
                                        ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                        : const Color(0xFF9D9D9D),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                      : const Color(0xFF9D9D9D),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isBn ? 'সক্রিয়' : 'Active',
                                  style: GoogleFonts.notoSansBengali(
                                    fontSize: 13,
                                    color: isDark
                                        ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                        : const Color(0xFF9D9D9D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Join Button
                        GestureDetector(
                          onTap: () {
                            Get.snackbar(
                              isBn ? 'যোগ দেওয়া হয়েছে' : 'Joined',
                              isBn
                                  ? '${group['name']} গ্রুপে যোগ দেওয়া হয়েছে'
                                  : 'Joined ${group['name']} group',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFd97757),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                isBn ? 'যোগ দিন' : 'Join',
                                style: GoogleFonts.notoSansBengali(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Tabs Bar
                        Row(
                          children: [
                            _buildTab(
                              label: isBn ? 'পোস্ট' : 'Post',
                              isActive: _activeTab == 'post',
                              isDark: isDark,
                              isBn: isBn,
                              onTap: () => setState(() => _activeTab = 'post'),
                            ),
                            const SizedBox(width: 24),
                            _buildTab(
                              label: isBn ? 'সম্পর্কে' : 'About',
                              isActive: _activeTab == 'about',
                              isDark: isDark,
                              isBn: isBn,
                              onTap: () => setState(() => _activeTab = 'about'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Divider
                        Container(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF0d3a4a)
                              : const Color(0xFFEBEBEB),
                        ),
                        const SizedBox(height: 16),
                        // Content based on active tab
                        if (_activeTab == 'post')
                          ...mockPosts.map((post) => _buildPostCard(
                                post,
                                isDark,
                                isBn,
                              )),
                        if (_activeTab == 'about')
                          _buildAboutContent(isDark, isBn),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ),
              // Top Overlay Buttons
              Positioned(
                top: 40,
                left: 16,
                child: _buildOverlayButton(
                  icon: Icons.arrow_back,
                  onTap: () => Get.back(),
                  isDark: isDark,
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: Row(
                  children: [
                    _buildOverlayButton(
                      icon: Icons.share_outlined,
                      onTap: () {
                        Get.snackbar(
                          'Share',
                          'Share feature coming soon',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildOverlayButton(
                      icon: Icons.chat_bubble_outline,
                      onTap: () {
                        Get.snackbar(
                          'Message',
                          'Message feature coming soon',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              // Help Button
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
                  activeScreen: 'community',
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTab({
    required String label,
    required bool isActive,
    required bool isDark,
    required bool isBn,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansBengali(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFFd97757)
                  : (isDark
                      ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                      : const Color(0xFF9D9D9D)),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isActive ? 40 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFFd97757),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    Map<String, dynamic> post,
    bool isDark,
    bool isBn,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF083140) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row (Avatar + Name + Time + Menu)
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFd97757),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post['avatar'].toString(),
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['authorName'].toString(),
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post['timeAgo'].toString(),
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                            : const Color(0xFF9D9D9D),
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Icon
              Icon(
                Icons.more_vert,
                color: isDark
                    ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                    : const Color(0xFF9D9D9D),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Post Content
          Text(
            post['content'].toString(),
            style: GoogleFonts.notoSansBengali(
              fontSize: 15,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Row (Like + Comment + Share)
          Row(
            children: [
              // Like Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0d3a4a).withValues(alpha: 0.5)
                      : const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF0d3a4a)
                        : const Color(0xFFD0D0D0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 14,
                      color: isDark
                          ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                          : const Color(0xFF9D9D9D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post['likeCount'].toString(),
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                            : const Color(0xFF9D9D9D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Comment Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0d3a4a).withValues(alpha: 0.5)
                      : const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF0d3a4a)
                        : const Color(0xFFD0D0D0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: isDark
                          ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                          : const Color(0xFF9D9D9D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post['commentCount'].toString(),
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                            : const Color(0xFF9D9D9D),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Share Button
              Row(
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: 16,
                    color: isDark
                        ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                        : const Color(0xFF9D9D9D),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBn ? 'শেয়ার' : 'Share',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                          : const Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutContent(bool isDark, bool isBn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'সম্পর্কে' : 'About',
          style: GoogleFonts.notoSansBengali(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isBn
              ? 'বাংলাদেশ টেক কমিউনিটি একটি উন্মুক্ত প্ল্যাটফর্ম যেখানে প্রযুক্তি উৎসাহীরা একত্রিত হয়ে জ্ঞান বিনিময়, নেটওয়ার্কিং এবং সহযোগিতা করতে পারে।'
              : 'Bangladesh Tech Community is an open platform where tech enthusiasts come together to share knowledge, network, and collaborate.',
          style: GoogleFonts.notoSansBengali(
            fontSize: 14,
            color: isDark
                ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                : const Color(0xFF555e67),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 22,
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
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
