# Torko – Project Analysis & Current Limitations

## 1. Project Overview

**Torko** (তর্ক) is a Bengali-focused social media Flutter app (iOS/Android) with:

- **Stack:** Flutter (Dart ^3.10.3), GetX 4.6.6, GetStorage, SharedPreferences, Pusher (real-time), CachedNetworkImage, Google Fonts (Noto Sans Bengali).
- **Backend:** REST API at `https://torko.attoexasolutions.com/api`; token-based auth.
- **Architecture:** MVC-style with GetX — Views, Controllers, Services, Models.

**Implemented areas:** Auth (phone OTP), feed (posts, likes, comments, share, save, hide), profiles, settings (privacy, notifications, theme, language), messaging (inbox + 1:1 chat with Pusher), community groups (list, create, detail), local community (Groups tab API-backed; Stages tab mock).

---

## 2. Implementation Summary

### 2.1 Authentication & Session

- **Flow:** Splash → Onboarding → Login (phone → OTP) → Profile setup → Location (optional) → Home.
- **APIs:** `create_users` (send OTP), `verify_otp` (verify, receive token).
- **Storage:** Token and user data in GetStorage; theme/language in SharedPreferences.
- **Pusher:** Initialized in `InitialBindings` when a session exists, and again after login in `LoginController`.

### 2.2 Feed & Posts

- **APIs:** `get_all_post`, `single_post`, `create_post`, `update_post`, `delete_post`, `like_create`, save/unsave, share.
- **State:** `HomeController` holds `RxList<PostModel>`, like/share/comment counts, filters (forYou / following / trending).
- **Behavior:** Single load of all posts (no pagination). Pull-to-refresh. Optimistic like/share with rollback on failure.

### 2.3 Comments

- **APIs:** `get_all_comment`, `create_comment`, `update_comment`, `delete_comment`, `single_comment`.
- **Model:** `CommentModel` with `replies`; nested structure from API.
- **State:** `CommentController`; comment counts also tracked in `HomeController.postCommentCounts`.

### 2.4 Messaging & Real-Time

- **Pusher:** Singleton `PusherService`; private channel `private-chat.{userId}`; `message.sent` events.
- **Permanent controllers:** `ChatController`, `InboxController` (created in `InitialBindings`), never deleted.
- **Rule:** No API calls from Pusher handlers; only stream-based UI updates. Initial load and send via REST.
- **APIs:** Inbox (`messages`), conversation history (`single/message`), send (`messages/send`), search (`search/message`).

### 2.5 Community & Local Community

- **Groups:** `CommunityGroupApiService` — fetch all, fetch one, create. `LocalCommunityController` loads groups once; create group flow exists.
- **Stages:** Data hardcoded in `LocalCommunityView`; “Create stage” and “Join Stage” are placeholders (snackbars).
- **Group detail:** Cover, bio, member count, Post/About tabs; “Join” shows snackbar only (no join API).

### 2.6 Navigation & Overlays

- **Navigation:** `NavigationController` as main source of truth; `BottomNavController`, `HomeHeaderController` still used.
- **Overlays (Stack in `MyApp` builder):** Post detail, conversation, calling. Shown via `AppController` state.

### 2.7 Logout & Cleanup

- **Logout:** `LogoutService.clearAllData()` used from header and settings.
- **Clears:** GetStorage, SharedPreferences (torko_*), image cache, controller state (Post, Profile, Home, SavedPosts, Comment, Chat, Inbox).
- **Deletes:** Post, Profile, Home, Comment controllers. Chat and Inbox are **not** deleted (permanent).

---

## 3. Current Limitations

### 3.1 Logout & Real-Time Lifecycle

| Limitation | Details |
|------------|--------|
| **Pusher not disconnected on logout** | `LogoutService` never calls `PusherService().disconnect()` or `dispose()`. After logout, the socket remains connected to the previous user’s private channel. On next login, `PusherService().init()` runs again, but the old connection is not explicitly torn down. |
| **Pusher not re-initialized for new user** | Init is driven by “logged-in user at app start” and “right after login.” If tokens are manipulated or restored inconsistently, Pusher may not re-init correctly for the new user. |

**Recommendation:** In `LogoutService.clearAllData()`, call `PusherService().disconnect()` (and `dispose()` if you fully tear down Pusher on logout). Ensure init runs once per logged-in user and that logout always precedes init for a new user.

---

### 3.2 Message Notification Badge

| Limitation | Details |
|------------|--------|
| **Hardcoded badge count** | `AppController._messageNotificationCount` defaults to `5` and is only reset via `resetMessageNotifications()` when entering Messages. It is **never** set from real unread data (e.g. `InboxController` threads’ `unreadCount`). |
| **Badge misleading** | Users can see a non-zero badge even with no unread messages, or no badge when there are unread messages. |

**Recommendation:** Derive badge from `InboxController` (e.g. sum of `unreadCount` across threads). Update it when threads load and when Pusher delivers new messages, and keep `resetMessageNotifications()` for “mark as read” on entering Messages.

---

### 3.3 Pagination & Scale

| Limitation | Details |
|------------|--------|
| **Posts** | `HomeController.loadAllPosts()` fetches all posts in one go. No `page` / `limit` / cursor. Large feeds will increase latency, memory, and risk of timeouts. |
| **Comments** | `CommentController.loadComments()` loads all comments for a post at once. Same scaling concerns. |
| **Inbox** | Inbox API is called once (`loadInboxOnce`); no pagination for very large thread lists. |

**Recommendation:** Add pagination (or infinite scroll) for posts and comments, and for inbox if the API supports it. Use cursor- or offset-based params per backend contract.

---

### 3.4 Community & Stages

| Limitation | Details |
|------------|--------|
| **Stages fully mock** | Stages in Local Community are hardcoded in `LocalCommunityView`. No API, no real “live” state. |
| **Create stage** | “Create stage” FAB shows “Coming soon” snackbar. |
| **Join stage** | “Join Stage” in list and `StageJoinDialog` only show snackbars (“Joined stage”); no real join logic or stage room. |
| **Group join** | Group detail “Join” button only shows a snackbar; no join/leave API or membership state. |
| **Group share / message** | Share and message actions in group detail show “Coming soon.” |

**Recommendation:** Replace stages with API-backed models and implement create/join when backend is ready. Implement group join/leave and, if desired, share/message from group detail.

---

### 3.5 Dashboard vs Home

| Limitation | Details |
|------------|--------|
| **Duplicate feed concepts** | `DashboardController` keeps its own `posts` with **mock** data. `HomeController` uses **real** API posts. Dashboard and Home are separate UIs and state. |
| **Dashboard unused in main nav** | Bottom nav uses Home, Local Community, Create, Messages, Profile. Dashboard route exists but is not the default feed; dashboard uses mock data. |
| **Redundancy** | Two feed-like experiences (one real, one mock) can confuse maintenance and users. |

**Recommendation:** Either remove Dashboard or repurpose it (e.g. dashboard = Home with real feed). Avoid maintaining two parallel feed implementations.

---

### 3.6 Conversation Lifecycle & Chat State

| Limitation | Details |
|------------|--------|
| **`clearChat()` on conversation dispose** | `ConversationView.dispose()` calls `chatController.clearChat()`. Whenever the user leaves the conversation (overlay or route), full chat state (messages, `_conversationLoaded`, etc.) is cleared. |
| **Always reload on re-open** | Re-opening the same thread forces a fresh API load. Acceptable for correctness but incurs extra requests and loses local scroll position. |
| **Permanent controller, transient state** | `ChatController` is permanent, but per-conversation state is cleared on exit. Design is consistent but prioritizes “clean slate” over “resume where user left off.” |

**Recommendation:** If you want to preserve state when moving in/out of conversations, avoid clearing chat on dispose; clear only on logout or when explicitly “starting new chat.” Otherwise, document that chat state is intentionally transient on exit.

---

### 3.7 Error Handling & Resilience

| Limitation | Details |
|------------|--------|
| **Inconsistent error handling** | Controllers handle API/network errors differently. Some use `Get.snackbar`, others set `errorMessage` / `error` in controller only. |
| **No retry** | Failed requests (e.g. feed, comments, inbox) have no retry logic. User must pull-to-refresh or re-open. |
| **Timeout** | `NetworkCaller` uses a 10s timeout; no distinction between retryable vs non-retryable failures. |
| **Debug prints** | Various `print`/`debugPrint` calls remain (e.g. comment, message, Pusher). |

**Recommendation:** Standardize error handling (e.g. central “show error” helper), add retry for idempotent calls, and reduce or gate debug logging for release builds.

---

### 3.8 Security & Configuration

| Limitation | Details |
|------------|--------|
| **Pusher key in code** | `PusherService` has API key and cluster hardcoded. Prefer env/config or remote config. |
| **Token storage** | Token in GetStorage (no explicit encryption). Acceptable for many apps but worth reviewing against your security policy. |
| **Cleartext traffic** | PROJECT_SUMMARY notes `usesCleartextTraffic="true"` on Android. Prefer disabling for production. |
| **Token refresh** | No token refresh flow; expiry handling not evident. |

**Recommendation:** Move Pusher config out of code; restrict cleartext; consider token refresh and secure storage if required.

---

### 3.9 Data Consistency & State

| Limitation | Details |
|------------|--------|
| **Comment counts** | Both `CommentController` and `HomeController` deal with comment counts; `HomeController` tracks `postCommentCounts` for the feed. Risk of duplication or drift if not kept in sync. |
| **Like state** | `HomeController` uses `likedPosts`, `postLikeCounts`, and `PostModel.isLiked`. Logic is careful but multiple sources of truth. |
| **New conversation from Pusher** | When a **new** thread arrives via Pusher, `InboxController` can create a thread only if `message.sender` and `message.receiver` are present. Otherwise, that conversation may not appear until next inbox fetch. |

**Recommendation:** Prefer a single source of truth for counts (e.g. feed delegates to a dedicated store or API). Ensure Pusher payloads always include sender/receiver for new threads, or trigger an inbox refresh when receiving a message for an unknown thread.

---

### 3.10 Calling & Placeholders

| Limitation | Details |
|------------|--------|
| **Calling UI only** | `CallingView` exists as overlay; `startCall` / `endCall` are wired in `AppController`. No real VoIP or signalling. |
| **Conversation actions** | Phone/video/more actions in conversation are commented out; no call launch from chat. |

**Recommendation:** Either implement real calling or clearly treat it as “coming later” in UX (e.g. disable or hide call actions).

---

### 3.11 Testing & Maintainability

| Limitation | Details |
|------------|--------|
| **No automated tests** | No unit or integration tests; only default `widget_test.dart`. |
| **`app_pages.dart` empty** | `AppPages` is not used; routes are defined inline in `main.dart`. |
| **Documentation** | Many `*_REALTIME_*.md` and similar docs; some overlap. |

**Recommendation:** Add unit tests for controllers and services, and integration tests for critical flows (login, feed, chat). Optionally use `AppPages` for routing. Consolidate or archive redundant docs.

---

### 3.12 UX / Accessibility (from UX_REVIEW)

- No screen reader support or semantic labels.
- Some touch targets smaller than recommended.
- Inconsistent loading/empty states.
- Overlay system (post detail, conversation, calling) can be confusing.

These remain valid limitations; see `UX_REVIEW.md` for full detail.

---

## 4. Summary Table

| Area | Status | Main limitations |
|------|--------|------------------|
| **Auth & session** | ✅ Implemented | Token refresh, cleartext traffic |
| **Feed & posts** | ✅ Implemented | No pagination, single bulk load |
| **Comments** | ✅ Implemented | No pagination, count sync |
| **Messaging** | ✅ Implemented | Badge not from unread, new-thread edge cases |
| **Real-time (Pusher)** | ✅ Implemented | Not disconnected on logout, config in code |
| **Community groups** | ⚠️ Partial | Join/share/message placeholders |
| **Stages** | ❌ Mock | No API, no create/join |
| **Dashboard** | ⚠️ Mock | Separate from Home, mock data |
| **Calling** | ❌ UI only | No real calls |
| **Logout cleanup** | ⚠️ Partial | Pusher not disconnected |
| **Pagination** | ❌ Missing | Posts, comments, inbox |
| **Tests** | ❌ Missing | No coverage |

---

## 5. Suggested Priorities

1. **High:** Logout disconnects/disposes Pusher; message badge driven by real unread counts.
2. **High:** Pagination (or infinite scroll) for posts and comments.
3. **Medium:** Retry and consistent error handling; reduce debug prints.
4. **Medium:** Group join API and UI; align or remove Dashboard vs Home.
5. **Lower:** Stages API and create/join when backend exists; calling implementation or explicit “coming soon”; tests and routing cleanup.

This document reflects the codebase and project layout as of the analysis. Re-running a quick audit after major changes is recommended.
