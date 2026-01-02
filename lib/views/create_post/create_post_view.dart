import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/post_controller.dart';
import '../../services/user_info.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final appController = Get.find<AppController>();
  final postController = Get.put(PostController());
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        // Clear video if images are selected (typically you post either images or video, not both)
        if (postController.selectedVideo.value != null) {
          postController.selectedVideo.value = null;
        }
        postController.selectedImages.value = pickedFiles.map((file) => File(file.path)).toList();
      }
    } catch (e) {
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10), // Limit to 10 minutes
      );
      if (pickedFile != null) {
        // Check file size (limit to 100MB for videos)
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        const maxSize = 100 * 1024 * 1024; // 100MB
        
        if (fileSize > maxSize) {
          Get.snackbar(
            appController.language == AppLanguage.bn ? 'সতর্কতা' : 'Warning',
            appController.language == AppLanguage.bn 
                ? 'ভিডিও খুব বড়। সর্বোচ্চ 100MB' 
                : 'Video is too large. Maximum 100MB',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
        
        // Clear images if video is selected (typically you post either images or video, not both)
        if (postController.selectedImages.isNotEmpty) {
          postController.selectedImages.clear();
        }
        
        postController.selectedVideo.value = file;
      }
    } catch (e) {
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handlePost() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty && 
        description.isEmpty && 
        postController.selectedImages.isEmpty && 
        postController.selectedVideo.value == null) {
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'সতর্কতা' : 'Warning',
        appController.language == AppLanguage.bn 
            ? 'কিছু লিখুন বা ছবি/ভিডিও যোগ করুন' 
            : 'Please write something or add images/video',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Use title if provided, otherwise use description
    final postTitle = title.isNotEmpty ? title : (description.isNotEmpty ? description.substring(0, description.length > 50 ? 50 : description.length) : 'Untitled Post');
    final postDescription = description.isNotEmpty ? description : '';

    final success = await postController.createPost(
      title: postTitle,
      description: postDescription,
      images: postController.selectedImages.toList(),
      video: postController.selectedVideo.value,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'সফল' : 'Success',
        appController.language == AppLanguage.bn ? 'পোস্ট প্রকাশিত হয়েছে' : 'Post published',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        postController.errorMessage.value.isNotEmpty 
            ? postController.errorMessage.value 
            : (appController.language == AppLanguage.bn ? 'পোস্ট প্রকাশ করতে ব্যর্থ' : 'Failed to publish post'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;
      final canPost = (titleController.text.trim().isNotEmpty || 
                      descriptionController.text.trim().isNotEmpty || 
                      postController.selectedImages.isNotEmpty ||
                      postController.selectedVideo.value != null) &&
                      !postController.isCreating.value;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            onPressed: () {
              postController.clearForm();
              Get.back();
            },
          ),
          title: Text(
            isBn ? 'নতুন পোস্ট' : 'New Post',
            style: TextStyle(
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: canPost ? _handlePost : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: canPost 
                        ? AppColors.lightPrimary 
                        : AppColors.lightPrimary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: postController.isCreating.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isBn ? 'পোস্ট করুন' : 'Post',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.2),
                          child: Text(
                            (UserInfo.fullname?.isNotEmpty ?? false) 
                                ? UserInfo.fullname![0].toUpperCase() 
                                : 'U',
                            style: TextStyle(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (UserInfo.fullname?.isNotEmpty ?? false) ? UserInfo.fullname! : 'User',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.public,
                                      size: 12,
                                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isBn ? 'সবাই' : 'Everyone',
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Title Input
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: isBn ? 'পোস্টের শিরোনাম (ঐচ্ছিক)' : 'Post Title (Optional)',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description Input
                    TextField(
                      controller: descriptionController,
                      maxLines: null,
                      minLines: 5,
                      style: TextStyle(
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: isBn 
                            ? 'আপনি কি ভাবছেন?' 
                            : "What's on your mind?",
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Selected Video Preview
                    Obx(() {
                      if (postController.selectedVideo.value == null) {
                        return const SizedBox.shrink();
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'নির্বাচিত ভিডিও' : 'Selected Video',
                            style: TextStyle(
                              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                  color: Colors.black,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      const Icon(
                                        Icons.videocam,
                                        color: Colors.white54,
                                        size: 64,
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => postController.removeVideo(),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // Selected Images Preview
                    Obx(() {
                      if (postController.selectedImages.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'নির্বাচিত ছবি' : 'Selected Images',
                            style: TextStyle(
                              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: postController.selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            postController.selectedImages[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => postController.removeImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Media options
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 300;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: _buildMediaOption(
                          icon: Icons.image,
                          label: isBn ? 'ছবি' : 'Photo',
                          color: Colors.green,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: _pickImages,
                        ),
                      ),
                      Flexible(
                        child: _buildMediaOption(
                          icon: Icons.videocam,
                          label: isBn ? 'ভিডিও' : 'Video',
                          color: Colors.red,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: _pickVideo,
                        ),
                      ),
                      Flexible(
                        child: _buildMediaOption(
                          icon: Icons.poll,
                          label: isBn ? 'পোল' : 'Poll',
                          color: Colors.orange,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: () {
                            Get.snackbar(
                              isBn ? 'সতর্কতা' : 'Notice',
                              isBn ? 'পোল শীঘ্রই আসছে' : 'Poll coming soon',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                      Flexible(
                        child: _buildMediaOption(
                          icon: Icons.location_on,
                          label: isBn ? 'স্থান' : 'Location',
                          color: Colors.blue,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: () {
                            Get.snackbar(
                              isBn ? 'সতর্কতা' : 'Notice',
                              isBn ? 'স্থান শীঘ্রই আসছে' : 'Location coming soon',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmall ? 20 : 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              fontSize: isSmall ? 10 : 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
