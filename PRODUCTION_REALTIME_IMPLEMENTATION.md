# PRODUCTION-READY REALTIME MESSAGING IMPLEMENTATION

## CHANNEL & EVENT CONSISTENCY RULES

**Backend Channel:** `PrivateChannel('chat.{to_user_id}')`  
**Flutter Subscription:** `private-chat.{currentUserId}`  
**Event Name:** `message.sent`  
**Payload:** MessageModel JSON structure

**CRITICAL:** Backend broadcasts TO `chat.{to_user_id}` → Pusher converts to `private-chat.{to_user_id}` → Flutter subscribes to `private-chat.{currentUserId}`

---

## 1. LARAVEL BROADCASTING SETUP

### config/broadcasting.php
```php
<?php

return [
    'default' => env('BROADCAST_DRIVER', 'pusher'),

    'connections' => [
        'pusher' => [
            'driver' => 'pusher',
            'key' => env('PUSHER_APP_KEY'),
            'secret' => env('PUSHER_APP_SECRET'),
            'app_id' => env('PUSHER_APP_ID'),
            'options' => [
                'cluster' => env('PUSHER_APP_CLUSTER'),
                'encrypted' => true,
                'host' => env('PUSHER_HOST'),
                'port' => env('PUSHER_PORT', 443),
                'scheme' => env('PUSHER_SCHEME', 'https'),
            ],
        ],
    ],
];
```

### app/Providers/BroadcastServiceProvider.php
```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Broadcast;

class BroadcastServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        // API routes for broadcasting auth (custom token auth)
        Broadcast::routes(['middleware' => ['api']]);

        // Channel authorization
        Broadcast::channel('chat.{userId}', function ($user, $userId) {
            return (int) $user->id === (int) $userId;
        });
    }
}
```

### routes/api.php (or routes/channels.php)
```php
<?php

use Illuminate\Support\Facades\Broadcast;

// Broadcasting auth endpoint (handled by BroadcastServiceProvider)
// Route: POST /api/broadcasting/auth
// Middleware: api
// Expected: socket_id, channel_name, api_token (in body)
// Returns: { "auth": "key:signature" }
```

### app/Events/MessageSent.php
```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;

    public function __construct($message)
    {
        $this->message = $message;
    }

    public function broadcastOn()
    {
        // CRITICAL: Broadcast to chat.{to_user_id}
        // Pusher converts to private-chat.{to_user_id}
        return new PrivateChannel('chat.' . $this->message->to_user_id);
    }

    public function broadcastAs()
    {
        // CRITICAL: Event name must be exactly 'message.sent'
        return 'message.sent';
    }

    public function broadcastWith()
    {
        // CRITICAL: Payload must match MessageModel structure
        return [
            'id' => $this->message->id,
            'from_user_id' => $this->message->from_user_id,
            'to_user_id' => $this->message->to_user_id,
            'message_content' => $this->message->message_content,
            'is_read' => $this->message->is_read,
            'created_at' => $this->message->created_at->toIso8601String(),
            'updated_at' => $this->message->updated_at->toIso8601String(),
            'sender' => $this->message->sender ? [
                'id' => $this->message->sender->id,
                'fullname' => $this->message->sender->fullname,
                'profile_image' => $this->message->sender->profile_image,
            ] : null,
            'receiver' => $this->message->receiver ? [
                'id' => $this->message->receiver->id,
                'fullname' => $this->message->receiver->fullname,
                'profile_image' => $this->message->receiver->profile_image,
            ] : null,
        ];
    }
}
```

### Backend Auth Endpoint Response Format
**CRITICAL:** `/api/broadcasting/auth` MUST return:
```json
{
  "auth": "9df09725d514e737df9a:signature_here"
}
```

**Request Format:**
- Method: POST
- Body: `{ "socket_id": "...", "channel_name": "private-chat.65", "api_token": "..." }`
- Headers: `Authorization: Bearer {token}` (optional, if middleware uses it)

---

## 2. FLUTTER PUSHERSERVICE (FINAL PRODUCTION VERSION)

### lib/services/pusher_service.dart
```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/message_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import '../services/user_info.dart';

/// Production-ready PusherService for real-time messaging
/// 
/// CRITICAL ARCHITECTURE:
/// - True singleton (one instance app-wide)
/// - Uses ONLY key + cluster (NO app_id, NO secret in Flutter)
/// - Subscribes to private channel: private-chat.{currentUserId}
/// - Implements private channel authorizer via /broadcasting/auth
/// - Emits MessageModel objects via incomingMessages stream
/// - Production-safe: no memory leaks, proper cleanup
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  PusherChannel? _currentChannel;
  
  // StreamController for parsed MessageModel objects
  StreamController<MessageModel>? _incomingMessagesController;
  
  bool _isConnected = false;
  int? _currentUserId;
  bool _isInitialized = false;
  bool _isDisposed = false;

  // Pusher configuration
  static const String _pusherKey = '9df09725d514e737df9a';
  static const String _pusherCluster = 'ap2';
  
  /// Stream of incoming messages (MessageModel objects)
  /// 
  /// CRITICAL: Returns same stream instance, never recreates
  /// CRITICAL: Emits MessageModel objects (already parsed)
  Stream<MessageModel> get incomingMessages {
    if (_isDisposed) {
      throw StateError('PusherService has been disposed');
    }
    _incomingMessagesController ??= StreamController<MessageModel>.broadcast();
    return _incomingMessagesController!.stream;
  }

  /// Check if Pusher is connected
  bool get isConnected => _isConnected && !_isDisposed;

  /// Connect to Pusher and subscribe to user's private channel
  /// 
  /// [currentUserId] - Current user's ID for channel subscription
  /// 
  /// CRITICAL: Idempotent - safe to call multiple times
  /// CRITICAL: Subscribes to private channel: private-chat.{currentUserId}
  Future<void> connect({required int currentUserId}) async {
    if (_isDisposed) {
      throw StateError('PusherService has been disposed');
    }

    // Idempotent check: already connected for same user
    if (_isConnected && _currentUserId == currentUserId && _isInitialized) {
      if (kDebugMode) {
        print('✅ [PUSHER] Already connected for user $currentUserId');
      }
      return;
    }

    _currentUserId = currentUserId;

    try {
      // Initialize StreamController ONCE (never recreate)
      _incomingMessagesController ??= StreamController<MessageModel>.broadcast();
      
      // Initialize Pusher instance ONCE
      if (!_isInitialized) {
        if (kDebugMode) {
          print('🔄 [PUSHER] Initializing...');
        }
        
        _pusher ??= PusherChannelsFlutter.getInstance();
        
        await _pusher!.init(
          apiKey: _pusherKey,
          cluster: _pusherCluster,
          onAuthorizer: _onAuthorizer, // CRITICAL: Required for private channels
          onConnectionStateChange: _onConnectionStateChange,
          onError: _onError,
          onSubscriptionSucceeded: _onSubscriptionSucceeded,
          onEvent: _onEvent,
          onSubscriptionError: _onSubscriptionError,
          onDecryptionFailure: _onDecryptionFailure,
          onMemberAdded: _onMemberAdded,
          onMemberRemoved: _onMemberRemoved,
        );

        _isInitialized = true;
        if (kDebugMode) {
          print('✅ [PUSHER] Initialized');
        }
      }

      // Connect to Pusher (idempotent)
      if (!_isConnected) {
        if (kDebugMode) {
          print('🔄 [PUSHER] Connecting...');
        }
        await _pusher!.connect();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Subscribe to private chat channel (CRITICAL: private-chat.{currentUserId})
      final channelName = 'private-chat.$currentUserId';
      if (_currentChannel == null || _currentChannel!.channelName != channelName) {
        await subscribeToUserChannel(currentUserId: currentUserId);
      }

      _isConnected = true;
      
      if (kDebugMode) {
        print('✅ [PUSHER] Connected to $channelName');
      }
    } catch (e, stackTrace) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ [PUSHER] Connection failed: $e');
        print('   Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// Authorizer callback for private channel authentication
  /// 
  /// CRITICAL: Called by Pusher when subscribing to private-* channels
  /// CRITICAL: Must call backend /broadcasting/auth endpoint
  /// CRITICAL: Returns auth signature from backend
  Future<Map<String, dynamic>> _onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    if (kDebugMode) {
      print('🔐 [PUSHER] Authorizing channel: $channelName');
    }

    try {
      final token = UserInfo.apiToken;
      if (token == null || token.isEmpty) {
        throw Exception('No API token for Pusher authorization');
      }

      final response = await NetworkCaller.postAuth(
        url: Urls.pusher_auth,
        body: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
      );

      if (!response.isSuccess || response.body == null) {
        throw Exception('Pusher authorization failed: ${response.errorMessage ?? 'Unknown error'}');
      }

      final authData = response.body!;
      final auth = authData['auth'] as String?;

      if (auth == null || auth.isEmpty) {
        throw Exception('Invalid auth response: missing "auth" field');
      }

      if (kDebugMode) {
        print('✅ [PUSHER] Authorization success');
      }

      return {'auth': auth};
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [PUSHER] Authorization failed: $e');
        print('   Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// Subscribe to user's private channel
  Future<void> subscribeToUserChannel({required int currentUserId}) async {
    if (_pusher == null) {
      throw Exception('Pusher not initialized. Call connect() first.');
    }

    try {
      final channelName = 'private-chat.$currentUserId';
      
      if (_currentChannel != null && _currentChannel!.channelName == channelName) {
        return; // Already subscribed
      }
      
      if (kDebugMode) {
        print('🔌 [PUSHER] Subscribing to $channelName');
      }

      _currentChannel = await _pusher!.subscribe(
        channelName: channelName,
      );

      if (kDebugMode) {
        print('✅ [PUSHER] Subscribed to $channelName');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [PUSHER] Subscription failed: $e');
        print('   Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// Disconnect from Pusher
  Future<void> disconnect() async {
    try {
      if (_currentChannel != null) {
        await _pusher?.unsubscribe(channelName: _currentChannel!.channelName);
        _currentChannel = null;
      }
      
      await _pusher?.disconnect();
      _isConnected = false;
      _currentUserId = null;
      
      if (kDebugMode) {
        print('✅ [PUSHER] Disconnected');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [PUSHER] Disconnect error: $e');
      }
    }
  }

  // ==================== Pusher Event Handlers ====================

  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    final stateStr = currentState.toString();
    if (kDebugMode) {
      print('🔄 [PUSHER] State: $previousState -> $stateStr');
    }
    
    if (stateStr == 'CONNECTED') {
      _isConnected = true;
    } else if (stateStr == 'DISCONNECTED' || stateStr == 'FAILED') {
      _isConnected = false;
    }
  }

  void _onError(String message, int? code, dynamic e) {
    if (kDebugMode) {
      print('❌ [PUSHER] Error: $message (code: $code)');
    }
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    if (kDebugMode) {
      print('✅ [PUSHER] Subscription succeeded: $channelName');
    }
  }

  void _onEvent(PusherEvent event) {
    if (kDebugMode) {
      print('📨 [PUSHER] Event: ${event.eventName} on ${event.channelName}');
    }
    
    try {
      // Parse event data
      Map<String, dynamic> eventData;
      if (event.data is String) {
        eventData = jsonDecode(event.data as String);
      } else if (event.data is Map) {
        eventData = Map<String, dynamic>.from(event.data);
      } else {
        if (kDebugMode) {
          print('❌ [PUSHER] Unknown event data type: ${event.data.runtimeType}');
        }
        return;
      }

      // CRITICAL: Parse and emit MessageModel if it's a message event
      final eventName = event.eventName;
      final isMessageEvent = eventName != null && 
          (eventName == 'message.sent' ||
           eventName.toLowerCase() == 'message.sent');

      if (isMessageEvent) {
        try {
          final message = MessageModel.fromJson(eventData);
          
          // CRITICAL: Emit MessageModel to incomingMessages stream
          if (_incomingMessagesController != null && !_incomingMessagesController!.isClosed) {
            _incomingMessagesController!.add(message);
            
            if (kDebugMode) {
              print('✅ [PUSHER] Message emitted: id=${message.id}');
            }
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('❌ [PUSHER] Parse error: $e');
            print('   Stack: $stackTrace');
            print('   Data: $eventData');
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [PUSHER] Event processing error: $e');
        print('   Stack: $stackTrace');
      }
    }
  }

  void _onSubscriptionError(String message, dynamic e) {
    if (kDebugMode) {
      print('❌ [PUSHER] Subscription error: $message');
    }
  }

  void _onDecryptionFailure(String event, String reason) {
    if (kDebugMode) {
      print('⚠️ [PUSHER] Decryption failure: $event - $reason');
    }
  }

  void _onMemberAdded(String channelName, PusherMember member) {
    // Not used for private channels
  }

  void _onMemberRemoved(String channelName, PusherMember member) {
    // Not used for private channels
  }

  /// Dispose resources
  /// CRITICAL: Only call on app logout, not on screen close
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    _incomingMessagesController?.close();
    _incomingMessagesController = null;
    disconnect();
    _isInitialized = false;
    
    if (kDebugMode) {
      print('✅ [PUSHER] Disposed');
    }
  }
}
```

---

## 3. FLUTTER STREAM CONSUMPTION

### lib/controllers/chat_controller.dart (Subscription Pattern)
```dart
// In ChatController class

StreamSubscription<MessageModel>? _pusherSubscription;

Future<void> _connectPusher() async {
  if (currentUserId == null) return;

  try {
    final pusherService = PusherService();
    
    if (!pusherService.isConnected) {
      await pusherService.connect(currentUserId: currentUserId!);
    }

    // CRITICAL: Cancel previous subscription if exists
    await _pusherSubscription?.cancel();
    _pusherSubscription = null;

    // CRITICAL: Subscribe to incomingMessages stream
    _pusherSubscription = pusherService.incomingMessages.listen(
      (message) {
        _handleIncomingMessage(message);
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ [CHAT] Stream error: $error');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('⚠️ [CHAT] Stream closed');
        }
      },
      cancelOnError: false,
    );
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ [CHAT] Pusher connection error: $e');
      print('   Stack: $stackTrace');
    }
  }
}

@override
void onClose() {
  _pusherSubscription?.cancel();
  _pusherSubscription = null;
  messages.clear();
  receivedMessageIds.clear();
  super.onClose();
}
```

### lib/controllers/inbox_controller.dart (Subscription Pattern)
```dart
// In InboxController class

StreamSubscription<MessageModel>? _pusherSubscription;

Future<void> _connectPusher() async {
  final currentUserId = UserInfo.userId;
  if (currentUserId == null) return;

  try {
    final pusherService = PusherService();
    
    if (!pusherService.isConnected) {
      await pusherService.connect(currentUserId: currentUserId);
    }

    // CRITICAL: Cancel previous subscription if exists
    await _pusherSubscription?.cancel();
    _pusherSubscription = null;

    // CRITICAL: Subscribe to incomingMessages stream
    _pusherSubscription = pusherService.incomingMessages.listen(
      (message) {
        _handleIncomingMessage(message);
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ [INBOX] Stream error: $error');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('⚠️ [INBOX] Stream closed');
        }
      },
      cancelOnError: false,
    );
  } catch (e) {
    if (kDebugMode) {
      print('❌ [INBOX] Pusher connection error: $e');
    }
  }
}

@override
void onClose() {
  _pusherSubscription?.cancel();
  _pusherSubscription = null;
  searchEC.dispose();
  super.onClose();
}
```

---

## 4. PRODUCTION SAFETY REQUIREMENTS

### ✅ Singleton Pattern
- `PusherService()` returns same instance always
- Only one Pusher connection app-wide

### ✅ Proper Lifecycle
- `connect()` is idempotent (safe to call multiple times)
- `dispose()` only called on app logout
- Streams properly closed in `onClose()`

### ✅ Memory Leak Prevention
- StreamController closed in `dispose()`
- Subscriptions cancelled in controller `onClose()`
- No duplicate listeners (cancel before subscribe)

### ✅ Duplicate Prevention
- `receivedMessageIds` Set in ChatController
- Message ID checked before adding to list

### ✅ Error Handling
- All callbacks wrapped in try-catch
- Stream errors don't crash app (`cancelOnError: false`)
- Graceful degradation if Pusher fails

### ✅ App Resume Handling
- Connection state tracked
- Reconnect on state change if needed
- Stream listeners persist across screens

---

## 5. VERIFICATION CHECKLIST

### Connection
- [ ] Pusher connects (`CONNECTED` state)
- [ ] Only one Pusher instance (singleton)
- [ ] Connection persists across screens

### Authorization
- [ ] `onAuthorizer` called on subscription
- [ ] Backend returns `{ "auth": "..." }`
- [ ] Subscription succeeds

### Event Reception
- [ ] Events received (`[PUSHER] Event: message.sent`)
- [ ] MessageModel parsed successfully
- [ ] MessageModel emitted to stream

### ChatController
- [ ] Stream listener active
- [ ] Messages filtered correctly
- [ ] Messages added to list
- [ ] UI rebuilds (Obx)

### InboxController
- [ ] Stream listener active
- [ ] Thread updated in-place
- [ ] No API call for existing conversations

### Production Safety
- [ ] No memory leaks (streams closed)
- [ ] No duplicate messages
- [ ] Stable under rapid messages
- [ ] Works after app resume

---

## SUCCESS INDICATORS

**✅ PRODUCTION-READY WHEN:**
1. Messages appear instantly (< 100ms)
2. Zero API calls on receive (existing conversations)
3. No missed events
4. No duplicates
5. Stable under rapid messaging
6. No memory leaks
7. Works after app resume

**All checklist items must PASS.**
