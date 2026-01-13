# Torko - Project Summary

## 1. Project Overview

**Project Name:** Torko (তর্ক)

**Purpose:** A Bengali-focused social media mobile application built with Flutter, enabling users to create posts, interact through comments and likes, manage profiles, and engage in community features.

**Target Users:** Bengali-speaking users seeking a localized social media experience with features like:
- Social feed with posts, likes, and threaded comments
- User profiles and authentication
- Community and local community features
- Messaging and calling capabilities
- Notifications and settings management

**Platform Type:** Native Mobile Application (iOS & Android)

**Base URL:** `https://torko.attoexasolutions.com/api`

---

## 2. Tech Stack & Architecture

### Frontend Technologies
- **Framework:** Flutter (Dart SDK ^3.10.3)
- **State Management:** GetX 4.6.6
  - Reactive state management with `RxList`, `RxBool`, `RxMap`, `RxSet`
  - Navigation and routing via GetX
- **Local Storage:**
  - GetStorage 2.1.1 (key-value storage for user data, tokens, settings)
  - SharedPreferences 2.2.2 (language and theme preferences)
- **UI/UX:**
  - Material Design with custom theming
  - Google Fonts 6.1.0 (Noto Sans Bengali support)
  - Flutter Animate 4.5.0 (animations)
  - Cached Network Image 3.3.1 (image caching)
- **Image Handling:**
  - Image Picker 1.0.7 (camera/gallery access)

### Backend Integration
- **API Communication:** Custom `NetworkCaller` service
  - HTTP GET/POST requests with JSON payloads
  - Bearer token authentication
  - Timeout handling (10 seconds)
  - Request/response logging (debug mode)
- **API Endpoint Base:** `https://torko.attoexasolutions.com/api`
- **Authentication:** Token-based (API token stored locally)

### Architecture Pattern
- **MVC-like with GetX:**
  - **Views:** UI screens (Flutter widgets)
  - **Controllers:** Business logic and state management (GetX controllers)
  - **Models:** Data structures (PostModel, CommentModel)
  - **Services:** API calls, authentication, user info management

### Database/Local Storage
- **No local database** - data is fetched from API and cached in memory
- **GetStorage:** Persistent key-value storage for:
  - Authentication tokens
  - User profile data
  - Privacy settings
  - Notification preferences
- **SharedPreferences:** Theme and language preferences

### Third-Party Services
- Google Fonts API (runtime font fetching)
- Custom REST API backend (attoexasolutions.com)

---

## 3. Codebase Structure

```
lib/
├── main.dart                          # App entry point, routing setup
├── controllers/                       # Feature-specific controllers
│   ├── comment_controller.dart       # Comment CRUD, threading logic
│   ├── post_controller.dart          # Post management
│   ├── bottom_nav_controller.dart    # Bottom navigation state
│   ├── navigation_controller.dart    # Navigation tracking
│   ├── home_header_controller.dart   # Home header state
│   ├── splash_controller.dart        # Splash screen logic
│   └── post_with_comments_controller.dart
├── core/                             # Core application infrastructure
│   ├── bindings/
│   │   └── initial_bindings.dart    # Dependency injection setup
│   ├── controllers/
│   │   ├── app_controller.dart      # Global app state (theme, language, notifications)
│   │   └── dashboard_controller.dart
│   ├── routes/
│   │   ├── app_routes.dart          # Route constants
│   │   └── app_pages.dart
│   ├── theme/
│   │   ├── app_theme.dart           # Light/dark theme definitions
│   │   ├── app_colors.dart          # Color palette
│   │   └── app_sizes.dart
│   └── translations/
│       └── app_translations.dart    # Bengali/English translations
├── models/                           # Data models
│   ├── post_model.dart              # Post structure
│   └── comment_model.dart           # Comment structure with nested replies
├── services/                         # Business logic services
│   ├── network_caller.dart          # HTTP request wrapper
│   ├── urls.dart                    # API endpoint definitions
│   ├── auth_service.dart            # Authentication checks
│   ├── user_info.dart               # User data storage/retrieval
│   └── logout_service.dart
├── views/                            # UI screens (View-Controller pattern)
│   ├── splash/                      # Splash screen
│   ├── onboarding/                  # App introduction
│   ├── login/                       # Phone OTP authentication
│   ├── profile_data_onboarding/     # User profile setup
│   ├── location_onboarding/         # Location selection
│   ├── home/                        # Main feed (HomeController + HomeView)
│   ├── create_post/                 # Post creation
│   ├── post_detail/                 # Post details with comments
│   ├── profile/                     # User profile
│   ├── notifications/               # Notifications list
│   ├── messages/                    # Messages list
│   ├── conversation/                # Chat overlay
│   ├── calling/                     # Call overlay
│   ├── settings/                    # Settings menu
│   ├── account_settings/            # Account configuration
│   ├── privacy_settings/            # Privacy controls
│   └── notification_settings/       # Notification preferences
└── widgets/                          # Reusable UI components
    ├── comment_widget.dart          # Threaded comment UI
    ├── post_card.dart               # Post display card
    ├── like_button_widget.dart      # Like button with animation
    ├── home_header.dart             # Home screen header
    └── bottom_nav.dart              # Bottom navigation bar
```

### Key Modules

**State Management (GetX):**
- Controllers extend `GetxController` with reactive variables (`RxList`, `RxBool`, etc.)
- Views use `Obx()` or `GetBuilder()` for reactive updates
- Dependency injection via `Get.put()`, `Get.find()`, `Get.isRegistered()`

**Services Layer:**
- `NetworkCaller`: Centralized HTTP client with error handling
- `UserInfo`: Static class managing user data persistence (GetStorage)
- `AuthService`: Singleton for authentication state checks

**Models:**
- `PostModel`: Post data with images, counts, user info
- `CommentModel`: Recursive comment structure supporting nested replies

---

## 4. Core Functionality

### Authentication & Authorization
**Flow:**
1. **Splash Screen** → Checks authentication status
2. **Onboarding** → First-time user introduction
3. **Login** → Phone number input → OTP verification
4. **Profile Setup** → Profile data collection (name, bio, gender, etc.)
5. **Location Setup** → Location selection (optional)
6. **Home** → Main application

**API Endpoints:**
- `create_users` - Send OTP (phone number)
- `verify_otp` - Verify OTP code
- Token stored in GetStorage for subsequent requests

**Authorization:**
- Bearer token in Authorization header OR `api_token` in POST body
- Token retrieved from `UserInfo.apiToken`
- Token validated on app startup

### Posts (Feed System)
**Features:**
- View all posts in feed (`get_all_post` API)
- Create new post with images (`create_post`)
- Edit/delete own posts (`update_post`, `delete_post`)
- Like/unlike posts (`like_create`)
- View post details with full-screen overlay
- Real-time like count updates (optimistic UI)

**Controllers:**
- `HomeController`: Manages post feed, likes, filtering
- `PostController`: Post creation/editing
- `CommentController`: Comment management

**Data Flow:**
1. `HomeController.loadAllPosts()` → API call
2. Parse `PostModel` from JSON
3. Store in `RxList<PostModel> posts`
4. UI updates reactively via `Obx()`

### Comments (Threaded System)
**Features:**
- View comments on posts (`get_all_comment`)
- Create top-level comments (`create_comment`)
- Reply to comments (nested replies via `reply_id`)
- Edit/delete own comments
- Threaded UI (Facebook-style with vertical lines)
- Real-time comment count updates

**Structure:**
- Flat API response with `reply_id` linking
- Frontend builds nested tree structure
- Comments can be nested multiple levels (parent → child → grandchild)

**Controllers:**
- `CommentController`: Comment CRUD, tree building, counting

### User Profile
**Features:**
- View/edit profile (`update_users` API)
- Profile image upload (`profile_image_update`)
- Cover image upload (`cover_image_update`)
- Profile data stored locally (GetStorage)

### Settings & Preferences
**Privacy Settings:**
- Post visibility
- Active status visibility
- Like/comment visibility
- Message permissions
- Read receipts
- Typing indicators
- Tag permissions
- Stored in GetStorage, synced via `update_privacy_settings` API

**Notification Settings:**
- Push notifications
- Do-not-disturb mode
- Silent hours
- Per-type notifications (likes, comments, messages, etc.)
- Stored in GetStorage, synced via `update_notifications` API

**App Settings:**
- Theme toggle (light/dark)
- Language toggle (Bengali/English)
- Stored in SharedPreferences

### Messaging & Calls (UI Ready)
- Conversation overlay system (full-screen overlay)
- Calling overlay system
- Routes defined but implementation appears placeholder

### Community Features (UI Ready)
- Community view
- Local community view
- Stage room view
- Routes defined but implementation appears placeholder

---

## 5. Application Workflow

### User Journey
1. **App Launch:**
   - `SplashController` checks authentication
   - If logged in → Home
   - If not → Onboarding/Login

2. **Authentication:**
   - User enters phone number
   - OTP sent via `create_users` API
   - User enters OTP
   - `verify_otp` API validates and returns token
   - Token stored in GetStorage
   - User redirected to profile setup

3. **Profile Setup:**
   - User fills profile data
   - Location selection (optional)
   - Data saved via `update_users` API
   - Redirected to Home

4. **Home Feed:**
   - `HomeController` loads posts via `get_all_post`
   - Posts displayed in scrollable list
   - User can like, comment, share
   - Bottom navigation for other screens

5. **Post Interaction:**
   - Tap post → Opens `PostDetailView` overlay
   - View comments, add comments
   - Like/unlike with real-time updates
   - Optimistic UI updates with API sync

6. **Settings:**
   - User accesses Settings from profile
   - Modify privacy/notification preferences
   - Changes saved to GetStorage and API

### Backend Request Flow
1. **Request Preparation:**
   - Get token from `UserInfo.apiToken`
   - Build request body/headers
   - Add Authorization header (Bearer token) or `api_token` in body

2. **Network Call:**
   - `NetworkCaller.getRequest()` or `postRequest()`
   - 10-second timeout
   - Error handling and logging

3. **Response Processing:**
   - Parse JSON response
   - Extract `status` and `data` fields
   - Update reactive state (RxList, RxBool, etc.)
   - Trigger UI updates via GetX reactivity

4. **Error Handling:**
   - Network errors → Show error message
   - API errors → Extract error message from response
   - Timeout → Show timeout message

### Data Lifecycle
1. **Creation:**
   - User action triggers controller method
   - API call with data
   - On success: Update local state + refresh from API
   - Optimistic UI updates in some cases (likes, deletes)

2. **Update:**
   - Edit action triggers API call
   - On success: Reload data from API
   - Update reactive state

3. **Deletion:**
   - Delete action triggers API call
   - Optimistic removal from UI
   - On API success: Refresh data
   - On API failure: Rollback UI change

4. **Caching:**
   - User data cached in GetStorage
   - Post/comment data cached in memory (RxList)
   - Images cached via `cached_network_image`

---

## 6. Integrations

### External APIs
**Base URL:** `https://torko.attoexasolutions.com/api`

**Authentication:**
- `create_users` (POST) - Send OTP
- `verify_otp` (POST) - Verify OTP

**User Management:**
- `update_users` (POST) - Update profile
- `delete_users` (POST) - Delete account
- `profile_image_update` (POST) - Upload profile image
- `cover_image_update` (POST) - Upload cover image

**Posts:**
- `get_all_post` (GET/POST) - Fetch all posts
- `single_post` (POST) - Get single post
- `create_post` (POST) - Create post
- `update_post` (POST) - Update post
- `delete_post` (POST) - Delete post
- `user/posts` (POST) - Get user's posts

**Comments:**
- `get_all_comment` (GET/POST) - Get comments for post
- `single_comment` (POST) - Get single comment
- `create_comment` (POST) - Create comment
- `update_comment` (POST) - Update comment
- `delete_comment` (POST) - Delete comment

**Interactions:**
- `like_create` (POST) - Like/unlike post

**Settings:**
- `update_notifications` (POST) - Update notification settings
- `update_privacy_settings` (POST) - Update privacy settings

**Request Format:**
- JSON body with `api_token` field (POST)
- OR Bearer token in Authorization header (GET/POST)
- Response format: `{status: bool, data: {...}, message: "..."}`

### Security Considerations
- **Token Storage:** API tokens stored in GetStorage (encrypted on iOS, standard on Android)
- **Token Transmission:** Bearer token in headers or `api_token` in body
- **No HTTPS Enforcement:** API uses HTTPS but no certificate pinning
- **Input Validation:** Basic validation on client side (required fields, empty checks)
- **Error Handling:** Errors logged but not exposed to users in detail
- **Network Security:** Android manifest allows cleartext traffic (`usesCleartextTraffic="true"`)

### Data Sync
- **Real-time Updates:** Optimistic UI updates with API sync
- **Pull-to-Refresh:** Available on feed and comments
- **No WebSockets:** Polling-based (refresh on user action)
- **Offline Support:** Limited - cached data available but no offline queue

---

## 7. Strengths & Risks

### Strengths
1. **Clean Architecture:**
   - Separation of concerns (Views, Controllers, Services, Models)
   - Reusable widgets and services
   - GetX provides good state management

2. **User Experience:**
   - Bengali language support
   - Dark/light theme
   - Smooth animations
   - Optimistic UI updates for likes/comments

3. **Code Organization:**
   - Well-structured folder hierarchy
   - Consistent naming conventions
   - Modular design

4. **Localization:**
   - Multi-language support (Bengali/English)
   - Translation system in place

### Risks & Technical Debt

1. **API Response Handling:**
   - **Issue:** Comment tree building logic removed - relies on API's pre-populated `replies` array
   - **Risk:** Grandchild comments may not display correctly if API only returns direct children
   - **Impact:** Comment count mismatch between UI and database

2. **Error Handling:**
   - Inconsistent error handling across controllers
   - Network errors may not provide user-friendly messages
   - No retry logic for failed requests

3. **Performance:**
   - No pagination for posts/comments (loads all at once)
   - Image caching helps but large lists may cause memory issues
   - No lazy loading for images

4. **Security:**
   - Cleartext traffic allowed in Android manifest
   - No certificate pinning
   - Token stored in plain GetStorage (standard but not encrypted)
   - No token refresh mechanism

5. **State Management:**
   - Multiple controllers managing similar state (e.g., post counts)
   - Potential state synchronization issues
   - No centralized state management for cross-feature data

6. **Testing:**
   - No unit tests found
   - No integration tests
   - Only basic widget test template exists

7. **Code Quality:**
   - Some debug print statements left in production code
   - Comment tree building logic was removed (recent change)
   - Some unused or placeholder features (messaging, calling, community)

8. **Data Consistency:**
   - Comment counts calculated differently in different places
   - No single source of truth for post/comment counts
   - Potential race conditions with optimistic updates

---

## 8. Improvement Suggestions

### Architecture & Code Quality
1. **Restore Comment Tree Building:**
   - Re-implement `_buildCommentTree()` method to properly construct nested comment trees from flat API responses
   - Ensure all nested levels (grandchildren, etc.) are displayed
   - Fix comment count calculation to match database

2. **Centralized State Management:**
   - Create a centralized store for post/comment counts
   - Avoid duplicate state across controllers
   - Use GetX's dependency injection more effectively

3. **Error Handling:**
   - Implement consistent error handling strategy
   - Add user-friendly error messages
   - Implement retry logic for network failures
   - Add error boundary widgets

4. **Testing:**
   - Add unit tests for controllers
   - Add widget tests for critical UI components
   - Add integration tests for key user flows

### Performance
1. **Pagination:**
   - Implement pagination for posts feed
   - Implement pagination for comments
   - Add infinite scroll or "Load More" buttons

2. **Image Optimization:**
   - Implement image compression before upload
   - Add image lazy loading
   - Consider using WebP format

3. **Caching Strategy:**
   - Implement intelligent caching for posts/comments
   - Cache API responses with expiration
   - Clear cache on logout

### Security
1. **Network Security:**
   - Remove `usesCleartextTraffic="true"` from Android manifest
   - Implement certificate pinning for API calls
   - Use HTTPS only

2. **Authentication:**
   - Implement token refresh mechanism
   - Add token expiration handling
   - Secure token storage (consider using Flutter Secure Storage)

3. **Input Validation:**
   - Add server-side validation (if not already present)
   - Sanitize user inputs
   - Prevent XSS attacks in comments

### Features
1. **Real-time Updates:**
   - Implement WebSocket connection for real-time updates
   - Push notifications for likes, comments, messages
   - Real-time typing indicators

2. **Offline Support:**
   - Implement offline queue for actions
   - Cache posts/comments for offline viewing
   - Sync pending actions when online

3. **Messaging & Calls:**
   - Complete implementation of messaging feature
   - Integrate real calling functionality
   - Add file sharing in messages

4. **Community Features:**
   - Complete community feature implementation
   - Add group creation and management
   - Implement stage room functionality

### User Experience
1. **Loading States:**
   - Add skeleton loaders for posts/comments
   - Improve loading indicators
   - Add pull-to-refresh everywhere applicable

2. **Accessibility:**
   - Add screen reader support
   - Improve color contrast
   - Add accessibility labels

3. **Internationalization:**
   - Complete translation coverage
   - Add date/time formatting based on locale
   - Support RTL languages if needed

---

## 9. Final Summary

### What is Torko?
**Torko** is a Bengali-focused social media mobile application built with Flutter that enables users to create and share posts, interact through comments and likes, manage profiles, and engage with community features. The app targets Bengali-speaking users and provides a localized experience with Bengali language support, cultural customization, and social networking capabilities.

### How It Works
- **Authentication:** Users sign up/login using phone number and OTP verification
- **Feed System:** Users view a feed of posts from all users, can like, comment, and share
- **Post Creation:** Users create posts with text and multiple images
- **Comments:** Threaded comment system supporting nested replies (parent → child → grandchild)
- **Profile Management:** Users customize profiles, upload images, and manage privacy settings
- **Settings:** Users configure privacy, notifications, theme, and language preferences
- **Real-time Updates:** Optimistic UI updates for likes/comments with API synchronization

### Key Features
- ✅ Phone-based authentication with OTP
- ✅ Social feed with posts, likes, and comments
- ✅ Threaded comments with nested replies
- ✅ User profiles with image uploads
- ✅ Privacy and notification settings
- ✅ Dark/light theme support
- ✅ Bengali/English language support
- ✅ Real-time like/comment count updates
- 🚧 Messaging (UI ready, not fully implemented)
- 🚧 Calling (UI ready, not fully implemented)
- 🚧 Community features (UI ready, not fully implemented)

### Technology Stack
- **Frontend:** Flutter (Dart)
- **State Management:** GetX
- **Backend:** REST API (PHP/Laravel likely, based on API structure)
- **Storage:** GetStorage (key-value), SharedPreferences
- **Networking:** HTTP with custom NetworkCaller service

### Current Status
The application is functional for core features (authentication, posts, comments, profiles, settings) but has some technical debt:
- Comment tree building logic needs restoration for proper nested comment display
- Some features (messaging, calling, community) are UI-ready but not fully implemented
- Performance optimizations (pagination, caching) needed for scale
- Security improvements recommended (certificate pinning, token refresh)

### Business Value
Torko provides a localized social media platform for Bengali-speaking users, offering familiar social networking features with cultural and linguistic customization. The app enables community building, content sharing, and user engagement in the Bengali language with a modern, responsive mobile experience.
