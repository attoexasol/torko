import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/controllers/app_controller.dart';

/// End Stage confirmation dialog - match screenshot.
class EndStageDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isBn;

  const EndStageDialog({
    super.key,
    required this.onConfirm,
    required this.isBn,
  });

  static void show({required VoidCallback onConfirm}) {
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;
    Get.dialog(
      EndStageDialog(onConfirm: onConfirm, isBn: isBn),
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
              isBn ? 'স্টেজ শেষ করুন' : 'End Stage',
              style: GoogleFonts.notoSansBengali(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isBn ? 'আপনি কি নিশ্চিত যে এই স্টেজ শেষ করতে চান?' : 'Are you sure you want to end this stage?',
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
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          isBn ? 'বাতিল' : 'Cancel',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onConfirm();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          isBn ? 'নিশ্চিত' : 'Confirm',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    );
  }
}
