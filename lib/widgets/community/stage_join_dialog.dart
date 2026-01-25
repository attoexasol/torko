import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';

class StageJoinDialog extends StatelessWidget {
  final Map<String, dynamic> stage;

  const StageJoinDialog({
    super.key,
    required this.stage,
  });

  static void show(BuildContext context, Map<String, dynamic> stage) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: isBn ? 'স্টেজ যোগ দিন' : 'Join Stage',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: StageJoinDialog(stage: stage),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final isDark = appController.isDarkMode;
    final isBn = appController.language == AppLanguage.bn;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.86,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section (Salmon/Orange)
            _buildHeader(context, isDark, isBn),
            // Body Section (Dark Teal)
            _buildBody(context, isDark, isBn),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isBn) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFFd97757),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Stack(
        children: [
          // Top-left: Live Badge
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(999),
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
          ),
          // Top-right: Close Button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
          // Category Pill (below live badge)
          Positioned(
            top: 32,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                stage['category']?.toString() ?? (isBn ? 'ব্যবসা' : 'Business'),
                style: GoogleFonts.notoSansBengali(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, bool isBn) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
      ),
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              stage['title']?.toString() ?? (isBn ? 'স্টার্টআপ সাফল্যের গোপন কথা' : 'Startup Success Secrets'),
              style: GoogleFonts.notoSansBengali(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            // Host Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFd97757),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (stage['hostName']?.toString() ?? 'H')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Host Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['hostName']?.toString() ?? 'Rifat Hassan',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isBn ? 'হোস্ট • @${stage['hostUsername'] ?? 'rifat_h'}' : 'Host • @${stage['hostUsername'] ?? 'rifat_h'}',
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
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: isBn ? 'যোগদান' : 'Joined',
                    value: stage['joinedCount']?.toString() ?? '২৩৪',
                    isDark: isDark,
                    isBn: isBn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: isBn ? 'সময়' : 'Time',
                    value: stage['duration']?.toString() ?? '৪৫ মিনিট',
                    isDark: isDark,
                    isBn: isBn,
                    showIcon: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Info Text Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF052029) : const Color(0xFFEBEBEB),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                isBn
                    ? 'এই স্টেজে যোগ দিয়ে আপনি হোস্ট এবং অন্যান্য শ্রোতাদের সাথে লাইভ অডিও কথোপকথনে অংশ নিতে পারবেন। আপনার মাইক্রোফোন ডিফল্টভাবে বন্ধ থাকবে।'
                    : 'By joining this stage, you can participate in live audio conversations with the host and other listeners. Your microphone will be off by default.',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                      : const Color(0xFF555e67),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Bottom Actions Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF0d3a4a)
                              : const Color(0xFFD0D0D0),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isBn ? 'বাতিল' : 'Cancel',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
                                : const Color(0xFF555e67),
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
                      Navigator.of(context).pop();
                      Get.snackbar(
                        isBn ? 'স্টেজে যোগ দেওয়া হয়েছে' : 'Joined Stage',
                        isBn
                            ? '${stage['title']} স্টেজে যোগ দেওয়া হয়েছে'
                            : 'Joined ${stage['title']} stage',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFd97757),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          isBn ? 'এখনই যোগ দিন' : 'Join Now',
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

  Widget _buildStatCard({
    required String label,
    required String value,
    required bool isDark,
    required bool isBn,
    bool showIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showIcon) ...[
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isDark
                      ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                      : const Color(0xFF9D9D9D),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFFB8DED6).withValues(alpha: 0.7)
                      : const Color(0xFF9D9D9D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.notoSansBengali(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
