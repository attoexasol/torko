import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torko/core/controllers/app_controller.dart';

/// Delete Group confirmation dialog - matches app theme. onConfirm is async; shows loader on Delete button.
class GroupDeleteDialog extends StatefulWidget {
  final Future<void> Function() onConfirm;
  final VoidCallback? onCancel;
  final bool isBn;

  const GroupDeleteDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    required this.isBn,
  });

  static void show({
    required Future<void> Function() onConfirm,
    VoidCallback? onCancel,
  }) {
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;
    Get.dialog(
      GroupDeleteDialog(
        onConfirm: onConfirm,
        onCancel: onCancel,
        isBn: isBn,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<GroupDeleteDialog> createState() => _GroupDeleteDialogState();
}

class _GroupDeleteDialogState extends State<GroupDeleteDialog> {
  bool _deleting = false;

  Future<void> _handleConfirm() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await widget.onConfirm();
      if (mounted) Get.back();
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      final isBn = widget.isBn;
      Get.snackbar(
        isBn ? '⚠️ মুছে ফেলা যায়নি' : '⚠️ Delete failed',
        msg,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = widget.isBn;
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
              isBn ? 'গ্রুপ মুছে ফেলুন' : 'Delete Group',
              style: GoogleFonts.notoSansBengali(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isBn
                  ? 'আপনি কি নিশ্চিত যে এই গ্রুপটি মুছে ফেলতে চান? এই কাজটি পূর্বাবস্থায় ফিরানো যাবে না।'
                  : 'Are you sure you want to delete this group? This action cannot be undone.',
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
                    onTap: _deleting
                        ? null
                        : () {
                            Get.back();
                            widget.onCancel?.call();
                          },
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
                    onTap: _deleting ? null : _handleConfirm,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _deleting
                          ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                isBn ? 'মুছে ফেলুন' : 'Delete',
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
