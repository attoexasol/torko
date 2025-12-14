import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final appController = Get.find<AppController>();
  final contentController = TextEditingController();

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
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
            onPressed: () => Get.back(),
          ),
          title: Text(
            language == AppLanguage.bn ? 'নতুন পোস্ট' : 'New Post',
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
                onTap: contentController.text.isNotEmpty ? () {
                  Get.back();
                  Get.snackbar(
                    language == AppLanguage.bn ? 'সফল' : 'Success',
                    language == AppLanguage.bn ? 'পোস্ট প্রকাশিত হয়েছে' : 'Post published',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.lightPrimary,
                    colorText: Colors.white,
                  );
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: contentController.text.isNotEmpty 
                        ? AppColors.lightPrimary 
                        : AppColors.lightPrimary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      language == AppLanguage.bn ? 'পোস্ট করুন' : 'Post',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
                  children: [
                    // User info row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.2),
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language == AppLanguage.bn ? 'ব্যবহারকারী' : 'User Name',
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
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 12,
                                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    language == AppLanguage.bn ? 'সবাই' : 'Everyone',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Content Input
                    TextField(
                      controller: contentController,
                      maxLines: null,
                      minLines: 5,
                      style: TextStyle(
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: language == AppLanguage.bn 
                            ? 'আপনি কি ভাবছেন?' 
                            : "What's on your mind?",
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
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
                          label: language == AppLanguage.bn ? 'ছবি' : 'Photo',
                          color: Colors.green,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: () {},
                        ),
                      ),
                      Flexible(
                        child: _buildMediaOption(
                          icon: Icons.videocam,
                          label: language == AppLanguage.bn ? 'ভিডিও' : 'Video',
                          color: Colors.red,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: () {},
                        ),
                      ),
                      Flexible(
                        child: _buildMediaOption(
                          icon: Icons.poll,
                          label: language == AppLanguage.bn ? 'পোল' : 'Poll',
                          color: Colors.orange,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: () {},
                        ),
                      ),
                      Flexible(
                        child: _buildMediaOption(
                          icon: Icons.location_on,
                          label: language == AppLanguage.bn ? 'স্থান' : 'Location',
                          color: Colors.blue,
                          isDark: isDark,
                          isSmall: isSmallScreen,
                          onTap: () {},
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
