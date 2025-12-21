import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/dashboard_controller.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/controllers/app_controller.dart';
import 'services/user_info.dart';
import 'views/splash/splash_view.dart';
import 'views/onboarding/onboarding_view.dart';
import 'views/login/login_view.dart';
import 'views/profile_data_onboarding/profile_data_onboarding_view.dart';
import 'views/location_onboarding/location_onboarding_view.dart';
import 'views/create_post/create_post_view.dart';
import 'views/notifications/notifications_view.dart';
import 'views/profile/profile_view.dart';
import 'views/explore/explore_view.dart';
import 'views/messages/messages_view.dart';
import 'views/community/community_view.dart';
import 'views/local_community/local_community_view.dart';
import 'views/stage_room/stage_room_view.dart';
import 'views/settings/settings_view.dart';
import 'views/account_settings/account_settings_view.dart';
import 'views/privacy_settings/privacy_settings_view.dart';
import 'views/notification_settings/notification_settings_view.dart';
import 'views/conversation/conversation_view.dart';
import 'views/calling/calling_view.dart';
import 'views/post_detail/post_detail_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserInfo.init();
  runApp(const MyApp());
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
        GetPage(name: AppRoutes.splash, page: () => const SplashView()),
        GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
        GetPage(name: AppRoutes.login, page: () => const LoginView()),
        GetPage(name: AppRoutes.profileData, page: () => const ProfileDataOnboardingView()),
        GetPage(name: AppRoutes.locationData, page: () => const LocationOnboardingView()),
        GetPage(name: AppRoutes.createPost, page: () => const CreatePostView()),
        GetPage(name: AppRoutes.notifications, page: () => const NotificationsView()),
        GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
        GetPage(name: AppRoutes.explore, page: () => const ExploreView()),
        GetPage(name: AppRoutes.messages, page: () => const MessagesView()),
        GetPage(name: AppRoutes.community, page: () => const CommunityView()),
        GetPage(name: AppRoutes.localCommunity, page: () => const LocalCommunityView()),
        GetPage(name: AppRoutes.stageRoom, page: () => const StageRoomView()),
        GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
        GetPage(name: AppRoutes.accountSettings, page: () => const AccountSettingsView()),
        GetPage(name: AppRoutes.privacySettings, page: () => const PrivacySettingsView()),
        GetPage(name: AppRoutes.notificationSettings, page: () => const NotificationSettingsView()),
        GetPage(name: AppRoutes.conversation, page: () => const ConversationView()),
        GetPage(name: AppRoutes.calling, page: () => const CallingView()),
        GetPage(name: AppRoutes.postDetail, page: () => const PostDetailView()),
        GetPage(name: AppRoutes.dashboard, page: () => const DashboardView()),
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
