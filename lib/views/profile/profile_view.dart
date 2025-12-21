import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/post_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with TickerProviderStateMixin {
  final appController = Get.find<AppController>();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Tab and interaction states
  String _activeTab = 'post';
  final Set<int> _likedPosts = {};
  final Set<int> _likedPolls = {};
  final Set<int> _likedSaved = {};
  double _lastScrollY = 0;
  
  // Edit mode states
  bool _isEditMode = false;
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editLocationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _savedName = 'Thomas R.';
  String _savedLocation = 'Dhaka, Bangladesh';
  String _savedBio = '';
  File? _profileImage;
  File? _coverImage;
  
  // 4-Step Profile Completion (25% each step)
  bool _hasProfilePhoto = false;  // Step 1 - 25%
  bool _hasBio = false;          // Step 2 - 50% 
  bool _hasCoverPhoto = false;   // Step 3 - 75%
  bool _hasFirstPost = false;    // Step 4 - 100%
  
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;
  
  // Step progression logic
  int get _currentStep {
    if (!_hasProfilePhoto) return 1;
    if (!_hasBio) return 2;
    if (!_hasCoverPhoto) return 3;
    if (!_hasFirstPost) return 4;
    return 4; // All completed
  }
  
  // Profile completion items (4 steps in order)
  List<Map<String, dynamic>> get _profileCompletionItems {
    final isBn = appController.language == AppLanguage.bn;
    return [
      {
        'id': 'profile_photo',
        'step': 1,
        'completed': _hasProfilePhoto,
        'label': isBn ? 'প্রোফাইল ছবি আপলোড করুন' : 'Upload a profile photo',
        'action': 'upload_profile',
      },
      {
        'id': 'bio',  
        'step': 2,
        'completed': _hasBio,
        'label': isBn ? 'বায়ো যোগ করুন' : 'Add a bio',
        'action': 'add_bio',
      },
      {
        'id': 'cover_photo',
        'step': 3, 
        'completed': _hasCoverPhoto,
        'label': isBn ? 'কভার ছবি যোগ করুন' : 'Add a cover photo',
        'action': 'upload_cover',
      },
      {
        'id': 'first_post',
        'step': 4,
        'completed': _hasFirstPost, 
        'label': isBn ? 'প্রথম পোস্ট তৈরি করুন' : 'Create first post',
        'action': 'create_post',
      },
    ];
  }
  
  // Progress calculations
  int get _completedItems => _profileCompletionItems.where((item) => item['completed'] == true).length;
  int get _totalItems => 4;
  int get _completionPercentage => _completedItems * 25; // 25% per step
  bool get _isProfileComplete => _completionPercentage == 100;
  
  // Step access control
  bool _canAccessStep(int stepNumber) {
    return stepNumber <= _currentStep; // Can access current and previous steps
  }
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkFromWelcome();
    _setupScrollListener();
    
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabAnimation = CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    );
    
    _editNameController.text = _savedName;
    _editLocationController.text = _savedLocation;
    _bioController.text = _savedBio;
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _editNameController.dispose();
    _editLocationController.dispose();
    _bioController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }
  
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final currentScrollY = _scrollController.offset;
      final scrollDelta = currentScrollY - _lastScrollY;
      
      if (currentScrollY < 10) {
        appController.setHideBottomNav(false);
      } else if (scrollDelta > 15 && currentScrollY > 20) {
        appController.setHideBottomNav(true);
      } else if (scrollDelta < -5) {
        appController.setHideBottomNav(false);
      }
      
      _lastScrollY = currentScrollY;
    });
  }
  
  // Load user data and completion state
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('torko_user_profile');
    
    // Load completion states
    final hasProfilePhoto = prefs.getBool('torko_profile_step_1') ?? false;
    final hasBio = prefs.getBool('torko_profile_step_2') ?? false;
    final hasCoverPhoto = prefs.getBool('torko_profile_step_3') ?? false;
    final hasFirstPost = prefs.getBool('torko_profile_step_4') ?? false;
    
    // Load image paths
    final profileImagePath = prefs.getString('torko_profile_image_path');
    final coverImagePath = prefs.getString('torko_cover_image_path');
    final bioText = prefs.getString('torko_profile_bio') ?? '';
    
    // Load profile image if exists
    File? loadedProfileImage;
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      final file = File(profileImagePath);
      if (await file.exists()) {
        loadedProfileImage = file;
      }
    }
    
    // Load cover image if exists
    File? loadedCoverImage;
    if (coverImagePath != null && coverImagePath.isNotEmpty) {
      final file = File(coverImagePath);
      if (await file.exists()) {
        loadedCoverImage = file;
      }
    }
    
    if (profileStr != null) {
      try {
        final profile = jsonDecode(profileStr);
        setState(() {
          _savedName = profile['name'] ?? profile['fullName'] ?? 'Thomas R.';
          _savedLocation = profile['location'] ?? 'Dhaka, Bangladesh';
          _savedBio = profile['bio'] ?? bioText;
          _editNameController.text = _savedName;
          _editLocationController.text = _savedLocation;
          _bioController.text = _savedBio;
        });
      } catch (e) {
        // Ignore parsing errors
      }
    }
    
    // Update bio from separate key if not in profile
    if (_savedBio.isEmpty && bioText.isNotEmpty) {
      _savedBio = bioText;
      _bioController.text = _savedBio;
    }
    
    setState(() {
      _hasProfilePhoto = hasProfilePhoto;
      _hasBio = hasBio || _savedBio.isNotEmpty;
      _hasCoverPhoto = hasCoverPhoto;
      _hasFirstPost = hasFirstPost;
      _profileImage = loadedProfileImage;
      _coverImage = loadedCoverImage;
    });
  }
  
  // Save completion state
  Future<void> _saveCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('torko_profile_step_1', _hasProfilePhoto);
    await prefs.setBool('torko_profile_step_2', _hasBio);
    await prefs.setBool('torko_profile_step_3', _hasCoverPhoto);
    await prefs.setBool('torko_profile_step_4', _hasFirstPost);
  }
  
  // Mark step as completed
  Future<void> _markStepCompleted(int step) async {
    setState(() {
      switch (step) {
        case 1: _hasProfilePhoto = true; break;
        case 2: _hasBio = true; break;
        case 3: _hasCoverPhoto = true; break;
        case 4: _hasFirstPost = true; break;
      }
    });
    
    await _saveCompletionState();
    
    final isBn = appController.language == AppLanguage.bn;
    final progress = (_completedItems) * 25;
    
    Get.snackbar(
      isBn ? 'ধাপ সম্পূর্ণ!' : 'Step Completed!',
      isBn ? 'অগ্রগতি: $progress%' : 'Progress: $progress%',
      backgroundColor: AppColors.lightPrimary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  // Handle step navigation with access control
  void _handleStepAction(String action, int stepNumber) {
    if (!_canAccessStep(stepNumber)) {
      final isBn = appController.language == AppLanguage.bn;
      Get.snackbar(
        isBn ? 'ধাপ সম্পূর্ণ করুন' : 'Complete Previous Steps',
        isBn ? 'পূর্ববর্তী ধাপগুলো আগে সম্পূর্ণ করুন' : 'Please complete previous steps first',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    FocusManager.instance.primaryFocus?.unfocus();
    
    switch (action) {
      case 'upload_profile':
        _showImageSourceSheet(isProfile: true);
        break;
      case 'add_bio':
        _handleEditClick();
        break;
      case 'upload_cover':
        _showImageSourceSheet(isProfile: false);
        break;
      case 'create_post':
        _handleCreatePost();
        break;
    }
  }
  
  // Reusable image picker bottom sheet
  Future<void> _showImageSourceSheet({required bool isProfile}) async {
    final isBn = appController.language == AppLanguage.bn;
    final isDark = appController.isDarkMode;
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'ছবি নির্বাচন করুন' : 'Choose photo',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0f1419),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.lightPrimary),
                ),
                title: Text(
                  isBn ? 'ক্যামেরা' : 'Camera',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isProfile: isProfile);
                },
              ),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.lightPrimary),
                ),
                title: Text(
                  isBn ? 'গ্যালারি' : 'Gallery',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isProfile: isProfile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Pick image from source
  Future<void> _pickImage(ImageSource source, {required bool isProfile}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: isProfile ? 500 : 1200,
        maxHeight: isProfile ? 500 : 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final prefs = await SharedPreferences.getInstance();
        
        if (isProfile) {
          setState(() {
            _profileImage = file;
          });
          await prefs.setString('torko_profile_image_path', pickedFile.path);
          await _markStepCompleted(1);
        } else {
          setState(() {
            _coverImage = file;
          });
          await prefs.setString('torko_cover_image_path', pickedFile.path);
          await _markStepCompleted(3);
        }
      }
    } catch (e) {
      final isBn = appController.language == AppLanguage.bn;
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'ছবি নির্বাচন করতে সমস্যা হয়েছে' : 'Failed to pick image',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
  
  // Handle create post navigation
  Future<void> _handleCreatePost() async {
    final result = await Get.toNamed(AppRoutes.createPost);
    // TODO: CreatePost should return true when post is successfully created
    // Currently marking as complete on navigation return
    if (result == true) {
      await _markStepCompleted(4);
    }
  }
  
  void _checkFromWelcome() {
    SharedPreferences.getInstance().then((prefs) {
      final fromWelcome = prefs.getString('torko_from_welcome');
      if (fromWelcome == 'complete_profile') {
        setState(() => _isEditMode = true);
      }
    });
  }
  
  void _handleEditClick() {
    setState(() {
      _isEditMode = true;
      _editNameController.text = _savedName;
      _editLocationController.text = _savedLocation;
      _bioController.text = _savedBio;
    });
  }
  
  Future<void> _handleSaveEdit() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _savedName = _editNameController.text;
      _savedLocation = _editLocationController.text;
      _savedBio = _bioController.text;
      _isEditMode = false;
    });
    
    // Save to SharedPreferences
    await prefs.setString('torko_profile_bio', _savedBio);
    
    // Also save to profile JSON
    final profileData = {
      'name': _savedName,
      'location': _savedLocation,
      'bio': _savedBio,
    };
    await prefs.setString('torko_user_profile', jsonEncode(profileData));
    
    // Mark bio step as completed only if bio is not empty
    if (_savedBio.trim().isNotEmpty) {
      await _markStepCompleted(2);
    }
  }
  
  void _handleCancelEdit() {
    setState(() {
      _editNameController.text = _savedName;
      _editLocationController.text = _savedLocation;
      _bioController.text = _savedBio;
      _isEditMode = false;
    });
  }
  
  Future<void> _pickProfileImage() async {
    await _showImageSourceSheet(isProfile: true);
  }
  
  Future<void> _pickCoverImage() async {
    await _showImageSourceSheet(isProfile: false);
  }
  
  void _handleBack() async {
    final prefs = await SharedPreferences.getInstance();
    final fromWelcome = prefs.getString('torko_from_welcome');
    
    if (fromWelcome == 'complete_profile') {
      await prefs.remove('torko_from_welcome');
      Get.offNamed(AppRoutes.welcomeProfile);
    } else {
      Get.back();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAFAFA),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Cover photo , bg photo

                _buildCoverSection(isDark, isBn),

                _buildProfileCard(isDark, isBn),
                _buildPostCards(isDark, isBn),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    });
  }
  
  Widget _buildCoverSection(bool isDark, bool isBn) {
    return Container(
      height: 240,
      width: double.infinity,
      color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFF5F5F5),
      child: Stack(
        children: [
          // Cover Image or Gradient - tappable to add cover
          GestureDetector(
            onTap: (_isEditMode || !_hasCoverPhoto) ? _pickCoverImage : null,
            child: _coverImage != null
                ? Image.file(_coverImage!, width: double.infinity, height: 240, fit: BoxFit.cover)
                : Container(
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
                  ),
          ),
          
          // Camera icon overlay for cover photo (when editable)
          if (_isEditMode || !_hasCoverPhoto)
            Positioned(
              bottom: 100,
              right: 20,
              child: GestureDetector(
                onTap: _pickCoverImage,
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
                    onTap: _handleBack,
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
                        Icons.chevron_left,
                        color: isDark ? Colors.white : const Color(0xFF0f1419),
                        size: 24,
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
  }
  
  Widget _buildProfileCard(bool isDark, bool isBn) {
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
        child: Column(
          children: [
            _buildProfilePicture(isDark),
            _buildNameSection(isDark),
            _buildLocationSection(isDark),
            if (!_isEditMode && _savedBio.isNotEmpty) _buildBioDisplay(isDark),
            if (_isEditMode) _buildBioField(isDark, isBn),
            if (_isEditMode) _buildEditButtons(isDark, isBn),
            _buildStats(isDark, isBn),

            // Profile completion percentage %
            if (!_isProfileComplete) _buildProfileCompletionCard(isDark, isBn),
            _buildTabs(isDark, isBn),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfilePicture(bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -65),
      child: Center(
        child: Stack(
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
                child: _profileImage != null
                    ? Image.file(_profileImage!, fit: BoxFit.cover)
                    : const Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _handleEditClick,
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
            if (_isEditMode)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNameSection(bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 8),
        child: _isEditMode
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _editNameController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withOpacity(0.1),
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
                _savedName,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0f1419),
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
  
  Widget _buildLocationSection(bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _isEditMode
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 14, color: AppColors.lightPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A3B43) : const Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _editLocationController,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF2C2C2E),
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
                    _savedLocation,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  // Bio display (non-edit mode)
  Widget _buildBioDisplay(bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          _savedBio,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: isDark ? const Color(0xFF9e9e9e) : const Color(0xFF657786),
            height: 1.4,
          ),
        ),
      ),
    );
  }
  
  // Bio field (edit mode)
  Widget _buildBioField(bool isDark, bool isBn) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: _bioController,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF0d3a4a) : Colors.black.withOpacity(0.1),
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
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _handleCancelEdit,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf0f0f0),
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
                onTap: _handleSaveEdit,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
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
        ),
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
  
  // MAIN PROFILE COMPLETION CARD - Pill Button Design (Image 2) with Step Logic (Image 1)
  Widget _buildProfileCompletionCard(bool isDark, bool isBn) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - exactly like Image 2
            Row(
              children: [
                Text(
                  '${isBn ? 'প্রোফাইল সম্পূর্ণতা' : 'Profile Progress'}: $_completionPercentage%',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                const Spacer(),
                Text(
                  isBn ? 'শুধু আপনি দেখতে পারবেন' : 'Only visible to you',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: const Color(0xFF8e8e8e),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Segmented progress bar
            Row(
              children: List.generate(4, (index) {
                final filled = index < _completedItems;
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: filled
                          ? AppColors.lightPrimary
                          : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFD0D5DD)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 12),
            
            // Pill buttons for incomplete steps - exactly like Image 2 with step logic from Image 1
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profileCompletionItems
                  .where((item) => !item['completed'])
                  .map((item) => _buildPillButton(item, isDark))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  // Pill button - exactly matching Image 2 design with Image 1 logic
  Widget _buildPillButton(Map<String, dynamic> item, bool isDark) {
    final canAccess = _canAccessStep(item['step']);
    final isCurrentStep = _currentStep == item['step'];
    
    return GestureDetector(
      onTap: () => _handleStepAction(item['action'], item['step']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentStep 
                ? AppColors.lightPrimary 
                : const Color(0xFF9CA3AF),
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
        final containerWidth = constraints.maxWidth;
        final tabWidth = containerWidth / 3;
        int index = _activeTab == 'post' ? 0 : _activeTab == 'poll' ? 1 : 2;
        
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
                  Expanded(child: _buildTabButton('post', Icons.grid_on, 'Post')),
                  Expanded(child: _buildTabButton('poll', Icons.poll, 'Poll')),
                  Expanded(child: _buildTabButton('saved', Icons.bookmark_outline, 'Saved')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTabButton(String tab, IconData icon, String label) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = tab);
        _tabAnimationController.forward(from: 0);
      },
      child: SizedBox(
        height: 53,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF9D9D9D)),
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
  }
  
  Widget _buildPostCards(bool isDark, bool isBn) {
    // Simplified post cards - you can expand this with your existing post logic
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
