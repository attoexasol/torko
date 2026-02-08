import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/sent_requests_controller.dart';
import '../model/sent_request_model.dart';

/// Sent request card colors (local).
class _SentCardColors {
  static const card = Color(0xFF0d3a4a);
  static const cardBorder = Color(0xFF104050);
  static const chipBg = Color(0xFF0a2f3d);
  static const primary = Color(0xFFd97757);
  static const danger = Color(0xFFff4d4f);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textMuted = Color(0xA6FFFFFF);
}

/// Sent request card: avatar, name, username, location, status chip, cancel button.
class SentRequestCard extends StatelessWidget {
  final SentRequestModel model;

  const SentRequestCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SentRequestsController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _SentCardColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _SentCardColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _SentCardColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.displayUsername,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 13,
                        color: _SentCardColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (model.location != null && model.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: _SentCardColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              model.location!,
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 12,
                                color: _SentCardColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'রিকোয়েস্ট পাঠানো হয়েছে',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 11,
                        color: _SentCardColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => c.onCancelRequest(model),
              icon: Icon(Icons.close, size: 20, color: _SentCardColors.danger),
              label: Text(
                'রিকোয়েস্ট বাতিল করুন',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _SentCardColors.danger,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _SentCardColors.danger,
                side: const BorderSide(color: _SentCardColors.danger, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        color: _SentCardColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          model.initials,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _SentCardColors.chipBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _SentCardColors.cardBorder, width: 1),
      ),
      child: Text(
        'অপেক্ষমান',
        style: GoogleFonts.notoSansBengali(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _SentCardColors.primary,
        ),
      ),
    );
  }
}
