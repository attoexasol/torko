import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/comment_controller.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/comment_model.dart';
import '../../widgets/comment_widget.dart';

class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final appController = Get.find<AppController>();
  late final CommentController commentController;
  int? postId;

  @override
  void initState() {
    super.initState();
    commentController = Get.put(CommentController());
    
    // Get post ID from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      print('DEBUG PostDetail: args = $args');
      
      if (args != null) {
        if (args is Map && args['postId'] != null) {
          final id = args['postId'];
          print('DEBUG PostDetail: postId from args = $id (${id.runtimeType})');
          if (id is int) {
            postId = id;
          } else if (id is String) {
            postId = int.tryParse(id);
          }
        }
      }
      
      // Also try to get from postDetailData
      final postData = appController.postDetailData;
      print('DEBUG PostDetail: postData = $postData');
      
      if (postData != null && postData['id'] != null) {
        final id = postData['id'];
        print('DEBUG PostDetail: id from postData = $id (${id.runtimeType})');
        if (postId == null) {
          if (id is int) {
            postId = id;
          } else if (id is String) {
            postId = int.tryParse(id);
          }
        }
      }
      
      print('DEBUG PostDetail: Final postId = $postId');
      
      // Load comments if we have a post ID
      if (postId != null && postId! > 0) {
        print('DEBUG PostDetail: Loading comments for postId = $postId');
        commentController.loadComments(postId!);
      } else {
        print('DEBUG PostDetail: No valid postId found');
      }
      
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Clear comment state when leaving
    commentController.clearComments();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;
      final postData = appController.postDetailData;
      
      if (postData == null) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
            child: Text(
              isBn ? 'পোস্ট পাওয়া যায়নি' : 'Post not found',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
        );
      }
      
      // Get post info
      final authorName = postData['author'] ?? postData['createdBy']?['name'] ?? 'User';
      final authorImage = postData['authorImage'] ?? postData['createdBy']?['profile_image'];
      final content = postData['content'] ?? postData['post_description'] ?? '';
      final title = postData['title'] ?? postData['post_title'] ?? '';
      final timestamp = postData['timestamp'] ?? _formatTimestamp(postData['created_at']);
      final likes = postData['likes'] ?? postData['post_like_count'] ?? 0;
      final commentCount = postData['comments'] ?? postData['post_comment_count'] ?? 0;
      final images = _getImages(postData);
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                    onPressed: () {
                      appController.closePostDetail();
                      Get.back();
                    },
                  ),
                  Text(
                    isBn ? 'পোস্ট' : 'Post',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Author
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _buildAuthorAvatar(authorName, authorImage, isDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        authorName,
                                        style: GoogleFonts.notoSansBengali(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: AppColors.lightPrimary,
                                    ),
                                  ],
                                ),
                                Text(
                                  timestamp,
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Post Title
                    if (title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          title,
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            height: 1.4,
                          ),
                        ),
                      ),
                    
                    // Post Content
                    if (content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Text(
                          content,
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 16,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            height: 1.5,
                          ),
                        ),
                      ),
                    
                    // Post Images
                    if (images.isNotEmpty) _buildImages(images, isDark),
                    
                    // Post Stats
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '$likes',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.chat_bubble_outline,
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Obx(() => Text(
                            '${commentController.commentCount}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            ),
                          )),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Divider(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      height: 1,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Comments Section
                    if (postId != null && postId! > 0)
                      CommentSection(
                        postId: postId!,
                        showTitle: true,
                      ),
                    
                    const SizedBox(height: 100), // Space for input field
                  ],
                ),
              ),
            ),
            
            // Comment Input
            if (postId != null && postId! > 0)
              CommentInputField(
                postId: postId!,
                commentController: commentController,
                isDark: isDark,
                isBn: isBn,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAuthorAvatar(String name, String? imageUrl, bool isDark) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
        backgroundImage: CachedNetworkImageProvider(imageUrl),
      );
    }
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: AppColors.lightPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  List<String> _getImages(Map<String, dynamic> postData) {
    final postImages = postData['post_images'];
    final image = postData['image'];
    final images = postData['images'];
    
    if (postImages is List && postImages.isNotEmpty) {
      return postImages.map<String>((e) {
        final url = e.toString();
        if (url.startsWith('http')) return url;
        return 'https://torko.attoexasolutions.com/$url';
      }).toList();
    }
    
    if (images is List && images.isNotEmpty) {
      return images.map<String>((e) => e.toString()).toList();
    }
    
    if (image != null && image.toString().isNotEmpty) {
      return [image.toString()];
    }
    
    return [];
  }

  Widget _buildImages(List<String> images, bool isDark) {
    if (images.length == 1) {
      return CachedNetworkImage(
        imageUrl: images[0],
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 300,
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 300,
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
          child: const Icon(Icons.broken_image, size: 48),
        ),
      );
    }
    
    // Multiple images grid
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < images.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: images[index],
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 200,
                  height: 200,
                  color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 200,
                  height: 200,
                  color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dateTime = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      final isBn = appController.language == AppLanguage.bn;
      
      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}${isBn ? 'দি' : 'd'}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}${isBn ? 'ঘ' : 'h'}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}${isBn ? 'মি' : 'm'}';
      } else {
        return isBn ? 'এখনই' : 'now';
      }
    } catch (e) {
      return '';
    }
  }
}
