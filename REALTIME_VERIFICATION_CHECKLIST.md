# Realtime Messaging Verification Checklist

## What Was Wrong and Why the Fix Works

### 1. Channel naming mismatch
- **Wrong:** Flutter subscribed to `private-chat.{userId}`. Laravel uses `PrivateChannel('user.{userId}')` → Pusher channel **`private-user.{userId}`**.
- **Fix:** Flutter now subscribes to `private-user.{userId}` via `PusherService.channelNameForUser(userId)`. Matches Laravel exactly.

### 2. Broadcasting auth body
- **Wrong:** `postAuth` sends `api_token` in body plus Bearer. Protocol requires body **only** `{ socket_id, channel_name }` and `Authorization: Bearer <token>`.
- **Fix:** `NetworkCaller.postBroadcastingAuth` POSTs with Bearer and body strictly `{ socket_id, channel_name }`. Used in `PusherService._onAuthorizer`.

### 3. Payload parsing
- **Wrong:** Always unwrapping `data` / `message` first. Protocol says **flat** JSON at root.
- **Fix:** Use root as payload; only unwrap `data` or `message` if root lacks `id` / `from_user_id`.

### 4. Resume re-subscribe storm
- **Wrong:** On every app resume we called `PusherService().init(userId)`, even when already connected.
- **Fix:** `AppLifecycleService` checks `isConnected && currentUserId == userId` and skips init; otherwise reconnects. No repeated subscribe.

### 5. Chat stream attachment
- **Wrong:** Stream listener attached in controller **constructor** (runs before `onInit`).
- **Fix:** Listener attached in `onInit` for a single, well-defined lifecycle hook.

### 6. Debugging
- **Wrong:** No single place to inspect connection state and subscribed channel.
- **Fix:** `PusherService.debugPrintConnectionState()` logs `connected`, `userId`, `channel`, flags. Called from InitialBindings (post-init), AppLifecycleService (resume), and can be invoked from UI or DevTools.

---

## Verification Checklist

### Auth success
- [ ] Log in, open app, check logs for `[PUSHER] auth request channel=...` then `[PUSHER] auth success: private-user.<userId>`.
- [ ] If you see `[PUSHER] auth failed` or `auth response status: 4xx`, fix backend `/api/broadcasting/auth` (Bearer, body `socket_id` + `channel_name`, response `{ auth }`).

### Subscription success
- [ ] After auth success, see `[PUSHER] subscribing to private-user.<userId>` then `[PUSHER] subscribe success: private-user.<userId>`.
- [ ] No `[PUSHER] subscribe error` messages.

### Event received
- [ ] User A sends to User B. On User B’s device, see `[PUSHER] event received: message.sent` then `[PUSHER] event received | id=... from=... to=...`.
- [ ] If event never arrives, confirm Laravel broadcasts to `PrivateChannel('user.<recipient_id>')` with event `message.sent` and flat payload.

### UI updates without refresh
- [ ] User B receives message: it appears in conversation immediately (no pull-to-refresh).
- [ ] Inbox thread list updates (reorder, unread) when a new message arrives.
- [ ] Sender sees own message via HTTP response (optimistic update), not via socket; no duplicate.

### Debug helper
- [ ] Call `PusherService().debugPrintConnectionState()` (e.g. from a debug button or DevTools) and confirm logs show `connected`, `userId`, `channel`, `initializing`, `disconnecting`.

### Lifecycle
- [ ] **App start:** Logged in → `[InitialBindings] Pusher init for userId=...` → init success → `debugPrintConnectionState` in logs.
- [ ] **Login:** After OTP verify, `PusherService().disconnect()` then `init(userId)`; logs as above.
- [ ] **Resume:** Background → foreground. If already connected, `[AppLifecycleService] resume: already connected, skip re-subscribe` and `debugPrintConnectionState`. If not, `resume: reconnecting Pusher for userId=...`.
- [ ] **Logout:** `LogoutService` calls `PusherService().disconnect()` first, then clears storage/controllers. No Pusher activity after logout.

---

## Quick manual test

1. Log in as User A on device 1, User B on device 2 (or two simulators).
2. A opens chat with B, sends "Hello".
3. B should see "Hello" instantly with no refresh.
4. B replies "Hi". A should see "Hi" instantly.
5. Check logs for auth success, subscribe success, event received, and UI update (e.g. `[CHAT] REALTIME message added | ...`, `[INBOX] REALTIME thread updated | ...`).

---

## Files changed

| File | Changes |
|------|--------|
| `lib/services/pusher_service.dart` | Channel `private-user.{id}`; `channelNameForUser`; auth via `postBroadcastingAuth`; flat payload parse; logs; `debugPrintConnectionState`; `currentChannelName` getter. |
| `lib/services/network_caller.dart` | `postBroadcastingAuth(url, socketId, channelName)` – Bearer + body only `socket_id`, `channel_name`. |
| `lib/controllers/chat_controller.dart` | Stream listener in `onInit` (not constructor); simplified logs. |
| `lib/controllers/inbox_controller.dart` | No logic changes; already listens in `onInit`, updates threads, refresh/ordering. |
| `lib/core/bindings/initial_bindings.dart` | Post-init `debugPrintConnectionState` on success/failure. |
| `lib/services/app_lifecycle_service.dart` | Resume: skip init if already connected; `debugPrintConnectionState` on resume. |
| `lib/services/logout_service.dart` | No code changes; already disconnects Pusher first. |
