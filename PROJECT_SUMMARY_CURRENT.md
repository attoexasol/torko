# Torko – Full Project Summary & Current Implementation

**Last updated:** January 2025  

---

## 1. Project Overview

**Torko** (তর্ক) is a Bengali-focused social Flutter app (iOS & Android) that provides:

- **Feed:** Posts, likes, comments, share, save, hide (real API).
- **Messaging:** Inbox + 1:1 chat with **Pusher** real-time delivery.
- **Community:** Groups (API) and Stages (mock); local community tabs.
- **Profile, settings:** Privacy, notifications, theme (light/dark), language (Bengali/English).
- **Auth:** Phone OTP (create_users → verify_otp), token-based API access.

**Backend:** REST API at `https://torko.attoexasolutions.com/api`.  
**Realtime:** Laravel Broadcasting + Pusher; Flutter uses `pusher_channels_flutter`.

---

## 2. Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter (Dart ^3.10.3) |
| **State / routing** | GetX 4.6.6 |
| **Local storage** | GetStorage, SharedPreferences |
| **HTTP** | `http` via `NetworkCaller` |
| **Realtime** | Pusher (`pusher_channels_flutter` ^2.2.1) |
| **Images** | `cached_network_image`, `image_picker` |
| **Fonts** | Google Fonts (Noto Sans Bengali), `flutter_animate` |

---

## 3. Architecture

- **Pattern:** MVC-style with GetX (Views, Controllers, Services, Models).
- **Global state:** `AppController` (theme, language, overlays, notification count).  
- **Navigation:** `NavigationController` as source of truth; bottom nav → Home, Local Community, Create Post, Messages, Profile.
- **Overlays:** Conversation, Calling, Post Detail rendered as full-screen overlays via `AppController` state in `MyApp` builder (`Stack` over `child`).

---

## 4. Directory Structure

```
lib/
├── main.dart
├── core/
│   ├── bindings/     → InitialBindings (Pusher init, permanent controllers)
│   ├── controllers/  → AppController, DashboardController
│   ├── routes/       → AppRoutes, AppPages
│   ├── theme/        → AppColors, AppSizes, AppTheme
│   └── translations/ → AppTranslations (bn/en)
├── controllers/      → BottomNav, HomeHeader, Navigation, Chat, Inbox, Post, Comment, etc.
├── models/           → Post, Message, InboxThread, Comment, UserMini, CommunityGroup, etc.
├── services/
│   ├── network_caller.dart  → GET/POST, postAuth (Bearer + api_token)
│   ├── user_info.dart       → GetStorage-backed user/settings
│   ├── pusher_service.dart  → Singleton Pusher, private-chat.{userId}, message.sent
│   ├── logout_service.dart  → Pusher disconnect → storage → caches → controller reset
│   ├── app_lifecycle_service.dart → Resume → Pusher reconnect
│   ├── urls.dart            → API base + endpoints
│   ├── message_api_service.dart
│   ├── post_api_service.dart
│   ├── community_group_api_service.dart
│   └── auth_service.dart
├── views/            → Splash, Login, Home, Messages, Conversation, Community, Profile, Settings, etc.
├── widgets/          → BottomNav, HomeHeader, PostCard, CommentWidget, CommunityTabs, etc.
└── utils/            → GenderMapper, TimeFormatter
```

---

## 5. Authentication & Session

| Step | Action |
|------|--------|
| 1 | **Splash** (`SplashController`): ~1.75s delay → `AuthService.isLoggedIn()` |
| 2 | Not logged in → `Get.offAllNamed(Login)`. Logged in → `Get.offAllNamed(Home)`. |
| 3 | **Login:** Phone → `create_users` (OTP sent) → OTP → `verify_otp` (token + user id). |
| 4 | After verify: `UserInfo` updated (token, userId, verified). **Pusher:** `disconnect()` then `init(userId)`. Navigate to `ProfileDataOnboarding`. |
| 5 | Optional: Profile data, location onboarding. Then Home. |
| 6 | **Storage:** Token, user profile, privacy/notification prefs in GetStorage; theme/language in SharedPreferences. |

**Logout:** `LogoutService.clearAllData()` (used from header/settings). Order: **Pusher disconnect** → UserInfo/SharedPrefs erase → image cache clear → controller state clear → delete non-permanent controllers. Chat/Inbox controllers are **permanent**; only their state is cleared.

---

## 6. Core Features & Current Implementation

### 6.1 Feed & Posts

- **APIs:** `get_all_post`, `single_post`, `create_post`, `update_post`, `delete_post`, `like_create`, save/unsave, share.
- **State:** `HomeController` – `RxList<PostModel>`, filters (forYou / following / trending), like/comment counts. Single load (no pagination). Pull-to-refresh.
- **UI:** `HomeView` with `PostCard`; overlay `PostDetailView` for single post. Optimistic like/share with rollback on failure.

### 6.2 Comments

- **APIs:** `get_all_comment`, `create_comment`, `update_comment`, `delete_comment`, `single_comment`.
- **State:** `CommentController`; counts also in `HomeController.postCommentCounts`. All comments loaded per post (no pagination).

### 6.3 Messaging & Realtime

| Component | Implementation |
|-----------|----------------|
| **Pusher** | Singleton `PusherService`. Key `9df09725d514e737df9a`, cluster `ap2`. |
| **Channel** | `private-chat.{userId}`. Auth via `POST /api/broadcasting/auth` (socket_id, channel_name). |
| **Event** | `message.sent`. Payload unwrapped from root / `data` / `message`; `MessageModel.fromJson`. |
| **Init** | Once at app start if token+userId exist (`InitialBindings`). Again after login (`LoginController.handleOTPComplete`). Previous connection `disconnect()` before `init(newUserId)`. |
| **Lifecycle** | `AppLifecycleService` (WidgetsBindingObserver): on **resume** → `PusherService().init(userId)` if logged in. No disconnect on pause. |
| **Logout** | `LogoutService` calls `PusherService().disconnect()` first (unsubscribe + disconnect + reset state). |

**Permanent controllers:** `ChatController`, `InboxController` (created in `InitialBindings`), never deleted. Each subscribes to `PusherService().incomingMessages` **once** (constructor / onInit). **Stream-only updates:** no API calls from Pusher handlers; API only for initial load and send.

- **Inbox:** `MessageApiService.fetchInboxRows` → `InboxController.fetchInbox`. `loadInboxOnce()` from `MessagesView.initState`; refresh pull-to-refresh. Pusher updates threads (reorder, unread, new thread when sender/receiver present).
- **Chat:** `ChatController.initChat(toUserId, ...)` when opening a conversation. `loadConversationOnce` per conversation; duplicate loads avoided via `_conversationLoaded`. Pusher adds messages for active conversation only; notifies Inbox. Switching conversations clears messages when `previousActiveUserId != toUserId`.
- **Conversation UI:** `ConversationView` uses `Get.find<ChatController>()`, `Obx` on `messages`. Clear chat on dispose; no Pusher subscribe/unsubscribe in view.

**APIs:** Inbox `messages`, conversation `single/message`, send `messages/send`, search `search/message`.

### 6.4 Community & Local Community

- **Groups:** `CommunityGroupApiService` – fetch all, fetch one, create. `LocalCommunityController` loads groups; `GroupsTabView` displays. Create group flow exists.
- **Stages:** Data hardcoded in `LocalCommunityView`. “Create stage” / “Join stage” are placeholders (snackbars). No Stages API.
- **Group detail:** Cover, bio, member count, Post/About tabs. “Join” only snackbar (no join API). Share/message “Coming soon.”

### 6.5 Dashboard vs Home

- **Dashboard:** `DashboardController` + `DashboardView`. Own **mock** posts; bottom nav “Dashboard” exists but Dashboard route is separate from main feed.
- **Home:** `HomeController` + `HomeView`. **Real** API feed. Main nav uses Home.
- **Note:** Two feed-like UIs (Dashboard mock, Home real); Dashboard not the default feed.

### 6.6 Profile, Settings, Notifications

- **Profile:** `ProfileController` + `ProfileView`. Update via `update_users`, profile/cover image APIs. Own posts, liked/saved.
- **Settings:** Account, privacy, notification settings. Persist via UserInfo / SharedPreferences and API where applicable.
- **Notifications:** `NotificationsView`; backend `update_notifications` etc. Message badge: `AppController.messageNotificationCount` (reset on entering Messages); **not** derived from real unread counts (e.g. Inbox).

### 6.7 Overlays

- **Conversation:** `AppController.openConversation(data)` → overlay `ConversationView`. Can also open via `Get.toNamed(conversation)` with args.
- **Call:** `AppController.startCall(data)` → `CallingView` overlay. End closes overlay.
- **Post detail:** `AppController.openPostDetail(data)` → `PostDetailView` overlay.

---

## 7. Key Services

| Service | Role |
|--------|------|
| **NetworkCaller** | GET/POST; `postAuth` adds Bearer + api_token from `UserInfo`. Timeout, logging. |
| **UserInfo** | GetStorage: token, userId, profile, privacy/notification prefs. `saveUserProfile`, `clear` / `eraseAll`. |
| **PusherService** | Singleton. `init(userId)`, `disconnect()`, `incomingMessages` stream. Channel `private-chat.{userId}`, event `message.sent`, auth endpoint above. Re-entrancy flags, channel tracking. |
| **LogoutService** | `clearAllData()`: Pusher disconnect → UserInfo/SharedPrefs erase → image cache → controller state clear → delete non-permanent controllers. |
| **AppLifecycleService** | `WidgetsBindingObserver`. On resume, if logged in, `PusherService().init(userId)`. |
| **MessageApiService** | Inbox, conversation, send, search. `MessageApiException` on failure. |
| **Urls** | Base `https://torko.attoexasolutions.com/api`; all API and `broadcasting/auth` paths. |

---

## 8. Key Controllers

| Controller | Lifetime | Purpose |
|------------|----------|---------|
| **AppController** | Permanent | Theme, language, overlays (conversation, call, post detail), message badge, hide bottom nav. |
| **NavigationController** | Permanent | Current screen, bottom nav index, `navigateTo` / `navigateByIndex`. Resets message notifications on Messages. |
| **ChatController** | Permanent | Messages, `initChat`, `loadConversationOnce`, `sendMessage`. Listens to `incomingMessages`; stream-only updates. |
| **InboxController** | Permanent | Threads, `loadInboxOnce`, `fetchInbox`, search. Listens to `incomingMessages`; stream-only updates. |
| **HomeController** | Lazy, deleted on logout | Feed, filters, like/comment counts. |
| **PostController** | Lazy | Create/edit post form, submit. |
| **CommentController** | Lazy, deleted on logout | Comments for a post. |
| **LocalCommunityController** | Per LocalCommunity | Groups, stages tab, create group. |
| **DashboardController** | Lazy | Dashboard mock feed, quick actions. |

---

## 9. Routes

| Route | View | Notes |
|-------|------|-------|
| `/` (initial) | `SplashView` | Then Login or Home |
| `/onboarding` | `OnboardingView` | |
| `/login` | `LoginView` | Phone → OTP → verify |
| `/profileData` | `ProfileDataOnboardingView` | Post-login |
| `/locationData` | `LocationOnboardingView` | Optional |
| `/home` | `HomeView` | Main feed |
| `/dashboard` | `DashboardView` | Mock feed |
| `/createPost` | `CreatePostView` | |
| `/notifications` | `NotificationsView` | |
| `/profile` | `ProfileView` | |
| `/explore` | `ExploreView` | |
| `/messages` | `MessagesView` | Inbox; `loadInboxOnce` |
| `/conversation` | `ConversationView` | Chat with user (args or overlay) |
| `/community` | `CommunityView` | |
| `/localCommunity` | `LocalCommunityView` | Groups + Stages tabs |
| `/stageRoom` | `StageRoomView` | |
| `/settings` | `SettingsView` | |
| `/accountSettings`, `/privacySettings`, `/notificationSettings` | Respective views | |
| `/calling` | `CallingView` | Overlay |
| `/postDetail` | `PostDetailView` | Overlay |
| `/groupDetail` | `GroupDetailScreen` | |
| `/createGroup` | `CreateGroupView` | |

---

## 10. Realtime Implementation Summary

- **Single Pusher singleton**, one `private-chat.{userId}` subscription per user. No per-screen init.
- **Init:** App start (InitialBindings) when token+userId exist; after login (disconnect then init). Reconnect on app resume (AppLifecycleService).
- **Teardown:** `LogoutService` calls `PusherService().disconnect()` before clearing storage and controllers.
- **Event:** `message.sent` only. Payload: root or `data`/`message` unwrapped; must have `id` and `from_user_id`; then `MessageModel.fromJson`. Parse errors logged (debug) with raw payload and stack.
- **Chat:** `ChatController` consumes stream; updates `messages` for active conversation only; notifies Inbox. Switch-conversation clear when changing partner.
- **Inbox:** `InboxController` consumes stream; updates thread list, unread, reorder; creates new thread when sender/receiver in payload.
- **UI:** Obx on controller state; no reload for new messages. Conversation disposes clear chat state only; no unsubscribe in view.

See `REALTIME_AUDIT_AND_FIX.md` for Laravel Event, `broadcastAs`/`broadcastOn`/payload, and verification checklist.

---

## 11. Known Limitations

| Area | Limitation |
|------|------------|
| **Message badge** | `messageNotificationCount` is not driven by real unread data (e.g. Inbox unread). Reset on entering Messages only. |
| **Pagination** | Posts, comments, inbox: single load. No pagination/infinite scroll. |
| **Stages** | Fully mock. No create/join API or real live state. |
| **Group join** | “Join” in group detail is placeholder (snackbar). No join/leave API. |
| **Dashboard vs Home** | Two feeds (Dashboard mock, Home real). Dashboard not default; some redundancy. |
| **Calling** | UI overlay only; no real VoIP implementation. |

---

## 12. File Reference (Key Files)

| Purpose | Files |
|---------|-------|
| **Entry** | `main.dart`, `InitialBindings` |
| **App state** | `AppController`, `NavigationController` |
| **Realtime** | `PusherService`, `AppLifecycleService`, `ChatController`, `InboxController` |
| **Auth / logout** | `LoginController`, `AuthService`, `LogoutService`, `UserInfo` |
| **Feed** | `HomeController`, `HomeView`, `PostController`, `PostApiService` |
| **Messaging** | `MessageApiService`, `ConversationView`, `MessagesView` |
| **Community** | `LocalCommunityController`, `LocalCommunityView`, `CommunityGroupApiService` |
| **API / config** | `NetworkCaller`, `Urls` |
| **Realtime audit** | `REALTIME_AUDIT_AND_FIX.md` |
| **Limitations** | `PROJECT_ANALYSIS_AND_LIMITATIONS.md` |

---

This document reflects the **current** implementation. For realtime fixes, Laravel alignment, and verification steps, use `REALTIME_AUDIT_AND_FIX.md`.
