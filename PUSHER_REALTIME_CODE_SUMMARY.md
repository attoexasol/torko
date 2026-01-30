# Pusher & Real-Time Messaging – Code Summary

Focused summary of the current Pusher and real-time chat implementation in Torko.

---

## 1. Overview

| Item | Value |
|------|--------|
| **Package** | `pusher_channels_flutter` ^2.2.1 |
| **Key** | `9df09725d514e737df9a` |
| **Cluster** | `ap2` |
| **Channel** | `private-chat.{userId}` |
| **Event** | `message.sent` |
| **Auth** | `POST /api/broadcasting/auth` (`socket_id`, `channel_name`; token via `postAuth`) |

**Flow:** Single Pusher singleton → one subscription per user → `incomingMessages` stream → ChatController & InboxController listen. Stream-only updates (no API in handlers). Init at app start + after login; disconnect on logout; reconnect on app resume.

---

## 2. PusherService (`lib/services/pusher_service.dart`)

### 2.1 Singleton & State

```dart
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  PusherChannel? _channel;
  String? _currentChannelName;           // for unsubscribe

  StreamController<MessageModel> _controller =
      StreamController<MessageModel>.broadcast();

  bool _initialized = false;
  bool _connected = false;
  int? _currentUserId;
  bool _initializing = false;            // re-entrancy
  bool _disconnecting = false;           // re-entrancy
```

### 2.2 Public API

| Member | Purpose |
|--------|---------|
| `stream` / `incomingMessages` / `messagesStream` | Same `Stream<MessageModel>`. Never closed on disconnect. |
| `isConnected` | `_connected` (true when CONNECTED and subscribed). |
| `currentUserId` | `_currentUserId` or null. |
| `init({required int userId})` | Connect, subscribe `private-chat.{userId}`, reset on user change. |
| `disconnect()` | Unsubscribe, disconnect socket, clear state. Safe no-op when already disconnected. |
| `dispose()` | Close stream + disconnect. Only for full teardown; logout uses `disconnect()` only. |

### 2.3 `init(userId)` Logic

- If `_initializing` → return.
- If `_connected && _currentUserId == userId` → return.
- Set `_initializing = true`.
- If `_connected || _initialized` → `await disconnect()` then continue.
- `_currentUserId = userId`, `_pusher = PusherChannelsFlutter.getInstance()`.
- `_pusher!.init(...)` with:
  - `onAuthorizer`: `_onAuthorizer` → `POST` `Urls.pusher_auth` with `socket_id`, `channel_name`; expect `{ auth }`.
  - `onConnectionStateChange`: set `_connected` from CONNECTED / DISCONNECTED|FAILED; on CONNECTED call `_subscribe(userId)`.
  - `onEvent`: if `eventName == 'message.sent'` → `_handleEvent(event)`.
- `_pusher!.connect()`, short delay, set `_initialized = true`.
- On error: reset state, `rethrow`. `finally`: `_initializing = false`.

### 2.4 `_subscribe(userId)`

```dart
_currentChannelName = 'private-chat.$userId';
_channel = await _pusher!.subscribe(channelName: _currentChannelName!);
// on error: _currentChannelName = null, rethrow
```

### 2.5 `_onAuthorizer`

- Reads `UserInfo.apiToken`. If missing → throw.
- `NetworkCaller.postAuth` → `Urls.pusher_auth`, body `{ socket_id, channel_name }`.
- Expects `body['auth']` string. Returns `{ 'auth': auth }`.

### 2.6 `_handleEvent(PusherEvent event)`

1. Parse `event.data` → `Map<String, dynamic> raw` (support String or Map).
2. **Unwrap payload:**  
   - If `raw['data']` is Map → `payload = raw['data']`.  
   - Else if `raw['message']` is Map → `payload = raw['message']`.  
   - Else `payload = raw`.
3. Require `payload['id']` and `payload['from_user_id']`; otherwise log and return.
4. `message = MessageModel.fromJson(payload)`, then `_controller.add(message)`.
5. On parse error: log error, `event.data`, and stack (debug only).

### 2.7 `disconnect()` Logic

- If `_disconnecting` → return.
- If not initialized and no channel/pusher → return.
- Set `_disconnecting = true`.
- If `_currentChannelName != null && _pusher != null` → `unsubscribe(_currentChannelName)`, then `_channel = null`, `_currentChannelName = null`.
- If `_pusher != null` → `_pusher!.disconnect()`, then `_pusher = null`.
- Set `_initialized = false`, `_connected = false`, `_currentUserId = null`, `_currentChannelName = null`.
- `finally`: `_disconnecting = false`.

---

## 3. ChatController (`lib/controllers/chat_controller.dart`)

### 3.1 Role

- **Permanent** controller (created in InitialBindings, never deleted).
- Listens to `PusherService().incomingMessages` **once** (in constructor).
- **Stream-only:** no API calls from Pusher handlers. API only for initial load and send.

### 3.2 State

```dart
final RxList<MessageModel> messages = <MessageModel>[].obs;
final RxBool isSending = false.obs;
final RxBool isLoading = false.obs;
final RxString errorMessage = ''.obs;

int? currentUserId;
int? activeUserId;   // conversation partner
int? toUserId;
String? receiverName;
String? receiverAvatar;

final Set<int> receivedMessageIds = <int>{};
final Map<int, bool> _conversationLoaded = <int, bool>{};
StreamSubscription<MessageModel>? _pusherSubscription;
```

### 3.3 Stream Listener (constructor)

```dart
_pusherSubscription = PusherService().incomingMessages.listen(
  (message) => _handleIncomingMessage(message),
  onError: (e) => /* debugPrint */,
  cancelOnError: false,
);
```

### 3.4 `initChat(toUserId, receiverName, receiverAvatar)`

- Require `UserInfo.userId`. Return if missing.
- If `activeUserId == toUserId` and `_conversationLoaded[toUserId]` → update display fields only, return.
- `previousActiveUserId = activeUserId`; then set `activeUserId = toUserId`, etc.
- If `previousActiveUserId != null && previousActiveUserId != toUserId` → `messages.clear()`, `receivedMessageIds.clear()` (switch conversation).
- If `!_conversationLoaded[toUserId]` → `loadConversationOnce(toUserId)`, then mark loaded.

### 3.5 `_handleIncomingMessage(MessageModel message)`

- If `activeUserId == null` or `currentUserId == null` → return (Inbox handles it).
- Check conversation: `(from==active && to==current) || (from==current && to==active)`. If not → return.
- If `receivedMessageIds.contains(message.id)` → return (duplicate).
- Add `message.id` to `receivedMessageIds`.
- If message not in `messages` → `_addMessageSorted(message)`, `messages.refresh()`.
- `_notifyInboxUpdate(message)` (InboxController).

### 3.6 `sendMessage(content)`

- Validate user, token, `toUserId != currentUserId`.
- Create `MessageModel.temporary(...)`, add to `messages`, `messages.refresh()`.
- `MessageApiService.sendMessage(...)` → on success replace temp with sent, refresh, `_notifyInboxUpdate`; on failure remove temp, show error.

### 3.7 `clearChat()`

- Reset `activeUserId`, `toUserId`, receiver fields, `messages`, `receivedMessageIds`, `_conversationLoaded`, errors. **Does not** cancel stream subscription.

---

## 4. InboxController (`lib/controllers/inbox_controller.dart`)

### 4.1 Role

- **Permanent** controller. Listens to `PusherService().incomingMessages` **once** in `onInit` (`_connectPusher`).
- **Stream-only:** no API in handlers. API only for initial load, refresh, search.

### 4.2 State

```dart
final RxList<InboxThreadModel> threads = <InboxThreadModel>[].obs;
final RxBool loading = false.obs;
final RxString error = ''.obs;
// search, searchResults, etc.
StreamSubscription<MessageModel>? _pusherSubscription;
bool _loadedOnce = false;
```

### 4.3 Stream Listener (`_connectPusher` in onInit)

```dart
_pusherSubscription = PusherService().incomingMessages.listen(
  (message) => _handleIncomingMessage(message),
  onError: (e) => /* debugPrint */,
  cancelOnError: false,
);
```

### 4.4 `loadInboxOnce()`

- If `_loadedOnce` → return. Else set `_loadedOnce = true`, call `fetchInbox()`.
- Called from **MessagesView** `initState` only.

### 4.5 `_handleIncomingMessage(MessageModel message)`

- `currentUserId = UserInfo.userId`; return if null.
- `otherUserId = from == current ? to : from`.
- If thread with `otherUserId` exists: update last message, unread count, reorder (move to index 0), `threads.refresh()`.
- Else: if `sender` and `receiver` present, create new `InboxThreadModel`, `insert(0)`, `threads.refresh()`.

### 4.6 `resetLoadedFlag()`

- `_loadedOnce = false`. Used on logout so next open triggers `fetchInbox` again.

---

## 5. Lifecycle Hooks

### 5.1 App Start (`InitialBindings`)

```dart
Get.put(ChatController(), permanent: true);
Get.put(InboxController(), permanent: true);
Get.put(AppLifecycleService(), permanent: true);

void _initializePusherIfLoggedIn() {
  final token = UserInfo.apiToken;
  final userId = UserInfo.userId;
  if (token == null || token.isEmpty || userId == null) return;
  PusherService().init(userId: userId).catchError((e) => /* debugPrint */);
}
```

### 5.2 After Login (`LoginController.handleOTPComplete`)

- On verify success: update `UserInfo` (token, userId, verified).
- Then:
  ```dart
  await PusherService().disconnect();
  await PusherService().init(userId: currentUserId);
  ```
- Navigate to profile data onboarding.

### 5.3 Logout (`LogoutService.clearAllData`)

**Order:**

1. `await PusherService().disconnect()`
2. `UserInfo.eraseAll()`, clear SharedPreferences, image cache
3. Clear controller state (including Chat, Inbox)
4. Delete non-permanent controllers (Chat/Inbox **not** deleted)

### 5.4 App Resume (`AppLifecycleService`)

- `WidgetsBindingObserver` → `didChangeAppLifecycleState`.
- If `state != AppLifecycleState.resumed` → return.
- If no `UserInfo.userId` or no valid token → return.
- `PusherService().init(userId: userId).catchError(...)`.

No disconnect on pause; only reconnect on resume.

---

## 6. Message Payload & Model

### 6.1 Expected Payload (snake_case)

- **Required:** `id`, `from_user_id`, `to_user_id`, `message_content`, `is_read`, `created_at`, `updated_at`.
- **Optional:** `sender`, `receiver` (objects with `id`, `fullname`, `profile_image` / `profile_image`).

PusherService unwraps `data` or `message` when present; otherwise uses root. Validates `id` and `from_user_id` before `MessageModel.fromJson`.

### 6.2 `MessageModel.fromJson`

- Reads `id`, `from_user_id`, `to_user_id`, `message_content`, `is_read`, `created_at`, `updated_at`, `sender`, `receiver`.
- Uses `UserMiniModel.fromJson` for `sender` / `receiver`.

---

## 7. UI Wiring

### 7.1 Messages View

- `Get.find<InboxController>()`, then `loadInboxOnce()` in `initState`.
- Pull-to-refresh → `inboxController.refresh()` (fetchInbox).
- List → `Obx` on `threads`; tap → `Get.toNamed(conversation, arguments: { to_user_id, fullname, profile_image, ... })`.

### 7.2 Conversation View

- `Get.find<ChatController>()`. No Pusher init/subscribe in view.
- `didChangeDependencies` → `_initializeChat()` once: resolve `to_user_id` from args or `AppController.conversationData` → `chatController.initChat(...)`.
- `Obx` on `chatController.messages` (and loading/error). Send → `chatController.sendMessage(content)`.
- On dispose: `chatController.clearChat()` (state only). No unsubscribe.

### 7.3 Overlay

- Conversation can also open via `AppController.openConversation(data)` as overlay (`ConversationView` in `MyApp` builder stack).

---

## 8. Auth Endpoint

- **URL:** `Urls.pusher_auth` → `https://torko.attoexasolutions.com/api/broadcasting/auth`
- **Method:** POST (via `NetworkCaller.postAuth`).
- **Body:** `{ "socket_id": "...", "channel_name": "private-chat.{userId}" }`.
- **Headers:** Auth from `UserInfo.apiToken` (Bearer + body `api_token` as used by `postAuth`).
- **Response:** `{ "auth": "..." }` used by Pusher SDK.

---

## 9. File Reference

| File | Responsibility |
|------|----------------|
| `lib/services/pusher_service.dart` | Singleton Pusher, init/disconnect, channel, auth, event handling, stream. |
| `lib/controllers/chat_controller.dart` | Permanent; stream listener; initChat, loadConversationOnce, sendMessage, handleIncoming. |
| `lib/controllers/inbox_controller.dart` | Permanent; stream listener; loadInboxOnce, fetchInbox, handleIncoming. |
| `lib/core/bindings/initial_bindings.dart` | Register Chat, Inbox, AppLifecycle; Pusher init when logged in. |
| `lib/views/login/login_controller.dart` | After OTP verify: disconnect → init Pusher. |
| `lib/services/logout_service.dart` | Pusher disconnect first, then storage/controllers. |
| `lib/services/app_lifecycle_service.dart` | Resume → Pusher init when logged in. |
| `lib/models/message_model.dart` | Message model, `fromJson`, `temporary`. |
| `lib/services/urls.dart` | `pusher_auth` endpoint. |

---

## 10. Quick Checklist

- [ ] Single Pusher singleton; one `private-chat.{userId}` subscription per user.
- [ ] Init: app start (if logged in) + after login (disconnect then init). Reconnect on resume.
- [ ] Logout: `PusherService().disconnect()` before clearing storage/controllers.
- [ ] ChatController & InboxController permanent; listen to `incomingMessages` once; stream-only updates.
- [ ] Chat: `initChat` → `loadConversationOnce` per conversation; switch conversation clears messages.
- [ ] Inbox: `loadInboxOnce` from MessagesView; refresh = fetchInbox; Pusher updates threads.
- [ ] Event `message.sent`; payload unwrapped from root / `data` / `message`; `MessageModel.fromJson`.
- [ ] Auth: `POST /api/broadcasting/auth` with `socket_id`, `channel_name`, token.

For Laravel-side alignment (event, channel, payload, `ShouldBroadcastNow`) and E2E checks, see **`REALTIME_AUDIT_AND_FIX.md`**.
