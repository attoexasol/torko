import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../core/controllers/app_controller.dart';
import '../core/routes/app_routes.dart';
import 'inbox_controller.dart';

/// Centralized navigation controller - single source of truth for navigation state
class NavigationController extends GetxController {
  static NavigationController get to => Get.find<NavigationController>();
  
  /// Current active screen - reactive
  final RxString currentScreen = 'home'.obs;
  
  /// Selected tab index for bottom nav (0-4)
  final RxInt selectedIndex = 0.obs;
  
  AppController get appController => Get.find<AppController>();
  
  /// Screen to index mapping
  static const Map<String, int> screenToIndex = {
    'home': 0,
    'localCommunity': 1,
    'explore': 1,
    'createPost': 2,
    'messages': 3,
    'profile': 4,
  };
  
  /// Index to screen mapping
  static const Map<int, String> indexToScreen = {
    0: 'home',
    1: 'localCommunity',
    2: 'createPost',
    3: 'messages',
    4: 'profile',
  };
  
  /// Route to screen mapping
  static const Map<String, String> routeToScreen = {
    '/home': 'home',
    '/localCommunity': 'localCommunity',
    '/explore': 'localCommunity',
    '/messages': 'messages',
    '/profile': 'profile',
    '/createPost': 'createPost',
  };
  
  /// Getters for active state checks
  bool get isHome => currentScreen.value == 'home';
  bool get isLocalCommunity => 
      currentScreen.value == 'localCommunity' || currentScreen.value == 'explore';
  bool get isMessages => currentScreen.value == 'messages';
  bool get isProfile => currentScreen.value == 'profile';
  
  int get messageNotificationCount => appController.messageNotificationCount;
  
  @override
  void onInit() {
    super.onInit();
    // Sync with current route on initialization
    _syncWithCurrentRoute();
    
    // Listen to route changes
    ever(currentScreen, (_) {
      _updateSelectedIndex();
    });
  }
  
  /// Sync navigation state with current route
  void _syncWithCurrentRoute() {
    final route = Get.currentRoute;
    final screen = routeToScreen[route];
    if (screen != null) {
      currentScreen.value = screen;
      _updateSelectedIndex();
    }
  }
  
  /// Update selected index based on current screen
  void _updateSelectedIndex() {
    final index = screenToIndex[currentScreen.value];
    if (index != null && index != 2) { // Don't update for createPost
      selectedIndex.value = index;
    }
  }
  
  /// Set current screen and update index
  void setCurrentScreen(String screen) {
    currentScreen.value = screen;
  }
  
  /// Navigate by index (for bottom nav taps)
  void navigateByIndex(int index) {
    if (index == 2) {
      // Create post - don't change selected index, just navigate
      Get.toNamed(AppRoutes.createPost);
      return;
    }
    
    final screen = indexToScreen[index];
    if (screen != null) {
      navigateTo(screen);
    }
  }
  
  /// Navigate to a screen
  void navigateTo(String screen) {
    // Get current route
    final currentRoute = Get.currentRoute;
    final targetRoute = _screenToRoute(screen);
    
    // Update state first
    currentScreen.value = screen;
    
    // Handle messages notification reset
    if (screen == 'messages') {
      appController.resetMessageNotifications();
      
      // Refresh inbox when messages screen is selected
      if (Get.isRegistered<InboxController>()) {
        final inboxController = Get.find<InboxController>();
        if (kDebugMode) {
          print('🔄 [NavigationController] Refreshing inbox on messages screen select');
        }
        inboxController.fetchInbox();
      }
    }
    
    // If already on the same route, just refresh state (don't navigate again)
    if (currentRoute == targetRoute) {
      // Force update the UI by toggling the screen
      update();
      return;
    }
    
    // Navigate to the target route
    switch (screen) {
      case 'home':
        Get.offAllNamed(AppRoutes.home);
        break;
      case 'localCommunity':
        Get.offAllNamed(AppRoutes.localCommunity);
        break;
      case 'createPost':
        Get.toNamed(AppRoutes.createPost);
        break;
      case 'messages':
        Get.offAllNamed(AppRoutes.messages);
        break;
      case 'profile':
        Get.offAllNamed(AppRoutes.profile);
        break;
      case 'notifications':
        Get.toNamed(AppRoutes.notifications);
        break;
      case 'settings':
        Get.toNamed(AppRoutes.settings);
        break;
    }
  }
  
  /// Navigate from drawer - handles same route case
  void navigateFromDrawer(String screen) {
    // Update state
    currentScreen.value = screen;
    
    // Handle messages notification reset
    if (screen == 'messages') {
      appController.resetMessageNotifications();
    }
    
    // Always navigate (drawer will be closed by the caller)
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
      case 'profile':
        Get.offAllNamed(AppRoutes.profile);
        break;
      case 'notifications':
        Get.toNamed(AppRoutes.notifications);
        break;
      case 'settings':
        Get.toNamed(AppRoutes.settings);
        break;
    }
  }
  
  /// Handle messages tap (with notification reset)
  void handleMessagesTap() {
    appController.resetMessageNotifications();
    
    // Refresh inbox when messages tab is tapped
    if (Get.isRegistered<InboxController>()) {
      final inboxController = Get.find<InboxController>();
      if (kDebugMode) {
        print('🔄 [NavigationController] Refreshing inbox on messages tap');
      }
      inboxController.fetchInbox();
    }
    
    navigateTo('messages');
  }
  
  /// Convert screen name to route
  String _screenToRoute(String screen) {
    switch (screen) {
      case 'home':
        return AppRoutes.home;
      case 'localCommunity':
        return AppRoutes.localCommunity;
      case 'createPost':
        return AppRoutes.createPost;
      case 'messages':
        return AppRoutes.messages;
      case 'profile':
        return AppRoutes.profile;
      case 'notifications':
        return AppRoutes.notifications;
      case 'settings':
        return AppRoutes.settings;
      default:
        return AppRoutes.home;
    }
  }
  
  /// Called when navigating back - sync state
  void onRouteChanged(String? route) {
    if (route != null) {
      final screen = routeToScreen[route];
      if (screen != null) {
        currentScreen.value = screen;
      }
    }
  }
}

