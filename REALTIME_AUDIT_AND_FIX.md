# Realtime Chat Audit & Fix – Laravel + Flutter (Pusher)

## 1. What Was Wrong

### Laravel (Backend)
- **Queue blocking realtime:** Using `ShouldBroadcast` queues the event. Workers must run, and delays add latency. Use `ShouldBroadcastNow` so the event is broadcast immediately in the same request.
- **Channel mismatch:** Flutter subscribes to **private** `private-chat.{userId}` and uses `/api/broadcasting/auth`. Laravel must broadcast on **private** channel `private-chat.{recipientId}` (via `PrivateChannel('chat.{id}')`). Using public `Channel('user.{id}')` or wrong prefix breaks private auth and subscription.
- **Event name:** Client listens for `message.sent`. Laravel must use `broadcastAs('message.sent')`; otherwise the class name is used and the app ignores events.
- **Payload shape:** Flutter expects a JSON object with `id`, `from_user_id`, `to_user_id`, `message_content`, `is_read`, `created_at`, `updated_at` (and optionally `sender` / `receiver`). Wrong keys or wrapping (e.g. only `data`) can break parsing without clear logs.
- **Broadcast target:** Event must be sent to the **recipient’s** channel (`to_user_id`), not the sender’s. Each user subscribes to `private-chat.{ownUserId}`; they receive messages when someone sends **to** them.

### Flutter (Frontend)
- **Payload parsing:** Laravel may send root `{ id, from_user_id, ... }` or `{ data: { ... } }` / `{ message: { ... } }`. The app only parsed the root. We now unwrap `data` / `message` when present and validate `id` / `from_user_id` before parsing.
- **Parse errors:** On `MessageModel.fromJson` failure we didn’t log the raw payload. We now log parse error, `event.data`, and stack trace in debug.
- **Switch conversation:** When changing conversation, we didn’t clear messages because we compared `activeUserId != toUserId` **after** updating `activeUserId`. We now store `previousActiveUserId` and clear only when switching to a different user.
- **Logging:** Replaced `print` with `debugPrint` and `kDebugMode` in Pusher, Chat, Inbox, and Conversation.

---

## 2. Corrected Laravel Event Class

**File:** `app/Events/MessageSent.php`

```php
<?php

namespace App\Events;

use App\Models\Message;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Message $message;

    public function __construct(Message $message)
    {
        $this->message = $message;
    }

    /**
     * Broadcast on recipient's PRIVATE channel.
     * Flutter subscribes to private-chat.{userId}; Laravel PrivateChannel('chat.X') → private-chat.X
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('chat.' . $this->message->to_user_id),
        ];
    }

    /**
     * Event name. Must match Flutter: "message.sent"
     */
    public function broadcastAs(): string
    {
        return 'message.sent';
    }

    /**
     * Payload keys must match Flutter MessageModel.fromJson (snake_case).
     * Optional: 'sender', 'receiver' for new-thread creation in inbox.
     */
    public function broadcastWith(): array
    {
        $payload = [
            'id' => $this->message->id,
            'from_user_id' => $this->message->from_user_id,
            'to_user_id' => $this->message->to_user_id,
            'message_content' => $this->message->message_content,
            'is_read' => (int) ($this->message->is_read ?? 0),
            'created_at' => $this->message->created_at->toIso8601String(),
            'updated_at' => $this->message->updated_at->toIso8601String(),
        ];

        if ($this->message->relationLoaded('sender') && $this->message->sender) {
            $payload['sender'] = [
                'id' => $this->message->sender->id,
                'fullname' => $this->message->sender->fullname ?? $this->message->sender->name ?? '',
                'profile_image' => $this->message->sender->profile_image ?? $this->message->sender->profileImage ?? null,
            ];
        }
        if ($this->message->relationLoaded('receiver') && $this->message->receiver) {
            $payload['receiver'] = [
                'id' => $this->message->receiver->id,
                'fullname' => $this->message->receiver->fullname ?? $this->message->receiver->name ?? '',
                'profile_image' => $this->message->receiver->profile_image ?? $this->message->receiver->profileImage ?? null,
            ];
        }

        return $payload;
    }
}
```

**Dispatch after saving the message:**

```php
$message = Message::create([...]);
$message->load(['sender', 'receiver']);
event(new MessageSent($message));

// Optional: server-side logging (config('app.debug') or similar)
// Log::debug('MessageSent dispatched', ['id' => $message->id, 'to_user_id' => $message->to_user_id]);
```

---

## 3. Laravel `config/broadcasting.php` (Pusher)

Ensure Pusher config matches your app and `.env`:

```php
'pusher' => [
    'driver' => 'pusher',
    'key' => env('PUSHER_APP_KEY'),
    'secret' => env('PUSHER_APP_SECRET'),
    'app_id' => env('PUSHER_APP_ID'),
    'options' => [
        'cluster' => env('PUSHER_APP_CLUSTER', 'ap2'),
        'encrypted' => true,
        'host' => env('PUSHER_HOST') ?: 'socket.pusher.com',
    ],
],
```

---

## 4. Laravel `.env` (match Pusher dashboard)

```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=9df09725d514e737df9a
PUSHER_APP_SECRET=your_secret
PUSHER_APP_CLUSTER=ap2
```

Flutter uses key `9df09725d514e737df9a` and cluster `ap2`. These must match the Laravel app’s Pusher app.

---

## 5. Private channel auth

- Flutter calls `POST /api/broadcasting/auth` with `socket_id`, `channel_name`, and (via `Authorization` / body) `api_token`.
- Laravel’s `Broadcast::routes()` etc. must expose `/api/broadcasting/auth` and validate the API token (same as your other API auth).  
- Ensure the route uses the same auth middleware as your message API so token validation is consistent.

---

## 6. Flutter Changes Summary

| Component | Change |
|----------|--------|
| **PusherService** | Unwrap `data` / `message` from event payload; validate `id` / `from_user_id`; on parse error log `event.data` and stack; all logs `debugPrint` + `kDebugMode`. |
| **ChatController** | Fix switch-conversation clear using `previousActiveUserId`; `debugPrint` + `kDebugMode` for all logs. |
| **InboxController** | `debugPrint` + `kDebugMode` for all logs. |
| **ConversationView** | `debugPrint` + `kDebugMode` for init/chat logs. |

- **Architecture:** Single Pusher singleton, init at app start (InitialBindings / after login), one `private-chat.{userId}` subscription per user, lifecycle via `disconnect` on logout. No re-init on chat screen open.
- **Unsubscribe:** Handled in `PusherService.disconnect()` (unsubscribe + disconnect). Conversation dispose only clears chat state; it does not unsubscribe (we stay on the same user channel).

---

## 7. Why the Fix Works

1. **`ShouldBroadcastNow`** – Event is broadcast immediately in the HTTP request that creates the message, so no queue delay.
2. **`PrivateChannel('chat.' . to_user_id)`** – Matches Flutter `private-chat.{userId}` and private auth.
3. **`broadcastAs('message.sent')`** – Matches Flutter’s `onEvent` filter, so events are handled.
4. **Broadcast to recipient** – Recipient subscribes to `private-chat.{ownUserId}`; we send to `private-chat.{to_user_id}`, so the right user gets the event.
5. **Stable payload** – Snake_case and optional `sender`/`receiver` match `MessageModel` / `UserMiniModel`; Flutter unwraps `data`/`message` when present.
6. **Switch-conversation clear** – Clearing when `previousActiveUserId != toUserId` avoids showing the previous thread’s messages in the new one.
7. **Parse-error logging** – Raw payload and stack trace make backend payload issues easy to spot.

---

## 8. Verification Checklist

### Laravel
- [ ] `MessageSent` implements `ShouldBroadcastNow`.
- [ ] `broadcastOn()` returns `[new PrivateChannel('chat.' . $this->message->to_user_id)]`.
- [ ] `broadcastAs()` returns `'message.sent'`.
- [ ] `broadcastWith()` includes `id`, `from_user_id`, `to_user_id`, `message_content`, `is_read`, `created_at`, `updated_at` (and optionally `sender`/`receiver`).
- [ ] `event(new MessageSent($message))` is fired **after** the message is created and, if used, relations are loaded.
- [ ] `.env` and `config/broadcasting.php` match Pusher app (key, cluster).
- [ ] `POST /api/broadcasting/auth` exists, uses API token auth, and is used by Flutter for private channels.

### Flutter
- [ ] Pusher init once at startup (and after login) with correct key/cluster.
- [ ] Subscribe to `private-chat.{currentUserId}` only; no per-screen subscribe.
- [ ] Listen for event `message.sent`; handle only that.
- [ ] Parse payload (root or `data`/`message`), then `MessageModel.fromJson`.
- [ ] Chat UI uses `Obx` / controller reactive state; no reload for new messages.
- [ ] On logout, `PusherService.disconnect()` is called (unsubscribe + disconnect).

### E2E
- [ ] User A sends to User B → B sees the message immediately (no refresh).
- [ ] User B sends to User A → A sees the message immediately.
- [ ] Inbox list updates in realtime when a new message arrives (thread reorder / new thread).
- [ ] Switching conversations shows the correct thread and no stale messages from the previous one.
- [ ] Debug logs: `[PUSHER] connection state: CONNECTED`, `[PUSHER] subscribed: private-chat.X`, `[PUSHER] event received | id=...`, `[CHAT] REALTIME message added | ...`, `[INBOX] REALTIME thread updated | ...`.

---

## 9. Optional: Fallback Polling

If you add a “reconnect” or “fallback” mode when the socket fails:

- Use a modest polling interval (e.g. 10–15 s) only when Pusher is disconnected.
- Poll inbox/conversation only; do not poll while Pusher is connected.
- Prefer fixing Pusher (auth, channel, event name, payload) over relying on polling.

---

## 10. Quick Reference

| Layer | Channel | Event | Payload |
|-------|---------|-------|---------|
| Laravel | `PrivateChannel('chat.' . to_user_id)` → `private-chat.{to_user_id}` | `message.sent` | `broadcastWith()` snake_case |
| Flutter | Subscribe `private-chat.{currentUserId}` | Bind `message.sent` | Unwrap `data`/`message` if present → `MessageModel.fromJson` |

Auth: `POST /api/broadcasting/auth` with `socket_id`, `channel_name`, API token.  
Pusher key: `9df09725d514e737df9a`, cluster: `ap2` (must match Laravel Pusher app).
