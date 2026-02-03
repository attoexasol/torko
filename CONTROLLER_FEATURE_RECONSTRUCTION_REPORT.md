# CONTROLLER_FEATURE_RECONSTRUCTION_REPORT

**Project:** Torko (Flutter/GetX)  
**Date:** February 2, 2025  
**Task:** Move controllers from lib/core/controllers/ into respective presentation feature folders per PDF architecture

---

## 1. Final lib/ Folder Tree (ASCII)

```
lib/
├── main.dart
│
├── app/
│   ├── bindings/initial_bindings.dart
│   ├── routes/app_routes.dart, app_pages.dart
│   └── theme/app_colors.dart, app_sizes.dart, app_theme.dart
│
├── core/
│   ├── constants/realtime_config.dart, urls.dart
│   ├── controllers/
│   │   └── app_controller.dart          ← GLOBAL ONLY (kept)
│   ├── localization/app_translations.dart
│   ├── services/ (13 services)
│   ├── utils/gender_mapper.dart, time_formatter.dart
│   └── widgets/ (bottom_nav, comment_widget, home_header, etc.)
│
├── data/models/ (auth, comment_model, post_model, etc.)
├── helpers/.gitkeep
│
└── presentation/
    ├── main/
    │   └── controllers/
    │       ├── bottom_nav_controller.dart
    │       ├── dashboard_controller.dart
    │       └── navigation_controller.dart
    │
    ├── splash/controllers/, views/
    ├── auth/controllers/, views/
    ├── home/
    │   ├── controllers/
    │   │   ├── home_controller.dart
    │   │   ├── home_header_controller.dart
    │   │   └── post_controller.dart
    │   └── views/home_view.dart
    │
    ├── conversation/
    │   ├── controllers/chat_controller.dart
    │   └── views/
    │
    ├── messages/
    │   ├── controllers/inbox_controller.dart
    │   └── views/
    │
    ├── post_detail/
    │   ├── controllers/
    │   │   ├── comment_controller.dart
    │   │   └── post_with_comments_controller.dart
    │   └── views/
    │
    ├── profile/
    │   ├── controllers/
    │   │   ├── profile_controller.dart
    │   │   └── profile_timeline_controller.dart
    │   └── views/
    │
    ├── saved_posts/
    │   └── controllers/saved_posts_controller.dart
    │
    ├── friends/
    │   ├── controllers/friends_controller.dart
    │   └── views/
    │
    ├── local_community/
    │   ├── controllers/local_community_controller.dart
    │   └── views/
    │
    ├── community/
    │   ├── controllers/
    │   │   ├── community_controller.dart
    │   │   ├── community_groups_controller.dart
    │   │   ├── group_detail_controller.dart
    │   │   ├── group_members_controller.dart
    │   │   └── group_posts_controller.dart
    │   ├── bindings/, routes/, views/
    │   └── _legacy_duplicates/
    │
    └── (other features: account_settings, create_post, edit_post, explore,
        location_onboarding, notification_settings, notifications,
        onboarding, privacy_settings, profile_data_onboarding,
        settings, stage_room, calling)
```

---

## 2. Controller Move Table (OLD → NEW)

| OLD PATH | NEW PATH |
|----------|----------|
| lib/core/controllers/app_controller.dart | **KEPT** lib/core/controllers/app_controller.dart (global) |
| lib/core/controllers/navigation_controller.dart | lib/presentation/main/controllers/navigation_controller.dart |
| lib/core/controllers/bottom_nav_controller.dart | lib/presentation/main/controllers/bottom_nav_controller.dart |
| lib/core/controllers/dashboard_controller.dart | lib/presentation/main/controllers/dashboard_controller.dart |
| lib/core/controllers/home_header_controller.dart | lib/presentation/home/controllers/home_header_controller.dart |
| lib/core/controllers/post_controller.dart | lib/presentation/home/controllers/post_controller.dart |
| lib/core/controllers/chat_controller.dart | lib/presentation/conversation/controllers/chat_controller.dart |
| lib/core/controllers/inbox_controller.dart | lib/presentation/messages/controllers/inbox_controller.dart |
| lib/core/controllers/comment_controller.dart | lib/presentation/post_detail/controllers/comment_controller.dart |
| lib/core/controllers/post_with_comments_controller.dart | lib/presentation/post_detail/controllers/post_with_comments_controller.dart |
| lib/core/controllers/profile_timeline_controller.dart | lib/presentation/profile/controllers/profile_timeline_controller.dart |
| lib/core/controllers/saved_posts_controller.dart | lib/presentation/saved_posts/controllers/saved_posts_controller.dart |
| lib/core/controllers/friends_controller.dart | lib/presentation/friends/controllers/friends_controller.dart |
| lib/core/controllers/local_community_controller.dart | lib/presentation/local_community/controllers/local_community_controller.dart |
| lib/core/controllers/community_groups_controller.dart | lib/presentation/community/controllers/community_groups_controller.dart |
| lib/core/controllers/group_detail_controller.dart | lib/presentation/community/controllers/group_detail_controller.dart |
| lib/core/controllers/group_members_controller.dart | lib/presentation/community/controllers/group_members_controller.dart |
| lib/core/controllers/group_posts_controller.dart | lib/presentation/community/controllers/group_posts_controller.dart |

---

## 3. Files Updated for Imports (Grouped by Folder)

### app/
- initial_bindings.dart (bottom_nav, chat, home_header, inbox, navigation)

### lib/
- main.dart (dashboard_controller, community_groups_controller)

### core/widgets/
- bottom_nav.dart (navigation_controller)
- home_header.dart (navigation_controller)
- post_card.dart (post_controller, saved_posts_controller)
- comment_widget.dart (comment_controller)
- community/groups_tab_view.dart (community_groups_controller)
- group/group_members_sheet.dart (group_members_controller)

### core/services/
- logout_service.dart (chat, comment, community_groups, inbox, post, saved_posts)

### presentation/main/controllers/
- navigation_controller.dart (inbox_controller path)

### presentation/home/controllers/
- home_controller.dart (navigation, saved_posts)

### presentation/conversation/controllers/
- chat_controller.dart (inbox_controller path)

### presentation/saved_posts/controllers/
- saved_posts_controller.dart (post_controller, profile_timeline_controller paths)

### presentation/messages/views/
- messages_view.dart (navigation, inbox)

### presentation/conversation/views/
- conversation_view.dart (chat_controller)

### presentation/community/
- bindings/community_binding.dart (community_groups_controller)
- views/community_view.dart (community_groups, navigation)
- views/create_group_view.dart (community_groups_controller)
- views/group_detail_screen.dart (community_groups, group_detail)
- views/groups/dialogs/group_edit_sheet.dart (community_groups, group_detail)
- views/groups/posts/create_group_post_screen.dart (group_detail, group_posts)
- views/groups/posts/edit_group_post_sheet.dart (group_detail)
- controllers/community_groups_controller.dart (group_detail path)
- controllers/group_posts_controller.dart (group_detail path)

### presentation/explore/views/
- explore_view.dart (navigation)

### presentation/local_community/views/
- local_community_view.dart (community_groups, local_community, navigation)

### presentation/post_detail/views/
- post_detail_view.dart (comment_controller)

### presentation/profile/views/
- profile_view.dart (post, profile_timeline, saved_posts, friends)

### presentation/account_settings/controllers/
- account_settings_controller.dart (post_controller)

### presentation/create_post/views/
- create_post_view.dart (post_controller)

### presentation/edit_post/views/
- edit_post_view.dart (post_controller)

### presentation/auth/controllers/
- login_controller.dart (chat, inbox)

### presentation/friends/views/
- friends_screen.dart (friends_controller)

---

## 4. Binding/Route Reference Updates

| File | Change |
|------|--------|
| lib/app/bindings/initial_bindings.dart | Updated imports: bottom_nav_controller, chat_controller, home_header_controller, inbox_controller, navigation_controller |
| lib/main.dart | Updated imports: dashboard_controller, community_groups_controller; GetPage groupDetail binding unchanged |
| lib/presentation/community/bindings/community_binding.dart | Updated import: community_groups_controller |

---

## 5. Verification Results

| Command | Result |
|---------|--------|
| flutter pub get | Pass |
| flutter analyze | Pass (no blocking errors) |
| flutter build apk --debug | Pass – `√ Built build\app\outputs\flutter-apk\app-debug.apk` |

---

*Report generated upon completion of controller feature reconstruction.*
