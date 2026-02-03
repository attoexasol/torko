# Torko GetX Structure Reconstruction Plan

Structure-only reconstruction to match target GetX architecture. No UI, logic, API, or behavioral changes.

---

## 1. TARGET FOLDER TREE (NEW)

```
lib/
├── main.dart
│
├── app/
│   ├── bindings/
│   │   └── initial_bindings.dart
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_sizes.dart
│       └── app_theme.dart
│
├── core/
│   ├── constants/
│   │   ├── urls.dart
│   │   └── realtime_config.dart
│   ├── controllers/
│   │   ├── app_controller.dart
│   │   ├── dashboard_controller.dart
│   │   ├── navigation_controller.dart
│   │   ├── bottom_nav_controller.dart
│   │   ├── chat_controller.dart
│   │   ├── inbox_controller.dart
│   │   ├── home_header_controller.dart
│   │   ├── community_groups_controller.dart
│   │   ├── group_detail_controller.dart
│   │   ├── group_members_controller.dart
│   │   ├── group_posts_controller.dart
│   │   ├── local_community_controller.dart
│   │   ├── comment_controller.dart
│   │   ├── post_controller.dart
│   │   ├── post_with_comments_controller.dart
│   │   ├── profile_timeline_controller.dart
│   │   ├── saved_posts_controller.dart
│   │   └── friends_controller.dart
│   ├── localization/
│   │   └── app_translations.dart
│   ├── services/
│   │   ├── network_caller.dart
│   │   ├── user_info.dart
│   │   ├── auth_service.dart
│   │   ├── app_lifecycle_service.dart
│   │   ├── logout_service.dart
│   │   ├── reverb_service.dart
│   │   ├── message_api_service.dart
│   │   ├── post_api_service.dart
│   │   ├── community_group_api_service.dart
│   │   ├── community_group_service.dart
│   │   ├── community_group_post_service.dart
│   │   ├── group_member_service.dart
│   │   └── group_post_service.dart
│   ├── utils/
│   │   ├── time_formatter.dart
│   │   └── gender_mapper.dart
│   └── widgets/
│       ├── bottom_nav.dart
│       ├── comment_widget.dart
│       ├── home_header.dart
│       ├── like_button_widget.dart
│       ├── post_card.dart
│       ├── post_with_comments.dart
│       ├── community/
│       │   ├── community_tabs.dart
│       │   ├── groups_tab_view.dart
│       │   ├── stages_tab_view.dart
│       │   └── stage_join_dialog.dart
│       └── group/
│           └── group_members_sheet.dart
│
├── data/
│   └── models/
│       ├── auth/
│       │   ├── create_user_response.dart
│       │   └── verify_otp_response.dart
│       ├── comment_model.dart
│       ├── community_group_model.dart
│       ├── conversation_item_model.dart
│       ├── group_member_model.dart
│       ├── inbox_thread_model.dart
│       ├── message_model.dart
│       ├── message_row_model.dart
│       ├── post_model.dart
│       ├── search_message_result_model.dart
│       ├── search_user_model.dart
│       ├── timeline_item.dart
│       └── user_mini_model.dart
│
├── helpers/
│   └── .gitkeep
│
└── presentation/
    ├── splash/
    │   ├── controllers/
    │   │   └── splash_controller.dart
    │   └── views/
    │       └── splash_view.dart
    │
    ├── onboarding/
    │   └── views/
    │       └── onboarding_view.dart
    │
    ├── auth/
    │   ├── controllers/
    │   │   └── login_controller.dart
    │   └── views/
    │       └── login_view.dart
    │
    ├── profile_data_onboarding/
    │   ├── controllers/
    │   │   └── profile_data_onboarding_controller.dart
    │   └── views/
    │       └── profile_data_onboarding_view.dart
    │
    ├── location_onboarding/
    │   ├── controllers/
    │   │   └── location_onboarding_controller.dart
    │   └── views/
    │       └── location_onboarding_view.dart
    │
    ├── home/
    │   ├── controllers/
    │   │   └── home_controller.dart
    │   └── views/
    │       └── home_view.dart
    │
    ├── create_post/
    │   └── views/
    │       └── create_post_view.dart
    │
    ├── edit_post/
    │   └── views/
    │       └── edit_post_view.dart
    │
    ├── notifications/
    │   ├── controllers/
    │   │   └── notifications_controller.dart
    │   └── views/
    │       └── notifications_view.dart
    │
    ├── profile/
    │   ├── controllers/
    │   │   └── profile_controller.dart
    │   └── views/
    │       └── profile_view.dart
    │
    ├── explore/
    │   └── views/
    │       └── explore_view.dart
    │
    ├── messages/
    │   └── views/
    │       └── messages_view.dart
    │
    ├── settings/
    │   └── views/
    │       └── settings_view.dart
    │
    ├── account_settings/
    │   ├── controllers/
    │   │   └── account_settings_controller.dart
    │   └── views/
    │       └── account_settings_view.dart
    │
    ├── privacy_settings/
    │   ├── controllers/
    │   │   └── privacy_settings_controller.dart
    │   └── views/
    │       └── privacy_settings_view.dart
    │
    ├── notification_settings/
    │   ├── controllers/
    │   │   └── notification_settings_controller.dart
    │   └── views/
    │       └── notification_settings_view.dart
    │
    ├── conversation/
    │   └── views/
    │       └── conversation_view.dart
    │
    ├── calling/
    │   └── views/
    │       └── calling_view.dart
    │
    ├── post_detail/
    │   └── views/
    │       └── post_detail_view.dart
    │
    ├── friends/
    │   └── views/
    │       └── friends_screen.dart
    │
    ├── community/
    │   ├── bindings/
    │   │   └── community_binding.dart
    │   ├── routes/
    │   │   └── community_routes.dart
    │   ├── controllers/
    │   │   └── community_controller.dart
    │   └── views/
    │       ├── community_view.dart
    │       ├── create_group_view.dart
    │       ├── group_detail_screen.dart
    │       ├── groups/
    │       │   ├── dialogs/
    │       │   │   ├── group_delete_dialog.dart
    │       │   │   └── group_edit_sheet.dart
    │       │   └── posts/
    │       │       ├── create_group_post_screen.dart
    │       │       ├── edit_group_post_sheet.dart
    │       │       ├── group_post_delete_dialog.dart
    │       │       ├── group_post_options_sheet.dart
    │       │       └── widgets/
    │       │           ├── group_post_text_field.dart
    │       │           └── image_picker_strip.dart
    │       └── stages/
    │           ├── end_stage_dialog.dart
    │           ├── stage_card.dart
    │           ├── stage_controller.dart
    │           ├── stage_join_dialog.dart
    │           ├── stage_list_view.dart
    │           ├── stage_models.dart
    │           ├── stage_room_view.dart
    │           ├── screens/
    │           │   ├── end_stage_confirm_dialog.dart
    │           │   ├── stage_room_view.dart
    │           │   └── start_stage_sheet.dart
    │           └── widgets/
    │               ├── category_chips.dart
    │               ├── listener_tile.dart
    │               └── speaker_tile.dart
    │
    ├── local_community/
    │   └── views/
    │       └── local_community_view.dart
    │
    └── stage_room/
        └── views/
            └── stage_room_view.dart
```

---

## 2. FILE MAPPING TABLE (OLD PATH → NEW PATH)

| OLD PATH | NEW PATH |
|----------|----------|
| `lib/main.dart` | `lib/main.dart` |
| `lib/core/bindings/initial_bindings.dart` | `lib/app/bindings/initial_bindings.dart` |
| `lib/core/routes/app_routes.dart` | `lib/app/routes/app_routes.dart` |
| `lib/core/routes/app_pages.dart` | `lib/app/routes/app_pages.dart` |
| `lib/core/theme/app_colors.dart` | `lib/app/theme/app_colors.dart` |
| `lib/core/theme/app_sizes.dart` | `lib/app/theme/app_sizes.dart` |
| `lib/core/theme/app_theme.dart` | `lib/app/theme/app_theme.dart` |
| `lib/core/controllers/app_controller.dart` | `lib/core/controllers/app_controller.dart` |
| `lib/core/controllers/dashboard_controller.dart` | `lib/core/controllers/dashboard_controller.dart` |
| `lib/core/translations/app_translations.dart` | `lib/core/localization/app_translations.dart` |
| `lib/controllers/navigation_controller.dart` | `lib/core/controllers/navigation_controller.dart` |
| `lib/controllers/bottom_nav_controller.dart` | `lib/core/controllers/bottom_nav_controller.dart` |
| `lib/controllers/chat_controller.dart` | `lib/core/controllers/chat_controller.dart` |
| `lib/controllers/inbox_controller.dart` | `lib/core/controllers/inbox_controller.dart` |
| `lib/controllers/home_header_controller.dart` | `lib/core/controllers/home_header_controller.dart` |
| `lib/controllers/community_groups_controller.dart` | `lib/core/controllers/community_groups_controller.dart` |
| `lib/controllers/group_detail_controller.dart` | `lib/core/controllers/group_detail_controller.dart` |
| `lib/controllers/group_members_controller.dart` | `lib/core/controllers/group_members_controller.dart` |
| `lib/controllers/group_posts_controller.dart` | `lib/core/controllers/group_posts_controller.dart` |
| `lib/controllers/local_community_controller.dart` | `lib/core/controllers/local_community_controller.dart` |
| `lib/controllers/comment_controller.dart` | `lib/core/controllers/comment_controller.dart` |
| `lib/controllers/post_controller.dart` | `lib/core/controllers/post_controller.dart` |
| `lib/controllers/post_with_comments_controller.dart` | `lib/core/controllers/post_with_comments_controller.dart` |
| `lib/controllers/profile_timeline_controller.dart` | `lib/core/controllers/profile_timeline_controller.dart` |
| `lib/controllers/saved_posts_controller.dart` | `lib/core/controllers/saved_posts_controller.dart` |
| `lib/controllers/friends_controller.dart` | `lib/core/controllers/friends_controller.dart` |
| `lib/controllers/splash_controller.dart` | `lib/presentation/splash/controllers/splash_controller.dart` |
| `lib/services/network_caller.dart` | `lib/core/services/network_caller.dart` |
| `lib/services/user_info.dart` | `lib/core/services/user_info.dart` |
| `lib/services/auth_service.dart` | `lib/core/services/auth_service.dart` |
| `lib/services/app_lifecycle_service.dart` | `lib/core/services/app_lifecycle_service.dart` |
| `lib/services/logout_service.dart` | `lib/core/services/logout_service.dart` |
| `lib/services/reverb_service.dart` | `lib/core/services/reverb_service.dart` |
| `lib/services/message_api_service.dart` | `lib/core/services/message_api_service.dart` |
| `lib/services/post_api_service.dart` | `lib/core/services/post_api_service.dart` |
| `lib/services/community_group_api_service.dart` | `lib/core/services/community_group_api_service.dart` |
| `lib/services/community_group_service.dart` | `lib/core/services/community_group_service.dart` |
| `lib/services/community_group_post_service.dart` | `lib/core/services/community_group_post_service.dart` |
| `lib/services/group_member_service.dart` | `lib/core/services/group_member_service.dart` |
| `lib/services/group_post_service.dart` | `lib/core/services/group_post_service.dart` |
| `lib/services/urls.dart` | `lib/core/constants/urls.dart` |
| `lib/config/realtime_config.dart` | `lib/core/constants/realtime_config.dart` |
| `lib/utils/time_formatter.dart` | `lib/core/utils/time_formatter.dart` |
| `lib/utils/gender_mapper.dart` | `lib/core/utils/gender_mapper.dart` |
| `lib/widgets/bottom_nav.dart` | `lib/core/widgets/bottom_nav.dart` |
| `lib/widgets/comment_widget.dart` | `lib/core/widgets/comment_widget.dart` |
| `lib/widgets/home_header.dart` | `lib/core/widgets/home_header.dart` |
| `lib/widgets/like_button_widget.dart` | `lib/core/widgets/like_button_widget.dart` |
| `lib/widgets/post_card.dart` | `lib/core/widgets/post_card.dart` |
| `lib/widgets/post_with_comments.dart` | `lib/core/widgets/post_with_comments.dart` |
| `lib/widgets/community/community_tabs.dart` | `lib/core/widgets/community/community_tabs.dart` |
| `lib/widgets/community/groups_tab_view.dart` | `lib/core/widgets/community/groups_tab_view.dart` |
| `lib/widgets/community/stages_tab_view.dart` | `lib/core/widgets/community/stages_tab_view.dart` |
| `lib/widgets/community/stage_join_dialog.dart` | `lib/core/widgets/community/stage_join_dialog.dart` |
| `lib/widgets/group/group_members_sheet.dart` | `lib/core/widgets/group/group_members_sheet.dart` |
| `lib/models/auth/create_user_response.dart` | `lib/data/models/auth/create_user_response.dart` |
| `lib/models/auth/verify_otp_response.dart` | `lib/data/models/auth/verify_otp_response.dart` |
| `lib/models/comment_model.dart` | `lib/data/models/comment_model.dart` |
| `lib/models/community_group_model.dart` | `lib/data/models/community_group_model.dart` |
| `lib/models/conversation_item_model.dart` | `lib/data/models/conversation_item_model.dart` |
| `lib/models/group_member_model.dart` | `lib/data/models/group_member_model.dart` |
| `lib/models/inbox_thread_model.dart` | `lib/data/models/inbox_thread_model.dart` |
| `lib/models/message_model.dart` | `lib/data/models/message_model.dart` |
| `lib/models/message_row_model.dart` | `lib/data/models/message_row_model.dart` |
| `lib/models/post_model.dart` | `lib/data/models/post_model.dart` |
| `lib/models/search_message_result_model.dart` | `lib/data/models/search_message_result_model.dart` |
| `lib/models/search_user_model.dart` | `lib/data/models/search_user_model.dart` |
| `lib/models/timeline_item.dart` | `lib/data/models/timeline_item.dart` |
| `lib/models/user_mini_model.dart` | `lib/data/models/user_mini_model.dart` |
| `lib/views/splash/splash_view.dart` | `lib/presentation/splash/views/splash_view.dart` |
| `lib/views/onboarding/onboarding_view.dart` | `lib/presentation/onboarding/views/onboarding_view.dart` |
| `lib/views/login/login_controller.dart` | `lib/presentation/auth/controllers/login_controller.dart` |
| `lib/views/login/login_view.dart` | `lib/presentation/auth/views/login_view.dart` |
| `lib/views/profile_data_onboarding/profile_data_onboarding_controller.dart` | `lib/presentation/profile_data_onboarding/controllers/profile_data_onboarding_controller.dart` |
| `lib/views/profile_data_onboarding/profile_data_onboarding_view.dart` | `lib/presentation/profile_data_onboarding/views/profile_data_onboarding_view.dart` |
| `lib/views/location_onboarding/location_onboarding_controller.dart` | `lib/presentation/location_onboarding/controllers/location_onboarding_controller.dart` |
| `lib/views/location_onboarding/location_onboarding_view.dart` | `lib/presentation/location_onboarding/views/location_onboarding_view.dart` |
| `lib/views/home/home_controller.dart` | `lib/presentation/home/controllers/home_controller.dart` |
| `lib/views/home/home_view.dart` | `lib/presentation/home/views/home_view.dart` |
| `lib/views/create_post/create_post_view.dart` | `lib/presentation/create_post/views/create_post_view.dart` |
| `lib/views/edit_post/edit_post_view.dart` | `lib/presentation/edit_post/views/edit_post_view.dart` |
| `lib/views/notifications/notifications_controller.dart` | `lib/presentation/notifications/controllers/notifications_controller.dart` |
| `lib/views/notifications/notifications_view.dart` | `lib/presentation/notifications/views/notifications_view.dart` |
| `lib/views/profile/profile_controller.dart` | `lib/presentation/profile/controllers/profile_controller.dart` |
| `lib/views/profile/profile_view.dart` | `lib/presentation/profile/views/profile_view.dart` |
| `lib/views/explore/explore_view.dart` | `lib/presentation/explore/views/explore_view.dart` |
| `lib/views/messages/messages_view.dart` | `lib/presentation/messages/views/messages_view.dart` |
| `lib/views/settings/settings_view.dart` | `lib/presentation/settings/views/settings_view.dart` |
| `lib/views/account_settings/account_settings_controller.dart` | `lib/presentation/account_settings/controllers/account_settings_controller.dart` |
| `lib/views/account_settings/account_settings_view.dart` | `lib/presentation/account_settings/views/account_settings_view.dart` |
| `lib/views/privacy_settings/privacy_settings_controller.dart` | `lib/presentation/privacy_settings/controllers/privacy_settings_controller.dart` |
| `lib/views/privacy_settings/privacy_settings_view.dart` | `lib/presentation/privacy_settings/views/privacy_settings_view.dart` |
| `lib/views/notification_settings/notification_settings_controller.dart` | `lib/presentation/notification_settings/controllers/notification_settings_controller.dart` |
| `lib/views/notification_settings/notification_settings_view.dart` | `lib/presentation/notification_settings/views/notification_settings_view.dart` |
| `lib/views/conversation/conversation_view.dart` | `lib/presentation/conversation/views/conversation_view.dart` |
| `lib/views/calling/calling_view.dart` | `lib/presentation/calling/views/calling_view.dart` |
| `lib/views/post_detail/post_detail_view.dart` | `lib/presentation/post_detail/views/post_detail_view.dart` |
| `lib/views/friends/friends_screen.dart` | `lib/presentation/friends/views/friends_screen.dart` |
| `lib/views/local_community/local_community_view.dart` | `lib/presentation/local_community/views/local_community_view.dart` |
| `lib/views/stage_room/stage_room_view.dart` | `lib/presentation/stage_room/views/stage_room_view.dart` |
| `lib/modules/community/community_binding.dart` | `lib/presentation/community/bindings/community_binding.dart` |
| `lib/modules/community/community_routes.dart` | `lib/presentation/community/routes/community_routes.dart` |
| `lib/modules/community/controllers/community_controller.dart` | `lib/presentation/community/controllers/community_controller.dart` |
| `lib/modules/community/screens/community_view.dart` | `lib/presentation/community/views/community_view.dart` |
| `lib/views/community/create_group_view.dart` | `lib/presentation/community/views/create_group_view.dart` |
| `lib/views/community/group_detail_screen.dart` | `lib/presentation/community/views/group_detail_screen.dart` |
| `lib/views/community/community_view.dart` | *(duplicate - use modules version → community_view.dart)* |
| `lib/views/community/groups/dialogs/group_delete_dialog.dart` | `lib/presentation/community/views/groups/dialogs/group_delete_dialog.dart` |
| `lib/views/community/groups/dialogs/group_edit_sheet.dart` | `lib/presentation/community/views/groups/dialogs/group_edit_sheet.dart` |
| `lib/views/community/groups/posts/create_group_post_screen.dart` | `lib/presentation/community/views/groups/posts/create_group_post_screen.dart` |
| `lib/views/community/groups/posts/edit_group_post_sheet.dart` | `lib/presentation/community/views/groups/posts/edit_group_post_sheet.dart` |
| `lib/views/community/groups/posts/group_post_delete_dialog.dart` | `lib/presentation/community/views/groups/posts/group_post_delete_dialog.dart` |
| `lib/views/community/groups/posts/group_post_options_sheet.dart` | `lib/presentation/community/views/groups/posts/group_post_options_sheet.dart` |
| `lib/views/community/groups/posts/widgets/group_post_text_field.dart` | `lib/presentation/community/views/groups/posts/widgets/group_post_text_field.dart` |
| `lib/views/community/groups/posts/widgets/image_picker_strip.dart` | `lib/presentation/community/views/groups/posts/widgets/image_picker_strip.dart` |
| `lib/views/community/stages/end_stage_dialog.dart` | `lib/presentation/community/views/stages/end_stage_dialog.dart` |
| `lib/views/community/stages/stage_card.dart` | `lib/presentation/community/views/stages/stage_card.dart` |
| `lib/views/community/stages/stage_controller.dart` | `lib/presentation/community/views/stages/stage_controller.dart` |
| `lib/views/community/stages/stage_join_dialog.dart` | `lib/presentation/community/views/stages/stage_join_dialog.dart` |
| `lib/views/community/stages/stage_list_view.dart` | `lib/presentation/community/views/stages/stage_list_view.dart` |
| `lib/views/community/stages/stage_models.dart` | `lib/presentation/community/views/stages/stage_models.dart` |
| `lib/views/community/stages/stage_room_view.dart` | `lib/presentation/community/views/stages/stage_room_view.dart` |
| `lib/modules/community/stages/screens/end_stage_confirm_dialog.dart` | `lib/presentation/community/views/stages/screens/end_stage_confirm_dialog.dart` |
| `lib/modules/community/stages/screens/stage_room_view.dart` | `lib/presentation/community/views/stages/screens/stage_room_view.dart` |
| `lib/modules/community/stages/screens/start_stage_sheet.dart` | `lib/presentation/community/views/stages/screens/start_stage_sheet.dart` |
| `lib/modules/community/stages/widgets/category_chips.dart` | `lib/presentation/community/views/stages/widgets/category_chips.dart` |
| `lib/modules/community/stages/widgets/listener_tile.dart` | `lib/presentation/community/views/stages/widgets/listener_tile.dart` |
| `lib/modules/community/stages/widgets/speaker_tile.dart` | `lib/presentation/community/views/stages/widgets/speaker_tile.dart` |

---

## 3. IMPORT PATH UPDATES (BY SOURCE)

All imports must be updated to reflect new paths. Use package-relative imports (e.g. `package:torko/...`) or relative imports consistent with the project.

### 3.1 main.dart
- `core/bindings/initial_bindings.dart` → `app/bindings/initial_bindings.dart`
- `core/routes/app_routes.dart` → `app/routes/app_routes.dart`
- `core/theme/app_theme.dart` → `app/theme/app_theme.dart`
- `core/controllers/app_controller.dart` → `core/controllers/app_controller.dart`
- `services/user_info.dart` → `core/services/user_info.dart`
- `views/...` → `presentation/.../views/...`
- `modules/community/...` → `presentation/community/...`
- `controllers/community_groups_controller.dart` → `core/controllers/community_groups_controller.dart`

### 3.2 initial_bindings.dart
- `../controllers/app_controller.dart` → `../../core/controllers/app_controller.dart`
- `../../controllers/...` → `../../core/controllers/...`
- `../../services/...` → `../../core/services/...`

### 3.3 app_routes.dart
- No model/routes imports typically; verify if any.

### 3.4 app_theme.dart
- `app_colors.dart` → relative path within `app/theme/`
- `app_sizes.dart` → relative path within `app/theme/`

### 3.5 Controllers
- Replace `../models/` → `../../data/models/` (or package path)
- Replace `../services/` → `../../core/services/`
- Replace `../views/` → `../../presentation/.../views/`
- Replace `../../core/` paths as needed for app/, core/, data/

### 3.6 Services
- Replace `../models/` → `../../data/models/`
- Replace `../services/urls.dart` → `../../core/constants/urls.dart`
- Replace `config/realtime_config.dart` → `core/constants/realtime_config.dart`

### 3.7 Views
- Replace `../../controllers/` → `../../core/controllers/` or `../controllers/` (feature-local)
- Replace `../../widgets/` → `../../core/widgets/`
- Replace `../../models/` → `../../data/models/`
- Replace `../../services/` → `../../core/services/`
- Replace `../../core/` (theme, routes) → `../../app/` where applicable

### 3.8 Widgets
- Replace `../controllers/` → `../../core/controllers/`
- Replace `../core/` → `../../app/` or `../../core/` per new layout
- Replace `../models/` → `../../data/models/`
- Replace `../services/` → `../../core/services/`

### 3.9 Models
- Models typically have no internal cross-model imports; if any, update `../` to new relative paths.

### 3.10 Community module consolidation
- `modules/community/` and `views/community/` are merged into `presentation/community/`
- Resolve duplicate `community_view.dart` (views vs modules) — use single source in `presentation/community/views/community_view.dart`
- Resolve duplicate `stage_room_view.dart` (views/community/stages vs modules/community/stages/screens) — consolidate to one location
- Update all references to community views, bindings, routes

---

## 4. CONFIRMATION CHECKLIST

| Item | Status |
|------|--------|
| UI unchanged | ✅ Structure only |
| Widget layout unchanged | ✅ No layout edits |
| Business logic unchanged | ✅ No logic edits |
| API calls unchanged | ✅ No API edits |
| Controller logic unchanged | ✅ No controller body edits |
| Class names unchanged | ✅ No renames |
| Variable names unchanged | ✅ No renames |
| Method bodies unchanged | ✅ No behavior changes |
| Functionality preserved | ✅ Move + import updates only |
| GetX bindings preserved | ✅ Bindings moved, logic same |
| GetX routes preserved | ✅ Routes moved, definitions same |
| Dependency injection behavior preserved | ✅ Get.put/Get.find unchanged |
| App compiles after restructure | ⬜ To verify |
| App behaves exactly the same | ⬜ To verify |
| No runtime behavior changes | ⬜ To verify |
| No visual changes | ⬜ To verify |
| No API changes | ✅ No API code touched |

---

## 5. SPECIAL NOTES

### 5.1 Duplicate files to resolve
- **community_view.dart**: Exists in both `views/community/` and `modules/community/screens/`. Choose one as canonical; typically the module version if it has binding-specific setup.
- **stage_room_view.dart**: Exists in `views/community/stages/` and `modules/community/stages/screens/`. Consolidate to single file in `presentation/community/views/stages/` (or `stages/screens/` if sub-structure retained).

### 5.2 comment_count_store
If `lib/services/comment_count_store.dart` exists from prior work, map to `lib/core/services/comment_count_store.dart`.

### 5.3 Execution order
1. Create all new directories.
2. Move files (or copy then delete old) per mapping table.
3. Update all imports in every moved file.
4. Resolve duplicates (community_view, stage_room_view).
5. Run `flutter pub get` and `flutter analyze`.
6. Run app and verify behavior.
