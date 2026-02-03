import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/core/controllers/app_controller.dart';

class GroupPostDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isBn;

  const GroupPostDeleteDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    required this.isBn,
  });

  static void show({
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;
    Get.dialog(
      GroupPostDeleteDialog(onConfirm: onConfirm, onCancel: onCancel, isBn: isBn),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0a2f3d),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isBn ? 'পোস্ট মুছে ফেলুন' : 'Delete Post',
              style: GoogleFonts.notoSansBengali(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isBn
                  ? 'আপনি কি নিশ্চিত যে এই পোস্টটি মুছে ফেলতে চান?'
                  : 'Are you sure you want to delete this post?',
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                color: const Color(0xFFB8DED6).withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                      onCancel?.call();
                    },
                    child: Text(isBn ? 'বাতিল' : 'Cancel', style: const TextStyle(color: Colors.white)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(isBn ? 'মুছে ফেলুন' : 'Delete', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
