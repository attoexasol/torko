import 'package:get/get.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/services/user_info.dart';

class NotificationItem {
  final int id;
  final String type;
  final String user;
  final String action;
  final String time;
  final bool unread;
  final String avatar;

  NotificationItem({
    required this.id,
    required this.type,
    required this.user,
    required this.action,
    required this.time,
    required this.unread,
    required this.avatar,
  });
}

class HomeHeaderController extends GetxController {
  final RxBool menuOpen = false.obs;
  final RxBool searchOpen = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool notificationOpen = false.obs;
  final RxInt unreadCount = 5.obs;

  AppController get appController => Get.find<AppController>();
  String get language => appController.languageCode;
  bool get isBn => appController.language == AppLanguage.bn;

  // Menu items - matches React exactly
  List<Map<String, dynamic>> get menuItems => [
    {
      'icon': 'home',
      'label': isBn ? 'হোম' : 'Home',
      'action': () => navigateTo('home'),
    },
    {
      'icon': 'people',
      'label': isBn ? 'লোকাল কমিউনিটি' : 'Local Community',
      'action': () => navigateTo('localCommunity'),
    },
    {
      'icon': 'bookmark',
      'label': isBn ? 'সেভ করা' : 'Saved',
      'action': () => print('Saved'),
    },
    {
      'icon': 'message',
      'label': isBn ? 'মেসেজ' : 'Messages',
      'action': () => navigateTo('messages'),
    },
    {
      'icon': 'notifications',
      'label': isBn ? 'বিজ্ঞপ্তি' : 'Notifications',
      'action': () => navigateTo('notifications'),
    },
    {
      'icon': 'person',
      'label': isBn ? 'প্রোফাইল' : 'Profile',
      'action': () => navigateTo('profile'),
    },
    {
      'icon': 'settings',
      'label': isBn ? 'সেটিংস' : 'Settings',
      'action': () => navigateTo('settings'),
    },
  ];

  // Trending searches - matches React exactly
  List<String> get trendingSearches => [
    isBn ? 'ঢাকা ট্রাফিক' : 'Dhaka Traffic',
    isBn ? 'বাংলাদেশ ক্রিকেট' : 'Bangladesh Cricket',
    isBn ? 'টেক স্টার্টআপ' : 'Tech Startup',
    isBn ? 'রমজান ২০২৫' : 'Ramadan 2025',
    isBn ? 'চট্টগ্রাম ইভেন্ট' : 'Chittagong Events',
  ];

  // Mock notifications - matches React exactly
  List<NotificationItem> get mockNotifications => [
    NotificationItem(
      id: 1,
      type: 'like',
      user: isBn ? 'আহমেদ রহমান' : 'Ahmed Rahman',
      action: isBn ? 'আপনার পোস্ট লাইক করেছে' : 'liked your post',
      time: isBn ? '৫ মিনিট আগে' : '5 min ago',
      unread: true,
      avatar: '🙂',
    ),
    NotificationItem(
      id: 2,
      type: 'comment',
      user: isBn ? 'ফাতিমা খান' : 'Fatima Khan',
      action: isBn ? 'আপনার পোস্টে মন্তব্য করেছে' : 'commented on your post',
      time: isBn ? '১৫ মিনিট আগে' : '15 min ago',
      unread: true,
      avatar: '👩',
    ),
    NotificationItem(
      id: 3,
      type: 'follow',
      user: isBn ? 'মাহমুদ হাসান' : 'Mahmud Hasan',
      action: isBn ? 'আপনাকে ফলো করতে শুরু করেছে' : 'started following you',
      time: isBn ? '১ ঘণ্টা আগে' : '1 hour ago',
      unread: true,
      avatar: '👨',
    ),
    NotificationItem(
      id: 4,
      type: 'message',
      user: isBn ? 'নাফিসা আক্তার' : 'Nafisa Akter',
      action: isBn ? 'আপনাকে একটি মেসেজ পাঠিয়েছে' : 'sent you a message',
      time: isBn ? '২ ঘণ্টা আগে' : '2 hours ago',
      unread: false,
      avatar: '👩‍💼',
    ),
    NotificationItem(
      id: 5,
      type: 'like',
      user: isBn ? 'রাকিব ইসলাম' : 'Rakib Islam',
      action: isBn ? 'আপনার মন্তব্য লাইক করেছে' : 'liked your comment',
      time: isBn ? '৩ ঘণ্টা আগে' : '3 hours ago',
      unread: false,
      avatar: '🧑',
    ),
  ];

  // User info
  String get userName => UserInfo.fullname ?? (isBn ? 'আপনার নাম' : 'Your Name');
  String get userInitial => isBn ? 'আ' : 'U';

  void openMenu() {
    menuOpen.value = true;
  }

  void closeMenu() {
    menuOpen.value = false;
  }

  void openSearch() {
    searchOpen.value = true;
  }

  void closeSearch() {
    searchOpen.value = false;
    searchQuery.value = '';
  }

  void openNotifications() {
    notificationOpen.value = true;
  }

  void closeNotifications() {
    notificationOpen.value = false;
  }

  void handleMenuItemClick(Function action) {
    action();
    closeMenu();
  }

  void handleSearchSubmit() {
    if (searchQuery.value.trim().isNotEmpty) {
      print('Searching for: ${searchQuery.value}');
      closeSearch();
    }
  }

  void handleTrendingSearchClick(String term) {
    searchQuery.value = term;
    print('Search trending: $term');
  }

  void handleNotificationClick(int notificationId) {
    print('Notification clicked: $notificationId');
    closeNotifications();
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }
  }

  void handleMarkAllAsRead() {
    unreadCount.value = 0;
  }

  void handleLogout() {
    print('Logout');
    closeMenu();
    // Add actual logout logic here
  }

  void navigateTo(String screen) {
    closeMenu();
    closeNotifications();
    closeSearch();
    
    switch (screen) {
      case 'home':
        Get.offAllNamed(AppRoutes.home);
        break;
      case 'localCommunity':
        Get.offAllNamed(AppRoutes.localCommunity);
        break;
      case 'messages':
        Get.offAllNamed(AppRoutes.messages);
        break;
      case 'notifications':
        Get.toNamed(AppRoutes.notifications);
        break;
      case 'profile':
        Get.offAllNamed(AppRoutes.profile);
        break;
      case 'settings':
        Get.toNamed(AppRoutes.settings);
        break;
    }
  }
}

