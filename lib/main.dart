import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:torko/firebase_options.dart';
import 'package:torko/core/utils/app_logger.dart';
import 'package:torko/core/services/firestore_network_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:get/get.dart';
import 'package:torko/app/bindings/firestore_chat_binding.dart';
import 'package:torko/app/bindings/initial_bindings.dart';
import 'package:torko/app/bindings/splash_binding.dart';
import 'package:torko/app/bindings/messages_binding.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/app/theme/app_theme.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/community/controllers/community_groups_controller.dart';
import 'package:torko/presentation/main/controllers/dashboard_controller.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/presentation/auth/views/login_view.dart';
import 'package:torko/presentation/calling/views/calling_view.dart';
import 'package:torko/presentation/community/bindings/community_binding.dart';
import 'package:torko/presentation/community/routes/community_routes.dart';
import 'package:torko/presentation/community/views/community_view.dart';
import 'package:torko/presentation/community/views/create_group_view.dart';
import 'package:torko/presentation/community/views/group_detail_screen.dart';
import 'package:torko/presentation/conversation/views/conversation_view.dart';
import 'package:torko/presentation/create_post/views/create_post_view.dart';
import 'package:torko/presentation/home/views/home_view.dart';
import 'package:torko/presentation/location_onboarding/views/location_onboarding_view.dart';
import 'package:torko/presentation/messages/views/messages_view.dart';
import 'package:torko/presentation/notification_settings/views/notification_settings_view.dart';
import 'package:torko/presentation/notifications/views/notifications_view.dart';
import 'package:torko/presentation/onboarding/views/onboarding_view.dart';
import 'package:torko/presentation/post_detail/views/post_detail_view.dart';
import 'package:torko/presentation/privacy_settings/views/privacy_settings_view.dart';
import 'package:torko/presentation/profile/views/profile_view.dart';
import 'package:torko/presentation/profile_data_onboarding/views/profile_data_onboarding_view.dart';
import 'package:torko/presentation/account_settings/views/account_settings_view.dart';
import 'package:torko/presentation/explore/views/explore_view.dart';
import 'package:torko/presentation/firestore_chat/views/chat_list_screen.dart';
import 'package:torko/presentation/firestore_chat/views/chat_screen.dart';
import 'package:torko/presentation/friends/views/friends_screen.dart';
import 'package:torko/views/friends/requests/friends_requests_screen.dart';
import 'package:torko/views/friends/sent/sent_requests_screen.dart';
import 'package:torko/presentation/settings/views/settings_view.dart';
import 'package:torko/presentation/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  if (kDebugMode) AppLogger.auth('Firebase initialized');
  // Firestore: settings → enableNetwork (before controllers/streams)
  await FirestoreNetworkService.initializeOnlineOnly();
  await UserInfo.init();
  if (kDebugMode) {
    final uid = UserInfo.myUidString ?? UserInfo.firebaseUid;
    AppLogger.auth(uid != null ? 'User uid=$uid' : 'User uid=null');
  }
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Firebase.initializeApp failed: $e');
      debugPrint(st.toString());
    }
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Torko',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBindings(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
        GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
        GetPage(name: AppRoutes.login, page: () => const LoginView()),
        GetPage(name: AppRoutes.profileData, page: () => const ProfileDataOnboardingView()),
        GetPage(name: AppRoutes.locationData, page: () => const LocationOnboardingView()),
        GetPage(name: AppRoutes.home, page: () => const HomeView()),
        GetPage(name: AppRoutes.createPost, page: () => const CreatePostView()),
        GetPage(name: AppRoutes.notifications, page: () => const NotificationsView()),
        GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
        GetPage(name: AppRoutes.explore, page: () => const ExploreView()),
        GetPage(
          name: AppRoutes.messages,
          page: () => const MessagesView(),
          binding: MessagesBinding(),
        ),
        GetPage(
          name: AppRoutes.community,
          page: () => const CommunityView(),
          binding: CommunityBinding(),
        ),
        GetPage(
          name: AppRoutes.localCommunity,
          page: () => const CommunityView(),
          binding: CommunityBinding(),
        ),
        ...CommunityRoutes.pages,
        GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
        GetPage(name: AppRoutes.accountSettings, page: () => const AccountSettingsView()),
        GetPage(name: AppRoutes.privacySettings, page: () => const PrivacySettingsView()),
        GetPage(name: AppRoutes.notificationSettings, page: () => const NotificationSettingsView()),
        GetPage(
          name: AppRoutes.conversation,
          page: () => const ConversationView(),
          binding: MessagesBinding(),
        ),
        GetPage(name: AppRoutes.calling, page: () => const CallingView()),
        GetPage(name: AppRoutes.postDetail, page: () => const PostDetailView()),
        GetPage(name: AppRoutes.dashboard, page: () => const DashboardView()),
        GetPage(
          name: AppRoutes.groupDetail,
          page: () => const GroupDetailScreen(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<CommunityGroupsController>()) {
              Get.put(CommunityGroupsController(), permanent: false);
            }
          }),
        ),
        GetPage(name: AppRoutes.createGroup, page: () => const CreateGroupView()),
        GetPage(name: AppRoutes.friends, page: () => const FriendsScreen()),
        GetPage(name: AppRoutes.friendsRequests, page: () => const FriendsRequestsScreen()),
        GetPage(name: AppRoutes.friendsSent, page: () => const SentRequestsScreen()),
        GetPage(
          name: AppRoutes.chatList,
          page: () => const ChatListScreen(),
          binding: FirestoreChatListBinding(),
        ),
        GetPage(
          name: AppRoutes.chat,
          page: () => const ChatScreen(),
          binding: FirestoreChatRoomBinding(),
        ),
      ],
      builder: (context, child) {
        final appController = Get.find<AppController>();
        return Obx(() {
          return Theme(
            data: appController.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            child: Stack(
              children: [
                child!,
                // Conversation Overlay
                if (appController.conversationData != null)
                  const Positioned.fill(child: ConversationView()),
                // Call Overlay
                if (appController.callData != null)
                  const Positioned.fill(child: CallingView()),
                // Post Detail Overlay
                if (appController.postDetailData != null)
                  const Positioned.fill(child: PostDetailView()),
              ],
            ),
          );
        });
      },
    );
  }
}
