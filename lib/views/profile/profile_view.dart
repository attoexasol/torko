import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
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

  late AnimationController _tabAnimationController;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
          _buildPostCards(),
          const SizedBox(height: 100),
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
                if (!controller.isEditMode.value && controller.bio.value.isNotEmpty)
                  _buildBioDisplay(isDark),
                if (controller.isEditMode.value) _buildBioField(isDark, isBn),
                if (controller.isEditMode.value) _buildEditButtons(isDark, isBn),
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
                // Edit button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.enterEditMode,
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
                // Camera overlay when in edit mode
                if (controller.isEditMode.value)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: controller.pickProfileImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: controller.isUploadingProfile.value
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(Icons.camera_alt, color: Colors.white, size: 24),
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

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 8),
        child: Obx(() => controller.isEditMode.value
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller.nameController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF0d3a4a)
                            : Colors.black.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
                    ),
                  ),
                ),
              )
            : Text(
                controller.name.value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0f1419),
                ),
                textAlign: TextAlign.center,
              )),
      ),
    );
  }

  Widget _buildLocationSection(bool isDark) {
    final controller = widget.controller;

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Obx(() => controller.isEditMode.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 14, color: AppColors.lightPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A3B43)
                            : const Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: controller.locationController,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: isDark
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFF2C2C2E),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
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

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Obx(() => Text(
              controller.bio.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: isDark ? const Color(0xFF9e9e9e) : const Color(0xFF657786),
                height: 1.4,
              ),
            )),
      ),
    );
  }

  Widget _buildBioField(bool isDark, bool isBn) {
    final controller = widget.controller;

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: controller.bioController,
          maxLength: 200,
          maxLines: 3,
          textAlign: TextAlign.center,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
      ),
    );
  }

  Widget _buildEditButtons(bool isDark, bool isBn) {
    final controller = widget.controller;

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: controller.isSaving.value ? null : controller.cancelEdit,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0d3a4a)
                            : const Color(0xFFf0f0f0),
                        borderRadius: BorderRadius.circular(10),
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
                  child: GestureDetector(
                    onTap: controller.isSaving.value ? null : controller.saveProfile,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: controller.isSaving.value
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
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildStats(bool isDark, bool isBn) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('54', 'Posts', isDark),
            const SizedBox(width: 32),
            _buildStatItem('834', isBn ? 'প্রতিবেশী' : 'Neighbours', isDark),
            const SizedBox(width: 32),
            _buildStatItem('162', 'Following', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0f1419),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
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
    final controller = widget.controller;

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final tabWidth = containerWidth / 3;

        return Obx(() {
          int index = controller.activeTab.value == 'post'
              ? 0
              : controller.activeTab.value == 'poll'
                  ? 1
                  : 2;

          return Container(
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  left: tabWidth * index,
                  top: 0,
                  width: tabWidth,
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: _buildTabButton('post', Icons.grid_on, 'Post')),
                    Expanded(child: _buildTabButton('poll', Icons.poll, 'Poll')),
                    Expanded(
                        child: _buildTabButton(
                            'saved', Icons.bookmark_outline, 'Saved')),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildTabButton(String tab, IconData icon, String label) {
    final controller = widget.controller;

    return Obx(() {
      final isActive = controller.activeTab.value == tab;
      return GestureDetector(
        onTap: () {
          controller.setActiveTab(tab);
          _tabAnimationController.forward(from: 0);
        },
        child: SizedBox(
          height: 53,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isActive ? Colors.white : const Color(0xFF9D9D9D)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : const Color(0xFF9D9D9D),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPostCards() {
    final isDark = widget.isDark;

    return Transform.translate(
      offset: const Offset(0, -90),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Posts will be displayed here',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
