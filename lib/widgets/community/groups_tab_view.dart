import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/community_groups_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/community_group_model.dart';

class GroupsTabView extends StatelessWidget {
  final CommunityGroupsController controller;
  final bool isDark;
  final bool isBn;

  const GroupsTabView({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFd97757),
          ),
        );
      }
      if (controller.error.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.error.value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFB8DED6) : const Color(0xFF555e67),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => controller.loadGroups(),
                  child: Text(
                    isBn ? 'আবার চেষ্টা করুন' : 'Retry',
                    style: const TextStyle(color: Color(0xFFd97757)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      final groups = controller.groups;
      if (groups.isEmpty) {
        return Center(
          child: Text(
            isBn ? 'কোনো গ্রুপ নেই' : 'No groups found',
            style: GoogleFonts.notoSansBengali(
              fontSize: 16,
              color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.8) : const Color(0xFF9D9D9D),
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadGroups(),
        color: const Color(0xFFd97757),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          itemCount: groups.length,
          itemBuilder: (context, index) => _buildGroupCard(groups[index]),
        ),
      );
    });
  }

  String _membersLabel(int count) {
    if (isBn && count >= 1000) {
      final k = count ~/ 1000;
      final r = count % 1000;
      if (r == 0) return '$k,০০০';
      return '$k,${r.toString().padLeft(3, '0')}';
    }
    return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _coverUrl(CommunityGroupModel g) => controller.coverImageUrl(g);

  Widget _buildGroupCard(CommunityGroupModel group) {
    final cover = _coverUrl(group);
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.groupDetail, arguments: {'id': group.id});
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: cover.isEmpty
                  ? Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFFd97757),
                      child: const Center(
                        child: Icon(Icons.people, color: Colors.white54, size: 48),
                      ),
                    )
                  : Image.network(
                      cover,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          (group.visibility ?? 'public') == 'public'
                              ? (isBn ? 'সার্বজনীন' : 'Public')
                              : (isBn ? 'ব্যক্তিগত' : 'Private'),
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                : const Color(0xFF555e67),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.bio ?? '',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFB8DED6).withValues(alpha: 0.65)
                          : const Color(0xFF555e67),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: isDark
                                  ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                  : const Color(0xFF9D9D9D),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${_membersLabel(group.membersCount)} ${isBn ? 'সদস্য' : 'members'}',
                                style: GoogleFonts.notoSansBengali(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                      : const Color(0xFF9D9D9D),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
}
