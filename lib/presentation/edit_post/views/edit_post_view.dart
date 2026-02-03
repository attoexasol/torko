import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/home/controllers/post_controller.dart';
import 'package:torko/data/models/post_model.dart';
import 'package:torko/core/services/user_info.dart';

class EditPostView extends StatefulWidget {
  final PostModel post;

  const EditPostView({super.key, required this.post});

  @override
  State<EditPostView> createState() => _EditPostViewState();
}

class _EditPostViewState extends State<EditPostView> {
  final appController = Get.find<AppController>();
  final postController = Get.find<PostController>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  List<String> existingImageUrls = [];
  bool imagesChanged = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.post.postTitle;
    descriptionController.text = widget.post.postDescription;
    existingImageUrls = List.from(widget.post.postImages);
    
    // Load existing images into selectedImages if needed
    // Note: We can't convert URLs to Files, so we'll track them separately
  }

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
        setState(() {
          imagesChanged = true;
          postController.selectedImages.value = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'ত্রুটি' : 'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      existingImageUrls.removeAt(index);
      imagesChanged = true;
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      postController.selectedImages.removeAt(index);
    });
  }

  Future<void> _handleUpdate() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty && description.isEmpty && 
        postController.selectedImages.isEmpty && existingImageUrls.isEmpty) {
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'সতর্কতা' : 'Warning',
        appController.language == AppLanguage.bn 
            ? 'কিছু লিখুন বা ছবি যোগ করুন' 
            : 'Please write something or add images',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Use title if provided, otherwise use description
    final postTitle = title.isNotEmpty ? title : (description.isNotEmpty ? description.substring(0, description.length > 50 ? 50 : description.length) : 'Untitled Post');
    final postDescription = description.isNotEmpty ? description : '';

    final success = await postController.updatePost(
      postId: widget.post.id,
      title: postTitle,
      description: postDescription,
      images: postController.selectedImages.toList(),
      existingImageUrls: existingImageUrls, // Pass existing images to preserve them
    );

    if (success) {
      Get.back();
      Get.snackbar(
        appController.language == AppLanguage.bn ? 'সফল' : 'Success',
        appController.language == AppLanguage.bn ? 'পোস্ট আপডেট হয়েছে' : 'Post updated',
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
            : (appController.language == AppLanguage.bn ? 'পোস্ট আপডেট করতে ব্যর্থ' : 'Failed to update post'),
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
      final canUpdate = (titleController.text.trim().isNotEmpty || 
                        descriptionController.text.trim().isNotEmpty || 
                        postController.selectedImages.isNotEmpty ||
                        existingImageUrls.isNotEmpty) &&
                        !postController.isUpdating.value;
      
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
            isBn ? 'পোস্ট সম্পাদনা করুন' : 'Edit Post',
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
                onTap: canUpdate ? _handleUpdate : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: canUpdate 
                        ? AppColors.lightPrimary 
                        : AppColors.lightPrimary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: postController.isUpdating.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isBn ? 'আপডেট করুন' : 'Update',
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

                    // Existing Images Preview
                    if (existingImageUrls.isNotEmpty) ...[
                      Text(
                        isBn ? 'বর্তমান ছবি' : 'Current Images',
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
                          itemCount: existingImageUrls.length,
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
                                      child: Image.network(
                                        'https://torko.attoexasolutions.com/${existingImageUrls[index]}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.broken_image,
                                          color: isDark ? Colors.white54 : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _removeExistingImage(index),
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

                    // New Selected Images Preview
                    Obx(() {
                      if (postController.selectedImages.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'নতুন ছবি' : 'New Images',
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
                                          onTap: () => _removeNewImage(index),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMediaOption(
                    icon: Icons.image,
                    label: isBn ? 'ছবি যোগ করুন' : 'Add Photo',
                    color: Colors.green,
                    isDark: isDark,
                    onTap: _pickImages,
                  ),
                ],
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

