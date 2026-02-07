import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centered empty state with icon and message.
class FriendsEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;

  const FriendsEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark
                  ? const Color(0xFF0d3a4a)
                  : const Color(0xFFd0d0d0),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                    : const Color(0xFF657786),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
