import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImagePickerStrip extends StatelessWidget {
  final VoidCallback onAddTap;
  final List<String> base64Images;
  final void Function(int index) onRemove;
  final int maxCount;
  final bool disabled;

  const ImagePickerStrip({
    super.key,
    required this.onAddTap,
    required this.base64Images,
    required this.onRemove,
    this.maxCount = 5,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final count = base64Images.length;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Photos',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB8DED6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count/$maxCount',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 12,
                  color: const Color(0xFFB8DED6).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (count < maxCount)
                  GestureDetector(
                    onTap: disabled ? null : onAddTap,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0d3a4a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: disabled ? Colors.white38 : const Color(0xFFB8DED6).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ...List.generate(count, (i) {
                  final data = base64Images[i];
                  return _ThumbnailTile(
                    dataUri: data,
                    onRemove: () => onRemove(i),
                    disabled: disabled,
                  );
                }),
              ],
            ),
          ),
        ],
      );
  }
}

class _ThumbnailTile extends StatelessWidget {
  final String dataUri;
  final VoidCallback onRemove;
  final bool disabled;

  const _ThumbnailTile({
    required this.dataUri,
    required this.onRemove,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(),
          ),
          if (!disabled)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    try {
      if (dataUri.startsWith('data:image')) {
        final parts = dataUri.split(',');
        if (parts.length >= 2) {
          final bytes = _decodeBase64(parts[1].trim());
          if (bytes != null) {
            return Image.memory(
              bytes,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            );
          }
        }
      }
    } catch (_) {}
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFF0d3a4a),
      child: const Icon(Icons.image, color: Colors.white54),
    );
  }

  Uint8List? _decodeBase64(String s) {
    try {
      return Uint8List.fromList(base64Decode(s));
    } catch (_) {
      return null;
    }
  }
}
