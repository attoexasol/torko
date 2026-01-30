import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../controllers/group_detail_controller.dart';
import '../../models/community_group_model.dart';
import '../../widgets/bottom_nav.dart';

const String _baseImageUrl = 'https://torko.attoexasolutions.com/';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String _activeTab = 'post';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    int? id;
    if (args is Map && args['id'] != null) {
      final v = args['id'];
      if (v is int) id = v;
      if (v is num) id = v.toInt();
    }
    if (id == null) {
      Get.back();
      return;
    }
    final c = Get.put(GroupDetailController());
    c.fetchGroup(id);
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final c = Get.find<GroupDetailController>();

    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF052029) : Colors.white,
        body: SafeArea(
          bottom: false,
          child: Obx(() {
            if (c.loading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFd97757)),
              );
            }
            if (c.error.value.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.error.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFB8DED6) : const Color(0xFF555e67),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          final args = Get.arguments;
                          int? id;
                          if (args is Map && args['id'] != null) {
                            final v = args['id'];
                            if (v is int) id = v;
                            if (v is num) id = v.toInt();
                          }
                          if (id != null) c.fetchGroup(id);
                        },
                        child: const Text('Retry', style: TextStyle(color: Color(0xFFd97757))),
                      ),
                    ],
                  ),
                ),
              );
            }
            final group = c.group.value;
            if (group == null) {
              return const SizedBox.shrink();
            }
            return _buildContent(group, isDark, isBn);
          }),
        ),
      );
    });
  }

  Widget _buildContent(CommunityGroupModel group, bool isDark, bool isBn) {
    final cover = group.coverImage != null && group.coverImage!.isNotEmpty
        ? (group.coverImage!.startsWith('http') ? group.coverImage! : '$_baseImageUrl${group.coverImage}')
        : '';

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 280,
          child: cover.isEmpty
              ? Container(
                  color: const Color(0xFFd97757),
                  child: const Center(
                    child: Icon(Icons.people, color: Colors.white54, size: 64),
                  ),
                )
              : Image.network(
                  cover,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    height: 280,
                    color: const Color(0xFFd97757),
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.white54, size: 64),
                    ),
                  ),
                ),
        ),
        Positioned(
          top: 220,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    group.name,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                            '${_formatMembers(group.membersCount)} ${isBn ? 'সদস্য' : 'members'}',
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
                            (group.status ?? 'active') == 'active' ? (isBn ? 'সক্রিয়' : 'Active') : (group.status ?? ''),
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
                  GestureDetector(
                    onTap: () {
                      Get.snackbar(
                        isBn ? 'যোগ দেওয়া হয়েছে' : 'Joined',
                        '${group.name} ${isBn ? 'গ্রুপে যোগ দেওয়া হয়েছে' : 'group joined'}',
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
                  Row(
                    children: [
                      _buildTab('post', isBn ? 'পোস্ট' : 'Post', isDark, isBn),
                      const SizedBox(width: 24),
                      _buildTab('about', isBn ? 'সম্পর্কে' : 'About', isDark, isBn),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFEBEBEB),
                  ),
                  const SizedBox(height: 16),
                  if (_activeTab == 'post') ...[
                    ...(group.posts ?? []).map((p) => _buildPostCard(p, isDark, isBn)),
                  ],
                  if (_activeTab == 'about') _buildAboutContent(group, isDark, isBn),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
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
                  Get.snackbar('Share', 'Share feature coming soon', snackPosition: SnackPosition.BOTTOM);
                },
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildOverlayButton(
                icon: Icons.chat_bubble_outline,
                onTap: () {
                  Get.snackbar('Message', 'Message feature coming soon', snackPosition: SnackPosition.BOTTOM);
                },
                isDark: isDark,
              ),
            ],
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
          child: BottomNav(activeScreen: 'community'),
        ),
      ],
    );
  }

  String _formatMembers(int n) {
    if (n >= 1000) {
      final k = n ~/ 1000;
      final r = n % 1000;
      if (r == 0) return '$k,000';
      return '$k,${r.toString().padLeft(3, '0')}';
    }
    return n.toString();
  }

  Widget _buildTab(String tab, String label, bool isDark, bool isBn) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
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

  Widget _buildPostCard(CommunityGroupPostModel post, bool isDark, bool isBn) {
    final name = post.user?.fullname ?? '';
    final avatar = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final avatarUrl = post.user?.profileImage;
    final timeAgo = _timeAgo(post.createdAt);

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
          Row(
            children: [
              avatarUrl != null && avatarUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        avatarUrl.startsWith('http') ? avatarUrl : '$_baseImageUrl$avatarUrl',
                      ),
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFd97757),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                      name,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
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
          if (post.postTitle.isNotEmpty)
            Text(
              post.postTitle,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          if (post.postTitle.isNotEmpty && post.postDescription.isNotEmpty) const SizedBox(height: 6),
          if (post.postDescription.isNotEmpty)
            Text(
              post.postDescription,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          if (post.postImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.postImages.length,
                itemBuilder: (_, i) {
                  final path = post.postImages[i];
                  final url = path.startsWith('http') ? path : '$_baseImageUrl$path';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFF0d3a4a),
                          child: const Icon(Icons.image, color: Colors.white54),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _pill(
                Icons.favorite_outline,
                '0',
                isDark,
              ),
              const SizedBox(width: 12),
              _pill(
                Icons.chat_bubble_outline,
                '0',
                isDark,
              ),
              const Spacer(),
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

  Widget _pill(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0d3a4a).withValues(alpha: 0.5) : const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFD0D0D0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.7) : const Color(0xFF9D9D9D),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.notoSansBengali(
              fontSize: 12,
              color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.7) : const Color(0xFF9D9D9D),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final d = now.difference(dt);
      if (d.inDays > 365) return '${d.inDays ~/ 365} year${d.inDays >= 730 ? 's' : ''}';
      if (d.inDays > 30) return '${d.inDays ~/ 30} month${d.inDays >= 60 ? 's' : ''}';
      if (d.inDays > 0) return '${d.inDays} day${d.inDays > 1 ? 's' : ''}';
      if (d.inHours > 0) return '${d.inHours} hour${d.inHours > 1 ? 's' : ''}';
      if (d.inMinutes > 0) return '${d.inMinutes} min';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }

  Widget _buildAboutContent(CommunityGroupModel group, bool isDark, bool isBn) {
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
          group.bio ?? '',
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
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }

  Widget _buildHelpButton() {
    return GestureDetector(
      onTap: () {
        Get.snackbar('Help', 'Help feature coming soon', snackPosition: SnackPosition.BOTTOM);
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
