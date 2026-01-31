import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/controllers/app_controller.dart';
import '../widgets/listener_tile.dart';
import '../widgets/speaker_tile.dart';
import 'end_stage_confirm_dialog.dart';

class StageRoomView extends StatelessWidget {
  const StageRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final title = args['title']?.toString() ?? 'Stage';
    final description = args['description']?.toString() ?? '';
    final category = args['category']?.toString() ?? 'general';

    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;

    return Scaffold(
      backgroundColor: const Color(0xFF052029),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(title, description, category, isBn),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      isBn ? 'স্পিকার (1)' : 'Speakers (1)',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SpeakerTile(
                      initial: 'Y',
                      label: 'You (Host)',
                      isHost: true,
                      isSpeaking: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isBn ? 'শ্রোতা (3)' : 'Listeners (3)',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenerTile(
                      initial: 'S',
                      name: isBn ? 'সাদিয়া আহমেদ' : 'Sadia Ahmed',
                      handRaised: false,
                      onInvite: () {},
                      isBn: isBn,
                    ),
                    ListenerTile(
                      initial: 'T',
                      name: isBn ? 'তানভীর রহমান' : 'Tanvir Rahman',
                      handRaised: true,
                      onInvite: () {},
                      isBn: isBn,
                    ),
                    ListenerTile(
                      initial: 'N',
                      name: isBn ? 'নুসরাত জাহান' : 'Nusrat Jahan',
                      handRaised: false,
                      onInvite: () {},
                      isBn: isBn,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(isBn),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String description, String category, bool isBn) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              const SizedBox(width: 8),
              const Icon(Icons.people_outline, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                '4',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Get.snackbar(isBn ? 'শেয়ার' : 'Share', 'Share feature coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
                icon: const Icon(Icons.share, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
                      title,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          color: const Color(0xFFB8DED6).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0d3a4a),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: const Color(0xFFB8DED6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isBn) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0a2f3d),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.snackbar(isBn ? 'মিউট' : 'Mute', 'Mute toggled',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0d3a4a),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'মিউট' : 'Mute',
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
          const Spacer(),
          GestureDetector(
            onTap: () => EndStageConfirmDialog.show(isBn: isBn),
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
                    isBn ? 'স্টেজ শেষ করুন' : 'End Stage',
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
