import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/models/community_group_model.dart';
import 'edit_group_post_sheet.dart';

class GroupPostOptionsSheet extends StatelessWidget {
  final CommunityGroupPostModel post;
  final void Function(CommunityGroupPostModel post) onDelete;

  const GroupPostOptionsSheet({
    super.key,
    required this.post,
    required this.onDelete,
  });

  static void show({
    required CommunityGroupPostModel post,
    required void Function(CommunityGroupPostModel post) onDelete,
  }) {
    Get.bottomSheet(
      GroupPostOptionsSheet(post: post, onDelete: onDelete),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isRegistered<AppController>() && Get.find<AppController>().isDarkMode;
    final isBn = Get.isRegistered<AppController>() && Get.find<AppController>().language == AppLanguage.bn;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFFd97757)),
              title: Text(
                isBn ? 'সম্পাদনা' : 'Edit',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Get.back();
                EditGroupPostSheet.show(post: post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                isBn ? 'মুছে ফেলুন' : 'Delete',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Get.back();
                onDelete(post);
              },
            ),
          ],
        ),
      ),
    );
  }
}
