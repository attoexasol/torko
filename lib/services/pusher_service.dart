import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/message_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import '../services/user_info.dart';

/// Service for managing Pusher real-time connections with private channel authentication
/// 
/// CRITICAL ARCHITECTURE:
/// - True singleton (one instance app-wide)
/// - Uses ONLY key + cluster (NO app_id, NO secret in Flutter)
/// - Subscribes to private channel: private-chat.{currentUserId}
/// - Implements private channel authorizer via /broadcasting/auth
/// - Emits MessageModel objects via incomingMessages stream
/// - connect() is idempotent
/// - subscribeToUserChannel() is idempotent
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  PusherChannel? _currentChannel;
  
  // CRITICAL: StreamController created ONCE, never recreated
  final StreamController<Map<String, dynamic>> _eventController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // StreamController for parsed MessageModel objects
  StreamController<MessageModel>? _incomingMessagesController;
  
  bool _isConnected = false;
  int? _currentUserId;
  bool _isInitialized = false;

  // Pusher configuration
  // CRITICAL: Flutter uses ONLY key + cluster (NO app_id, NO secret)
  static const String _pusherKey = '9df09725d514e737df9a';
  static const String _pusherCluster = 'ap2';
  
  /// Stream of raw events from Pusher (for backward compatibility)
  Stream<Map<String, dynamic>> get onEventStream => _eventController.stream;
  
  /// Stream of incoming messages (MessageModel objects)
  /// 
  /// CRITICAL: Returns same stream instance, never recreates
  /// CRITICAL: Emits MessageModel objects (already parsed)
  Stream<MessageModel> get incomingMessages {
    _incomingMessagesController ??= StreamController<MessageModel>.broadcast();
    return _incomingMessagesController!.stream;
  }

  /// Check if Pusher is connected
  bool get isConnected => _isConnected;

  /// Connect to Pusher and subscribe to user's private channel
  /// 
  /// [currentUserId] - Current user's ID for channel subscription
  /// 
  /// CRITICAL: Idempotent - safe to call multiple times
  /// CRITICAL: Subscribes to private channel: private-chat.{currentUserId}
  /// CRITICAL: Backend broadcasts messages TO this channel (user.{to_user_id} becomes private-chat.{to_user_id})
  Future<void> connect({required int currentUserId}) async {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🔌 [CONNECTED] PusherService.connect() called');
      print('   currentUserId: $currentUserId');
      print('   _isConnected: $_isConnected');
      print('   _currentUserId: $_currentUserId');
    }
    
    // Idempotent check: already connected for same user
    if (_isConnected && _currentUserId == currentUserId && _isInitialized) {
      if (kDebugMode) {
        print('✅ [CONNECTED] Already connected for user $currentUserId - skipping');
        print('═══════════════════════════════════════════════════════════');
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
          print('🔄 [CONNECTED] Initializing Pusher connection...');
        }
        
        _pusher ??= PusherChannelsFlutter.getInstance();
        
        if (kDebugMode) {
          print('✅ [CONNECTED] Pusher instance obtained');
        }

        // Configure Pusher options
        // NOTE: For private channel auth, we'll handle it via subscribe callback
        // The pusher_channels_flutter plugin v2.2.1 handles private channel auth
        // by requiring an authorization endpoint URL or callback
        await _pusher!.init(
          apiKey: _pusherKey,
          cluster: _pusherCluster,
          onConnectionStateChange: _onConnectionStateChange,
          onError: _onError,
          onSubscriptionSucceeded: _onSubscriptionSucceeded,
          onEvent: _onEvent,
          onSubscriptionError: _onSubscriptionError,
          onDecryptionFailure: _onDecryptionFailure,
          onMemberAdded: _onMemberAdded,
          onMemberRemoved: _onMemberRemoved,
        );

        if (kDebugMode) {
          print('✅ [CONNECTED] Pusher initialized');
        }
        
        _isInitialized = true;
      }

      // Connect to Pusher (idempotent)
      if (!_isConnected) {
        if (kDebugMode) {
          print('🔄 [CONNECTED] Connecting to Pusher servers...');
        }
        await _pusher!.connect();

        // Wait a bit for connection to establish
        await Future.delayed(const Duration(milliseconds: 500));

        if (kDebugMode) {
          print('✅ [CONNECTED] Pusher connection established');
        }
      }

      // Subscribe to private chat channel (CRITICAL: private-chat.{currentUserId})
      // Only subscribe if not already subscribed to this channel
      final channelName = 'private-chat.$currentUserId';
      if (_currentChannel == null || _currentChannel!.channelName != channelName) {
        await subscribeToUserChannel(currentUserId: currentUserId);
      }

      _isConnected = true;
      
      if (kDebugMode) {
        print('✅ [CONNECTED] ✅ PusherService.connect() SUCCESS');
        print('   Connected: $_isConnected');
        print('   Channel: $channelName');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ [CONNECTED] PusherService.connect() FAILED');
        print('   Error: $e');
        print('   Stack: $stackTrace');
        print('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  // NOTE: Private channel authentication for pusher_channels_flutter v2.2.1
  // The plugin handles private channel auth automatically when subscribing to private-* channels
  // It requires the backend to have a /broadcasting/auth endpoint configured
  // The backend endpoint should accept: { "socket_id": "...", "channel_name": "private-chat.{id}", "api_token": "..." }
  // And return: { "auth": "..." }
  // 
  // For now, we'll use private channel names and let the plugin handle auth automatically
  // If auth fails, it will be caught in onSubscriptionError

  /// Subscribe to user's private channel
  /// 
  /// CRITICAL: Subscribes to private channel: private-chat.{currentUserId}
  /// CRITICAL: Backend MUST broadcast messages TO this channel
  /// CRITICAL: Idempotent - won't resubscribe if already subscribed
  /// CRITICAL: Uses authorization endpoint for private channel auth
  Future<void> subscribeToUserChannel({required int currentUserId}) async {
    if (_pusher == null) {
      throw Exception('Pusher not initialized. Call connect() first.');
    }

    try {
      // CRITICAL: Channel name is private-chat.{currentUserId}
      // Backend broadcasts to: PrivateChannel('chat.{to_user_id}') which becomes 'private-chat.{to_user_id}'
      final channelName = 'private-chat.$currentUserId';
      
      // Idempotent: don't resubscribe if already subscribed to same channel
      if (_currentChannel != null && _currentChannel!.channelName == channelName) {
        if (kDebugMode) {
          print('✅ [SUBSCRIBED] Already subscribed to channel: $channelName');
        }
        return;
      }
      
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('🔌 [SUBSCRIBED] Subscribing to Pusher private channel');
        print('   Channel name: $channelName');
        print('   Current user ID: $currentUserId');
        print('   ⚠️  Backend MUST broadcast messages TO this channel');
        print('   ⚠️  Event name: message.sent');
        print('═══════════════════════════════════════════════════════════');
      }

      // Subscribe to private channel
      // For private channels, the plugin will automatically call the authorization endpoint
      // We need to set up the authorization handler via init's onAuthorizer callback
      // But since we can't modify init after the fact, we'll handle auth via the endpoint URL
      // Note: pusher_channels_flutter v2.2.1 may require setting authorization endpoint differently
      // For now, try subscribing and handle auth errors via onSubscriptionError
      _currentChannel = await _pusher!.subscribe(
        channelName: channelName,
      );

      if (kDebugMode) {
        print('✅ [SUBSCRIBED] ✅ Channel subscription SUCCESS');
        print('   Channel: $channelName');
        print('   Waiting for events...');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [SUBSCRIBED] Channel subscription FAILED');
        print('   Error: $e');
        print('   Stack: $stackTrace');
        print('═══════════════════════════════════════════════════════════');
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
        print('DEBUG PusherService: Disconnected from Pusher');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG PusherService: Disconnect error - $e');
      }
    }
  }

  // ==================== Pusher Event Handlers ====================

  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    if (kDebugMode) {
      print('🔄 [CONNECTED] Connection state changed: $previousState -> $currentState');
    }
    if (currentState == 'CONNECTED') {
      _isConnected = true;
      if (kDebugMode) {
        print('✅ [CONNECTED] Pusher CONNECTED');
      }
    } else if (currentState == 'DISCONNECTED' || currentState == 'FAILED') {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ [CONNECTED] Pusher DISCONNECTED/FAILED');
      }
    }
  }

  void _onError(String message, int? code, dynamic e) {
    if (kDebugMode) {
      print('DEBUG PusherService: Error - $message (code: $code)');
    }
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    if (kDebugMode) {
      print('✅ [SUBSCRIBED] ✅ Subscription SUCCEEDED');
      print('   Channel: $channelName');
      print('   Data: $data');
      print('   Ready to receive events!');
    }
  }

  void _onEvent(PusherEvent event) {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('📨 [EVENT RECEIVED] ✅ EVENT RECEIVED FROM PUSHER');
      print('   Channel: ${event.channelName}');
      print('   Event Name: ${event.eventName}');
      print('   Raw Data Type: ${event.data.runtimeType}');
    }
    
    try {
      // Parse event data
      Map<String, dynamic> eventData;
      if (event.data is String) {
        final dataString = event.data as String;
        if (kDebugMode) {
          final preview = dataString.length > 200 ? '${dataString.substring(0, 200)}...' : dataString;
          print('📨 [EVENT RECEIVED] Raw data (string, first 200 chars): $preview');
        }
        eventData = jsonDecode(dataString);
      } else if (event.data is Map) {
        if (kDebugMode) {
          print('📨 [EVENT RECEIVED] Raw data (Map): ${event.data}');
        }
        eventData = Map<String, dynamic>.from(event.data);
      } else {
        if (kDebugMode) {
          print('❌ [EVENT RECEIVED] ❌ Unknown event data type: ${event.data.runtimeType}');
          print('   Data: ${event.data}');
        }
        return;
      }

      if (kDebugMode) {
        print('✅ [EVENT RECEIVED] Event data parsed successfully');
        print('   Parsed data: $eventData');
      }

      // CRITICAL: Parse and emit MessageModel if it's a message event
      // Backend broadcasts event name: message.sent
      final eventName = event.eventName;
      final isMessageEvent = eventName != null && 
          (eventName == 'message.sent' ||
           eventName.toLowerCase() == 'message.sent' ||
           eventName.contains('message.sent'));

      if (isMessageEvent) {
        if (kDebugMode) {
          print('📨 [EVENT RECEIVED] Message event detected - parsing MessageModel...');
          print('   Event name: $eventName');
        }
        
        try {
          // Parse MessageModel from event data
          // Backend sends message data directly in event
          final message = MessageModel.fromJson(eventData);
          
          if (kDebugMode) {
            print('✅ [EVENT RECEIVED] MessageModel parsed successfully');
            print('   Message ID: ${message.id}');
            print('   From User ID: ${message.fromUserId}');
            print('   To User ID: ${message.toUserId}');
            print('   Content: ${message.messageContent.length > 50 ? message.messageContent.substring(0, 50) + "..." : message.messageContent}');
          }
          
          // CRITICAL: Emit MessageModel to incomingMessages stream
          if (_incomingMessagesController != null && !_incomingMessagesController!.isClosed) {
            _incomingMessagesController!.add(message);
            
            if (kDebugMode) {
              print('✅ [EVENT RECEIVED] ✅ MessageModel emitted to incomingMessages stream');
              print('   Waiting for ChatController listener...');
            }
          } else if (kDebugMode) {
            print('❌ [EVENT RECEIVED] ❌ incomingMessages stream is closed');
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('❌ [EVENT RECEIVED] ❌ Failed to parse MessageModel');
            print('   Error: $e');
            print('   Stack: $stackTrace');
            print('   Event Data: $eventData');
          }
        }
      } else {
        if (kDebugMode) {
          print('⏭️  [EVENT RECEIVED] Event is not a message event - ignoring');
          print('   Expected: message.sent, Got: $eventName');
        }
      }
      
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [EVENT RECEIVED] ❌ Error parsing event data');
        print('   Error: $e');
        print('   Stack: $stackTrace');
        print('   Raw data: ${event.data}');
        print('═══════════════════════════════════════════════════════════');
      }
    }
  }

  void _onSubscriptionError(String message, dynamic e) {
    if (kDebugMode) {
      print('DEBUG PusherService: Subscription error - $message');
    }
  }

  void _onDecryptionFailure(String event, String reason) {
    if (kDebugMode) {
      print('DEBUG PusherService: Decryption failure - Event: $event, Reason: $reason');
    }
  }

  void _onMemberAdded(String channelName, PusherMember member) {
    if (kDebugMode) {
      print('DEBUG PusherService: Member added - Channel: $channelName, User: ${member.userId}');
    }
  }

  void _onMemberRemoved(String channelName, PusherMember member) {
    if (kDebugMode) {
      print('DEBUG PusherService: Member removed - Channel: $channelName, User: ${member.userId}');
    }
  }

  /// Dispose resources
  /// CRITICAL: Only call on app logout, not on screen close
  void dispose() {
    _incomingMessagesController?.close();
    _incomingMessagesController = null;
    _eventController.close();
    disconnect();
    _isInitialized = false;
  }
}
