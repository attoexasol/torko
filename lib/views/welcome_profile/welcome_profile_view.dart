import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class SuggestedAction {
  final String id;
  final String titleBn;
  final String titleEn;
  final String descriptionBn;
  final String descriptionEn;
  final IconData icon;
  bool completed;
  final String actionType;

  SuggestedAction({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.descriptionBn,
    required this.descriptionEn,
    required this.icon,
    required this.completed,
    required this.actionType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'completed': completed,
      };
}

class WelcomeProfileView extends StatefulWidget {
  const WelcomeProfileView({super.key});

  @override
  State<WelcomeProfileView> createState() => _WelcomeProfileViewState();
}

class _WelcomeProfileViewState extends State<WelcomeProfileView>
    with TickerProviderStateMixin {
  final appController = Get.find<AppController>();

  // User data
  Map<String, dynamic> userProfile = {};
  Map<String, dynamic> userLocation = {};

  // Actions
  List<SuggestedAction> suggestedActions = [];

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _emojiController;
  late AnimationController _cardController;
  late AnimationController _progressController;
  late AnimationController _contentController;
  late AnimationController _bottomController;

  // Animations
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _emojiScale;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;
  late Animation<double> _progressOpacity;
  late Animation<Offset> _progressSlide;
  late Animation<double> _contentOpacity;
  late Animation<double> _bottomOpacity;
  late Animation<Offset> _bottomSlide;

  Timer? _progressReloadTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
    _initActions();
    _startAnimations();
    _startProgressReloadTimer();
  }

  void _initAnimations() {
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    // Emoji animation
    _emojiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _emojiScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(_emojiController);

    // Card animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    _progressSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));

    // Content animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    // Bottom animation
    _bottomController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bottomOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bottomController, curve: Curves.easeOut));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _emojiController.repeat(
      reverse: false,
      period: const Duration(milliseconds: 5000),
    );

    await Future.delayed(const Duration(milliseconds: 200));
    _cardController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _bottomController.forward();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final profileStr = prefs.getString('torko_user_profile');
    if (profileStr != null) {
      try {
        userProfile = jsonDecode(profileStr);
      } catch (e) {
        userProfile = {};
      }
    }

    final locationStr = prefs.getString('torko_user_location');
    if (locationStr != null) {
      try {
        userLocation = jsonDecode(locationStr);
      } catch (e) {
        userLocation = {};
      }
    }

    setState(() {});
  }

  void _initActions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProgressStr = prefs.getString('torko_welcome_progress');

    List<dynamic>? savedProgress;
    if (savedProgressStr != null) {
      try {
        savedProgress = jsonDecode(savedProgressStr);
      } catch (e) {
        savedProgress = null;
      }
    }

    final locationStr = prefs.getString('torko_user_location');
    Map<String, dynamic> location = {};
    if (locationStr != null) {
      try {
        location = jsonDecode(locationStr);
      } catch (e) {
        location = {};
      }
    }

    final districtBn = location['districtBn'] ?? 'স্থানীয়';
    final district = location['district'] ?? 'your area';

    final defaultActions = [
      SuggestedAction(
        id: 'complete_profile',
        titleBn: 'প্রোফাইল সম্পূর্ণ করুন',
        titleEn: 'Complete Your Profile',
        descriptionBn: 'প্রোফাইল ছবি এবং বায়ো যোগ করুন',
        descriptionEn: 'Add profile picture and bio',
        icon: Icons.person_outline,
        completed: false,
        actionType: 'profile',
      ),
      SuggestedAction(
        id: 'find_community',
        titleBn: 'আপনার এলাকা খুঁজুন',
        titleEn: 'Find Your Community',
        descriptionBn: '$districtBn এর মানুষদের সাথে যুক্ত হন',
        descriptionEn: 'Connect with people in $district',
        icon: Icons.location_on_outlined,
        completed: true, // Already selected location
        actionType: 'explore',
      ),
      SuggestedAction(
        id: 'follow_people',
        titleBn: 'গ্রুপ ফলো করুন',
        titleEn: 'Follow Group',
        descriptionBn: 'আপনার আগ্রহের গ্রুপে যোগ দিন',
        descriptionEn: 'Join groups that interest you',
        icon: Icons.person_add_outlined,
        completed: false,
        actionType: 'follow',
      ),
      SuggestedAction(
        id: 'first_post',
        titleBn: 'প্রথম পোস্ট করুন',
        titleEn: 'Create Your First Post',
        descriptionBn: 'আপনার চিন্তা বা মতামত শেয়ার করুন',
        descriptionEn: 'Share your thoughts or opinion',
        icon: Icons.chat_bubble_outline,
        completed: false,
        actionType: 'post',
      ),
    ];

    if (savedProgress != null) {
      for (var action in defaultActions) {
        final saved = savedProgress.firstWhere(
          (p) => p['id'] == action.id,
          orElse: () => null,
        );
        if (saved != null) {
          action.completed = saved['completed'] ?? false;
        }
      }
    }

    setState(() {
      suggestedActions = defaultActions;
    });
  }

  void _startProgressReloadTimer() {
    _progressReloadTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _reloadProgress(),
    );
  }

  Future<void> _reloadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProgressStr = prefs.getString('torko_welcome_progress');

    if (savedProgressStr != null) {
      try {
        final savedProgress = jsonDecode(savedProgressStr) as List<dynamic>;
        bool hasChanges = false;

        for (var action in suggestedActions) {
          final saved = savedProgress.firstWhere(
            (p) => p['id'] == action.id,
            orElse: () => null,
          );
          if (saved != null && action.completed != saved['completed']) {
            action.completed = saved['completed'] ?? false;
            hasChanges = true;
          }
        }

        if (hasChanges && mounted) {
          setState(() {});
        }
      } catch (e) {
        // Ignore parse errors
      }
    }
  }

  void _handleActionClick(SuggestedAction action) async {
    if (action.completed) return;

    final prefs = await SharedPreferences.getInstance();

    switch (action.actionType) {
      case 'profile':
        await prefs.setString('torko_from_welcome', 'complete_profile');
        Get.toNamed(AppRoutes.profile);
        break;
      case 'follow':
        await prefs.setString('torko_from_welcome', 'follow_people');
        Get.toNamed(AppRoutes.localCommunity);
        break;
      case 'post':
        await prefs.setString('torko_from_welcome', 'first_post');
        Get.toNamed(AppRoutes.createPost);
        break;
      default:
        break;
    }
  }

  void _handleGetStarted() async {
    if (!_allCompleted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('torko_welcome_completed', true);
    Get.offAllNamed(AppRoutes.home);
  }

  int get _completedCount =>
      suggestedActions.where((action) => action.completed).length;

  int get _totalCount => suggestedActions.length;

  double get _progressPercentage =>
      _totalCount > 0 ? (_completedCount / _totalCount) : 0;

  bool get _allCompleted => _completedCount == _totalCount;

  @override
  void dispose() {
    _headerController.dispose();
    _emojiController.dispose();
    _cardController.dispose();
    _progressController.dispose();
    _contentController.dispose();
    _bottomController.dispose();
    _progressReloadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;

      final userName = userProfile['name'] ?? '';
      final divisionBn = userLocation['divisionBn'] ?? '';
      final districtBn = userLocation['districtBn'] ?? '';
      final division = userLocation['division'] ?? '';
      final district = userLocation['district'] ?? '';

      final locationText = isBn
          ? '$divisionBn, $districtBn'
          : '$division, $district';

      return Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : const Color(0xFFF0FDF4),
        body: Container(
          decoration: isDark
              ? null
              : const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color(0xFFF0FDF4),
                      Color(0xFFDCFCE7),
                    ],
                  ),
                ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(isDark, isBn, userName, locationText),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildContent(isDark, isBn),
                  ),
                ),

                // Bottom Actions
                _buildBottomActions(isDark, isBn),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark, bool isBn, String userName, String locationText) {
    return FadeTransition(
      opacity: _headerOpacity,
      child: SlideTransition(
        position: _headerSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Column(
            children: [
              // Welcome Message with Emoji
              ScaleTransition(
                scale: _emojiScale,
                child: const Text(
                  '🎉',
                  style: TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isBn ? 'স্বাগতম, $userName!' : 'Welcome, $userName!',
                style: TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkSecondary
                      : const Color(0xFF166534),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isBn
                    ? 'Torko তে আপনাকে স্বাগতম! চলুন শুরু করা যাক।'
                    : 'Welcome to Torko! Let\'s get you started.',
                style: TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkSecondary.withValues(alpha: 0.7)
                      : const Color(0xFF4D7C0F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // User Info Card
              FadeTransition(
                opacity: _cardOpacity,
                child: SlideTransition(
                  position: _cardSlide,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? null
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFDC2626),
                                      Color(0xFF166534),
                                    ],
                                  ),
                            color: isDark ? AppColors.darkPrimary : null,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontFamily: 'NotoSansBengali',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.darkSecondary
                                      : const Color(0xFF166534),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: isDark
                                        ? AppColors.darkSecondary.withValues(alpha: 0.6)
                                        : const Color(0xFF4D7C0F),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    locationText,
                                    style: TextStyle(
                                      fontFamily: 'NotoSansBengali',
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkSecondary.withValues(alpha: 0.6)
                                          : const Color(0xFF4D7C0F),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress Bar
              FadeTransition(
                opacity: _progressOpacity,
                child: SlideTransition(
                  position: _progressSlide,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'অগ্রগতি' : 'Progress',
                            style: TextStyle(
                              fontFamily: 'NotoSansBengali',
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkSecondary
                                  : const Color(0xFF166534),
                            ),
                          ),
                          Text(
                            '$_completedCount/$_totalCount',
                            style: TextStyle(
                              fontFamily: 'NotoSansBengali',
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _progressPercentage),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            AppColors.darkPrimary,
                                            AppColors.darkSecondary,
                                          ]
                                        : [
                                            const Color(0xFFDC2626),
                                            const Color(0xFF166534),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isBn) {
    return FadeTransition(
      opacity: _contentOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'প্রস্তাবিত পদক্ষেপ' : 'Suggested Actions',
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkSecondary
                  : const Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 12),

          // Action Items
          ...suggestedActions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildActionItem(action, isDark, isBn),
            );
          }),

          const SizedBox(height: 24),

          // Tips Section
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkMuted.withValues(alpha: 0.5)
                    : null,
                gradient: isDark
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x0DDC2626),
                          Color(0x0D166534),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF104050)
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 20,
                    color: isDark
                        ? AppColors.darkPrimary
                        : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? '💡 টিপস' : '💡 Quick Tip',
                          style: TextStyle(
                            fontFamily: 'NotoSansBengali',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkSecondary
                                : const Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBn
                              ? 'আপনার স্থানীয় কমিউনিটির সাথে সংযুক্ত হয়ে সেরা অভিজ্ঞতা পান। প্রতিদিন নতুন বন্ধু খুঁজুন এবং আকর্ষণীয় আলোচনায় অংশ নিন!'
                              : 'Get the best experience by connecting with your local community. Find new friends and join interesting discussions every day!',
                          style: TextStyle(
                            fontFamily: 'NotoSansBengali',
                            fontSize: 12,
                            height: 1.5,
                            color: isDark
                                ? AppColors.darkSecondary.withValues(alpha: 0.7)
                                : const Color(0xFF4D7C0F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionItem(SuggestedAction action, bool isDark, bool isBn) {
    return GestureDetector(
      onTap: () => _handleActionClick(action),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: action.completed
              ? (isDark
                  ? AppColors.darkCard.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.4))
              : (isDark
                  ? AppColors.darkCard
                  : Colors.white.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.completed
                ? (isDark
                    ? AppColors.darkBorder
                    : Colors.white.withValues(alpha: 0.4))
                : (isDark
                    ? AppColors.darkBorder
                    : Colors.white.withValues(alpha: 0.6)),
            width: 2,
          ),
        ),
        child: Opacity(
          opacity: action.completed ? 0.6 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.completed
                      ? (isDark
                          ? AppColors.darkPrimary.withValues(alpha: 0.2)
                          : const Color(0xFF166534).withValues(alpha: 0.2))
                      : (isDark
                          ? AppColors.darkMuted
                          : null),
                  gradient: action.completed || isDark
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x1ADC2626),
                            Color(0x1A166534),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  size: 24,
                  color: action.completed
                      ? (isDark
                          ? AppColors.darkPrimary
                          : const Color(0xFF166534))
                      : (isDark
                          ? AppColors.darkSecondary
                          : const Color(0xFF4D7C0F)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isBn ? action.titleBn : action.titleEn,
                            style: TextStyle(
                              fontFamily: 'NotoSansBengali',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkSecondary
                                  : const Color(0xFF166534),
                            ),
                          ),
                        ),
                        if (action.completed)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Transform.rotate(
                                  angle: (1 - value) * -3.14,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : const Color(0xFF166534),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: isDark
                                ? AppColors.darkSecondary.withValues(alpha: 0.5)
                                : const Color(0xFF4D7C0F),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBn ? action.descriptionBn : action.descriptionEn,
                      style: TextStyle(
                        fontFamily: 'NotoSansBengali',
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkSecondary.withValues(alpha: 0.6)
                            : const Color(0xFF4D7C0F),
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
  }

  Widget _buildBottomActions(bool isDark, bool isBn) {
    return FadeTransition(
      opacity: _bottomOpacity,
      child: SlideTransition(
        position: _bottomSlide,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      AppColors.darkBackground.withValues(alpha: 0),
                      AppColors.darkBackground.withValues(alpha: 0.95),
                      AppColors.darkBackground,
                    ]
                  : [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _handleGetStarted,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _allCompleted
                        ? (isDark ? AppColors.darkMuted : null)
                        : (isDark
                            ? AppColors.darkCard
                            : Colors.grey[200]),
                    gradient: _allCompleted && !isDark
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFDC2626),
                              Color(0xFF166534),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: _allCompleted
                          ? (isDark
                              ? AppColors.darkPrimary
                              : Colors.transparent)
                          : (isDark
                              ? AppColors.darkBorder
                              : Colors.grey[300]!),
                      width: 2,
                    ),
                    boxShadow: _allCompleted
                        ? [
                            BoxShadow(
                              color: isDark
                                  ? AppColors.darkPrimary.withValues(alpha: 0.3)
                                  : const Color(0xFF166534).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isBn ? 'শুরু করুন' : 'Get Started',
                        style: TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _allCompleted
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkSecondary.withValues(alpha: 0.4)
                                  : Colors.grey[400]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: _allCompleted
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkSecondary.withValues(alpha: 0.4)
                                : Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_allCompleted) ...[
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: _allCompleted ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    isBn
                        ? 'সব ধাপ সম্পূর্ণ করুন এগিয়ে যেতে'
                        : 'Complete all steps to continue',
                    style: TextStyle(
                      fontFamily: 'NotoSansBengali',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkSecondary.withValues(alpha: 0.6)
                          : const Color(0xFF4D7C0F).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
