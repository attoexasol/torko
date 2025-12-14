import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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
  
  String _activeTab = 'post'; // 'post', 'poll', 'saved'
  final Set<int> _likedPosts = {};
  final Set<int> _likedPolls = {};
  final Set<int> _likedSaved = {};
  double _lastScrollY = 0;
  
  // Edit mode states
  bool _isEditMode = false;
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editLocationController = TextEditingController();
  String _savedName = 'Thomas R.';
  String _savedLocation = 'Dhaka, Bangladesh';
  File? _profileImage;
  File? _coverImage;
  
  // Profile completion tracking
  final bool _hasBio = false;
  final bool _hasProfilePhoto = true;
  final bool _hasCoverPhoto = true;
  bool _hasLocation = true;
  final bool _hasFirstPost = true;
  
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;
  
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
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('torko_user_profile');
    final locationStr = prefs.getString('torko_user_location');
    
    if (profileStr != null) {
      try {
        final profile = jsonDecode(profileStr);
        setState(() {
          _savedName = profile['name'] ?? profile['fullName'] ?? 'Thomas R.';
          _editNameController.text = _savedName;
        });
      } catch (e) {
        // Ignore
      }
    }
    
    if (locationStr != null) {
      try {
        final location = jsonDecode(locationStr);
        final isBn = appController.language == AppLanguage.bn;
        final locationText = isBn
            ? '${location['divisionBn'] ?? ''}, ${location['districtBn'] ?? ''}'
            : '${location['division'] ?? ''}, ${location['district'] ?? ''}';
        if (locationText.trim().isNotEmpty && locationText != ',') {
          setState(() {
            _savedLocation = locationText;
            _editLocationController.text = _savedLocation;
            _hasLocation = true;
          });
        }
      } catch (e) {
        // Ignore
      }
    }
  }
  
  void _checkFromWelcome() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((p) {
      final fromWelcome = p.getString('torko_from_welcome');
      if (fromWelcome == 'complete_profile') {
        setState(() {
          _isEditMode = true;
        });
      }
    });
  }
  
  void _handleEditClick() {
    setState(() {
      _isEditMode = true;
      _editNameController.text = _savedName;
      _editLocationController.text = _savedLocation;
    });
  }
  
  Future<void> _handleSaveEdit() async {
    setState(() {
      _savedName = _editNameController.text;
      _savedLocation = _editLocationController.text;
      _isEditMode = false;
    });
    
    final prefs = await SharedPreferences.getInstance();
    final fromWelcome = prefs.getString('torko_from_welcome');
    
    if (fromWelcome == 'complete_profile') {
      final savedProgress = prefs.getString('torko_welcome_progress');
      
      if (savedProgress != null) {
        try {
          final progress = jsonDecode(savedProgress) as List;
          final updatedProgress = progress.map((item) {
            if (item['id'] == 'complete_profile') {
              return {...item, 'completed': true};
            }
            return item;
          }).toList();
          await prefs.setString('torko_welcome_progress', jsonEncode(updatedProgress));
        } catch (e) {
          // Ignore
        }
      } else {
        final initialProgress = [
          {'id': 'complete_profile', 'completed': true},
          {'id': 'find_community', 'completed': true},
          {'id': 'follow_people', 'completed': false},
          {'id': 'first_post', 'completed': false},
        ];
        await prefs.setString('torko_welcome_progress', jsonEncode(initialProgress));
      }
      
      await prefs.remove('torko_from_welcome');
      Get.offNamed(AppRoutes.welcomeProfile);
    }
  }
  
  void _handleCancelEdit() async {
    setState(() {
      _editNameController.text = _savedName;
      _editLocationController.text = _savedLocation;
      _isEditMode = false;
    });
    
    final prefs = await SharedPreferences.getInstance();
    final fromWelcome = prefs.getString('torko_from_welcome');
    
    if (fromWelcome == 'complete_profile') {
      await prefs.remove('torko_from_welcome');
      Get.offNamed(AppRoutes.welcomeProfile);
    }
  }
  
  Future<void> _pickProfileImage() async {
    // Note: image_picker would be needed for this
    // For now, we'll just show a placeholder
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     _profileImage = File(image.path);
    //     _hasProfilePhoto = true;
    //   });
    // }
  }
  
  Future<void> _pickCoverImage() async {
    // Note: image_picker would be needed for this
    // For now, we'll just show a placeholder
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
  
  List<Map<String, dynamic>> get _profileCompletionItems {
    final isBn = appController.language == AppLanguage.bn;
    return [
      {'id': 'bio', 'completed': _hasBio, 'label': isBn ? 'বায়ো যোগ করুন' : 'Add bio'},
      {'id': 'photo', 'completed': _hasProfilePhoto, 'label': isBn ? 'প্রোফাইল ছবি যোগ করুন' : 'Add profile photo'},
      {'id': 'cover', 'completed': _hasCoverPhoto, 'label': isBn ? 'কভার ছবি যোগ করুন' : 'Add cover photo'},
      {'id': 'location', 'completed': _hasLocation, 'label': isBn ? 'লোকেশন যোগ করুন' : 'Add location'},
      {'id': 'post', 'completed': _hasFirstPost, 'label': isBn ? 'প্রথম পোস্ট করুন' : 'Make first post'},
    ];
  }
  
  int get _completedItems => _profileCompletionItems.where((item) => item['completed'] == true).length;
  int get _totalItems => _profileCompletionItems.length;
  int get _completionPercentage => ((_completedItems / _totalItems) * 100).round();
  bool get _isProfileComplete => _completionPercentage == 100;
  
  // Sample posts data
  List<Map<String, dynamic>> get _userPosts {
    final isBn = appController.language == AppLanguage.bn;
    return [
      {
        'id': 1,
        'author': 'Thomas R.',
        'username': '@thomas_r',
        'timestamp': isBn ? '২ ঘণ্টা আগে' : '2h ago',
        'content': isBn
            ? 'আজকের সূর্যাস্ত অসাধারণ ছিল! ঢাকার আকাশ কত সুন্দর হতে পারে তা দেখে অবাক হলাম।'
            : 'The sunset today was amazing! I\'m amazed at how beautiful the Dhaka sky can be.',
        'type': 'image',
        'likes': 234,
        'comments': 45,
      },
      {
        'id': 2,
        'author': 'Thomas R.',
        'username': '@thomas_r',
        'timestamp': isBn ? '১ দিন আগে' : '1d ago',
        'content': isBn
            ? 'নতুন প্রকল্পে কাজ শুরু করেছি। অনেক উত্তেজনাপূর্ণ সময় সামনে!'
            : 'Started working on a new project. Exciting times ahead!',
        'type': 'text',
        'likes': 189,
        'comments': 28,
      },
      {
        'id': 3,
        'author': 'Thomas R.',
        'username': '@thomas_r',
        'timestamp': isBn ? '৩ দিন আগে' : '3d ago',
        'content': isBn
            ? 'আজ যা শিখলাম: ছোট পদক্ষেপগুলোই বড় পরিবর্তন আনে।'
            : 'Today I learned: Small steps lead to big changes.',
        'type': 'gradient',
        'gradient': 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        'likes': 312,
        'comments': 67,
      },
    ];
  }
  
  List<Map<String, dynamic>> get _pollPosts {
    final isBn = appController.language == AppLanguage.bn;
    return [
      {
        'id': 101,
        'author': 'Thomas R.',
        'username': '@thomas_r',
        'timestamp': isBn ? '৫ ঘণ্টা আগে' : '5h ago',
        'content': isBn ? 'আপনার প্রিয় প্রোগ্রামিং ভাষা কোনটি?' : 'What is your favorite programming language?',
        'type': 'poll',
        'poll': {
          'question': isBn ? 'আপনার প্রিয় প্রোগ্রামিং ভাষা কোনটি?' : 'What is your favorite programming language?',
          'options': [
            {'id': 1, 'text': 'JavaScript', 'votes': 156},
            {'id': 2, 'text': 'Python', 'votes': 234},
            {'id': 3, 'text': 'Java', 'votes': 89},
            {'id': 4, 'text': 'C++', 'votes': 67},
          ],
          'totalVotes': 546,
          'endTime': isBn ? '১ দিন বাকি' : '1 day left',
          'hasVoted': false,
        },
        'likes': 156,
        'comments': 89,
      },
      {
        'id': 102,
        'author': 'Thomas R.',
        'username': '@thomas_r',
        'timestamp': isBn ? '২ দিন আগে' : '2d ago',
        'content': isBn ? 'সপ্তাহান্তে কোন কাজটি করতে চান?' : 'What do you want to do this weekend?',
        'type': 'poll',
        'poll': {
          'question': isBn ? 'সপ্তাহান্তে কোন কাজটি করতে চান?' : 'What do you want to do this weekend?',
          'options': [
            {'id': 1, 'text': isBn ? 'বাইরে ঘুরতে যাওয়া' : 'Go outside', 'votes': 312},
            {'id': 2, 'text': isBn ? 'বই পড়া' : 'Read a book', 'votes': 189},
            {'id': 3, 'text': isBn ? 'মুভি দেখা' : 'Watch a movie', 'votes': 278},
            {'id': 4, 'text': isBn ? 'বন্ধুদের সাথে আড্ডা' : 'Hang out with friends', 'votes': 421},
          ],
          'totalVotes': 1200,
          'endTime': isBn ? 'শেষ হয়েছে' : 'Ended',
          'hasVoted': true,
          'votedOptionId': 4,
        },
        'likes': 203,
        'comments': 124,
      },
    ];
  }
  
  List<Map<String, dynamic>> get _savedPosts {
    final isBn = appController.language == AppLanguage.bn;
    return [
      {
        'id': 201,
        'author': 'রাফি আহমেদ',
        'username': '@rafi_ahmed',
        'timestamp': isBn ? '১ ঘণ্টা আগে' : '1h ago',
        'content': isBn
            ? 'প্রোডাক্টিভিটি টিপস: প্রতিদিন ৩টি গুরুত্বপূর্ণ কাজের লিস্ট তৈরি করুন এবং সকালেই সেগুলো শেষ করার চেষ্টা করুন।'
            : 'Productivity tips: Create a list of 3 important tasks every day and try to finish them in the morning.',
        'type': 'text',
        'likes': 445,
        'comments': 78,
      },
      {
        'id': 202,
        'author': 'নাদিয়া রহমান',
        'username': '@nadia_rahman',
        'timestamp': isBn ? '৪ ঘণ্টা আগে' : '4h ago',
        'content': isBn
            ? 'কক্সবাজারে সূর্যোদয়ের এই দৃশ্য সারাজীবন মনে থাকবে!'
            : 'This sunrise view at Cox\'s Bazar will stay in my memory forever!',
        'type': 'image',
        'likes': 892,
        'comments': 156,
      },
    ];
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _editNameController.dispose();
    _editLocationController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAFAFA),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Cover Image Section
                    _buildCoverSection(isDark, isBn),

                    // Profile Card
                    _buildProfileCard(isDark, isBn),

                    // Post Cards
                    _buildPostCards(isDark, isBn),

                    // Bottom padding
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
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
          // Cover Image
          if (_coverImage != null)
            Image.file(
              _coverImage!,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            )
          else
            Container(
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
            // Profile Picture
            _buildProfilePicture(isDark),
            
            // Name
            _buildNameSection(isDark),
            
            // Location
            _buildLocationSection(isDark),
            
            // Edit Mode Buttons
            if (_isEditMode) _buildEditButtons(isDark, isBn),
            
            // Stats
            _buildStats(isDark, isBn),
            
            // Profile Completion Card
            if (!_isProfileComplete) _buildProfileCompletionCard(isDark, isBn),
            
            // Tabs
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
                    : Image.asset(
                        'assets/images/42b72b8a79f3a110aa8f70956343252fbc8ff7c6.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFC4C4C4),
                          child: Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                      ),
              ),
            ),
            
            // Edit button
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ),
            
            // Camera overlay in edit mode
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
                        color: isDark
                            ? const Color(0xFF0d3a4a)
                            : Colors.black.withOpacity(0.1),
                        width: 2,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.lightPrimary, // 🔥 orange
                        width: 2,
                      ),
                    ),
                  ),






                  // decoration: InputDecoration(
                  //   border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),),
                  //   focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),),
                  //   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  // ),
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
        padding: const EdgeInsets.only(bottom: 16),
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
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                        suffixIcon: _editLocationController.text.trim().isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(right: 18),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFB8DED6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Color(0xFF1A1A1A),
                                    size: 14,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
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
                      color: isDark ? Colors.white : const Color(0x000ff333),
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
  
  Widget _buildProfileCompletionCard(bool isDark, bool isBn) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.lightPrimary.withValues(alpha: 0.2),
                  AppColors.lightSecondary.withValues(alpha: 0.2),
                ]
              : [
                  AppColors.lightPrimary.withValues(alpha: 0.1),
                  AppColors.lightSecondary.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightPrimary.withValues(alpha: isDark ? 0.4 : 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isBn ? 'প্রোফাইল সম্পূর্ণ করুন' : 'Complete your profile',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_completionPercentage%',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1a1a1a) : const Color(0xFFe0e0e0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _completionPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.lightPrimary, AppColors.lightSecondary],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Checklist
          ..._profileCompletionItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    item['completed'] == true ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: item['completed'] == true
                        ? AppColors.lightSecondary
                        : (isDark ? const Color(0xFF5e5e5e) : const Color(0xFF9d9d9d)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['label'],
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: item['completed'] == true
                            ? (isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471))
                            : (isDark ? Colors.white : const Color(0xFF0f1419)),
                        decoration: item['completed'] == true ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(
            isBn
                ? 'একটি সম্পূর্ণ প্রোফাইল আপনাকে সম্প্রদায়ের সাথে আরও ভালভাবে সংযুক্ত করবে!'
                : 'A complete profile helps you connect better with the community!',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: isDark ? const Color(0xFF8e8e8e) : const Color(0xFF536471),
            ),
          ),
        ],
        ),
      ),
    );
  }
  

  Widget _buildTabs(bool isDark, bool isBn) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final tabWidth = containerWidth / 3;

        int index = _activeTab == 'post'
            ? 0
            : _activeTab == 'poll'
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
              /// ✅ Active background (perfect like Image #2)
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

              /// Tabs
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      'post',
                      Icons.grid_on,
                      'Post',
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      'poll',
                      Icons.poll,
                      'Poll',
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      'saved',
                      Icons.bookmark_outline,
                      'Saved',
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }




  Widget _buildTabButton(String tab, IconData icon, String label, bool isDark) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
        _tabAnimationController.forward(from: 0);
      },
      child: SizedBox(
        height: 53,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF9D9D9D),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.1,
                color: isActive ? Colors.white : const Color(0xFF9D9D9D),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPostCards(bool isDark, bool isBn) {
    List<Map<String, dynamic>> posts = [];
    Set<int> likedSet = {};
    
    if (_activeTab == 'post') {
      posts = _userPosts;
      likedSet = _likedPosts;
    } else if (_activeTab == 'poll') {
      posts = _pollPosts;
      likedSet = _likedPolls;
    } else {
      posts = _savedPosts;
      likedSet = _likedSaved;
    }
    
    // Add 3rd poll post for 'poll' tab
    if (_activeTab == 'poll' && posts.length < 3) {
      posts = [...posts, _thirdPollPost];
    }
    
    // Add 3rd saved post for 'saved' tab
    if (_activeTab == 'saved' && posts.length < 3) {
      posts = [...posts, _thirdSavedPost];
    }
    
    return Transform.translate(
      offset: const Offset(0, -90),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: posts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PostCard(
                author: post['author'],
                username: post['username'],
                timestamp: post['timestamp'],
                content: post['content'],
                type: post['type'],
                gradient: post['gradient'],
                poll: post['poll'],
                likes: post['likes'],
                comments: post['comments'],
                isLiked: likedSet.contains(post['id']),
                onLike: () {
                  setState(() {
                    if (_activeTab == 'post') {
                      if (_likedPosts.contains(post['id'])) {
                        _likedPosts.remove(post['id']);
                      } else {
                        _likedPosts.add(post['id']);
                      }
                    } else if (_activeTab == 'poll') {
                      if (_likedPolls.contains(post['id'])) {
                        _likedPolls.remove(post['id']);
                      } else {
                        _likedPolls.add(post['id']);
                      }
                    } else {
                      if (_likedSaved.contains(post['id'])) {
                        _likedSaved.remove(post['id']);
                      } else {
                        _likedSaved.add(post['id']);
                      }
                    }
                  });
                },
                language: isBn ? 'bn' : 'en',
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> get _thirdPollPost {
    final isBn = appController.language == AppLanguage.bn;
    return {
      'id': 103,
      'author': 'Thomas R.',
      'username': '@thomas_r',
      'timestamp': isBn ? '১ সপ্তাহ আগে' : '1w ago',
      'content': isBn
          ? 'আপনি কোন সময়ে বেশি productive?'
          : 'When are you most productive?',
      'type': 'poll',
      'poll': {
        'question': isBn
            ? 'আপনি কোন সময়ে বেশি productive?'
            : 'When are you most productive?',
        'options': [
          {'id': 1, 'text': isBn ? 'ভোর ৫-৮টা' : 'Early morning (5-8 AM)', 'votes': 267},
          {'id': 2, 'text': isBn ? 'সকাল ৮-১২টা' : 'Morning (8 AM-12 PM)', 'votes': 445},
          {'id': 3, 'text': isBn ? 'বিকাল ১-৫টা' : 'Afternoon (1-5 PM)', 'votes': 189},
          {'id': 4, 'text': isBn ? 'রাত ৮-১২টা' : 'Night (8 PM-12 AM)', 'votes': 312},
        ],
        'totalVotes': 1213,
        'endTime': isBn ? 'শেষ হয়েছে' : 'Ended',
        'hasVoted': true,
        'votedOptionId': 2,
      },
      'likes': 92,
      'comments': 45,
    };
  }

  Map<String, dynamic> get _thirdSavedPost {
    final isBn = appController.language == AppLanguage.bn;
    return {
      'id': 203,
      'author': 'সাকিব হাসান',
      'username': '@sakib_hassan',
      'timestamp': isBn ? '১ দিন আগে' : '1d ago',
      'content': isBn
          ? 'জীবনে সফল হতে হলে প্রতিদিন একটু একটু করে এগিয়ে যেতে হবে। থেমে থাকলে পিছিয়ে যাওয়া ছাড়া কোনো উপায় নেই।'
          : 'To be successful in life, you have to move forward a little bit every day. If you stop, there is no other way but to fall behind.',
      'type': 'gradient',
      'gradient': 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
      'likes': 567,
      'comments': 234,
    };
  }
}
