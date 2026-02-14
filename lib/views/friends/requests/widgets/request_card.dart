import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/friends_requests_controller.dart';
import '../model/friend_request_model.dart';

/// Request card colors (local).
class _RequestCardColors {
  static const card = Color(0xFF0d3a4a);
  static const cardBorder = Color(0xFF104050);
  static const primary = Color(0xFFd97757);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textMuted = Color(0xA6FFFFFF); // white 0.65 opacity
}

/// Friend request card: avatar, name, location, mutual friends, Accept + Reject buttons.
class RequestCard extends StatelessWidget {
  final FriendRequestModel model;

  const RequestCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('PendingRequest userId=${model.userId} requestId=${model.requestId}');
    }
    final c = Get.find<FriendsRequestsController>();
    final isAccepting = c.acceptingIds.contains(model.requestId);
    final isRejecting = c.rejectingIds.contains(model.requestId);
    final isBusy = isAccepting || isRejecting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _RequestCardColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _RequestCardColors.cardBorder, width: 1),
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
                        color: _RequestCardColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (model.location != null && model.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        model.location!,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 13,
                          color: _RequestCardColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${model.mutualFriends} মিউচুয়াল বন্ধু',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 12,
                        color: _RequestCardColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : () => c.onAccept(model),
                    icon: isAccepting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 20, color: Colors.white),
                    label: isAccepting
                        ? const SizedBox.shrink()
                        : Text(
                            'গ্রহন করুন',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _RequestCardColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : () => c.onReject(model),
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: _RequestCardColors.textMuted,
                    ),
                    label: Text(
                      'প্রত্যাখান',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _RequestCardColors.textMuted,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _RequestCardColors.textMuted,
                      side: BorderSide(
                        color: _RequestCardColors.cardBorder,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
        color: _RequestCardColors.primary,
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
}
