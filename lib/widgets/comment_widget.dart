import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/comment_controller.dart';
import '../core/controllers/app_controller.dart';
import '../core/theme/app_colors.dart';
import '../models/comment_model.dart';

/// Widget for displaying a single comment with reply and edit/delete options
class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final CommentController commentController;
  final bool isDark;
  final bool isBn;
  final int depth;

  const CommentItem({
    super.key,
    required this.comment,
    required this.commentController,
    required this.isDark,
    required this.isBn,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final user = comment.user;
    final displayName = user?.displayName ?? 'User';
    final profileImage = user?.profileImage;
    final canModify = commentController.canModifyComment(comment);
    
    return Padding(
      padding: EdgeInsets.only(
        left: depth > 0 ? 40.0 : 0,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(displayName, profileImage),
              const SizedBox(width: 12),
              
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
                    Row(
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
                            child: Text(
                              isBn ? 'সম্পাদনা' : 'Edit',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _showDeleteConfirmation(context),
                            child: Text(
                              isBn ? 'মুছুন' : 'Delete',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: comment.replies.map((reply) => CommentItem(
                  comment: reply,
                  commentController: commentController,
                  isDark: isDark,
                  isBn: isBn,
                  depth: depth + 1,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String displayName, String? profileImage) {
    if (profileImage != null && profileImage.isNotEmpty) {
      return CircleAvatar(
        radius: depth > 0 ? 14 : 18,
        backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
        backgroundImage: CachedNetworkImageProvider(profileImage),
      );
    }
    
    return CircleAvatar(
      radius: depth > 0 ? 14 : 18,
      backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: TextStyle(
          color: AppColors.lightPrimary,
          fontWeight: FontWeight.w600,
          fontSize: depth > 0 ? 11 : 14,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          isBn ? 'মন্তব্য মুছুন?' : 'Delete Comment?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          isBn 
              ? 'আপনি কি নিশ্চিত যে আপনি এই মন্তব্যটি মুছতে চান?'
              : 'Are you sure you want to delete this comment?',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              isBn ? 'বাতিল' : 'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              commentController.deleteComment(comment.id);
            },
            child: Text(
              isBn ? 'মুছুন' : 'Delete',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isDark 
                          ? AppColors.darkBackground 
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(22),
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
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
      print('DEBUG CommentSection: postId = $postId, currentPostId = ${commentController.currentPostId.value}');
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

