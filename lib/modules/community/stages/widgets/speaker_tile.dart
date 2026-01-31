import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeakerTile extends StatelessWidget {
  final String initial;
  final String label;
  final bool isHost;
  final bool isSpeaking;

  const SpeakerTile({
    super.key,
    required this.initial,
    required this.label,
    this.isHost = false,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  initial.toUpperCase(),
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isHost)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0a2f3d), width: 2),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 14),
                ),
              ),
            if (isSpeaking)
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0a2f3d), width: 2),
                  ),
                  child: const Icon(Icons.volume_up, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.notoSansBengali(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
