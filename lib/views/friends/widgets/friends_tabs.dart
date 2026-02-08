import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Friends module colors (local).
class _FriendsTabColors {
  static const bg = Color(0xFF052029);
  static const primary = Color(0xFFd97757);
  static const inactiveBg = Color(0xFF0d3a4a);
  static const inactiveText = Color(0xFFB8DED6);
}

/// Segmented tab bar: সাজেশন, বন্ধুরা, রিকোয়েস্ট, পাঠানো.
/// Badge "3" only on রিকোয়েস্ট.
class FriendsTabs extends StatelessWidget {
  final RxString selectedTab;
  final int requestBadgeCount;

  const FriendsTabs({
    super.key,
    required this.selectedTab,
    this.requestBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _FriendsTabColors.bg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: [
                _TabPill(
                  label: 'সাজেশন',
                  isSelected: selectedTab.value == 'suggestions',
                  onTap: () => selectedTab.value = 'suggestions',
                ),
                const SizedBox(width: 8),
                _TabPill(
                  label: 'বন্ধুরা',
                  isSelected: selectedTab.value == 'friends',
                  onTap: () => selectedTab.value = 'friends',
                ),
                const SizedBox(width: 8),
                _TabPill(
                  label: 'রিকোয়েস্ট',
                  isSelected: selectedTab.value == 'requests',
                  onTap: () => selectedTab.value = 'requests',
                  badge: requestBadgeCount > 0 ? requestBadgeCount : null,
                ),
                const SizedBox(width: 8),
                _TabPill(
                  label: 'পাঠানো',
                  isSelected: selectedTab.value == 'sent',
                  onTap: () => selectedTab.value = 'sent',
                ),
              ],
            )),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _FriendsTabColors.primary
              : _FriendsTabColors.inactiveBg,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(color: _FriendsTabColors.inactiveBg, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : _FriendsTabColors.inactiveText,
              ),
            ),
            if (badge != null && badge! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _FriendsTabColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge! > 9 ? '9+' : '$badge',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
