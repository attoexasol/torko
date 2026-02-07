import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:torko/presentation/post_detail/controllers/comment_controller.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/data/models/comment_model.dart';

/// Widget for displaying a single comment with reply and edit/delete options
/// Implements Facebook-style threaded comments with clean vertical guide lines
class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final CommentController commentController;
  final bool isDark;
  final bool isBn;
  final int depth;
  final bool isLastReply;
  final bool showThreadLine;

  const CommentItem({
    super.key,
    required this.comment,
    required this.commentController,
    required this.isDark,
    required this.isBn,
    this.depth = 0,
    this.isLastReply = false,
    this.showThreadLine = true,
  });

  // Thread line configuration constants
  static const double _threadLineWidth = 2.0;
  static const double _avatarRadiusParent = 18.0;
  static const double _avatarRadiusReply = 14.0;
  static const double _replyIndent = 40.0; // Horizontal indent for replies

  @override
  Widget build(BuildContext context) {
    final user = comment.user;
    final displayName = user?.displayName ?? 'User';
    final profileImage = user?.profileImage;
    final canModify = commentController.canModifyComment(comment);
    final hasReplies = comment.replies.isNotEmpty;
    final avatarRadius = depth > 0 ? _avatarRadiusReply : _avatarRadiusParent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main comment row with optional thread line
        _buildCommentRow(
          displayName: displayName,
          profileImage: profileImage,
          canModify: canModify,
          hasReplies: hasReplies,
          avatarRadius: avatarRadius,
          context: context,
        ),
        
        // Replies section with threading
        if (hasReplies)
          _buildRepliesSection(avatarRadius),
      ],
    );
  }

  Widget _buildCommentRow({
    required String displayName,
    required String? profileImage,
    required bool canModify,
    required bool hasReplies,
    required double avatarRadius,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with thread line below (if has replies)
          _buildAvatarWithThreadLine(
            displayName: displayName,
            profileImage: profileImage,
            avatarRadius: avatarRadius,
            hasReplies: hasReplies,
          ),
          const SizedBox(width: 10),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF0d3a4a) 
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author name
                      Text(
                        displayName,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF050505),
                        ),
                      ),
                      const SizedBox(height: 2),
                      
                      // Comment text
                      Text(
                        comment.comment,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF050505),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Actions row
                _buildActionsRow(canModify, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithThreadLine({
    required String displayName,
    required String? profileImage,
    required double avatarRadius,
    required bool hasReplies,
  }) {
    final lineColor = isDark 
        ? Colors.white.withOpacity(0.15)
        : Colors.grey.withOpacity(0.35);

    // For parent comments with replies, show avatar + line below
    // For reply comments, show the line continuing from parent
    return Column(
      children: [
        // Avatar
        _buildAvatar(displayName, profileImage, avatarRadius),
        
        // Vertical line below avatar (only for comments with replies)
        if (hasReplies)
          Container(
            width: _threadLineWidth,
            height: 8, // Small connector from avatar to replies
            color: lineColor,
          ),
      ],
    );
  }

  Widget _buildRepliesSection(double parentAvatarRadius) {
    final lineColor = isDark 
        ? Colors.white.withOpacity(0.15)
        : Colors.grey.withOpacity(0.35);
    
    return Padding(
      padding: EdgeInsets.only(left: parentAvatarRadius - 1), // Align line with parent avatar center
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical thread line for all replies
          _ThreadLine(
            lineColor: lineColor,
            lineWidth: _threadLineWidth,
          ),
          
          // Replies column
          Expanded(
            child: Column(
              children: comment.replies.asMap().entries.map((entry) {
                final index = entry.key;
                final reply = entry.value;
                final isLast = index == comment.replies.length - 1;
                
                return _ReplyItem(
                  comment: reply,
                  commentController: commentController,
                  isDark: isDark,
                  isBn: isBn,
                  depth: depth + 1,
                  isLastReply: isLast,
                  lineColor: lineColor,
                  lineWidth: _threadLineWidth,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(bool canModify, BuildContext context) {
    return Row(
      children: [
        // Time
        Text(
          comment.timeAgo,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: isDark 
                ? const Color(0xFF8E8E8E) 
                : const Color(0xFF65676B),
          ),
        ),
        const SizedBox(width: 16),
        
        // Reply button
        GestureDetector(
          onTap: () => commentController.startReply(comment),
          child: Text(
            isBn ? 'উত্তর' : 'Reply',
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark 
                  ? const Color(0xFF8E8E8E) 
                  : const Color(0xFF65676B),
            ),
          ),
        ),
        
        // Edit/Delete if owner
        if (canModify) ...[
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => commentController.startEdit(comment),
            child: Icon(
              Icons.edit,
              size: 16,
              color: AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => commentController.deleteComment(comment.id),
            child: Icon(
              Icons.delete,
              size: 16,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(String displayName, String? profileImage, double radius) {
    final fontSize = radius > 16 ? 14.0 : 11.0;
    
    if (profileImage != null && profileImage.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
        backgroundImage: CachedNetworkImageProvider(profileImage),
      );
    }
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: TextStyle(
          color: AppColors.lightPrimary,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

/// Individual reply item with horizontal connector to thread line
class _ReplyItem extends StatelessWidget {
  final CommentModel comment;
  final CommentController commentController;
  final bool isDark;
  final bool isBn;
  final int depth;
  final bool isLastReply;
  final Color lineColor;
  final double lineWidth;

  const _ReplyItem({
    required this.comment,
    required this.commentController,
    required this.isDark,
    required this.isBn,
    required this.depth,
    required this.isLastReply,
    required this.lineColor,
    required this.lineWidth,
  });

  static const double _avatarRadius = 14.0;
  static const double _horizontalConnectorWidth = 12.0;

  @override
  Widget build(BuildContext context) {
    final user = comment.user;
    final displayName = user?.displayName ?? 'User';
    final profileImage = user?.profileImage;
    final canModify = commentController.canModifyComment(comment);
    final hasReplies = comment.replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reply row with horizontal connector
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal connector line + vertical continuation
              SizedBox(
                width: _horizontalConnectorWidth + 4,
                child: Stack(
                  children: [
                    // Vertical line continuation (if not last reply)
                    if (!isLastReply)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: lineWidth,
                          color: lineColor,
                        ),
                      ),
                    // Vertical line up to connector (if last reply)
                    if (isLastReply)
                      Positioned(
                        left: 0,
                        top: 0,
                        height: _avatarRadius, // Stop at avatar center
                        child: Container(
                          width: lineWidth,
                          color: lineColor,
                        ),
                      ),
                    // Horizontal connector to avatar
                    Positioned(
                      left: 0,
                      top: _avatarRadius - (lineWidth / 2),
                      child: Container(
                        width: _horizontalConnectorWidth,
                        height: lineWidth,
                        color: lineColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Avatar with thread line below (if has nested replies)
              Column(
                children: [
                  _buildAvatar(displayName, profileImage),
                  if (hasReplies)
                    Container(
                      width: lineWidth,
                      height: 8,
                      color: lineColor,
                    ),
                ],
              ),
              
              const SizedBox(width: 10),
              
              // Comment content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Comment bubble
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? const Color(0xFF0d3a4a) 
                              : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF050505),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              comment.comment,
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 14,
                                color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF050505),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Actions row
                      _buildActionsRow(canModify, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Nested replies (recursive)
        if (hasReplies)
          _buildNestedReplies(),
      ],
    );
  }

  Widget _buildNestedReplies() {
    return Padding(
      padding: EdgeInsets.only(left: _avatarRadius + _horizontalConnectorWidth + 4 - 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical thread line for nested replies
          _ThreadLine(
            lineColor: lineColor,
            lineWidth: lineWidth,
          ),
          
          // Nested replies column
          Expanded(
            child: Column(
              children: comment.replies.asMap().entries.map((entry) {
                final index = entry.key;
                final reply = entry.value;
                final isLast = index == comment.replies.length - 1;
                
                return _ReplyItem(
                  comment: reply,
                  commentController: commentController,
                  isDark: isDark,
                  isBn: isBn,
                  depth: depth + 1,
                  isLastReply: isLast,
                  lineColor: lineColor,
                  lineWidth: lineWidth,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(bool canModify, BuildContext context) {
    return Row(
      children: [
        Text(
          comment.timeAgo,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: isDark 
                ? const Color(0xFF8E8E8E) 
                : const Color(0xFF65676B),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => commentController.startReply(comment),
          child: Text(
            isBn ? 'উত্তর' : 'Reply',
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark 
                  ? const Color(0xFF8E8E8E) 
                  : const Color(0xFF65676B),
            ),
          ),
        ),
        if (canModify) ...[
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => commentController.startEdit(comment),
            child: Icon(
              Icons.edit,
              size: 16,
              color: AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => commentController.deleteComment(comment.id),
            child: Icon(
              Icons.delete,
              size: 16,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(String displayName, String? profileImage) {
    if (profileImage != null && profileImage.isNotEmpty) {
      return CircleAvatar(
        radius: _avatarRadius,
        backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
        backgroundImage: CachedNetworkImageProvider(profileImage),
      );
    }
    
    return CircleAvatar(
      radius: _avatarRadius,
      backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: AppColors.lightPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

}

/// Simple vertical thread line widget
class _ThreadLine extends StatelessWidget {
  final Color lineColor;
  final double lineWidth;

  const _ThreadLine({
    required this.lineColor,
    required this.lineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lineWidth,
      color: lineColor,
    );
  }
}

/// Comment input field with reply/edit mode support
class CommentInputField extends StatefulWidget {
  final int postId;
  final CommentController commentController;
  final bool isDark;
  final bool isBn;

  const CommentInputField({
    super.key,
    required this.postId,
    required this.commentController,
    required this.isDark,
    required this.isBn,
  });

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to edit mode changes
    ever(widget.commentController.editingComment, (CommentModel? comment) {
      if (comment != null) {
        _textController.text = comment.comment;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isReplyMode = widget.commentController.isReplyMode.value;
      final isEditMode = widget.commentController.isEditMode.value;
      final replyingTo = widget.commentController.replyingTo.value;
      final editingComment = widget.commentController.editingComment.value;
      final isSubmitting = widget.commentController.isSubmitting.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply/Edit indicator
          if (isReplyMode || isEditMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isDark 
                    ? const Color(0xFF0d3a4a) 
                    : const Color(0xFFE4E6EB),
                border: Border(
                  bottom: BorderSide(
                    color: widget.isDark 
                        ? const Color(0xFF104050) 
                        : const Color(0xFFCCD0D5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit : Icons.reply,
                    size: 16,
                    color: AppColors.lightPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEditMode
                          ? (widget.isBn ? 'মন্তব্য সম্পাদনা করছেন' : 'Editing comment')
                          : (widget.isBn 
                              ? '${replyingTo?.user?.displayName ?? "User"} কে উত্তর দিচ্ছেন'
                              : 'Replying to ${replyingTo?.user?.displayName ?? "User"}'),
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 13,
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isEditMode) {
                        widget.commentController.cancelEdit();
                        _textController.clear();
                      } else {
                        widget.commentController.cancelReply();
                      }
                    },
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: widget.isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          
          // Input field
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(
                top: BorderSide(
                  color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22), // 🔥 SAME radius
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(22), // 🔥 SAME radius
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        style: TextStyle(
                          color: widget.isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: isReplyMode
                              ? (widget.isBn ? 'উত্তর লিখুন...' : 'Write a reply...')
                              : (widget.isBn ? 'মন্তব্য করুন...' : 'Add a comment...'),
                          hintStyle: TextStyle(
                            color: widget.isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),

                          // 🚫 NO borders
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,

                          isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                
                // Submit button
                GestureDetector(
                  onTap: isSubmitting ? null : _handleSubmit,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Future<void> _handleSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final isEditMode = widget.commentController.isEditMode.value;
    final editingComment = widget.commentController.editingComment.value;
    final replyingTo = widget.commentController.replyingTo.value;

    bool success = false;

    if (isEditMode && editingComment != null) {
      // Update existing comment
      success = await widget.commentController.updateComment(
        commentId: editingComment.id,
        comment: text,
      );
    } else {
      // Create new comment (or reply)
      success = await widget.commentController.createComment(
        postId: widget.postId,
        comment: text,
        replyId: replyingTo?.id,
      );
    }

    if (success) {
      _textController.clear();
    }
  }
}

/// Full comment section widget that combines list and input
class CommentSection extends StatelessWidget {
  final int postId;
  final bool showTitle;

  const CommentSection({
    super.key,
    required this.postId,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    // Use existing controller or create new one
    late final CommentController commentController;
    if (Get.isRegistered<CommentController>()) {
      commentController = Get.find<CommentController>();
    } else {
      commentController = Get.put(CommentController());
    }

    // Load comments when widget is built (if not already loading this post)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (commentController.currentPostId.value != postId && postId > 0) {
        commentController.loadComments(postId);
      }
    });

    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;
      final isLoading = commentController.isLoading.value;
      final comments = commentController.comments;
      final errorMessage = commentController.errorMessage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    isBn ? 'মন্তব্য' : 'Comments',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF050505),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${commentController.commentCount})',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: isDark 
                          ? const Color(0xFF8E8E8E) 
                          : const Color(0xFF65676B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Loading indicator
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),

          // Error message
          if (errorMessage.isNotEmpty && comments.isEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 40,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isBn ? 'মন্তব্য লোড হয়নি' : 'Could not load comments',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        if (postId > 0) {
                          commentController.loadComments(postId);
                        }
                      },
                      child: Text(
                        isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry',
                        style: TextStyle(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Comments list
          if (!isLoading && comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: comments.map((comment) => CommentItem(
                  comment: comment,
                  commentController: commentController,
                  isDark: isDark,
                  isBn: isBn,
                )).toList(),
              ),
            ),

          // Empty state
          if (!isLoading && comments.isEmpty && errorMessage.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isBn ? 'কোন মন্তব্য নেই' : 'No comments yet',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 16,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBn ? 'প্রথম মন্তব্য করুন!' : 'Be the first to comment!',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

