import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'stage_models.dart';
import 'stage_controller.dart';

/// Join Stage dialog - static UI, no Obx, no Pusher. Match screenshot.
class StageJoinDialog extends StatelessWidget {
  final StageModel stage;
  final bool isBn;

  const StageJoinDialog({
    super.key,
    required this.stage,
    required this.isBn,
  });

  static void show(StageModel stage, bool isBn) {
    Get.dialog(
      StageJoinDialog(stage: stage, isBn: isBn),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
    );
  }

  void _onJoinNow() {
    Get.find<StageController>().joinStage(stage);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isRegistered<AppController>() &&
        Get.find<AppController>().isDarkMode;
    final maxW = MediaQuery.of(context).size.width;
    final dialogWidth = (maxW * 0.9).clamp(280.0, 420.0);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(isDark),
                      _buildBody(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFd97757),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  children: [
                    _buildLiveBadge(isDark),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (stage.category.isNotEmpty) _buildCategoryPill(isDark),
            ],
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildLiveBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
    );
  }

  Widget _buildCategoryPill(bool isDark) {
    final bg = Colors.white.withValues(alpha: 0.3);
    final textColor = Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        stage.category,
        style: GoogleFonts.notoSansBengali(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage.title,
            style: GoogleFonts.notoSansBengali(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          _buildHostRow(isDark),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: isBn ? 'শ্রোতা' : 'Listeners',
                  value: '${stage.listenersCount}',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: isBn ? 'সময়' : 'Duration',
                  value: stage.durationText,
                  isDark: isDark,
                  showIcon: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDescriptionBox(isDark),
          const SizedBox(height: 20),
          _buildButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildHostRow(bool isDark) {
    final initial = stage.hostName.isNotEmpty ? stage.hostName[0].toUpperCase() : 'H';
    final cardBg = isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5);
    final nameColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFd97757),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                  stage.hostName,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBn ? 'হোস্ট • @${stage.hostUsername}' : 'Host • @${stage.hostUsername}',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 12,
                    color: const Color(0xFFB8DED6).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required bool isDark,
    bool showIcon = false,
  }) {
    final cardBg = isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5);
    final valueColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
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
                  color: const Color(0xFFB8DED6).withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 12,
                  color: const Color(0xFFB8DED6).withValues(alpha: 0.8),
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
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox(bool isDark) {
    final boxBg = isDark ? const Color(0xFF052029) : const Color(0xFFEBEBEB);
    final textColor = isDark
        ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
        : const Color(0xFF555e67);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        isBn
            ? 'এই স্টেজে যোগ দিয়ে আপনি হোস্ট এবং অন্যান্য শ্রোতাদের সাথে লাইভ অডিও কথোপকথনে অংশ নিতে পারবেন। আপনার মাইক্রোফোন ডিফল্টভাবে বন্ধ থাকবে।'
            : 'By joining this stage, you can participate in live audio conversation with the host and other listeners. Your microphone will be muted by default.',
        style: GoogleFonts.notoSansBengali(
          fontSize: 13,
          color: textColor,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildButtons(bool isDark) {
    final cancelBg = isDark ? const Color(0xFF0d3a4a) : Colors.transparent;
    final cancelBorder = isDark ? const Color(0xFF0d3a4a) : const Color(0xFFD0D0D0);
    final cancelColor = isDark ? const Color(0xFFB8DED6) : const Color(0xFF555e67);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: cancelBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cancelBorder, width: 1.5),
              ),
              child: Center(
                child: Text(
                  isBn ? 'বাতিল' : 'Cancel',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cancelColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _onJoinNow,
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
    );
  }
}
