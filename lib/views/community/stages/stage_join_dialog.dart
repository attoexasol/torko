import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
    const isDark = true;
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
                color: const Color(0xFF0a2f3d),
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
                      _buildHeader(),
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

  Widget _buildHeader() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLiveBadge(),
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
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (stage.category.isNotEmpty) _buildCategoryPill(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBadge() {
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

  Widget _buildCategoryPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0d3a4a),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        stage.category,
        style: GoogleFonts.notoSansBengali(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFB8DED6),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage.title,
            style: GoogleFonts.notoSansBengali(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0d3a4a),
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
                    color: Colors.white,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0d3a4a),
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
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF052029),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        isBn
            ? 'এই স্টেজে যোগ দিয়ে আপনি হোস্ট এবং অন্যান্য শ্রোতাদের সাথে লাইভ অডিও কথোপকথনে অংশ নিতে পারবেন। আপনার মাইক্রোফোন ডিফল্টভাবে বন্ধ থাকবে।'
            : 'By joining this stage, you can participate in live audio conversation with the host and other listeners. Your microphone will be muted by default.',
        style: GoogleFonts.notoSansBengali(
          fontSize: 13,
          color: const Color(0xFFB8DED6).withValues(alpha: 0.8),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0d3a4a),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF0d3a4a)),
              ),
              child: Center(
                child: Text(
                  isBn ? 'বাতিল' : 'Cancel',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB8DED6),
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
