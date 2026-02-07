import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/data/models/friend_user.dart';
import 'package:torko/presentation/friends/controllers/friends_controller.dart';

/// Request card with Accept (orange) and Decline (outline) buttons.
class FriendRequestCard extends StatelessWidget {
  final FriendRequestItem request;
  final bool isDark;
  final bool isBn;

  const FriendRequestCard({
    super.key,
    required this.request,
    required this.isDark,
    required this.isBn,
  });

  static const _baseUrl = 'https://torko.attoexasolutions.com/';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FriendsController>();
    final user = request.user;
    final isAccepting = controller.isAcceptingByRequestId[request.requestId] == true;
    final isRejecting = controller.isRejectingByRequestId[request.requestId] == true;
    final isBusy = isAccepting || isRejecting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe0e0e0),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(user, 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0f1419),
                      ),
                    ),
                    if (user.displayUsername.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.displayUsername,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                              : const Color(0xFF657786),
                        ),
                      ),
                    ],
                    if (user.address != null && user.address!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.address!,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                              : const Color(0xFF657786),
                        ),
                      ),
                    ],
                    if (user.mutualFriends > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${user.mutualFriends} ${isBn ? 'মিউচুয়াল বন্ধু' : 'mutual friends'}',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFB8DED6).withValues(alpha: 0.5)
                              : const Color(0xFF9ca3af),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isBusy ? null : () => controller.onAccept(request.requestId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF0d3a4a),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isAccepting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isBn ? 'গ্রহণ করুন' : 'Accept',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : () => controller.onDecline(request.requestId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFd0d0d0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isRejecting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isBn ? 'প্রত্যাখ্যান' : 'Decline',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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

  Widget _buildAvatar(FriendUser user, double size) {
    final url = user.profileImage;
    final hasUrl = url != null && url.isNotEmpty;
    final fullUrl = hasUrl && !url.startsWith('http') ? _baseUrl + url : url;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.darkPrimary,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: hasUrl && fullUrl != null
                ? CachedNetworkImage(
                    imageUrl: fullUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildInitials(user.displayName, size),
                    errorWidget: (_, __, ___) => _buildInitials(user.displayName, size),
                  )
                : _buildInitials(user.displayName, size),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
