import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stage_models.dart';

class StageCard extends StatelessWidget {
  final StageModel stage;
  final bool isDark;
  final bool isBn;
  final VoidCallback onTap;

  const StageCard({
    super.key,
    required this.stage,
    required this.isDark,
    required this.isBn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFEBEBEB),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (stage.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8DED6),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      stage.category,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (stage.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(13),
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stage.title,
              style: GoogleFonts.notoSansBengali(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildHostAvatar(stage.hostName),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.hostName,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${stage.listenersCount} ${isBn ? 'শ্রোতা' : 'listeners'}',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 12,
                              color: const Color(0xFF9D9D9D),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '⊙',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stage.durationText,
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 12,
                              color: const Color(0xFF9D9D9D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFd97757),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    isBn ? 'স্টেজে যোগ দিন' : 'Join Stage',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostAvatar(String hostName) {
    final initial = hostName.isNotEmpty ? hostName[0].toUpperCase() : '?';
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFd97757),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
