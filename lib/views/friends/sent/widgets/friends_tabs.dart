import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/sent_requests_controller.dart';

/// Sent screen tab colors (local).
class _SentTabsColors {
  static const bgTop = Color(0xFF0a2f3d);
  static const primary = Color(0xFFd97757);
  static const inactiveBg = Color(0xFF0d3a4a);
  static const inactiveText = Color(0xFFB8DED6);
}

/// Segmented tab bar for Sent screen: পাঠানো selected, badge on পাঠানো.
class SentFriendsTabs extends StatelessWidget {
  const SentFriendsTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SentRequestsController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _SentTabsColors.bgTop,
            Color(0xFF052029),
          ],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: [
                _TabPill(
                  icon: Icons.person_add,
                  label: 'সাজেশন',
                  isSelected: c.selectedTab.value == 0,
                  onTap: () => c.selectTab(0),
                ),
                const SizedBox(width: 8),
                _TabPill(
                  icon: Icons.people,
                  label: 'বন্ধুরা',
                  isSelected: c.selectedTab.value == 1,
                  onTap: () => c.selectTab(1),
                ),
                const SizedBox(width: 8),
                _TabPill(
                  icon: Icons.person_add_alt_1,
                  label: 'রিকোয়েস্ট',
                  isSelected: c.selectedTab.value == 2,
                  onTap: () => c.selectTab(2),
                ),
                const SizedBox(width: 8),
                _TabPill(
                  icon: Icons.send,
                  label: 'পাঠানো',
                  isSelected: c.selectedTab.value == 3,
                  onTap: () => c.selectTab(3),
                  badge: c.sentBadgeCount.value > 0 ? c.sentBadgeCount.value : null,
                ),
              ],
            )),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _TabPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _SentTabsColors.primary
                  : _SentTabsColors.inactiveBg,
              borderRadius: BorderRadius.circular(24),
              border: isSelected
                  ? null
                  : Border.all(color: _SentTabsColors.inactiveBg, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : _SentTabsColors.inactiveText,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : _SentTabsColors.inactiveText,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _SentTabsColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF052029), width: 1),
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
            ),
        ],
      ),
    );
  }
}
