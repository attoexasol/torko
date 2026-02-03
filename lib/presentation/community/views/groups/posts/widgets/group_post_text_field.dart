import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupPostTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? error;
  final int maxLines;
  final int? maxLength;

  const GroupPostTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.error,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    const isDark = true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansBengali(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB8DED6),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: GoogleFonts.notoSansBengali(fontSize: 15, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSansBengali(
              color: const Color(0xFFB8DED6).withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: const Color(0xFF0d3a4a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null && error!.isNotEmpty ? Colors.red : const Color(0xFF0d3a4a),
              ),
            ),
          ),
        ),
        if (error != null && error!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: GoogleFonts.notoSansBengali(
              fontSize: 12,
              color: Colors.orange.shade300,
            ),
          ),
        ],
      ],
    );
  }
}
