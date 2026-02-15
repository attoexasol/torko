import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/presentation/home/controllers/post_controller.dart';
import 'package:torko/presentation/saved_posts/controllers/saved_posts_controller.dart';
import 'package:torko/data/models/post_model.dart';
import 'post_with_comments.dart';

// ==================== Poll Models ====================

class PollOption {
  final int id;
  final String text;
  int votes;

  PollOption({required this.id, required this.text, required this.votes});
}

class Poll {
  final String question;
  List<PollOption> options;
  int totalVotes;
  final String? endTime;
  bool hasVoted;
  int? votedOptionId;

  Poll({
    required this.question,
    required this.options,
    required this.totalVotes,
    this.endTime,
    this.hasVoted = false,
    this.votedOptionId,
  });
}

// ==================== PostCard Widget ====================

class PostCard extends StatefulWidget {
  final String? id;
  final int? userId; // Post owner's user ID
  final String author;
  final String username;
  final String? groupName;
  final bool verified;
  final String timestamp;
  final String content;
  final String? title;
  final String? avatar;
  final String? image;
  final String? video;
  final List<String>? images;
  final List<String>? videos;
  final String? type; // text, image, video, gradient, multiImage, multiVideo, poll
  final String? gradient;
  final Poll? poll;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isSaved; // Whether post is saved
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMenuClick;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSave; // Callback when save action is triggered
  final bool isShared;
  final DateTime? sharedAt;
  final int? sharedByUserId;
  final VoidCallback? onDeleteSharedPost;
  final PostModel? post;
  /// When true, PostWithComments opens with showInteractions: false (e.g. Profile → My Posts).
  final bool hideInteractionsInDetail;

  const PostCard({
    super.key,
    this.id,
    this.userId,
    required this.author,
    required this.username,
    this.groupName,
    this.verified = false,
    required this.timestamp,
    required this.content,
    this.title,
    this.avatar,
    this.image,
    this.video,
    this.images,
    this.videos,
    this.type,
    this.gradient,
    this.poll,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.isSaved = false,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onMenuClick,
    this.onEdit,
    this.onDelete,
    this.onSave,
    this.isShared = false,
    this.sharedAt,
    this.sharedByUserId,
    this.onDeleteSharedPost,
    this.post,
    this.hideInteractionsInDetail = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final appController = Get.find<AppController>();
  bool showShareMenu = false;
  bool showMediaViewer = false;
  int mediaViewerIndex = 0;
  bool isSaving = false; // Loading state for save action

  // Poll state
  late Poll? pollState;
  int? selectedOption;

  @override
  void initState() {
    super.initState();
    pollState = widget.poll;
    selectedOption = widget.poll?.votedOptionId;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.poll != oldWidget.poll) {
      pollState = widget.poll;
      selectedOption = widget.poll?.votedOptionId;
    }
  }

  bool get isBn => appController.language == AppLanguage.bn;
  bool get isDark => appController.isDarkMode;

  String get _avatarUrl {
    if (widget.avatar != null) return widget.avatar!;
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.author)}&background=d97757&color=fff&size=128';
  }

  void _handleShare(String type) async {
    final postUrl = 'https://torko.app/post/${widget.username}/${DateTime.now().millisecondsSinceEpoch}';

    switch (type) {
      case 'native':
        // Copy to clipboard as fallback for native share
        await Clipboard.setData(ClipboardData(text: '${widget.content} - $postUrl'));
        Get.snackbar(
          isBn ? 'লিংক কপি হয়েছে' : 'Link copied to clipboard',
          isBn ? 'শেয়ার করতে পেস্ট করুন' : 'Paste to share',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        break;
      case 'copy':
        await Clipboard.setData(ClipboardData(text: postUrl));
        Get.snackbar(
          isBn ? 'লিংক কপি হয়েছে' : 'Link copied',
          '',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;
      case 'whatsapp':
        await Clipboard.setData(ClipboardData(text: '${widget.content} - $postUrl'));
        Get.snackbar(
          isBn ? 'লিংক কপি হয়েছে' : 'Link copied',
          isBn ? 'ওয়াটসঅ্যাপে পেস্ট করুন' : 'Paste in WhatsApp',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'facebook':
        await Clipboard.setData(ClipboardData(text: postUrl));
        Get.snackbar(
          isBn ? 'লিংক কপি হয়েছে' : 'Link copied',
          isBn ? 'ফেসবুকে পেস্ট করুন' : 'Paste in Facebook',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'twitter':
        await Clipboard.setData(ClipboardData(text: '${widget.content} - $postUrl'));
        Get.snackbar(
          isBn ? 'লিংক কপি হয়েছে' : 'Link copied',
          isBn ? 'এক্সে পেস্ট করুন' : 'Paste in X',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
    setState(() => showShareMenu = false);
    widget.onShare?.call();
  }

  void _handlePostMenu(String action) {
    switch (action) {
      case 'edit':
        widget.onEdit?.call();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
      case 'bookmark':
        // This is now handled in bottom sheet
        break;
      case 'report':
        Get.snackbar(isBn ? 'রিপোর্ট করা হয়েছে' : 'Reported', '',
            snackPosition: SnackPosition.BOTTOM);
        break;
      case 'block':
        Get.snackbar(isBn ? '${widget.author} ব্লক করা হয়েছে' : '${widget.author} blocked', '',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.withOpacity(0.8));
        break;
    }
    widget.onMenuClick?.call();
  }

  void _showDeleteConfirmation() {
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

  void _handleVote(int optionId) {
    if (pollState == null || pollState!.hasVoted) return;

    setState(() {
      for (var option in pollState!.options) {
        if (option.id == optionId) {
          option.votes++;
        }
      }
      pollState!.totalVotes++;
      pollState!.hasVoted = true;
      pollState!.votedOptionId = optionId;
      selectedOption = optionId;
    });

    Get.snackbar(isBn ? 'ভোট দিয়েছি!' : 'Voted!', '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8));
  }

  void _navigateToPostDetail() {
    // Create PostData from widget properties
    final postData = PostData(
      id: widget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      author: widget.author,
      authorAvatar: widget.avatar,
      timestamp: widget.timestamp,
      content: widget.content,
      type: widget.type ?? 'text',
      image: widget.image,
      images: widget.images,
      video: widget.video,
      videos: widget.videos,
      gradient: widget.gradient,
      likes: widget.likes,
      comments: widget.comments,
      shares: 0,
      isLiked: widget.isLiked,
    );

    // Navigate to PostWithComments
    Get.to(
      () => PostWithComments(
        post: postData,
        onBack: () => Get.back(),
        showInteractions: !widget.hideInteractionsInDetail,
        onAddComment: (text, replyTo) {
          // Handle comment addition
          Get.snackbar(
            isBn ? 'মন্তব্য যোগ হয়েছে' : 'Comment added',
            text,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card - wrapped in GestureDetector for navigation
          GestureDetector(
            onTap: widget.onTap ?? () => _navigateToPostDetail(),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                border: Border.all(
                  color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe6e6e6),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isShared) _buildSharedLabel(isDark),
                  // Header Section
                  _buildHeader(isDark),

                  // Content Section
                  _buildContent(isDark),

                  // Action Buttons Section
                  _buildActions(isDark),
                ],
              ),
            ),
          ),

          // Share Menu Dropdown
          if (showShareMenu) _buildShareMenu(isDark),
        ],
      );
    });
  }

  /// Show bottom sheet menu with Save option
  void _showPostMenuBottomSheet(bool isDark) {
    final currentUserId = UserInfo.userId;
    final isOwnPost = widget.userId != null && currentUserId != null && widget.userId == currentUserId;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF536471) : const Color(0xFF9D9D9D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  isBn ? 'পোস্ট অপশন' : 'Post Options',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
              ),
              
              // Save / Unsave option
              if (widget.post != null)
                _buildBottomSheetMenuItem(
                  icon: widget.post!.saved ? Icons.bookmark_remove : Icons.bookmark,
                  label: widget.post!.saved
                      ? (isBn ? 'আনসেভ করুন' : 'Unsave')
                      : (isBn ? 'সংরক্ষণ করুন' : 'Save'),
                  onTap: () async {
                    Get.back();
                    if (!Get.isRegistered<SavedPostsController>()) {
                      Get.put(SavedPostsController());
                    }
                    await Get.find<SavedPostsController>().toggleSave(widget.post!);
                    widget.onSave?.call();
                  },
                  isDark: isDark,
                  isFirst: true,
                )
              else
                Builder(
                  builder: (context) {
                    final postController = Get.find<PostController>();
                    final postId = widget.id != null ? int.tryParse(widget.id!) : null;
                    return Obx(() {
                      final isCurrentlySaved = postId != null
                          ? postController.posts.firstWhereOrNull((p) => p.id == postId)?.saved ?? false
                          : widget.isSaved;
                      return _buildBottomSheetMenuItem(
                        icon: isCurrentlySaved ? Icons.bookmark : Icons.bookmark_border,
                        label: isCurrentlySaved
                            ? (isBn ? 'সংরক্ষিত' : 'Saved')
                            : (isBn ? 'সংরক্ষণ করুন' : 'Save'),
                        onTap: () async {
                          if (isSaving || postId == null) return;
                          setState(() => isSaving = true);
                          try {
                            final success = await postController.savePost(postId);
                            Get.back();
                            if (success) {
                              Get.snackbar(isBn ? 'সংরক্ষিত' : 'Saved', '',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.withOpacity(0.8),
                                  colorText: Colors.white);
                              widget.onSave?.call();
                            } else {
                              Get.snackbar(isBn ? 'ত্রুটি' : 'Error', isBn ? 'পোস্ট সংরক্ষণ করতে ব্যর্থ' : 'Failed to save post',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  colorText: Colors.white);
                            }
                          } catch (e) {
                            Get.back();
                            Get.snackbar(isBn ? 'ত্রুটি' : 'Error', e.toString(),
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.withOpacity(0.8),
                                colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isSaving = false);
                          }
                        },
                        isDark: isDark,
                        isLoading: isSaving,
                        isFirst: true,
                      );
                    });
                  },
                ),
              
              // Delete shared post (only when isShared)
              if (widget.isShared && widget.onDeleteSharedPost != null)
                _buildBottomSheetMenuItem(
                  icon: Icons.delete_outline,
                  label: isBn ? 'শেয়ার করা পোস্ট মুছুন' : 'Delete shared post',
                  onTap: () {
                    Get.back();
                    widget.onDeleteSharedPost?.call();
                  },
                  isDark: isDark,
                ),
              
              // Show Edit/Delete only for own posts
              if (isOwnPost) ...[
                _buildBottomSheetMenuItem(
                  icon: Icons.edit_outlined,
                  label: isBn ? 'সম্পাদনা করুন' : 'Edit',
                  onTap: () {
                    Get.back();
                    widget.onEdit?.call();
                  },
                  isDark: isDark,
                ),
                _buildBottomSheetMenuItem(
                  icon: Icons.delete_outline,
                  label: isBn ? 'মুছে ফেলুন' : 'Delete',
                  onTap: () {
                    Get.back();
                    _showDeleteConfirmation();
                  },
                  isDark: isDark,
                ),
              ],
              
              // Show Report/Block only for other users' posts
              if (!isOwnPost) ...[
                _buildBottomSheetMenuItem(
                  icon: Icons.flag_outlined,
                  label: isBn ? 'রিপোর্ট করুন' : 'Report',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      isBn ? 'রিপোর্ট করা হয়েছে' : 'Reported',
                      '',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    widget.onMenuClick?.call();
                  },
                  isDark: isDark,
                ),
                _buildBottomSheetMenuItem(
                  icon: Icons.block,
                  label: isBn ? 'ব্লক করুন' : 'Block',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      isBn ? '${widget.author} ব্লক করা হয়েছে' : '${widget.author} blocked',
                      '',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange.withOpacity(0.8),
                    );
                    widget.onMenuClick?.call();
                  },
                  isDark: isDark,
                  isLast: true,
                ),
              ] else ...[
                _buildBottomSheetMenuItem(
                  icon: Icons.flag_outlined,
                  label: isBn ? 'রিপোর্ট করুন' : 'Report',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      isBn ? 'রিপোর্ট করা হয়েছে' : 'Reported',
                      '',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    widget.onMenuClick?.call();
                  },
                  isDark: isDark,
                  isLast: true,
                ),
              ],
              
              // Cancel button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe6e6e6),
                        ),
                      ),
                    ),
                    child: Text(
                      isBn ? 'বাতিল' : 'Cancel',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0f1419),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Bottom padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isLoading = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: isFirst ? BorderSide.none : BorderSide(
              color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe6e6e6),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.lightPrimary,
                ),
              )
            else
              Icon(
                icon,
                size: 22,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0f1419),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedLabel(bool isDark) {
    String timeStr = '';
    if (widget.sharedAt != null) {
      final d = widget.sharedAt!;
      timeStr = '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Row(
        children: [
          Icon(
            Icons.share,
            size: 14,
            color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
          ),
          const SizedBox(width: 6),
          Text(
            isBn ? 'শেয়ার করা' : 'Shared',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
            ),
          ),
          if (timeStr.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
              ),
            ),
          ],
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
          ClipOval(
            child: Image.network(
              _avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.author.isNotEmpty ? widget.author[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.author,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0f1419),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.verified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.lightPrimary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.groupName != null
                      ? '${widget.groupName} · ${widget.timestamp}'
                      : widget.timestamp,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
                  ),
                ),
              ],
            ),
          ),

          // Menu Button
          GestureDetector(
            onTap: () => _showPostMenuBottomSheet(isDark),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: _ThreeDotsVerticalPainter(
                    color: const Color(0xFF8E8E8E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title (matches Home feed)
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Text(
              widget.title!,
              style: GoogleFonts.notoSansBengali(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
          ),
        // Text Content (except for gradient type)
        if (widget.type != 'gradient')
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Text(
              widget.content,
              style: GoogleFonts.roboto(
                fontSize: 15,
                height: 1.27,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
          ),

        // Gradient Text Post
        if (widget.type == 'gradient' && widget.gradient != null)
          _buildGradientContent(isDark),

        // Image Post
        if (widget.type == 'image' && widget.image != null)
          _buildImageContent(isDark),

        // Video Post
        if (widget.type == 'video' && widget.video != null)
          _buildVideoContent(isDark),

        // Multi Image Post
        if (widget.type == 'multiImage' && widget.images != null)
          _buildMultiImageContent(isDark),

        // Multi Video Post
        if (widget.type == 'multiVideo' && widget.videos != null)
          _buildMultiVideoContent(isDark),

        // Poll Post
        if (widget.type == 'poll' && pollState != null)
          _buildPollContent(isDark),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGradientContent(bool isDark) {
    List<Color> gradientColors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
    ];

    if (widget.gradient != null) {
      final hexPattern = RegExp(r'#([0-9A-Fa-f]{6})');
      final matches = hexPattern.allMatches(widget.gradient!);
      if (matches.length >= 2) {
        gradientColors = matches.map((match) {
          final hex = match.group(1)!;
          return Color(int.parse('FF$hex', radix: 16));
        }).take(2).toList();
      }
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      padding: const EdgeInsets.all(50),
      child: Center(
        child: Text(
          widget.content,
          style: GoogleFonts.notoSansBengali(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildImageContent(bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showMediaViewer = true;
          mediaViewerIndex = 0;
        });
        _showMediaViewer([widget.image!], 'image', 0);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Image.network(
          widget.image!,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 200,
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
            child: const Center(child: Icon(Icons.broken_image, size: 48)),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(bool isDark) {
    // Placeholder for video - can be enhanced with video_player package
    return Container(
      height: 300,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              isBn ? 'ভিডিও প্লেয়ার' : 'Video Player',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiImageContent(bool isDark) {
    final images = widget.images!;
    final count = images.length;

    return _MultiMediaGrid(
      media: images,
      type: 'image',
      onMediaClick: (index) => _showMediaViewer(images, 'image', index),
    );
  }

  Widget _buildMultiVideoContent(bool isDark) {
    final videos = widget.videos!;

    return _MultiMediaGrid(
      media: videos,
      type: 'video',
      onMediaClick: (index) => _showMediaViewer(videos, 'video', index),
    );
  }

  Widget _buildPollContent(bool isDark) {
    if (pollState == null) return const SizedBox();

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
            // Poll Question
            Text(
              pollState!.question,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
            const SizedBox(height: 16),

            // Poll Options
            ...pollState!.options.map((option) {
              final percentage = pollState!.totalVotes > 0
                  ? ((option.votes / pollState!.totalVotes) * 100).round()
                  : 0;
              final isVoted = pollState!.hasVoted && pollState!.votedOptionId == option.id;
              final maxVotes = pollState!.options.map((o) => o.votes).reduce((a, b) => a > b ? a : b);
              final isWinning = pollState!.hasVoted && option.votes == maxVotes;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: pollState!.hasVoted ? null : () => _handleVote(option.id),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isVoted
                          ? AppColors.lightPrimary.withOpacity(isDark ? 0.1 : 0.05)
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
                        if (pollState!.hasVoted)
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isWinning
                                      ? AppColors.lightPrimary.withOpacity(0.2)
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              if (isVoted)
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.lightPrimary,
                                ),
                              if (isVoted) const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: isVoted
                                        ? AppColors.lightPrimary
                                        : (isDark ? Colors.white : const Color(0xFF0f1419)),
                                    fontWeight: isVoted ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (pollState!.hasVoted)
                                Text(
                                  '$percentage%',
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isWinning
                                        ? AppColors.lightPrimary
                                        : (isDark
                                            ? const Color(0xFF8e8e8e)
                                            : const Color(0xFF536471)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Poll Footer
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe1e4e8),
                  ),
                ),
              ),
              child: Text(
                '${pollState!.totalVotes} ${isBn ? 'ভোট' : 'votes'}',
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
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      child: Row(
        children: [
          // Like Button
          _ActionPillButton(
            icon: widget.isLiked ? Icons.favorite : Icons.favorite_border,
            label: widget.likes >= 1000
                ? '${(widget.likes / 1000).toStringAsFixed(1)}k'
                : '${widget.likes}',
            isActive: widget.isLiked,
            activeColor: AppColors.lightPrimary,
            onTap: widget.onLike,
            isDark: isDark,
          ),
          const SizedBox(width: 12),

          // Comment Button - navigates to post with comments
          _ActionPillButton(
            icon: Icons.chat_bubble_outline,
            label: '${widget.comments}',
            isActive: false,
            activeColor: const Color(0xFFB8DED6),
            hoverColor: const Color(0xFFB8DED6),
            onTap: () {
              // Call the onComment callback first
              widget.onComment?.call();
              // Then navigate to post detail with comments
              _navigateToPostDetail();
            },
            isDark: isDark,
          ),

          const Spacer(),

          // Share Button - toggles share menu
          _ActionPillButton(
            icon: Icons.share_outlined,
            label: isBn ? 'শেয়ার' : 'Share',
            isActive: false,
            activeColor: const Color(0xFFB8DED6),
            hoverColor: const Color(0xFFB8DED6),
            onTap: () {
              final wasOpen = showShareMenu;
              setState(() => showShareMenu = !showShareMenu);
              // Call onShare callback when menu is opened (not when closing)
              if (!wasOpen) {
                widget.onShare?.call();
              }
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildShareMenu(bool isDark) {
    return Positioned(
      right: 18,
      bottom: 70,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        child: Container(
          constraints: const BoxConstraints(minWidth: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe6e6e6),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                icon: Icons.share,
                label: isBn ? 'নেটিভ শেয়ার' : 'Native Share',
                onTap: () => _handleShare('native'),
                isDark: isDark,
                isFirst: true,
              ),
              _buildMenuItem(
                icon: Icons.copy,
                label: isBn ? 'লিংক কপি করুন' : 'Copy link',
                onTap: () => _handleShare('copy'),
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Icons.chat,
                label: isBn ? 'ওয়াটসঅ্যাপ' : 'WhatsApp',
                onTap: () => _handleShare('whatsapp'),
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Icons.facebook,
                label: isBn ? 'ফেসবুক' : 'Facebook',
                onTap: () => _handleShare('facebook'),
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Icons.alternate_email,
                label: isBn ? 'এক্স (টুইটার)' : 'X (Twitter)',
                onTap: () => _handleShare('twitter'),
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostMenu(bool isDark) {
    // DEPRECATED: This method is no longer used - replaced with bottom sheet
    // Keeping for backward compatibility but should be removed
    return const SizedBox.shrink();
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(10) : Radius.zero,
        bottom: isLast ? const Radius.circular(10) : Radius.zero,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF536471)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.notoSansBengali(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaViewer(List<String> media, String type, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _MediaViewerDialog(
        media: media,
        type: type,
        initialIndex: initialIndex,
        author: widget.author,
        avatar: _avatarUrl,
        timestamp: widget.timestamp,
        content: widget.content,
        likes: widget.likes,
        comments: widget.comments,
        isLiked: widget.isLiked,
        onLike: widget.onLike,
        onComment: widget.onComment,
        onShare: widget.onShare,
        isBn: isBn,
      ),
    );
  }
}

// ==================== Action Pill Button Widget ====================

class _ActionPillButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color? hoverColor;
  final VoidCallback? onTap;
  final bool isDark;

  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.hoverColor,
    this.onTap,
    required this.isDark,
  });

  @override
  State<_ActionPillButton> createState() => _ActionPillButtonState();
}

class _ActionPillButtonState extends State<_ActionPillButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = widget.hoverColor ?? const Color(0xFFB8DED6);
    final borderColor = _isHovered && !widget.isActive
        ? hoverColor
        : (widget.isActive
            ? widget.activeColor
            : (widget.isDark ? const Color(0xFF104050) : const Color(0xFFe6e6e6)));
    final textColor = _isHovered && !widget.isActive
        ? hoverColor
        : (widget.isActive ? widget.activeColor : const Color(0xFF9D9D9D));
    final iconColor = _isHovered && !widget.isActive
        ? hoverColor
        : (widget.isActive ? widget.activeColor : const Color(0xFF9D9D9D));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.activeColor.withOpacity(0.1)
                : (widget.isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf5f5f5)),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Multi Media Grid Widget ====================

class _MultiMediaGrid extends StatelessWidget {
  final List<String> media;
  final String type;
  final Function(int) onMediaClick;

  const _MultiMediaGrid({
    required this.media,
    required this.type,
    required this.onMediaClick,
  });

  @override
  Widget build(BuildContext context) {
    final count = media.length;

    if (count == 1) {
      return GestureDetector(
        onTap: () => onMediaClick(0),
        child: _buildMediaItem(media[0], 0),
      );
    }

    if (count == 2) {
      return Row(
        children: [
          Expanded(child: GestureDetector(onTap: () => onMediaClick(0), child: _buildMediaItem(media[0], 0))),
          const SizedBox(width: 2),
          Expanded(child: GestureDetector(onTap: () => onMediaClick(1), child: _buildMediaItem(media[1], 1))),
        ],
      );
    }

    if (count == 3) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(onTap: () => onMediaClick(0), child: _buildMediaItem(media[0], 0)),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: GestureDetector(onTap: () => onMediaClick(1), child: _buildMediaItem(media[1], 1))),
                const SizedBox(height: 2),
                Expanded(child: GestureDetector(onTap: () => onMediaClick(2), child: _buildMediaItem(media[2], 2))),
              ],
            ),
          ),
        ],
      );
    }

    // 4 or more images
    return SizedBox(
      height: 300,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: count > 4 ? 4 : count,
        itemBuilder: (context, index) {
          if (index == 3 && count > 4) {
            return GestureDetector(
              onTap: () => onMediaClick(index),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMediaItem(media[index], index),
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
              ),
            );
          }
          return GestureDetector(
            onTap: () => onMediaClick(index),
            child: _buildMediaItem(media[index], index),
          );
        },
      ),
    );
  }

  Widget _buildMediaItem(String url, int index) {
    if (type == 'video') {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white70),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}

// ==================== Media Viewer Dialog ====================

class _MediaViewerDialog extends StatefulWidget {
  final List<String> media;
  final String type;
  final int initialIndex;
  final String author;
  final String avatar;
  final String timestamp;
  final String content;
  final int likes;
  final int comments;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isBn;

  const _MediaViewerDialog({
    required this.media,
    required this.type,
    required this.initialIndex,
    required this.author,
    required this.avatar,
    required this.timestamp,
    required this.content,
    required this.likes,
    required this.comments,
    required this.isLiked,
    this.onLike,
    this.onComment,
    this.onShare,
    required this.isBn,
  });

  @override
  State<_MediaViewerDialog> createState() => _MediaViewerDialogState();
}

class _MediaViewerDialogState extends State<_MediaViewerDialog> {
  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Full screen media viewer
          PageView.builder(
            controller: pageController,
            itemCount: widget.media.length,
            onPageChanged: (index) => setState(() => currentIndex = index),
            itemBuilder: (context, index) {
              if (widget.type == 'video') {
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, size: 80, color: Colors.white70),
                  ),
                );
              }
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.media[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),

          // Index indicator
          if (widget.media.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentIndex + 1} / ${widget.media.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          // Bottom info panel
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          widget.avatar,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.author,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.timestamp,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.content,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildViewerAction(
                        Icons.favorite,
                        '${widget.likes}',
                        widget.isLiked,
                        widget.onLike,
                      ),
                      _buildViewerAction(
                        Icons.chat_bubble_outline,
                        '${widget.comments}',
                        false,
                        widget.onComment,
                      ),
                      _buildViewerAction(
                        Icons.share,
                        widget.isBn ? 'শেয়ার' : 'Share',
                        false,
                        widget.onShare,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerAction(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.lightPrimary : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.lightPrimary : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Three Dots Vertical Painter ====================

class _ThreeDotsVerticalPainter extends CustomPainter {
  final Color color;

  _ThreeDotsVerticalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = size.width * 0.1;
    final centerX = size.width / 2;

    // Top dot
    canvas.drawCircle(Offset(centerX, size.height * 0.2), radius, paint);
    // Middle dot
    canvas.drawCircle(Offset(centerX, size.height * 0.5), radius, paint);
    // Bottom dot
    canvas.drawCircle(Offset(centerX, size.height * 0.8), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
