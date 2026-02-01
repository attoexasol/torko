import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/controllers/app_controller.dart';
import 'stage_models.dart';
import 'stage_controller.dart';
import 'end_stage_dialog.dart';

class StageRoomView extends StatelessWidget {
  final StageModel stage;

  const StageRoomView({
    super.key,
    required this.stage,
  });

  bool get _isBn =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().language == AppLanguage.bn;

  bool get _isDark =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().isDarkMode;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDark ? const Color(0xFF052029) : Colors.white;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildStageInfo(),
                          const SizedBox(height: 24),
                          _buildSpeakersSection(),
                          const SizedBox(height: 24),
                          _buildListenersSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final iconColor = _isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: iconColor),
          ),
          Container(
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
                  _isBn ? 'লাইভ' : 'LIVE',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.people_outline, color: iconColor, size: 18),
          const SizedBox(width: 4),
          Text(
            '4',
            style: GoogleFonts.notoSansBengali(
              fontSize: 14,
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Get.snackbar(
                _isBn ? 'শেয়ার' : 'Share',
                'Share feature coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: Icon(Icons.share, color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStageInfo() {
    final titleColor = _isDark ? Colors.white : const Color(0xFF1A1A1A);
    final descColor = _isDark
        ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
        : const Color(0xFF6B7280);
    final categoryBg = _isDark ? const Color(0xFF0d3a4a) : const Color(0xFFFEF6F4);
    final categoryTextColor = _isDark ? const Color(0xFFB8DED6) : const Color(0xFFd97757);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFd97757),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.radio, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
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
              ),
              if (stage.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  stage.description,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 14,
                    color: descColor,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stage.category.toLowerCase(),
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 12,
                    color: categoryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakersSection() {
    final initial = stage.hostName.isNotEmpty ? stage.hostName[0].toUpperCase() : 'Y';
    final textColor = _isDark ? Colors.white : const Color(0xFF1A1A1A);
    final borderColor = _isDark ? const Color(0xFF0a2f3d) : const Color(0xFFE5E7EB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isBn ? 'স্পিকার (1)' : 'Speakers (1)',
          style: GoogleFonts.notoSansBengali(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFd97757),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 14),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: const Icon(Icons.volume_up, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              _isBn ? 'আপনি (হোস্ট)' : 'You (Host)',
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListenersSection() {
    final listeners = [
      (_isBn ? 'সাদিয়া আহমেদ' : 'Sadia Ahmed', 'S', false),
      (_isBn ? 'তানভীর রহমান' : 'Tanvir Rahman', 'T', true),
      (_isBn ? 'নুসরাত জাহান' : 'Nusrat Jahan', 'N', false),
    ];
    final textColor = _isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isBn ? 'শ্রোতা (3)' : 'Listeners (3)',
          style: GoogleFonts.notoSansBengali(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ...listeners.map(
          (l) => _buildListenerTile(l.$1, l.$2, l.$3),
        ),
      ],
    );
  }

  Widget _buildListenerTile(String name, String initial, bool handRaised) {
    final cardBg = _isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5);
    final nameColor = _isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = _isDark
        ? const Color(0xFFB8DED6).withValues(alpha: 0.8)
        : const Color(0xFF6B7280);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: nameColor,
                  ),
                ),
                if (handRaised) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('🙌', style: GoogleFonts.notoSansBengali(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        _isBn ? 'হাত তুলেছে' : 'Hand raised',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (handRaised)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFd97757),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _isBn ? 'স্পিকার করুন' : 'Invite to Speak',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final barBg = _isDark ? const Color(0xFF0a2f3d) : Colors.white;
    final muteBg = _isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5);
    final muteBorder = _isDark ? Colors.transparent : const Color(0xFFE5E7EB);
    final muteColor = _isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: _isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.snackbar(
                _isBn ? 'মিউট' : 'Mute',
                'Mute toggled',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: muteBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: muteBorder, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: muteColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isBn ? 'মিউট' : 'Mute',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: muteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (Get.isRegistered<StageController>()) {
                Get.find<StageController>().endStageConfirm();
              } else {
                EndStageDialog.show(
                  onConfirm: () {
                    Get.back();
                    Get.back();
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isBn ? 'স্টেজ শেষ করুন' : 'End Stage',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
