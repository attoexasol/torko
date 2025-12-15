import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class PostCard extends StatelessWidget {
  final String author;
  final String username;
  final String timestamp;
  final String content;
  final String? type;
  final String? gradient;
  final Map<String, dynamic>? poll;
  final int likes;
  final int comments;
  final bool isLiked;
  final String language;

  final VoidCallback? onLike;
  final VoidCallback? onComment; // ✅ ADD
  final VoidCallback? onShare;   // ✅ ADD

  const PostCard({
    super.key,
    required this.author,
    required this.username,
    required this.timestamp,
    required this.content,
    this.type,
    this.gradient,
    this.poll,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.language = 'bn',
    this.onLike,
    this.onComment, // ✅ ADD
    this.onShare,   // ✅ ADD
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe6e6e6),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDark),
          
          // Content
          _buildContent(isDark),
          
          // Actions
          _buildActions(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.2),
            child: Text(
              author.isNotEmpty ? author[0].toUpperCase() : 'U',
              style: TextStyle(
                color: AppColors.lightPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timestamp,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu button
          IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 20,
              color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF8E8E8E),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (type == 'gradient' && gradient != null) {
      return _buildGradientContent(isDark);
    } else if (type == 'image') {
      return _buildImageContent(isDark);
    } else if (type == 'poll' && poll != null) {
      return _buildPollContent(isDark);
    } else {
      return _buildTextContent(isDark);
    }
  }

  Widget _buildTextContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        content,
        style: GoogleFonts.roboto(
          fontSize: 15,
          height: 1.27,
          color: isDark ? Colors.white : const Color(0xFF0f1419),
        ),
      ),
    );
  }

  Widget _buildGradientContent(bool isDark) {
    // Parse gradient string and extract colors
    List<Color> gradientColors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
    ];
    
    if (gradient != null) {
      // Parse the gradient string to extract colors
      final hexPattern = RegExp(r'#([0-9A-Fa-f]{6})');
      final matches = hexPattern.allMatches(gradient!);
      if (matches.length >= 2) {
        final colorList = matches.map((match) {
          final hex = match.group(1)!;
          return Color(int.parse('FF$hex', radix: 16));
        }).toList();
        gradientColors = colorList.take(2).toList();
      }
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        final fontSize = isSmallScreen ? 22.0 : 28.0;
        final padding = isSmallScreen ? 24.0 : 40.0;
        
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isSmallScreen ? 200 : 280),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: Text(
              content,
              style: GoogleFonts.notoSansBengali(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageContent(bool isDark) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 500),
      child: Image.asset(
        'assets/images/8fb677f541a8266f00e55fc543e55a475d028aef.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
          child: Icon(
            Icons.image,
            color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF9D9D9D),
          ),
        ),
      ),
    );
  }

  Widget _buildPollContent(bool isDark) {
    if (poll == null) return const SizedBox();
    
    final pollData = poll!;
    final options = pollData['options'] as List<dynamic>? ?? [];
    final totalVotes = pollData['totalVotes'] as int? ?? 0;
    final hasVoted = pollData['hasVoted'] as bool? ?? false;
    final votedOptionId = pollData['votedOptionId'] as int?;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf7f8fa),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF104050) : const Color(0xFFe6e6e6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Text(
              pollData['question'] ?? content,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
            const SizedBox(height: 16),
            
            // Options
            ...options.map((option) {
              final optionId = option['id'] as int;
              final optionText = option['text'] as String;
              final optionVotes = option['votes'] as int;
              final percentage = totalVotes > 0
                  ? ((optionVotes / totalVotes) * 100).round()
                  : 0;
              final isVoted = hasVoted && votedOptionId == optionId;
              final isWinning = hasVoted &&
                  optionVotes ==
                      (options.map((o) => o['votes'] as int).reduce((a, b) => a > b ? a : b));
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: hasVoted ? null : () {},
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isVoted
                          ? AppColors.lightPrimary.withValues(alpha: isDark ? 0.1 : 0.05)
                          : (isDark ? const Color(0xFF104050) : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isVoted
                            ? AppColors.lightPrimary
                            : (isDark ? const Color(0xFF104050) : const Color(0xFFe1e4e8)),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Progress bar
                        if (hasVoted)
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isWinning
                                      ? AppColors.lightPrimary.withValues(alpha: 0.2)
                                      : (isDark
                                          ? const Color(0xFF0d3a4a)
                                          : const Color(0xFFe1e4e8)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        
                        // Option content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              if (isVoted)
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: AppColors.lightPrimary,
                                ),
                              if (isVoted) const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: isVoted
                                        ? AppColors.lightPrimary
                                        : (isDark ? Colors.white : const Color(0xFF0f1419)),
                                    fontWeight: isVoted ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              if (hasVoted) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '$percentage%',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isWinning
                                        ? AppColors.lightPrimary
                                        : (isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            // Footer
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Divider(
                color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe1e4e8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$totalVotes ${language == 'bn' ? 'ভোট' : 'votes'}',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 320;
          final buttonPadding = isSmallScreen 
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
          final iconSize = isSmallScreen ? 18.0 : 20.0;
          final fontSize = isSmallScreen ? 12.0 : 14.0;
          
          return Row(
            children: [
              // Like Button
              Flexible(
                child: GestureDetector(
                  onTap: onLike,
                  child: Container(
                    padding: buttonPadding,
                    decoration: BoxDecoration(
                      color: isLiked
                          ? AppColors.lightPrimary.withValues(alpha: 0.1)
                          : (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf5f5f5)),
                      border: Border.all(
                        color: isLiked
                            ? AppColors.lightPrimary
                            : (isDark ? const Color(0xFF104050) : const Color(0xFFe6e6e6)),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: iconSize,
                          color: isLiked
                              ? AppColors.lightPrimary
                              : const Color(0xFF9D9D9D),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          likes >= 1000 ? '${(likes / 1000).toStringAsFixed(1)}k' : '$likes',
                          style: GoogleFonts.roboto(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            color: isLiked
                                ? AppColors.lightPrimary
                                : const Color(0xFF9D9D9D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
             // Comment Button
              Flexible(
              child: GestureDetector(
                onTap: onComment, // ✅ CONNECT
                child: Container(
                  padding: buttonPadding,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf5f5f5),
                    border: Border.all(
                      color: isDark ? const Color(0xFF104050) : const Color(0xFFe6e6e6),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: iconSize,
                        color: const Color(0xFF9D9D9D),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$comments',
                        style: GoogleFonts.roboto(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9D9D9D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
              
             // Share Button
              Flexible(
  child: GestureDetector(
    onTap: onShare, // ✅ CONNECT
    child: Container(
      padding: buttonPadding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf5f5f5),
        border: Border.all(
          color: isDark ? const Color(0xFF104050) : const Color(0xFFe6e6e6),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.share,
            size: iconSize,
            color: const Color(0xFF9D9D9D),
          ),
          if (!isSmallScreen) ...[
            const SizedBox(width: 6),
            Text(
              language == 'bn' ? 'শেয়ার' : 'Share',
              style: GoogleFonts.roboto(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9D9D9D),
              ),
            ),
          ],
        ],
      ),
    ),
  ),
),

            ],
          );
        },
      ),
    );
  }
}
