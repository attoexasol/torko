import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/navigation_controller.dart';

// Post model
class Post {
  final String id;
  final String author;
  final String username;
  final String? authorAvatar;
  final String? groupName;
  final String timestamp;
  final int hoursAgo;
  final String content;
  final String? image;
  final String? video;
  final List<String>? images;
  final List<String>? videos;
  final String type; // text, image, video, gradient, multiImage, multiVideo, poll
  final String? gradient;
  final Map<String, dynamic>? poll;
  int likes;
  final int comments;
  final int shares;
  bool isLiked;
  bool isSaved;
  bool isHidden;

  Post({
    required this.id,
    required this.author,
    required this.username,
    this.authorAvatar,
    this.groupName,
    required this.timestamp,
    required this.hoursAgo,
    required this.content,
    this.image,
    this.video,
    this.images,
    this.videos,
    required this.type,
    this.gradient,
    this.poll,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
    this.isSaved = false,
    this.isHidden = false,
  });
}

class HomeController extends GetxController {
  final RxString activeTab = 'forYou'.obs;
  final RxBool showHeader = true.obs;
  final RxBool isLoading = false.obs;
  final RxList<Post> posts = <Post>[].obs;
  final RxSet<String> savedPosts = <String>{}.obs;
  final RxSet<String> hiddenPosts = <String>{}.obs;
  final RxSet<String> followingUsers = <String>{}.obs;
  
  final ScrollController scrollController = ScrollController();
  double lastScrollY = 0;

  // Report dialog state
  final RxBool reportDialogOpen = false.obs;
  final RxString reportingPostId = ''.obs;
  final RxInt reportStep = 1.obs;
  final RxString reportReason = ''.obs;
  final RxString reportSubReason = ''.obs;

  // Gradients for text posts
  static const List<String> gradients = [
    'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
    'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    'linear-gradient(135deg, #30cfd0 0%, #330867 100%)',
    'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
    'linear-gradient(135deg, #ff9a56 0%, #ff6a88 100%)',
    'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
    'linear-gradient(135deg, #ff6e7f 0%, #bfe9ff 100%)',
    'linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%)',
    'linear-gradient(135deg, #f77062 0%, #fe5196 100%)',
  ];

  // Authors
  static const List<String> authors = [
    'Sarah Johnson', 'Michael Chen', 'Emma Williams', 'David Rodriguez', 'Lisa Anderson',
    'James Park', 'Sophia Martinez', 'আবদুল কাদের', 'নাজমুল হাসান', 'তানিয়া আফরিন',
    'Emily Brown', 'Christopher Lee', 'Isabella Garcia', 'Matthew Harris', 'Ava Thompson',
    'Ryan White', 'Mia Robinson', 'Kevin Walker', 'Charlotte Hall', 'Brandon Scott',
    'Daniel Kim', 'সাবিহা আক্তার', 'Olivia Taylor', 'শাহরিয়ার কবির', 'Robert Lewis'
  ];

  // Groups
  static const List<String> groups = [
    'ঢাকা ফুড লাভার্স', 'Tech Community BD', 'বই পড়ুয়া', 'Travel Bangladesh',
    'গুলশান কমিউনিটি', 'Photography BD', 'বাংলাদেশ স্টার্টআপ', 'Fitness Enthusiasts',
    'বনানী রেসিডেন্টস', 'Dhaka Bikers', 'ভ্রমণপিপাসু', 'Coding Ninjas BD',
    'রান্নাঘর', 'Dhaka University Alumni', 'বাংলা সাহিত্য', 'Sports Lovers BD',
    'মিরপুর কমিউনিটি', 'Digital Marketing BD', 'আর্ট এন্ড ক্রাফট', 'Entrepreneurs BD',
  ];

  // Text contents
  static const List<String> textContents = [
    'আজকের দিনটা সত্যিই অসাধারণ ছিল!',
    'জীবনে স্বপ্ন দেখতে কখনো ভুলে যেও না।',
    'পরিবার এবং বন্ধুরাই সবচেয়ে বড় সম্পদ।',
    'প্রতিটি সূর্যোদয়ের সাথে আসে নতুন আশা।',
    'কঠোর পরিশ্রমই সফলতার চাবিকাঠি।',
    'ভালোবাসা পৃথিবীকে বদলে দিতে পারে।',
    'শিক্ষাই জাতির মেরুদণ্ড।',
    'স্বপ্নকে বাস্তবে পরিণত করো।',
    'এই মুহূর্তটা আর কখনো ফিরে আসবে না।',
    'ধৈর্য এবং বিশ্বাসই সফলতার চাবি।',
    'Today was amazing! এত ভালো লাগলো',
    'Finally completed my project! অনেক কষ্ট করতে হয়েছে',
    'Weekend vibes with friends! মজা করলাম অনেক',
    'New cafe discover করলাম Dhanmondi তে, must try!',
    'Just finished reading this book! অসাধারণ ছিল',
    'Morning walk করে এলাম, feeling refreshed',
    'Trying new recipe today! দেখি কেমন হয়',
    'Late night coding session, coffee লাগবে',
    'Monsoon season এসে গেছে finally!',
    'Weekend plan করছি friends দের সাথে',
  ];

  // Content templates
  static const List<String> contentTemplates = [
    'আজকের সূর্যাস্ত সত্যিই অসাধারণ ছিল! দৃশ্যটা হৃদয় ভরিয়ে দিয়েছে।',
    'ঢাকার রাস্তায় বৃষ্টির দৃশ্য সবার সাথে শেয়ার করছি।',
    'সুন্দরবনের এক অপূর্ব প্রাকৃতিক দৃশ্য। বাংলাদেশের গর্ব!',
    'রমজান মাসে ইফতারের বিশেষ রেসিপি দেখুন!',
    'পাহাড়ি এলাকায় ভ্রমণের কিছু মুহূর্ত। অবিশ্বাস্য সৌন্দর্য!',
    'নতুন প্রযুক্তি নিয়ে কাজ করছি। অনেক উত্তেজিত!',
    'বইমেলায় নতুন বই কিনেছি। পড়ার জন্য অপেক্ষা করছি!',
    'ক্রিকেট ম্যাচের কিছু হাইলাইটস! চমৎকার পারফরম্যান্স।',
    "Cox's Bazar এ sunset দেখছি, breathtaking view!",
    'Gulshan Lake এ morning walk, so peaceful!',
    'Street food hunting in Old Dhaka! মজা লাগছে',
    'New coffee shop discover করলাম Banani তে, loved it!',
    'Pohela Boishakh celebration! সবাইকে শুভেচ্ছা',
    'Victory Day parade দেখে এলাম, proud moment!',
    'Rooftop party with squad! Perfect weather আজকে',
  ];

  // Sample images
  static const List<String> sampleImages = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    'https://images.unsplash.com/photo-1617634667039-8e4cb277ab46?w=800',
    'https://images.unsplash.com/photo-1551982932-22e28394fbb7?w=800',
    'https://images.unsplash.com/photo-1617121346253-43ef95179ac9?w=800',
    'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=800',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
  ];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    _initializeFollowingUsers();
    _generatePosts();
    
    // Set navigation state to home
    _navController.setCurrentScreen('home');
  }

  @override
  void onClose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _initializeFollowingUsers() {
    followingUsers.addAll(['Michael Chen', 'David Rodriguez', 'James Park', 'Olivia Taylor', 'Robert Lewis']);
  }

  void _handleScroll() {
    final appController = Get.find<AppController>();
    final currentScrollY = scrollController.offset;
    final scrollDelta = currentScrollY - lastScrollY;
    
    if (currentScrollY < 10) {
      showHeader.value = true;
      appController.setHideBottomNav(false);
    } else if (scrollDelta > 15 && currentScrollY > 20) {
      showHeader.value = false;
      appController.setHideBottomNav(true);
    } else if (scrollDelta < -5) {
      showHeader.value = true;
      appController.setHideBottomNav(false);
    }
    
    lastScrollY = currentScrollY;
  }

  void _generatePosts() {
    final List<Post> generatedPosts = [];
    
    for (int i = 1; i <= 50; i++) {
      final authorIndex = (i - 1) % authors.length;
      final author = authors[authorIndex];
      final randomHours = (i * 3) % 24 + 1;
      
      // Determine post type based on index for variety
      String type;
      String content;
      String? gradient;
      String? image;
      List<String>? images;
      Map<String, dynamic>? poll;
      
      final typeIndex = i % 10;
      
      if (typeIndex < 2) {
        // Gradient text post (20%)
        type = 'gradient';
        content = textContents[i % textContents.length];
        gradient = gradients[i % gradients.length];
      } else if (typeIndex < 4) {
        // Single image post (20%)
        type = 'image';
        content = contentTemplates[i % contentTemplates.length];
        image = sampleImages[i % sampleImages.length];
      } else if (typeIndex < 6) {
        // Multiple images post (20%)
        type = 'multiImage';
        content = contentTemplates[i % contentTemplates.length];
        final numImages = (i % 4) + 2; // 2 to 5 images
        images = [];
        for (int j = 0; j < numImages; j++) {
          images.add(sampleImages[(i + j) % sampleImages.length]);
        }
      } else if (typeIndex < 7) {
        // Poll post (10%)
        type = 'poll';
        content = 'কোনটি আপনার পছন্দ?';
        poll = {
          'question': i % 2 == 0 ? 'What is your favorite color?' : 'কোন খাবার বেশি পছন্দ?',
          'options': [
            {'id': 1, 'text': i % 2 == 0 ? 'Red' : 'বিরিয়ানি', 'votes': 45 + i},
            {'id': 2, 'text': i % 2 == 0 ? 'Blue' : 'খিচুড়ি', 'votes': 32 + i},
            {'id': 3, 'text': i % 2 == 0 ? 'Green' : 'পোলাও', 'votes': 28 + i},
            {'id': 4, 'text': i % 2 == 0 ? 'Yellow' : 'ভাত-মাছ', 'votes': 55 + i},
          ],
          'totalVotes': 160 + (i * 4),
          'hasVoted': i % 3 == 0,
          'votedOptionId': i % 3 == 0 ? (i % 4) + 1 : null,
        };
      } else {
        // Regular text post (30%)
        type = 'text';
        content = '${contentTemplates[i % contentTemplates.length]} ${textContents[i % textContents.length]}';
      }

      generatedPosts.add(Post(
        id: '$i',
        author: author,
        username: '@${author.replaceAll(' ', '').toLowerCase()}',
        authorAvatar: null,
        groupName: i % 3 == 0 ? groups[i % groups.length] : null, // ~33% group posts
        timestamp: '$randomHours${_getHoursSuffix()}',
        hoursAgo: randomHours,
        content: content,
        image: image,
        images: images,
        type: type,
        gradient: gradient,
        poll: poll,
        likes: 50 + (i * 17) % 2000,
        comments: 10 + (i * 7) % 300,
        shares: 5 + (i * 3) % 150,
        isLiked: i % 5 == 0,
      ));
    }
    
    posts.value = generatedPosts;
  }

  String _getHoursSuffix() {
    final appController = Get.find<AppController>();
    return appController.language == AppLanguage.bn ? 'ঘ' : 'h';
  }

  // Get filtered posts based on active tab
  List<Post> get filteredPosts {
    final visiblePosts = posts.where((post) => !hiddenPosts.contains(post.id)).toList();
    
    switch (activeTab.value) {
      case 'following':
        return visiblePosts.where((post) => followingUsers.contains(post.author)).toList();
      case 'trending':
        final sorted = List<Post>.from(visiblePosts);
        sorted.sort((a, b) => (b.likes + b.comments).compareTo(a.likes + a.comments));
        return sorted;
      case 'forYou':
      default:
        return visiblePosts;
    }
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
  }

  void handleLike(String postId) {
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = posts[postIndex];
      post.isLiked = !post.isLiked;
      post.likes = post.isLiked ? post.likes + 1 : post.likes - 1;
      posts.refresh();
    }
  }

  void handleComment(String postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: {'postId': postId});
  }

  void handleShare(String postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    appController.showNotification(
      title: isBn ? 'শেয়ার' : 'Share',
      message: isBn ? 'শেয়ার ফিচার শীঘ্রই আসছে!' : 'Share feature coming soon!',
    );
  }

  void handleSavePost(String postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    if (savedPosts.contains(postId)) {
      savedPosts.remove(postId);
      appController.showNotification(
        title: isBn ? 'আনসেভ' : 'Unsaved',
        message: isBn ? 'পোস্ট আনসেভ করা হয়েছে' : 'Post unsaved',
      );
    } else {
      savedPosts.add(postId);
      appController.showNotification(
        title: isBn ? 'সেভ' : 'Saved',
        message: isBn ? 'পোস্ট সেভ করা হয়েছে' : 'Post saved',
      );
    }
  }

  void handleHidePost(String postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    hiddenPosts.add(postId);
    posts.refresh();
    
    appController.showNotification(
      title: isBn ? 'লুকানো' : 'Hidden',
      message: isBn ? 'পোস্ট লুকানো হয়েছে' : 'Post hidden',
    );
  }

  void handleFollowUser(String author) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    if (followingUsers.contains(author)) {
      followingUsers.remove(author);
      appController.showNotification(
        title: isBn ? 'আনফলো' : 'Unfollowed',
        message: isBn ? '$author কে আনফলো করা হয়েছে' : 'Unfollowed $author',
      );
    } else {
      followingUsers.add(author);
      appController.showNotification(
        title: isBn ? 'ফলো' : 'Following',
        message: isBn ? '$author কে ফলো করা হয়েছে' : 'Following $author',
      );
    }
  }

  void handleReportPost(String postId) {
    reportingPostId.value = postId;
    reportDialogOpen.value = true;
    reportStep.value = 1;
    reportReason.value = '';
    reportSubReason.value = '';
  }

  void handleCopyLink(String postId) {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    // In a real app, use Clipboard.setData
    appController.showNotification(
      title: isBn ? 'কপি' : 'Copied',
      message: isBn ? 'লিংক কপি করা হয়েছে' : 'Link copied',
    );
  }

  void submitReport() {
    final appController = Get.find<AppController>();
    final isBn = appController.language == AppLanguage.bn;
    
    reportDialogOpen.value = false;
    reportStep.value = 1;
    reportReason.value = '';
    reportSubReason.value = '';
    reportingPostId.value = '';
    
    appController.showNotification(
      title: isBn ? 'রিপোর্ট' : 'Reported',
      message: isBn ? 'আপনার রিপোর্ট জমা দেওয়া হয়েছে। ধন্যবাদ!' : 'Your report has been submitted. Thank you!',
    );
  }

  void cancelReport() {
    reportDialogOpen.value = false;
    reportStep.value = 1;
    reportReason.value = '';
    reportSubReason.value = '';
    reportingPostId.value = '';
  }

  void setReportStep(int step) {
    reportStep.value = step;
  }

  void setReportReason(String reason) {
    reportReason.value = reason;
  }

  void setReportSubReason(String subReason) {
    reportSubReason.value = subReason;
  }

  bool isPostSaved(String postId) => savedPosts.contains(postId);
  bool isFollowing(String author) => followingUsers.contains(author);

  NavigationController get _navController {
    if (Get.isRegistered<NavigationController>()) {
      return Get.find<NavigationController>();
    } else {
      return Get.put(NavigationController(), permanent: true);
    }
  }

  void onNavigate(String screen) {
    // Use centralized navigation controller
    _navController.navigateTo(screen);
  }
}


