import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/local_community_controller.dart';
import '../../core/theme/app_colors.dart';

class CommunityTabs extends StatelessWidget {
  final CommunityTab activeTab;
  final ValueChanged<CommunityTab> onChange;
  final bool isDark;
  final bool isBn;

  const CommunityTabs({
    super.key,
    required this.activeTab,
    required this.onChange,
    required this.isDark,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF052029) : AppColors.lightBackground,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFfafafa),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                CommunityTab.stages,
                isBn ? 'স্টেজ' : 'Stages',
                Icons.radio,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                CommunityTab.groups,
                isBn ? 'গ্রুপ' : 'Groups',
                Icons.people,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(CommunityTab tab, String label, IconData icon) {
    final isActive = activeTab == tab;
    return GestureDetector(
      onTap: () => onChange(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFd97757) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.white
                  : (isDark ? const Color(0xFF9d9d9d) : const Color(0xFF9d9d9d)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.notoSansBengali(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : (isDark ? const Color(0xFF9d9d9d) : const Color(0xFF9d9d9d)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
