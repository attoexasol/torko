import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/friend_suggestion_model.dart';

/// Friends module colors (local to screen, no global theme change).
class _FriendsColors {
  static const bg = Color(0xFF052029);
  static const card = Color(0xFF0a2f3d);
  static const cardBorder = Color(0xFF0d3a4a);
  static const primary = Color(0xFFd97757);
  static const textWhite = Color(0xFFF9FAFB);
  static const textMuted = Color(0xFF9e9e9e);
  static const onlineDot = Color(0xFF22C55E);
}

/// Suggestion card: avatar, name, username, location, bio, mutual friends, Add Friend button.
class FriendSuggestionCard extends StatelessWidget {
  final FriendSuggestionModel model;

  const FriendSuggestionCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _FriendsColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _FriendsColors.cardBorder, width: 1),
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
                        color: _FriendsColors.textWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.displayUsername,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 13,
                        color: _FriendsColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (model.location != null && model.location!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: _FriendsColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              model.location!,
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 12,
                                color: _FriendsColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (model.bio != null && model.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        model.bio!,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: _FriendsColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (model.mutualFriends > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: _FriendsColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${model.mutualFriends} মিউচুয়াল বন্ধু',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 12,
                              color: _FriendsColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add, size: 20, color: Colors.white),
              label: Text(
                'বন্ধু যোগ করুন',
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _FriendsColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: _FriendsColors.primary,
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
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _FriendsColors.onlineDot,
              shape: BoxShape.circle,
              border: Border.all(
                color: _FriendsColors.card,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
