# Realtime Chat (Firestore) – Sanity Test Checklist

## Prerequisites
- Two physical devices or emulators (Device A = User 65, Device B = User 81)
- Both logged in with different accounts
- Firestore index created (see below)

## Firestore Index (REQUIRED)

Create composite index for inbox query:

**Collection:** `conversations`  
**Fields:**
- `members` — Array-contains
- `updatedAt` — Descending

**Why:** Inbox stream uses `where('members', arrayContains: uid).orderBy('updatedAt', descending: true)`. Firestore requires a composite index for this query.

**How:** Firebase Console → Firestore → Indexes → Composite → Add index, or let the app error link create it.

---

## Test Steps

### 1. App start → Home
- [ ] App launches without crash
- [ ] Logs: `[NAV] Splash loaded` → `[NAV] Auth ready → navigating to Home`
- [ ] Home screen shows posts

### 2. Open Messages tab
- [ ] Tap Messages in bottom nav
- [ ] Logs: `[NAV] Messages screen selected`, `[UI] MessagesView opened`, `[CTRL] InboxController init`, `[INBOX] stream update count=N`
- [ ] Inbox list shows conversations (or empty state)
- [ ] No HTTP dump logs

### 3. Open conversation
- [ ] Tap a thread (or start new via search)
- [ ] Logs: `[CHAT] open groupId=65_81 uid=65 to=81`, `[CHAT] stream update groupId=65_81 count=N`
- [ ] Messages load in chat
- [ ] Messages ordered oldest-first

### 4. Send message (Device A → Device B)
- [ ] Device A: Type message, tap Send
- [ ] Input clears immediately
- [ ] Send button shows loading briefly
- [ ] Device B: New message appears within 1–2 seconds (no refresh)
- [ ] Device B: Inbox updates (last message + ordering)

### 5. Send message (Device B → Device A)
- [ ] Device B: Send reply
- [ ] Device A: New message appears within 1–2 seconds
- [ ] Device A: Inbox updates if on Messages tab

### 6. No duplicates / no missing
- [ ] Same message does not appear twice
- [ ] All sent messages appear on both devices
- [ ] No manual refresh needed

### 7. Controller lifecycle
- [ ] Go back from Conversation → Messages
- [ ] Open another conversation
- [ ] No duplicate subscriptions (check logs for repeated stream init)
- [ ] Leave Messages tab → no crash
- [ ] Return to Messages → inbox loads again

### 8. Search (still REST)
- [ ] Search for user
- [ ] Tap result → opens conversation
- [ ] Conversation stream loads messages

---

## Expected Log Snippets

**Opening Messages:**
```
[NAV] Messages screen selected
[UI] MessagesView opened
[CTRL] InboxController init
[INBOX] stream update count=3
```

**Opening Conversation:**
```
[CHAT] open groupId=65_81 uid=65 to=81
[CHAT] stream update groupId=65_81 count=12
```

**After send:** No reload logs; new messages come via Firestore stream.

---

## Backend Requirement

Laravel must write to Firestore when `POST /api/messages/send` succeeds:
1. Create or update `conversations/{groupId}`
2. Add message to `conversations/{groupId}/messages/{messageId}`

Without this sync, sent messages will not appear in realtime.
