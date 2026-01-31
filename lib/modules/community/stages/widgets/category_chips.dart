import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChips extends StatelessWidget {
  final String selected;
  final bool isBn;
  final ValueChanged<String> onSelected;

  static const List<Map<String, String>> _categories = [
    {'id': 'general', 'en': 'General', 'bn': 'সাধারণ'},
    {'id': 'tech', 'en': 'Tech', 'bn': 'প্রযুক্তি'},
    {'id': 'business', 'en': 'Business', 'bn': 'ব্যবসা'},
    {'id': 'education', 'en': 'Education', 'bn': 'শিক্ষা'},
    {'id': 'entertainment', 'en': 'Entertainment', 'bn': 'বিনোদন'},
    {'id': 'sports', 'en': 'Sports', 'bn': 'খেলাধুলা'},
  ];

  const CategoryChips({
    super.key,
    required this.selected,
    required this.isBn,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((c) {
        final id = c['id']!;
        final label = isBn ? c['bn']! : c['en']!;
        final isActive = selected == id;
        return GestureDetector(
          onTap: () => onSelected(id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFd97757) : const Color(0xFF0d3a4a),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: GoogleFonts.notoSansBengali(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
