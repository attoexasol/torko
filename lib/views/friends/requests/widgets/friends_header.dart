import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Friends module colors (local).
class _FriendsHeaderColors {
  static const bgTop = Color(0xFF0a2f3d);
  static const bgBottom = Color(0xFF052029);
  static const primary = Color(0xFFd97757);
  static const textPrimary = Color(0xFFFFFFFF);
}

/// Header: back button, "বন্ধুরা", count pill "13 জন".
class FriendsHeader extends StatelessWidget {
  final int totalCount;

  const FriendsHeader({super.key, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _FriendsHeaderColors.bgTop,
            _FriendsHeaderColors.bgBottom,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: _FriendsHeaderColors.textPrimary,
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Text(
                  'বন্ধুরা',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _FriendsHeaderColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _FriendsHeaderColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCount জন',
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
