# Real-time Messaging Implementation Guide

## Overview
This document describes the implementation of real-time messaging functionality in the Torko Flutter app. The implementation includes:
- "Message" menu item in post feed
- Real-time messaging with Pusher
- REST API integration for sending messages
- Chat controller with optimistic updates

## Files Created/Modified

### New Files
1. **`lib/models/message_model.dart`**
   - Message data model with optimistic update support
   - Includes `isMine()`, `formattedTime`, and `copyWith()` helpers

2. **`lib/services/message_api_service.dart`**
   - REST API service for sending messages
   - Handles error cases and response parsing
   - Uses `Urls.send_message` endpoint

3. **`lib/services/pusher_service.dart`**
   - Singleton service for Pusher real-time connections
   - Manages connection, subscription, and event streaming
   - **Note**: Currently uses public channels as fallback (see Backend Requirements)

4. **`lib/controllers/chat_controller.dart`**
   - GetX controller for chat state management
   - Handles message sending (optimistic updates)
   - Manages Pusher event listeners
   - Duplicate message protection
   - Message sorting by timestamp and ID

### Modified Files
1. **`lib/views/home/home_view.dart`**
   - Added "Message" menu item above "Save" in post menu
   - Added `_handleMessageTap()` method
   - Handles user ID validation and navigation

2. **`lib/views/conversation/conversation_view.dart`**
   - Integrated with `ChatController`
   - Real-time message display with auto-scroll
   - Sending state indicators
   - Error handling UI

3. **`pubspec.yaml`**
   - Added `pusher_channels_flutter: ^2.2.1` dependency

## API Integration

### Send Message Endpoint
- **URL**: `POST https://torko.attoexasolutions.com/api/messages/send`
- **Request Body**:
  ```json
  {
    "api_token": "<USER_API_TOKEN>",
    "to_user_id": <int>,
    "message_content": "<string>"
  }
  ```
- **Response**:
  ```json
  {
    "status": true,
    "data": {
      "id": <int>,
      "from_user_id": <int>,
      "to_user_id": <int>,
      "message_content": "<string>",
      "created_at": "<ISO8601 string>"
    }
  }
  ```

### User ID Mapping
- **Post Author ID**: `post.userId` (from `PostModel`)
- **Current User ID**: `UserInfo.userId` (from GetStorage)
- **Receiver ID**: `post.userId` (author of the post)
- **Validation**: Prevents messaging yourself (receiverUserId == currentUserId)

## Pusher Configuration

### Current Setup
- **Key**: `f252ee4951f42b5ce3b5`
- **Cluster**: `ap2`
- **Channel Strategy**: Currently using public channels (`user.<userId>`)

### Backend Requirements (TODO)

#### Private Channel Authentication Endpoint
For production, backend must provide Pusher private channel authentication:

**Endpoint**: `POST /api/pusher/auth`

**Request Body**:
```json
{
  "socket_id": "<socket_id>",
  "channel_name": "private-user.<userId>"
}
```

**Response**:
```json
{
  "auth": "<auth_token>"
}
```

**Expected Event Payload**:
When a message is sent, backend should broadcast to Pusher with:
- **Channel**: `private-user.<toUserId>` (receiver's private channel)
- **Event Name**: `message.sent` or `App\\Events\\MessageSent` (backend-dependent)
- **Event Data**:
  ```json
  {
    "id": <int>,
    "from_user_id": <int>,
    "to_user_id": <int>,
    "message_content": "<string>",
    "created_at": "<ISO8601 string>"
  }
  ```

#### Implementation Steps for Backend
1. Create `/api/pusher/auth` endpoint
2. Validate user authentication (check `api_token`)
3. Return Pusher auth token for private channel subscription
4. Update PusherService to use private channels:
   - Change channel name from `user.<userId>` to `private-user.<userId>`
   - Add authentication callback in `PusherService.subscribeToUserChannel()`

## User Flow

1. **User taps three-dots menu on a post**
2. **Selects "Message" option** (above "Save")
3. **Validation**:
   - Checks if user is logged in
   - Validates receiver user ID
   - Prevents self-messaging
4. **Navigation**:
   - Opens conversation overlay via `appController.openConversation()`
   - Passes `toUserId`, `fromUserId`, `name`, `avatar`
5. **Conversation View**:
   - Initializes `ChatController` with receiver info
   - Connects to Pusher
   - Subscribes to user's channel
   - Displays messages (empty state if no messages)
6. **Sending Messages**:
   - User types message and taps send
   - Optimistic update: Message appears immediately (temporary ID)
   - REST API call to send message
   - On success: Replace temporary message with server response
   - On failure: Mark message as failed or show error
7. **Receiving Messages** (Real-time):
   - Pusher event received
   - Duplicate check (using message IDs)
   - Add to message list (sorted by timestamp)
   - Auto-scroll to bottom

## Key Features

### Optimistic Updates
- Messages appear immediately when sent
- Temporary negative IDs for pending messages
- Replaced with server response on success
- Error state for failed messages

### Duplicate Protection
- Maintains `Set<int> receivedMessageIds`
- Prevents duplicate messages from Pusher events
- Works with temporary IDs and server IDs

### Message Sorting
- Sorted by `createdAt` (descending)
- Secondary sort by `id` (descending)
- Maintains chronological order

### Error Handling
- Network errors with user-friendly messages
- Validation errors (empty message, invalid user)
- Self-messaging prevention
- Failed message indicators in UI

## Testing Checklist

- [ ] Message menu item appears in post menu (above Save)
- [ ] Menu item disabled/hidden for own posts (or shows warning)
- [ ] Navigation to conversation view works
- [ ] Message sending works via REST API
- [ ] Optimistic updates display correctly
- [ ] Failed messages show error state
- [ ] Pusher connection establishes
- [ ] Real-time messages received and displayed
- [ ] Duplicate messages prevented
- [ ] Auto-scroll works on new messages
- [ ] Message sorting correct
- [ ] Error messages shown appropriately

## Known Limitations

1. **Public Channels**: Currently using public Pusher channels. Should migrate to private channels for production.
2. **Message History**: No endpoint for fetching message history. Only real-time messages displayed.
3. **Channel Authentication**: Backend auth endpoint not yet implemented (see Backend Requirements).
4. **Avatar Display**: Avatar URL not currently passed from post to conversation (can be extended).

## Future Enhancements

1. **Message History API**: Load previous messages when opening conversation
2. **Private Channels**: Implement backend auth endpoint and switch to private channels
3. **Read Receipts**: Mark messages as read
4. **Typing Indicators**: Show when user is typing
5. **Message Actions**: Edit, delete, reply to messages
6. **Media Messages**: Support images, files in messages
7. **Message Search**: Search within conversation
8. **Notifications**: Push notifications for new messages

## Dependencies

- `pusher_channels_flutter: ^2.2.1` - Real-time messaging
- `get: ^4.6.6` - State management (already in project)
- `get_storage: ^2.1.1` - Local storage (already in project)

## Notes

- All user-facing text supports Bengali and English (via `AppLanguage`)
- Error messages are localized
- Follows existing GetX patterns in the codebase
- Uses existing theme system (`AppColors`, dark/light mode)
- Consistent with existing UI patterns
