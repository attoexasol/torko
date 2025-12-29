import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/home_header.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final appController = Get.find<AppController>();

    return Obx(() {
      final isDark = appController.isDarkMode;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: Stack(
          children: [
            // Main content
            CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                // Space for header
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 60,
                  ),
                ),
                
                // Tabs Section
                SliverToBoxAdapter(
                  child: _buildTabs(controller, appController, isDark),
                ),
                
                // Posts Feed
                Obx(() => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final posts = controller.filteredPosts;
                      if (index >= posts.length) return null;
                      
                      final post = posts[index];
                      return _HomePostCard(
                        post: post,
                        controller: controller,
                        appController: appController,
                        isDark: isDark,
                      );
                    },
                    childCount: controller.filteredPosts.length,
                  ),
                )),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
            
            // Fixed Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Obx(() => AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: controller.showHeader.value ? Offset.zero : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: controller.showHeader.value ? 1.0 : 0.0,
                  child: Container(
                    color: isDark ? AppColors.darkBackground : Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: const HomeHeader(),
                    ),
                  ),
                ),
              )),
            ),
            
            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNav(
                activeScreen: 'home',
                hideNav: appController.hideBottomNav,
                onNavigate: controller.onNavigate,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabs(HomeController controller, AppController appController, bool isDark) {
    final isBn = appController.language == AppLanguage.bn;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
        children: [
          _TabButton(
            label: isBn ? 'আপনার জন্য' : 'For You',
            isActive: controller.activeTab.value == 'forYou',
            onTap: () => controller.setActiveTab('forYou'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: isBn ? 'ফলোয়িং' : 'Following',
            isActive: controller.activeTab.value == 'following',
            onTap: () => controller.setActiveTab('following'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: isBn ? 'ট্রেন্ডিং' : 'Trending',
            isActive: controller.activeTab.value == 'trending',
            onTap: () => controller.setActiveTab('trending'),
            isDark: isDark,
            icon: Icons.local_fire_department,
          ),
        ],
      )),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;
  final IconData? icon;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.lightPrimary.withOpacity(0.15)
              : (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.lightPrimary
                : (isDark ? const Color(0xFF104050) : const Color(0xFFE6E6E6)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? AppColors.lightPrimary
                    : (isDark ? const Color(0xFF8E8E8E) : const Color(0xFF536471)),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.notoSansBengali(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.lightPrimary
                    : (isDark ? const Color(0xFF8E8E8E) : const Color(0xFF536471)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePostCard extends StatelessWidget {
  final Post post;
  final HomeController controller;
  final AppController appController;
  final bool isDark;

  const _HomePostCard({
    required this.post,
    required this.controller,
    required this.appController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = appController.language == AppLanguage.bn;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe6e6e6),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isBn),
          
          // Content
          _buildContent(),
          
          // Actions
          _buildActions(isBn),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isBn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
            backgroundImage: post.authorAvatar != null
                ? CachedNetworkImageProvider(post.authorAvatar!)
                : null,
            child: post.authorAvatar == null
                ? Text(
                    post.author.isNotEmpty ? post.author[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: AppColors.lightPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name row
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.author,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0f1419),
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
                
                // Group name if exists
                if (post.groupName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: 12,
                        color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF536471),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          post.groupName!,
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF536471),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Timestamp
                Text(
                  post.timestamp,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF536471),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu button
          _buildMenuButton(isBn),
        ],
      ),
    );
  }

  Widget _buildMenuButton(bool isBn) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        size: 20,
        color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF8E8E8E),
      ),
      color: isDark ? const Color(0xFF0d3a4a) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF104050) : const Color(0xFFE6E6E6),
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'save':
            controller.handleSavePost(post.id);
            break;
          case 'follow':
            controller.handleFollowUser(post.author);
            break;
          case 'hide':
            controller.handleHidePost(post.id);
            break;
          case 'report':
            controller.handleReportPost(post.id);
            break;
          case 'copy':
            controller.handleCopyLink(post.id);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'save',
          child: Obx(() => Row(
            children: [
              Icon(
                controller.isPostSaved(post.id) 
                    ? Icons.bookmark 
                    : Icons.bookmark_border,
                size: 18,
                color: controller.isPostSaved(post.id)
                    ? AppColors.lightPrimary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 12),
              Text(
                controller.isPostSaved(post.id)
                    ? (isBn ? 'আনসেভ করুন' : 'Unsave')
                    : (isBn ? 'সেভ করুন' : 'Save'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          )),
        ),
        PopupMenuItem(
          value: 'follow',
          child: Obx(() => Row(
            children: [
              Icon(
                controller.isFollowing(post.author)
                    ? Icons.person_remove
                    : Icons.person_add,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(width: 12),
              Text(
                controller.isFollowing(post.author)
                    ? (isBn ? 'আনফলো করুন' : 'Unfollow')
                    : (isBn ? 'ফলো করুন' : 'Follow'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          )),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(
                Icons.link,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(width: 12),
              Text(
                isBn ? 'লিংক কপি করুন' : 'Copy link',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'hide',
          child: Row(
            children: [
              Icon(
                Icons.visibility_off,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(width: 12),
              Text(
                isBn ? 'পোস্ট লুকান' : 'Hide post',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              const Icon(
                Icons.flag,
                size: 18,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                isBn ? 'রিপোর্ট করুন' : 'Report',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (post.type) {
      case 'gradient':
        return _buildGradientContent();
      case 'image':
        return _buildImageContent();
      case 'multiImage':
        return _buildMultiImageContent();
      case 'poll':
        return _buildPollContent();
      default:
        return _buildTextContent();
    }
  }

  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        post.content,
        style: GoogleFonts.notoSansBengali(
          fontSize: 15,
          height: 1.4,
          color: isDark ? Colors.white : const Color(0xFF0f1419),
        ),
      ),
    );
  }

  Widget _buildGradientContent() {
    // Parse gradient colors
    List<Color> gradientColors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
    ];
    
    if (post.gradient != null) {
      final hexPattern = RegExp(r'#([0-9A-Fa-f]{6})');
      final matches = hexPattern.allMatches(post.gradient!);
      if (matches.length >= 2) {
        final colorList = matches.map((match) {
          final hex = match.group(1)!;
          return Color(int.parse('FF$hex', radix: 16));
        }).toList();
        gradientColors = colorList.take(2).toList();
      }
    }
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          post.content,
          style: GoogleFonts.notoSansBengali(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text content
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              post.content,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
          ),
        
        // Image
        if (post.image != null)
          ClipRRect(
            child: CachedNetworkImage(
              imageUrl: post.image!,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 280,
                color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 280,
                color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF9D9D9D),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultiImageContent() {
    final images = post.images ?? [];
    if (images.isEmpty) return _buildTextContent();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text content
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              post.content,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
            ),
          ),
        
        // Image grid
        _buildImageGrid(images),
      ],
    );
  }

  Widget _buildImageGrid(List<String> images) {
    final count = images.length;
    
    if (count == 1) {
      return _buildSingleImage(images[0]);
    } else if (count == 2) {
      return _buildTwoImages(images);
    } else if (count == 3) {
      return _buildThreeImages(images);
    } else {
      return _buildFourPlusImages(images);
    }
  }

  Widget _buildSingleImage(String url) {
    return ClipRRect(
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 280,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(280),
        errorWidget: (context, url, error) => _buildImageError(280),
      ),
    );
  }

  Widget _buildTwoImages(List<String> images) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[0],
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(200),
              errorWidget: (context, url, error) => _buildImageError(200),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[1],
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(200),
              errorWidget: (context, url, error) => _buildImageError(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeImages(List<String> images) {
    return SizedBox(
      height: 260,
      child: Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[0],
              height: 260,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(260),
              errorWidget: (context, url, error) => _buildImageError(260),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[1],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(129),
                    errorWidget: (context, url, error) => _buildImageError(129),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[2],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(129),
                    errorWidget: (context, url, error) => _buildImageError(129),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourPlusImages(List<String> images) {
    final remainingCount = images.length - 4;
    
    return SizedBox(
      height: 280,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[0],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(139),
                    errorWidget: (context, url, error) => _buildImageError(139),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[1],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(139),
                    errorWidget: (context, url, error) => _buildImageError(139),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[2],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(139),
                    errorWidget: (context, url, error) => _buildImageError(139),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: images[3],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildImagePlaceholder(139),
                        errorWidget: (context, url, error) => _buildImageError(139),
                      ),
                      if (remainingCount > 0)
                        Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Text(
                              '+$remainingCount',
                              style: GoogleFonts.roboto(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildImageError(double height) {
    return Container(
      height: height,
      color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5),
      child: Icon(
        Icons.broken_image,
        color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF9D9D9D),
      ),
    );
  }

  Widget _buildPollContent() {
    final isBn = appController.language == AppLanguage.bn;
    final pollData = post.poll;
    if (pollData == null) return _buildTextContent();
    
    final options = pollData['options'] as List<dynamic>? ?? [];
    final totalVotes = pollData['totalVotes'] as int? ?? 0;
    final hasVoted = pollData['hasVoted'] as bool? ?? false;
    final votedOptionId = pollData['votedOptionId'] as int?;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              pollData['question'] ?? post.content,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                fontWeight: FontWeight.w600,
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
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isVoted
                        ? AppColors.lightPrimary.withOpacity(isDark ? 0.15 : 0.1)
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
                                color: AppColors.lightPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      
                      // Option content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            if (isVoted) ...[
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.lightPrimary,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                optionText,
                                style: GoogleFonts.notoSansBengali(
                                  fontSize: 14,
                                  color: isVoted
                                      ? AppColors.lightPrimary
                                      : (isDark ? Colors.white : const Color(0xFF0f1419)),
                                  fontWeight: isVoted ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (hasVoted) ...[
                              const SizedBox(width: 8),
                              Text(
                                '$percentage%',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF536471),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            // Total votes
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$totalVotes ${isBn ? 'ভোট' : 'votes'}',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF8E8E8E) : const Color(0xFF536471),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isBn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Row(
        children: [
          // Like button
          _ActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: _formatCount(post.likes),
            isActive: post.isLiked,
            onTap: () => controller.handleLike(post.id),
            isDark: isDark,
          ),
          
          const SizedBox(width: 8),
          
          // Comment button
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: _formatCount(post.comments),
            isActive: false,
            onTap: () => controller.handleComment(post.id),
            isDark: isDark,
          ),
          
          const Spacer(),
          
          // Share button
          _ActionButton(
            icon: Icons.share_outlined,
            label: isBn ? 'শেয়ার' : 'Share',
            isActive: false,
            onTap: () => controller.handleShare(post.id),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.lightPrimary.withOpacity(0.1)
              : (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.lightPrimary
                : (isDark ? const Color(0xFF104050) : const Color(0xFFE6E6E6)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? AppColors.lightPrimary
                  : const Color(0xFF9D9D9D),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? AppColors.lightPrimary
                    : const Color(0xFF9D9D9D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


