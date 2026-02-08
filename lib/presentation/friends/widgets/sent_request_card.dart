import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/data/models/friend_user.dart';
import 'package:torko/presentation/friends/controllers/friends_controller.dart';

/// Sent request card: avatar, name, username, location, Pending (disabled) + Cancel Request buttons.
class SentRequestCard extends StatelessWidget {
  final FriendRequestItem request;
  final bool isDark;
  final bool isBn;

  const SentRequestCard({
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
    final isCancelling = controller.isCancellingByRequestId[request.requestId] == true;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(user, 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0f1419),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.displayUsername.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.displayUsername,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                              : const Color(0xFF9ca3af),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (user.address != null && user.address!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: isDark
                                ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                                : const Color(0xFF657786),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.address!,
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                                    : const Color(0xFF657786),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      isBn ? 'রিকোয়েস্ট পাঠানো হয়েছে' : 'Request sent',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFFB8DED6).withValues(alpha: 0.5)
                            : const Color(0xFF9ca3af),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? const Color(0xFFB8DED6).withValues(alpha: 0.6)
                          : const Color(0xFF9ca3af),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF0d3a4a)
                            : const Color(0xFFd0d0d0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      isBn ? 'অপেক্ষমান' : 'Pending',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: isCancelling ? null : () => controller.cancelRequestAndRefresh(request.requestId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFff4d4f),
                      side: const BorderSide(color: Color(0xFFff4d4f)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: isCancelling
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFff4d4f),
                            ),
                          )
                        : Text(
                            isBn ? 'রিকোয়েস্ট বাতিল করুন' : 'Cancel Request',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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

  Widget _buildAvatar(FriendUser user, double size) {
    final url = user.profileImage;
    final hasUrl = url != null && url.isNotEmpty;
    final fullUrl = hasUrl && !url.startsWith('http') ? _baseUrl + url : url;

    return Container(
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
    );
  }

  Widget _buildInitials(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
