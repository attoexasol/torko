import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListenerTile extends StatelessWidget {
  final String initial;
  final String name;
  final bool handRaised;
  final VoidCallback onInvite;
  final bool isBn;

  const ListenerTile({
    super.key,
    required this.initial,
    required this.name,
    required this.handRaised,
    required this.onInvite,
    this.isBn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0d3a4a),
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
                initial.toUpperCase(),
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
                    color: Colors.white,
                  ),
                ),
                if (handRaised) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '🙌',
                        style: GoogleFonts.notoSansBengali(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBn ? 'হাত তুলেছে' : 'Hand raised',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: const Color(0xFFB8DED6).withValues(alpha: 0.8),
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
              onTap: onInvite,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFd97757),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isBn ? 'স্পিকার করুন' : 'Invite to Speak',
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
}
