import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/community/controllers/group_members_controller.dart';
import 'package:torko/data/models/group_member_model.dart';

const String _baseImageUrl = 'https://torko.attoexasolutions.com/';

/// Bottom sheet showing group members. Admin sees Approve/Remove; members list from API.
class GroupMembersSheet extends StatefulWidget {
  final int groupId;
  final bool isAdmin;

  const GroupMembersSheet({
    super.key,
    required this.groupId,
    this.isAdmin = true,
  });

  static void show({required int groupId, bool isAdmin = true}) {
    Get.bottomSheet(
      GroupMembersSheet(groupId: groupId, isAdmin: isAdmin),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  State<GroupMembersSheet> createState() => _GroupMembersSheetState();
}

class _GroupMembersSheetState extends State<GroupMembersSheet> {
  String _filter = 'all'; // all | pending | approved

  @override
  void initState() {
    super.initState();
    Get.put(GroupMembersController(widget.groupId), tag: 'group_members_${widget.groupId}');
    Get.find<GroupMembersController>(tag: 'group_members_${widget.groupId}').loadMembers();
  }

  GroupMembersController get _ctrl =>
      Get.find<GroupMembersController>(tag: 'group_members_${widget.groupId}');

  List<GroupMemberModel> get _filteredMembers {
    final list = _ctrl.members;
    if (_filter == 'pending') return list.where((m) => m.status == 'pending').toList();
    if (_filter == 'approved') return list.where((m) => m.status == 'approved').toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final isDark = appController.isDarkMode;
    final isBn = appController.language == AppLanguage.bn;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'সদস্য' : 'Members',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Obx(() => Text(
                        '${_ctrl.totalMembers.value}',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                              : const Color(0xFF9D9D9D),
                        ),
                      )),
                ],
              ),
            ),
            if (widget.isAdmin) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildChip('all', isBn ? 'সব' : 'All', isDark),
                    const SizedBox(width: 8),
                    _buildChip('pending', isBn ? 'অপেক্ষমান' : 'Pending', isDark),
                    const SizedBox(width: 8),
                    _buildChip('approved', isBn ? 'অনুমোদিত' : 'Approved', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Obx(() {
              if (_ctrl.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFd97757)),
                  ),
                );
              }
              final items = _filteredMembers;
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    isBn ? 'কোন সদস্য নেই' : 'No members',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 15,
                      color: isDark
                          ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                          : const Color(0xFF9D9D9D),
                    ),
                  ),
                );
              }
              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _buildMemberRow(items[i], isDark, isBn),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String value, String label, bool isDark) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFd97757)
              : (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSansBengali(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : (isDark ? const Color(0xFFB8DED6) : const Color(0xFF555e67)),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberRow(GroupMemberModel member, bool isDark, bool isBn) {
    final name = member.user.fullname?.trim();
    final displayName = (name != null && name.isNotEmpty) ? name : (isBn ? 'অজানা' : 'Unknown');
    final avatarUrl = member.user.profileImage;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final imageUrl = avatarUrl != null && avatarUrl.isNotEmpty
        ? (avatarUrl.startsWith('http') ? avatarUrl : '$_baseImageUrl$avatarUrl')
        : null;

    final joinedStr = member.createdAt != null
        ? '${isBn ? 'যোগদান' : 'Joined'}: ${_formatDate(member.createdAt!)}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF083140) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          imageUrl != null
              ? CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(imageUrl),
                  onBackgroundImageError: (o, s) {},
                )
              : Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFd97757),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: member.status == 'approved'
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.status == 'approved'
                            ? (isBn ? 'অনুমোদিত' : 'Approved')
                            : (isBn ? 'অপেক্ষমান' : 'Pending'),
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (joinedStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    joinedStr,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                          : const Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.isAdmin) ...[
            if (member.status == 'pending')
              Obx(() {
                final approving = _ctrl.isApprovingIds.contains(member.id);
                return GestureDetector(
                  onTap: approving
                      ? null
                      : () => _ctrl.approve(member.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd97757).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: approving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isBn ? 'অনুমোদন' : 'Approve',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),
            if (member.status == 'pending') const SizedBox(width: 8),
            Obx(() {
              final deleting = _ctrl.isDeletingIds.contains(member.id);
              return GestureDetector(
                onTap: deleting ? null : () => _ctrl.remove(member.id),
                child: deleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFd97757),
                        ),
                      )
                    : Icon(
                        Icons.person_remove_outlined,
                        size: 22,
                        color: Colors.red.shade400,
                      ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
