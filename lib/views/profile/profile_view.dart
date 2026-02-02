import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/profile_timeline_controller.dart';
import '../../controllers/saved_posts_controller.dart';
import '../../controllers/friends_controller.dart';
import '../../models/timeline_item.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_with_comments.dart';
import '../../views/edit_post/edit_post_view.dart';
import '../../models/post_model.dart';
import '../../services/user_info.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
  final appController = Get.find<AppController>();
    final controller = Get.put(ProfileController());
  
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAFAFA),
        body: SafeArea(
          bottom: false,
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _ProfileBody(
                  controller: controller,
                  appController: appController,
                  isDark: isDark,
                  isBn: isBn,
                ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              isBn ? 'শুরু করুন' : 'Get Started',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }
}

class _ProfileBody extends StatefulWidget {
  final ProfileController controller;
  final AppController appController;
  final bool isDark;
  final bool isBn;

  const _ProfileBody({
    required this.controller,
    required this.appController,
    required this.isDark,
    required this.isBn,
  });

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
  }
  
class _ProfileBodyState extends State<_ProfileBody> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _lastScrollY = 0;
  String? _lastActiveTab;
  final postController = Get.put(PostController());
  final savedPostsController = Get.put(SavedPostsController());
  final timelineController = Get.put(ProfileTimelineController());
  final friendsController = Get.put(FriendsController());

  late AnimationController _tabAnimationController;
  
  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    if (widget.controller.activeTab.value == 'post') {
      _lastActiveTab = 'post';
      timelineController.fetchTimeline();
    }
    
    ever(widget.controller.activeTab, (String tab) {
      if (tab == 'post' && _lastActiveTab != 'post') {
        timelineController.fetchTimeline();
      } else if (tab == 'saved' && _lastActiveTab != 'saved') {
        savedPostsController.loadSavedPosts();
      } else if (tab == 'friends' && _lastActiveTab != 'friends') {
        // Friends tab selected - data is already loaded in FriendsController
      }
      _lastActiveTab = tab;
    });
    
    ever(timelineController.timeline, (List<TimelineItem> _) {
      widget.controller.updateFirstPostStatus(timelineController.timeline.isNotEmpty);
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }
  
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final currentScrollY = _scrollController.offset;
      final scrollDelta = currentScrollY - _lastScrollY;
      
      if (currentScrollY < 10) {
        widget.appController.setHideBottomNav(false);
      } else if (scrollDelta > 15 && currentScrollY > 20) {
        widget.appController.setHideBottomNav(true);
      } else if (scrollDelta < -5) {
        widget.appController.setHideBottomNav(false);
      }
      
      _lastScrollY = currentScrollY;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
          _buildCoverSection(),
          _buildProfileCard(),
         const SizedBox(height: 10,),
          Obx(() {
            final activeTab = widget.controller.activeTab.value;
            if (activeTab == 'post') {
              return _buildTimelineCards();
            } else if (activeTab == 'poll') {
              return _buildPollCards();
            } else if (activeTab == 'saved') {
              return _buildSavedCards();
            } else if (activeTab == 'friends') {
              return _buildFriendsCards();
            } else {
              return _buildSavedCards();
            }
          }),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 100), // Extra space for FAB
              ],
        ),
      );
  }
  
  Widget _buildCoverSection() {
    final controller = widget.controller;
    final isDark = widget.isDark;
    final isBn = widget.isBn;

    return Obx(() {
      final canEditCover = controller.isEditMode.value || !controller.hasCoverPhoto.value;

    return Container(
      height: 240,
      width: double.infinity,
      color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFF5F5F5),
      child: Stack(
        children: [
          // Cover Image or Gradient
            GestureDetector(
              onTap: canEditCover ? controller.pickCoverImage : null,
              child: _buildCoverImage(isDark),
            ),

            // Upload indicator for cover
            if (controller.isUploadingCover.value)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),

            // Camera icon overlay
            if (canEditCover && !controller.isUploadingCover.value)
              Positioned(
                bottom: 100,
                right: 20,
                child: GestureDetector(
                  onTap: controller.pickCoverImage,
                  child: Container(
                    width: 40,
                    height: 40,
              decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                ),
              ),
            ),
          
          // Header Controls
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () => Get.offAllNamed(AppRoutes.home),
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                      ),
                        child: Text(
                          isBn ? 'এড়িয়ে যান' : 'Skip',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0f1419),
                          ),
                      ),
                    ),
                  ),
                  Text(
                    isBn ? 'প্রোফাইল' : 'Profile',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0f1419),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.settings),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings,
                        color: isDark ? Colors.white : const Color(0xFF0f1419),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    });
  }
  
  Widget _buildCoverImage(bool isDark) {
    final controller = widget.controller;

    return Obx(() {
      if (controller.coverFile.value != null) {
        return Image.file(
          controller.coverFile.value!,
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
        );
      } else if (controller.coverImageUrl.value.isNotEmpty) {
        return Image.network(
          controller.coverImageUrl.value,
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultCover(isDark),
        );
      }
      return _buildDefaultCover(isDark);
    });
  }

  Widget _buildDefaultCover(bool isDark) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0a2f3d), const Color(0xFF0d3a4a)]
              : [const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final controller = widget.controller;
    final isDark = widget.isDark;
    final isBn = widget.isBn;

    return Transform.translate(
      offset: const Offset(0, -90),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(20, 23, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFEAEAEA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(33),
        ),
        child: Obx(() => Column(
          children: [
            _buildProfilePicture(isDark),
            _buildNameSection(isDark),
            _buildLocationSection(isDark),
            // Always show bio display (tappable to edit)
            _buildBioDisplay(isDark),
            _buildStats(isDark, isBn),
                if (!controller.isProfileComplete) _buildProfileCompletionCard(isDark, isBn),
            _buildTabs(isDark, isBn),
          ],
            )),
      ),
    );
  }
  
  Widget _buildProfilePicture(bool isDark) {
    final controller = widget.controller;

    return Transform.translate(
      offset: const Offset(0, -65),
      child: Center(
        child: Obx(() => Stack(
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: const Color(0xFFC4C4C4),
                border: Border.all(color: const Color(0xFF008001), width: 3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                    child: _buildProfileImage(),
              ),
            ),
                // Edit button - only opens profile image picker
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                    onTap: controller.pickProfileImage, // Directly open image picker
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFff7a51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ),
                // Camera overlay when uploading
                if (controller.isUploadingProfile.value)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
            )),
      ),
    );
  }

  Widget _buildProfileImage() {
    final controller = widget.controller;

    return Obx(() {
      if (controller.profileFile.value != null) {
        return Image.file(controller.profileFile.value!, fit: BoxFit.cover);
      } else if (controller.profileImageUrl.value.isNotEmpty) {
        return Image.network(
          controller.profileImageUrl.value,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, color: Colors.white, size: 40),
        );
      }
      return const Icon(Icons.person, color: Colors.white, size: 40);
    });
  }
  
  Widget _buildNameSection(bool isDark) {
    final controller = widget.controller;
    final appController = widget.appController;

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 8),
        child: Obx(() {
          // Use appController.userFullname for instant update when changed in Account Settings
          final displayName = appController.userFullname.isNotEmpty
              ? appController.userFullname
              : controller.name.value;
          return Text(
              displayName,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0f1419),
              ),
              textAlign: TextAlign.center,
            );
        }),
      ),
    );
  }
  
  Widget _buildLocationSection(bool isDark) {
    final controller = widget.controller;

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 14, color: AppColors.lightPrimary),
                const SizedBox(width: 6),
                Text(
                  controller.address.value,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF8e8e8e)
                        : const Color(0xFF536471),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildBioDisplay(bool isDark) {
    final controller = widget.controller;
    final isBn = widget.isBn;

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Obx(() {
          final bioText = controller.bio.value.isNotEmpty 
              ? controller.bio.value 
              : (isBn ? 'বায়ো যোগ করুন' : 'Add bio');
          
          return GestureDetector(
            onTap: () => _showBioEditDialog(isDark, isBn),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.5)
                    : const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Text(
                bioText,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: controller.bio.value.isNotEmpty
                      ? (isDark ? const Color(0xFF9e9e9e) : const Color(0xFF657786))
                      : (isDark ? const Color(0xFF6e6e6e) : const Color(0xFF9CA3AF)),
                  height: 1.4,
                  fontStyle: controller.bio.value.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showBioEditDialog(bool isDark, bool isBn) {
    final controller = widget.controller;
    
    // Initialize bio controller with current bio
    controller.bioController.text = controller.bio.value;
    controller.isBioEditing.value = true;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).padding.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'বায়ো সম্পাদনা করুন' : 'Edit Bio',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.cancelBioEdit();
                    Get.back();
                  },
                  child: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Bio TextField
            TextField(
              controller: controller.bioController,
              maxLength: 200,
              maxLines: 4,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF2C2C2E),
              ),
              decoration: InputDecoration(
                hintText: isBn ? 'একটি সংক্ষিপ্ত বায়ো লিখুন' : 'Write a short bio',
                hintStyle: GoogleFonts.roboto(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF6e6e6e) : const Color(0xFF9CA3AF),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF0d3a4a)
                        : Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
                ),
                counterStyle: GoogleFonts.roboto(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF6e6e6e) : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: controller.isSavingBio.value
                        ? null
                        : () {
                            controller.cancelBioEdit();
                            Get.back();
                          },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0d3a4a)
                            : const Color(0xFFf0f0f0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          isBn ? 'বাতিল' : 'Cancel',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => GestureDetector(
                    onTap: controller.isSavingBio.value
                        ? null
                        : () async {
                            // Save bio and close dialog
                            final success = await controller.saveBio();
                            if (success) {
                              Get.back(); // Close dialog only on success
                            }
                          },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: controller.isSavingBio.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isBn ? 'সংরক্ষণ করুন' : 'Save',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  
  Widget _buildStats(bool isDark, bool isBn) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
        child: Obx(() {
          // Use timeline length for post count (same data as Post tab)
          final postCount = timelineController.timeline.length.toString();
          final friendsCount = friendsController.friends.length.toString();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Center(child: _buildStatItem(postCount, 'Posts', isDark))),
              Expanded(child: Center(child: _buildStatItem('0', isBn ? 'প্রতিবেশী' : 'Neighbours', isDark))),
              Expanded(child: Center(child: _buildStatItem('0', 'Following', isDark))),
              Expanded(child: Center(child: _buildStatItem(friendsCount, isBn ? 'বন্ধু' : 'Friends', isDark))),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0f1419),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileCompletionCard(bool isDark, bool isBn) {
    final controller = widget.controller;

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Header
            Row(
              children: [
                    Flexible(
                      child: Text(
                        '${isBn ? 'প্রোফাইল সম্পূর্ণতা' : 'Profile Progress'}: ${controller.completionPercentage}%',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                  isBn ? 'শুধু আপনি দেখতে পারবেন' : 'Only visible to you',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: const Color(0xFF8e8e8e),
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Segmented progress bar
            Row(
              children: List.generate(4, (index) {
                    final filled = index < controller.completedItems;
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: filled
                              ? AppColors.lightPrimary
                              : (isDark
                                  ? const Color(0xFF3A3A3A)
                                  : const Color(0xFFD0D5DD)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 12),
            
                // Pill buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
                  children: controller.profileCompletionItems
                  .where((item) => !item['completed'])
                  .map((item) => _buildPillButton(item, isDark))
                  .toList(),
            ),
          ],
            )),
      ),
    );
  }
  
  Widget _buildPillButton(Map<String, dynamic> item, bool isDark) {
    final controller = widget.controller;
    final canAccess = controller.canAccessStep(item['step']);
    final isCurrentStep = controller.currentStep == item['step'];
    
    return GestureDetector(
      onTap: () => controller.handleStepAction(item['action'], item['step']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentStep ? AppColors.lightPrimary : const Color(0xFF9CA3AF),
            width: isCurrentStep ? 2 : 1,
          ),
          color: isCurrentStep 
              ? AppColors.lightPrimary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Text(
          item['label'],
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: isCurrentStep ? FontWeight.w600 : FontWeight.normal,
            color: isCurrentStep 
                ? AppColors.lightPrimary
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabs(bool isDark, bool isBn) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        final barHeight = isSmallScreen ? 72.0 : 64.0;
        return Container(
          height: barHeight,
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(child: _buildTabButton('post', Icons.grid_on, 'Post', isSmallScreen)),
              Expanded(child: _buildTabButton('poll', Icons.poll, 'Poll', isSmallScreen)),
              Expanded(child: _buildTabButton('saved', Icons.bookmark_outline, 'Saved', isSmallScreen)),
              Expanded(child: _buildTabButton('friends', Icons.person_outline, isBn ? 'বন্ধু' : 'Friends', isSmallScreen)),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTabButton(String tab, IconData icon, String label, bool isSmallScreen) {
    final controller = widget.controller;

    return Obx(() {
      final isActive = controller.activeTab.value == tab;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.setActiveTab(tab);
            _tabAnimationController.forward(from: 0);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.lightPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: isSmallScreen ? 16 : 18,
                    color: isActive ? Colors.white : const Color(0xFF9D9D9D),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: GoogleFonts.roboto(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : const Color(0xFF9D9D9D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  
  Widget _buildPostCards() {
    final isDark = widget.isDark;
    final isBn = widget.isBn;

    return Obx(() {

      if (postController.isLoading.value && postController.posts.isEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      if (postController.errorMessage.value.isNotEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  postController.errorMessage.value,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => postController.loadUserPosts(),
                  child: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (postController.posts.isEmpty) {
    return Transform.translate(
      offset: const Offset(0, -90),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Text(
              isBn ? 'কোন পোস্ট নেই' : 'No posts yet',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

      return Transform.translate(
        offset: const Offset(0, -90),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: postController.posts.length,
            itemBuilder: (context, index) {
              final post = postController.posts[index];
              return GestureDetector(
                onTap: () async {
                  // Get full post details and navigate
                  final fullPost = await postController.getSinglePost(post.id);
                  if (fullPost != null) {
                    // Convert PostModel to PostData for PostWithComments
                    final postData = PostData(
                      id: fullPost.id.toString(),
                      author: fullPost.createdBy?.name ?? 'Unknown',
                      authorAvatar: null,
                      timestamp: _formatTimestamp(fullPost.createdAt),
                      title: fullPost.postTitle.isNotEmpty ? fullPost.postTitle : null,
                      content: fullPost.postDescription,
                      type: fullPost.postImages.isNotEmpty ? 'multiImage' : 'text',
                      images: fullPost.postImages.map((img) => 'https://torko.attoexasolutions.com/$img').toList(),
                      likes: fullPost.postLikeCount,
                      comments: fullPost.postCommentCount,
                      shares: fullPost.postShareCount,
                      isLiked: fullPost.isLiked, // Use isLiked getter from PostModel
                    );

                    Get.to(
                      () => PostWithComments(
                        post: postData,
                        onBack: () => Get.back(),
                        onAddComment: (text, replyTo) {
                          // TODO: Handle comment addition
                        },
                        onEdit: () {
                          // Navigate to edit post screen
                          Get.back(); // Close PostWithComments first
                          Get.to(
                            () => EditPostView(post: fullPost),
                            transition: Transition.rightToLeft,
                          );
                        },
                        onDelete: () async {
                          // Delete the post
                          final success = await postController.deletePost(fullPost.id);
                          if (success) {
                            Get.back(); // Close PostWithComments
                            Get.snackbar(
                              isBn ? 'সফল' : 'Success',
                              isBn ? 'পোস্ট মুছে ফেলা হয়েছে' : 'Post deleted',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                            // Reload user's posts
                            postController.loadUserPosts();
                          } else {
                            Get.snackbar(
                              isBn ? 'ত্রুটি' : 'Error',
                              postController.errorMessage.value.isNotEmpty
                                  ? postController.errorMessage.value
                                  : (isBn ? 'পোস্ট মুছে ফেলতে ব্যর্থ' : 'Failed to delete post'),
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),
                      transition: Transition.rightToLeft,
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0d3a4a) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: post.postImages.isNotEmpty
                        ? Image.network(
                            'https://torko.attoexasolutions.com/${post.postImages[0]}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description,
                                color: isDark ? Colors.white70 : Colors.black54,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                post.postTitle.isNotEmpty 
                                    ? (post.postTitle.length > 20 
                                        ? '${post.postTitle.substring(0, 20)}...' 
                                        : post.postTitle)
                                    : (post.postDescription.isNotEmpty 
                                        ? (post.postDescription.length > 20 
                                            ? '${post.postDescription.substring(0, 20)}...' 
                                            : post.postDescription)
                                        : ''),
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildTimelineCards() {
    final isDark = widget.isDark;
    final isBn = widget.isBn;

    return Obx(() {
      if (timelineController.loading.value && timelineController.timeline.isEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      }
      if (timelineController.error.value.isNotEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: isDark ? Colors.white70 : Colors.black54),
                const SizedBox(height: 16),
                Text(
                  timelineController.error.value,
                  style: GoogleFonts.roboto(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => timelineController.fetchTimeline(),
                  child: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                ),
              ],
            ),
          ),
        );
      }
      if (timelineController.timeline.isEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dynamic_feed, size: 64, color: isDark ? Colors.white54 : Colors.black54),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'কোন পোস্ট নেই' : 'No posts yet',
                  style: GoogleFonts.roboto(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      return Transform.translate(
        offset: const Offset(0, -90),
          child: RefreshIndicator(
          onRefresh: () => timelineController.fetchTimeline(),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: timelineController.timeline.length,
            itemBuilder: (context, index) {
              final item = timelineController.timeline[index];
              final p = item.post;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: PostCard(
                  id: p.id.toString(),
                  userId: p.userId,
                  author: p.createdBy?.name ?? 'User',
                  username: '@user',
                  timestamp: _formatTimestamp(p.createdAt),
                  content: p.postDescription,
                  type: p.postImages.isEmpty ? 'text' : (p.postImages.length == 1 ? 'image' : 'multiImage'),
                  image: p.postImages.isNotEmpty ? _imageUrl(p.postImages.first) : null,
                  images: p.postImages.length > 1 ? p.postImages.map(_imageUrl).toList() : null,
                  likes: p.postLikeCount,
                  comments: p.postCommentCount,
                  isLiked: p.isLiked,
                  isSaved: p.saved,
                  post: p,
                  isShared: item.isShared,
                  sharedAt: item.sharedAt,
                  sharedByUserId: item.sharedByUserId,
                  onLike: () {},
                  onComment: () async {
                    final fp = await postController.getSinglePost(p.id);
                    if (fp != null) {
                      final postData = PostData(
                        id: fp.id.toString(),
                        author: fp.createdBy?.name ?? 'Unknown',
                        authorAvatar: null,
                        timestamp: _formatTimestamp(fp.createdAt),
                        title: fp.postTitle.isNotEmpty ? fp.postTitle : null,
                        content: fp.postDescription,
                        type: fp.postImages.isNotEmpty ? 'multiImage' : 'text',
                        images: fp.postImages.map((img) => 'https://torko.attoexasolutions.com/$img').toList(),
                        likes: fp.postLikeCount,
                        comments: fp.postCommentCount,
                        shares: fp.postShareCount,
                        isLiked: fp.isLiked,
                      );
                      Get.to(() => PostWithComments(post: postData, onBack: () => Get.back(), onAddComment: (_, __) {}));
                    }
                  },
                  onShare: () {},
                  onDeleteSharedPost: item.isShared
                      ? () => timelineController.onDeleteSharePressed(p)
                      : null,
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildPollCards() {
    final isDark = widget.isDark;
    final isBn = widget.isBn;

    return Transform.translate(
      offset: const Offset(0, -90),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          isBn ? 'পোলগুলি এখানে দেখানো হবে' : 'Polls will be displayed here',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSavedCards() {
    final isDark = widget.isDark;
    final isBn = widget.isBn;

    return Obx(() {
      // Loading state
      if (savedPostsController.loadingSaved && savedPostsController.savedPosts.isEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      // Error state
      if (savedPostsController.error.value.isNotEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(height: 16),
                Text(
                  savedPostsController.error.value,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => savedPostsController.loadSavedPosts(),
                  child: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                ),
              ],
            ),
          ),
        );
      }

      // Empty state
      if (savedPostsController.savedPosts.isEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'কোন সংরক্ষিত পোস্ট নেই' : 'No saved posts yet',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => savedPostsController.loadSavedPosts(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(isBn ? 'রিফ্রেশ করুন' : 'Refresh'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.lightPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // List of saved posts
      return Transform.translate(
        offset: const Offset(0, -90),
        child: RefreshIndicator(
          onRefresh: () => savedPostsController.fetchSaved(),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: savedPostsController.savedPosts.length,
            itemBuilder: (context, index) {
              final post = savedPostsController.savedPosts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: PostCard(
                  id: post.id.toString(),
                  userId: post.userId,
                  author: post.createdBy?.name ?? 'User',
                  username: '@user',
                  timestamp: _formatTimestamp(post.createdAt),
                  content: post.postDescription,
                  type: post.postImages.isEmpty ? 'text' : (post.postImages.length == 1 ? 'image' : 'multiImage'),
                  image: post.postImages.isNotEmpty ? _imageUrl(post.postImages.first) : null,
                  images: post.postImages.length > 1 ? post.postImages.map(_imageUrl).toList() : null,
                  likes: post.postLikeCount,
                  comments: post.postCommentCount,
                  isLiked: post.isLiked,
                  isSaved: post.saved,
                  post: post,
                  onLike: () {},
                  onComment: () async {
                    final fp = await postController.getSinglePost(post.id);
                    if (fp != null) {
                      final postData = PostData(
                        id: fp.id.toString(),
                        author: fp.createdBy?.name ?? 'Unknown',
                        authorAvatar: null,
                        timestamp: _formatTimestamp(fp.createdAt),
                        title: fp.postTitle.isNotEmpty ? fp.postTitle : null,
                        content: fp.postDescription,
                        type: fp.postImages.isNotEmpty ? 'multiImage' : 'text',
                        images: fp.postImages.map((img) => 'https://torko.attoexasolutions.com/$img').toList(),
                        likes: fp.postLikeCount,
                        comments: fp.postCommentCount,
                        shares: fp.postShareCount,
                        isLiked: fp.isLiked,
                      );
                      Get.to(() => PostWithComments(post: postData, onBack: () => Get.back(), onAddComment: (_, __) {}));
                    }
                  },
                  onShare: () {},
                ),
              );
            },
          ),
        ),
      );
    });
  }

  String _imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return 'https://torko.attoexasolutions.com/$path';
  }

  Widget _buildFriendsCards() {
    final isDark = widget.isDark;
    final isBn = widget.isBn;

    return Obx(() {
      // Empty state
      if (friendsController.friends.isEmpty) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'এখনো কোনো বন্ধু নেই' : 'No friends yet',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // List of friends
      return Transform.translate(
        offset: const Offset(0, -90),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: friendsController.friends.length,
          itemBuilder: (context, index) {
            final friend = friendsController.friends[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                border: Border.all(
                  color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe0e0e0),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: friend.avatar != null && friend.avatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  friend.avatar!.startsWith('http')
                                      ? friend.avatar!
                                      : 'https://torko.attoexasolutions.com/${friend.avatar!}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildAvatarInitials(friend.name, 56),
                                ),
                              )
                            : _buildAvatarInitials(friend.name, 56),
                      ),
                      if (friend.isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0f1419),
                          ),
                        ),
                        if (friend.username.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@${friend.username}',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                            ),
                          ),
                        ],
                        if (friend.location != null && friend.location!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            friend.location!,
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFB8DED6).withOpacity(0.5) : const Color(0xFF9ca3af),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAvatarInitials(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
