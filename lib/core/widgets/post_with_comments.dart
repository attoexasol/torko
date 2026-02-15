import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';

// ==================== Models ====================

class PostData {
  final String id;
  final String author;
  final String? authorAvatar;
  final String timestamp;
  final String? title;
  final String content;
  final String type; // text, image, video, gradient, multiImage, multiVideo
  final String? image;
  final List<String>? images;
  final String? video;
  final List<String>? videos;
  final String? gradient;
  int likes;
  final int comments;
  final int shares;
  bool isLiked;

  PostData({
    required this.id,
    required this.author,
    this.authorAvatar,
    required this.timestamp,
    this.title,
    required this.content,
    required this.type,
    this.image,
    this.images,
    this.video,
    this.videos,
    this.gradient,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
  });
}

class CommentReply {
  final String id;
  final String author;
  final String? authorHandle;
  final String? avatar;
  final String? avatarColor;
  final String initials;
  final String text;
  final String timestamp;
  int likes;
  bool isLiked;
  List<CommentReply>? replies;

  CommentReply({
    required this.id,
    required this.author,
    this.authorHandle,
    this.avatar,
    this.avatarColor,
    required this.initials,
    required this.text,
    required this.timestamp,
    required this.likes,
    required this.isLiked,
    this.replies,
  });
}

// ==================== PostWithComments Widget ====================

class PostWithComments extends StatefulWidget {
  final PostData post;
  final VoidCallback onBack;
  final Function(String text, String? replyTo)? onAddComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  /// When false (e.g. Profile → My Posts), hide counts/actions/comment section.
  final bool showInteractions;

  const PostWithComments({
    super.key,
    required this.post,
    required this.onBack,
    this.onAddComment,
    this.onEdit,
    this.onDelete,
    this.showInteractions = true,
  });

  @override
  State<PostWithComments> createState() => _PostWithCommentsState();
}

class _PostWithCommentsState extends State<PostWithComments> {
  final appController = Get.find<AppController>();
  late bool isLiked;
  late int likesCount;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    likesCount = widget.post.likes;
  }

  void _handleLike() {
    setState(() {
      if (isLiked) {
        likesCount--;
      } else {
        likesCount++;
      }
      isLiked = !isLiked;
    });
  }

  String _getAuthorInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return words[0][0] + words[1][0];
    }
    return name[0];
  }

  void _showDeleteConfirmation() {
    final isBn = appController.language == AppLanguage.bn;
    Get.dialog(
      AlertDialog(
        title: Text(isBn ? 'পোস্ট মুছে ফেলুন' : 'Delete Post'),
        content: Text(isBn 
            ? 'আপনি কি নিশ্চিত যে আপনি এই পোস্টটি মুছে ফেলতে চান?' 
            : 'Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isBn ? 'মুছে ফেলুন' : 'Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkBackground : Colors.white)
                    .withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isBn ? 'পোস্ট' : 'Post',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 672), // max-w-2xl
                    child: Column(
                      children: [
                        // Main Post
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                _buildAvatar(48, isDark),
                                const SizedBox(width: 12),

                                // Post Body
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.post.author,
                                                  style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  '@${widget.post.author.toLowerCase().replaceAll(' ', '')}',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    color: isDark
                                                        ? AppColors
                                                            .darkMutedForeground
                                                        : AppColors
                                                            .lightMutedForeground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            itemBuilder: (context) {
                                              final isBn = appController.language == AppLanguage.bn;
                                              return [
                                                if (widget.onEdit != null)
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text(isBn ? 'সম্পাদনা করুন' : 'Edit'),
                                                  ),
                                                if (widget.onDelete != null) ...[
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      isBn ? 'মুছে ফেলুন' : 'Delete',
                                                      style: const TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                                if (widget.onEdit == null && widget.onDelete == null)
                                                  PopupMenuItem(
                                                    value: 'report',
                                                    child: Text(isBn ? 'রিপোর্ট করুন' : 'Report'),
                                                  ),
                                              ];
                                            },
                                            onSelected: (value) {
                                              if (value == 'edit' && widget.onEdit != null) {
                                                widget.onEdit!();
                                              } else if (value == 'delete' && widget.onDelete != null) {
                                                _showDeleteConfirmation();
                                              }
                                            },
                                            icon: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                              ),
                                              child: Icon(
                                                Icons.more_horiz,
                                                size: 20,
                                                color: isDark
                                                    ? AppColors
                                                        .darkMutedForeground
                                                    : AppColors
                                                        .darkMutedForeground,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Post Title (if exists)
                                      if (widget.post.title != null && widget.post.title!.isNotEmpty) ...[
                                        Text(
                                          widget.post.title!,
                                          style: GoogleFonts.roboto(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            height: 1.4,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],

                                      // Post Text
                                      Text(
                                        widget.post.content,
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Post Media
                                      _buildMedia(isDark),

                                      // Timestamp
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: widget.showInteractions ? 12 : 0,
                                        ),
                                        child: Text(
                                          widget.post.timestamp,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: isDark
                                                ? AppColors.darkMutedForeground
                                                : AppColors.lightMutedForeground,
                                          ),
                                        ),
                                      ),

                                      // Stats + Action Buttons (hidden when showInteractions=false)
                                      if (widget.showInteractions) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: isDark
                                                    ? AppColors.darkBorder
                                                    : AppColors.lightBorder,
                                              ),
                                              bottom: BorderSide(
                                                color: isDark
                                                    ? AppColors.darkBorder
                                                    : AppColors.lightBorder,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildStatButton(
                                                '${widget.post.comments}',
                                                isBn ? 'মন্তব্য' : 'Comments',
                                                isDark,
                                              ),
                                              const SizedBox(width: 16),
                                              _buildStatButton(
                                                '$likesCount',
                                                isBn ? 'পছন্দ' : 'Likes',
                                                isDark,
                                              ),
                                              const SizedBox(width: 16),
                                              _buildStatButton(
                                                '${widget.post.shares}',
                                                isBn ? 'শেয়ার' : 'Shares',
                                                isDark,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildActionButton(
                                                icon: Icons.favorite,
                                                label: isBn ? 'পছন্দ' : 'Like',
                                                isActive: isLiked,
                                                activeColor:
                                                    const Color(0xFFf91880),
                                                onTap: _handleLike,
                                                isDark: isDark,
                                              ),
                                            ),
                                            Expanded(
                                              child: _buildActionButton(
                                                icon: Icons.chat_bubble_outline,
                                                label: isBn ? 'মন্তব্য' : 'Comment',
                                                isActive: false,
                                                activeColor: Colors.blue,
                                                onTap: () {},
                                                isDark: isDark,
                                              ),
                                            ),
                                            Expanded(
                                              child: _buildActionButton(
                                                icon: Icons.share_outlined,
                                                label: isBn ? 'শেয়ার' : 'Share',
                                                isActive: false,
                                                activeColor: Colors.green,
                                                onTap: () {},
                                                isDark: isDark,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isSaved = !isSaved;
                                                });
                                              },
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isSaved
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_outline,
                                                  size: 20,
                                                  color: isSaved
                                                      ? AppColors.lightPrimary
                                                      : (isDark
                                                          ? AppColors
                                                              .darkMutedForeground
                                                          : AppColors
                                                              .lightMutedForeground),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Comments Section (hidden when showInteractions=false)
                        if (widget.showInteractions)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ModernCommentSection(
                              postId: widget.post.id,
                              onAddComment: widget.onAddComment,
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatar(double size, bool isDark) {
    if (widget.post.authorAvatar != null) {
      return ClipOval(
        child: Image.network(
          widget.post.authorAvatar!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarFallback(size),
        ),
      );
    }
    return _buildAvatarFallback(size);
  }

  Widget _buildAvatarFallback(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFd97757), Color(0xFFB8DED6)],
        ),
      ),
      child: Center(
        child: Text(
          _getAuthorInitials(widget.post.author),
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(bool isDark) {
    final post = widget.post;

    if (post.type == 'image' && post.image != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            post.image!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              child: const Icon(Icons.image, size: 48),
            ),
          ),
        ),
      );
    }

    if (post.type == 'multiImage' && post.images != null && post.images!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildMultiImageGrid(post.images!, isDark),
      );
    }

    if (post.type == 'gradient' && post.gradient != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 200),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: _parseGradient(post.gradient!),
          ),
          child: Center(
            child: Text(
              post.content,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMultiImageGrid(List<String> images, bool isDark) {
    final count = images.length;
    if (count == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(images[0], fit: BoxFit.cover),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count >= 2 ? 2 : 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: count > 4 ? 4 : count,
        itemBuilder: (context, index) {
          if (index == 3 && count > 4) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(images[index], fit: BoxFit.cover),
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      '+${count - 4}',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Image.network(images[index], fit: BoxFit.cover);
        },
      ),
    );
  }

  LinearGradient _parseGradient(String gradientStr) {
    // Simple gradient parsing - default to accent gradient
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFd97757), Color(0xFFB8DED6)],
    );
  }

  Widget _buildStatButton(String count, String label, bool isDark) {
    return GestureDetector(
      onTap: () {},
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: count,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: ' $label',
              style: GoogleFonts.roboto(
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? icon : icon,
              size: 18,
              color: isActive
                  ? activeColor
                  : (isDark
                      ? AppColors.darkMutedForeground
                      : AppColors.lightMutedForeground),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: isActive
                      ? activeColor
                      : (isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ModernCommentSection Widget ====================

class ModernCommentSection extends StatefulWidget {
  final String postId;
  final Function(String text, String? replyTo)? onAddComment;

  const ModernCommentSection({
    super.key,
    required this.postId,
    this.onAddComment,
  });

  @override
  State<ModernCommentSection> createState() => _ModernCommentSectionState();
}

class _ModernCommentSectionState extends State<ModernCommentSection> {
  final appController = Get.find<AppController>();
  late List<CommentReply> comments;
  CommentReply? replyTo;

  @override
  void initState() {
    super.initState();
    _initializeComments();
  }

  void _initializeComments() {
    comments = [];
  }

  void _handleAddComment(String text) {
    final isBn = appController.language == AppLanguage.bn;

    final newComment = CommentReply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: isBn ? 'আপনি' : 'You',
      authorHandle: '@you',
      initials: isBn ? 'আ' : 'Y',
      avatarColor: '#d97757',
      text: text,
      timestamp: isBn ? 'এইমাত্র' : 'Just now',
      likes: 0,
      isLiked: false,
    );

    setState(() {
      if (replyTo != null) {
        _addReplyToComment(comments, replyTo!.id, newComment);
        replyTo = null;
      } else {
        comments.insert(0, newComment);
      }
    });

    widget.onAddComment?.call(text, replyTo?.id);
  }

  void _addReplyToComment(
      List<CommentReply> commentList, String parentId, CommentReply newReply) {
    for (var comment in commentList) {
      if (comment.id == parentId) {
        comment.replies ??= [];
        comment.replies!.add(newReply);
        return;
      }
      if (comment.replies != null) {
        _addReplyToComment(comment.replies!, parentId, newReply);
      }
    }
  }

  void _handleLike(String commentId) {
    setState(() {
      _toggleLike(comments, commentId);
    });
  }

  void _toggleLike(List<CommentReply> commentList, String commentId) {
    for (var comment in commentList) {
      if (comment.id == commentId) {
        comment.isLiked = !comment.isLiked;
        comment.likes += comment.isLiked ? 1 : -1;
        return;
      }
      if (comment.replies != null) {
        _toggleLike(comment.replies!, commentId);
      }
    }
  }

  void _handleReply(CommentReply comment) {
    setState(() {
      replyTo = comment;
    });
  }

  void _handleDelete(String commentId) {
    setState(() {
      _deleteComment(comments, commentId);
    });
  }

  void _deleteComment(List<CommentReply> commentList, String commentId) {
    commentList.removeWhere((c) => c.id == commentId);
    for (var comment in commentList) {
      if (comment.replies != null) {
        _deleteComment(comment.replies!, commentId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Input
          _CommentInput(
            onSubmit: _handleAddComment,
            replyTo: replyTo,
            onCancelReply: () => setState(() => replyTo = null),
          ),
          const SizedBox(height: 16),

          // Comments List
          if (comments.isEmpty)
            _buildEmptyState(isDark, isBn)
          else
            ...comments.map((comment) => _CommentItem(
                  comment: comment,
                  onReply: _handleReply,
                  onLike: _handleLike,
                  onDelete: _handleDelete,
                  level: 0,
                )),

          // Load More Button
          if (comments.length >= 3)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isBn ? 'আরো মন্তব্য দেখুন' : 'Load more comments',
                    style: GoogleFonts.roboto(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildEmptyState(bool isDark, bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: (isDark
                      ? AppColors.darkMutedForeground
                      : AppColors.lightMutedForeground)
                  .withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              isBn ? 'এখনও কোন মন্তব্য নেই' : 'No comments yet',
              style: GoogleFonts.roboto(
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isBn ? 'প্রথম মন্তব্য করুন' : 'Be the first to comment',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CommentInput Widget ====================

class _CommentInput extends StatefulWidget {
  final Function(String) onSubmit;
  final CommentReply? replyTo;
  final VoidCallback onCancelReply;

  const _CommentInput({
    required this.onSubmit,
    this.replyTo,
    required this.onCancelReply,
  });

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final appController = Get.find<AppController>();
  final textController = TextEditingController();
  final focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() => isFocused = focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (textController.text.trim().isEmpty) return;
    widget.onSubmit(textController.text);
    textController.clear();
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Column(
        children: [
          // Reply To Banner
          if (widget.replyTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkMuted : AppColors.lightMuted)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkMutedForeground
                              : AppColors.lightMutedForeground,
                        ),
                        children: [
                          TextSpan(text: isBn ? 'উত্তর দিচ্ছেন ' : 'Replying to '),
                          TextSpan(
                            text: widget.replyTo!.author,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onCancelReply,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        isBn ? 'বাতিল' : 'Cancel',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFd97757),
                ),
                child: Center(
                  child: Text(
                    isBn ? 'আ' : 'Y',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Text Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkMuted : AppColors.lightMuted)
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: isFocused
                        ? Border.all(
                            color: AppColors.lightPrimary.withOpacity(0.5),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          focusNode: focusNode,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSubmit(),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                isBn ? 'মন্তব্য লিখুন...' : 'Write a comment...',
                            hintStyle: GoogleFonts.roboto(
                              color: isDark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      // Send button
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: textController,
                        builder: (context, value, child) {
                          if (value.text.trim().isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: _handleSubmit,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                                iconSize: 20,
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.image_outlined,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                                iconSize: 20,
                                onPressed: () {},
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ==================== CommentItem Widget ====================

class _CommentItem extends StatefulWidget {
  final CommentReply comment;
  final Function(CommentReply) onReply;
  final Function(String) onLike;
  final Function(String)? onDelete;
  final int level;
  final bool isLastChild;

  const _CommentItem({
    required this.comment,
    required this.onReply,
    required this.onLike,
    this.onDelete,
    required this.level,
    this.isLastChild = false,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  final appController = Get.find<AppController>();
  bool isHovered = false;

  Color _parseColor(String? colorStr) {
    if (colorStr == null) return const Color(0xFFd97757);
    try {
      final hex = colorStr.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFd97757);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;
      final hasReplies =
          widget.comment.replies != null && widget.comment.replies!.isNotEmpty;
      final avatarSize = widget.level == 0 ? 40.0 : 36.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Row
          MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with threading line
                  SizedBox(
                    width: avatarSize,
                    child: Column(
                      children: [
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _parseColor(widget.comment.avatarColor),
                          ),
                          child: Center(
                            child: Text(
                              widget.comment.initials,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: widget.level == 0 ? 14 : 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Comment Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Comment Bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted)
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.comment.author,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color:
                                            isDark ? Colors.white : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (widget.comment.authorHandle != null) ...[
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        widget.comment.authorHandle!,
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkMutedForeground
                                              : AppColors.lightMutedForeground,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Text
                              Text(
                                widget.comment.text,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Bar
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.comment.timestamp,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkMutedForeground
                                        : AppColors.lightMutedForeground,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => widget.onLike(widget.comment.id),
                                  child: Text(
                                    '${isBn ? 'পছন্দ' : 'Like'}${widget.comment.likes > 0 ? ' · ${widget.comment.likes}' : ''}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: widget.comment.isLiked
                                          ? AppColors.lightPrimary
                                          : (isDark
                                              ? AppColors.darkMutedForeground
                                              : AppColors.lightMutedForeground),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => widget.onReply(widget.comment),
                                  child: Text(
                                    isBn ? 'উত্তর দিন' : 'Reply',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkMutedForeground
                                          : AppColors.lightMutedForeground,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              if (isHovered) ...[
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.darkMutedForeground
                                        : AppColors.lightMutedForeground,
                                  ),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(isBn ? 'সম্পাদনা' : 'Edit'),
                                    ),
                                    if (widget.onDelete != null)
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          isBn ? 'মুছে ফেলুন' : 'Delete',
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                    PopupMenuItem(
                                      value: 'report',
                                      child:
                                          Text(isBn ? 'রিপোর্ট করুন' : 'Report'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'delete' &&
                                        widget.onDelete != null) {
                                      widget.onDelete!(widget.comment.id);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nested Replies
          if (hasReplies)
            Padding(
              padding: EdgeInsets.only(left: avatarSize / 2),
              child: Column(
                children: widget.comment.replies!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reply = entry.value;
                  final isLast = index == widget.comment.replies!.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(left: avatarSize / 2 + 8),
                    child: _CommentItem(
                      comment: reply,
                      onReply: widget.onReply,
                      onLike: widget.onLike,
                      onDelete: widget.onDelete,
                      level: widget.level + 1,
                      isLastChild: isLast,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    });
  }
}

