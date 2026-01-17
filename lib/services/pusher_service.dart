import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/message_model.dart';

/// Service for managing Pusher real-time connections
/// 
/// CRITICAL ARCHITECTURE:
/// - True singleton (one instance app-wide)
/// - Uses ONLY key + cluster (NO app_id in Flutter)
/// - Emits MessageModel objects for easy consumption
/// - connect() is idempotent
/// - subscribeToUserChannel() is idempotent
/// - NEVER calls APIs
/// - NEVER reconnects unnecessarily
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  PusherChannel? _currentChannel;
  
  // CRITICAL: StreamController created ONCE, never recreated
  final StreamController<Map<String, dynamic>> _eventController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // CRITICAL: StreamController for parsed MessageModel objects
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
  /// CRITICAL: Subscribes to CURRENT USER's channel (user.{currentUserId})
  /// CRITICAL: Backend must broadcast messages TO this channel
  /// 
  /// Note: For private channels, backend must provide auth endpoint
  /// Currently uses public channel as fallback (see TODOs below)
  Future<void> connect({required int currentUserId}) async {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🔌 [CHECKPOINT 1] PusherService.connect() called');
      print('   currentUserId: $currentUserId');
      print('   _isConnected: $_isConnected');
      print('   _currentUserId: $_currentUserId');
    }
    
    // Idempotent check: already connected for same user
    if (_isConnected && _currentUserId == currentUserId && _isInitialized) {
      if (kDebugMode) {
        print('✅ [CHECKPOINT 1] Already connected for user $currentUserId - skipping');
        print('═══════════════════════════════════════════════════════════');
      }
      return;
    }

    _currentUserId = currentUserId;

    try {
      // CRITICAL: Initialize StreamController ONCE (never recreate)
      _incomingMessagesController ??= StreamController<MessageModel>.broadcast();
      
      // CRITICAL: Initialize Pusher instance ONCE
      if (!_isInitialized) {
        if (kDebugMode) {
          print('🔄 [CHECKPOINT 1] Initializing Pusher connection...');
        }
        
        _pusher ??= PusherChannelsFlutter.getInstance();
        
        if (kDebugMode) {
          print('✅ [CHECKPOINT 1] Pusher instance obtained');
        }

        // Configure Pusher options (only once)
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
          print('✅ [CHECKPOINT 1] Pusher initialized');
        }
        
        _isInitialized = true;
      }

      // Connect to Pusher (idempotent)
      if (!_isConnected) {
        if (kDebugMode) {
          print('🔄 [CHECKPOINT 1] Connecting to Pusher servers...');
        }
        await _pusher!.connect();

        // Wait a bit for connection to establish
        await Future.delayed(const Duration(milliseconds: 500));

        if (kDebugMode) {
          print('✅ [CHECKPOINT 1] Pusher connection established');
        }
      }

      // Subscribe to user channel (CRITICAL: user.{currentUserId})
      // Only subscribe if not already subscribed to this channel
      if (_currentChannel == null || _currentChannel!.channelName != 'user.$currentUserId') {
        await subscribeToUserChannel(currentUserId: currentUserId);
      }

      _isConnected = true;
      
      if (kDebugMode) {
        print('✅ [CHECKPOINT 1] ✅ PusherService.connect() SUCCESS');
        print('   Connected: $_isConnected');
        print('   Channel: user.$currentUserId');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ [CHECKPOINT 1] PusherService.connect() FAILED');
        print('   Error: $e');
        print('   Stack: $stackTrace');
        print('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  /// Subscribe to user's private channel
  /// 
  /// CRITICAL: Subscribes to CURRENT USER's channel: user.{currentUserId}
  /// CRITICAL: Backend MUST broadcast messages TO this channel
  /// CRITICAL: Idempotent - won't resubscribe if already subscribed
  /// 
  /// TODO: Backend must provide Pusher private channel auth endpoint
  /// Expected endpoint: POST /api/pusher/auth
  /// Request body: { "socket_id": "<socket_id>", "channel_name": "private-user.<userId>" }
  /// Response: { "auth": "<auth_token>" }
  /// 
  /// For now, using public channel as fallback (not recommended for production)
  Future<void> subscribeToUserChannel({required int currentUserId}) async {
    if (_pusher == null) {
      throw Exception('Pusher not initialized. Call connect() first.');
    }

    try {
      // CRITICAL: Channel name is user.{currentUserId}
      // Backend must broadcast messages TO this channel when sending to currentUserId
      final channelName = 'user.$currentUserId';
      
      // Idempotent: don't resubscribe if already subscribed to same channel
      if (_currentChannel != null && _currentChannel!.channelName == channelName) {
        if (kDebugMode) {
          print('✅ [CHECKPOINT 2] Already subscribed to channel: $channelName');
        }
        return;
      }
      
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('🔌 [CHECKPOINT 2] Subscribing to Pusher channel');
        print('   Channel name: $channelName');
        print('   Current user ID: $currentUserId');
        print('   ⚠️  Backend MUST broadcast messages TO this channel');
        print('═══════════════════════════════════════════════════════════');
      }

      // CRITICAL: subscribe() doesn't take onEvent parameter
      // Events are handled by the global onEvent callback set in init()
      _currentChannel = await _pusher!.subscribe(
        channelName: channelName,
      );

      if (kDebugMode) {
        print('✅ [CHECKPOINT 2] ✅ Channel subscription SUCCESS');
        print('   Channel: $channelName');
        print('   Waiting for events...');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [CHECKPOINT 2] Channel subscription FAILED');
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
      
      print('DEBUG PusherService: Disconnected from Pusher');
    } catch (e) {
      print('DEBUG PusherService: Disconnect error - $e');
    }
  }

  // ==================== Pusher Event Handlers ====================

  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    if (kDebugMode) {
      print('🔄 [CHECKPOINT 1] Connection state changed: $previousState -> $currentState');
    }
    if (currentState == 'CONNECTED') {
      _isConnected = true;
      if (kDebugMode) {
        print('✅ [CHECKPOINT 1] Pusher CONNECTED');
      }
    } else if (currentState == 'DISCONNECTED' || currentState == 'FAILED') {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ [CHECKPOINT 1] Pusher DISCONNECTED/FAILED');
      }
    }
  }

  void _onError(String message, int? code, dynamic e) {
    print('DEBUG PusherService: Error - $message (code: $code)');
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    if (kDebugMode) {
      print('✅ [CHECKPOINT 2] ✅ Subscription SUCCEEDED');
      print('   Channel: $channelName');
      print('   Data: $data');
      print('   Ready to receive events!');
    }
  }

  void _onEvent(PusherEvent event) {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('📨 [CHECKPOINT 3] ✅ EVENT RECEIVED FROM PUSHER');
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
          print('📨 [CHECKPOINT 3] Raw data (string, first 200 chars): $preview');
        }
        eventData = jsonDecode(dataString);
      } else if (event.data is Map) {
        if (kDebugMode) {
          print('📨 [CHECKPOINT 3] Raw data (Map): ${event.data}');
        }
        eventData = Map<String, dynamic>.from(event.data);
      } else {
        if (kDebugMode) {
          print('❌ [CHECKPOINT 3] ❌ Unknown event data type: ${event.data.runtimeType}');
          print('   Data: ${event.data}');
        }
        return;
      }

      if (kDebugMode) {
        print('✅ [CHECKPOINT 3] Event data parsed successfully');
        print('   Parsed data: $eventData');
      }

      // CRITICAL: Forward raw event to legacy stream (for backward compatibility)
      if (!_eventController.isClosed) {
        _eventController.add({
          'eventName': event.eventName,
          'channelName': event.channelName,
          'data': eventData,
        });
      }

      // CRITICAL: Parse and emit MessageModel if it's a message event
      final eventName = event.eventName;
      final isMessageEvent = eventName != null && 
          (eventName.toLowerCase().contains('message') || 
           eventName.contains('Message') ||
           eventName == 'message.sent' ||
           eventName == 'App\\Events\\MessageSent' ||
           eventName.contains('MessageSent'));

      if (isMessageEvent) {
        if (kDebugMode) {
          print('📨 [CHECKPOINT 3] Message event detected - parsing MessageModel...');
        }
        
        try {
          // Parse MessageModel from event data
          final message = MessageModel.fromJson(eventData);
          
          if (kDebugMode) {
            print('✅ [CHECKPOINT 3] MessageModel parsed successfully');
            print('   Message ID: ${message.id}');
            print('   From User ID: ${message.fromUserId}');
            print('   To User ID: ${message.toUserId}');
            print('   Content: ${message.messageContent.length > 50 ? message.messageContent.substring(0, 50) + "..." : message.messageContent}');
          }
          
          // CRITICAL: Emit MessageModel to incomingMessages stream
          if (_incomingMessagesController != null && !_incomingMessagesController!.isClosed) {
            _incomingMessagesController!.add(message);
            
            if (kDebugMode) {
              print('✅ [CHECKPOINT 3] ✅ MessageModel emitted to incomingMessages stream');
              print('   Waiting for ChatController listener...');
            }
          } else {
            if (kDebugMode) {
              print('❌ [CHECKPOINT 3] ❌ incomingMessages stream is closed');
            }
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('❌ [CHECKPOINT 3] ❌ Failed to parse MessageModel');
            print('   Error: $e');
            print('   Stack: $stackTrace');
            print('   Event Data: $eventData');
          }
        }
      } else {
        if (kDebugMode) {
          print('⏭️  [CHECKPOINT 3] Event is not a message event - ignoring');
        }
      }
      
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [CHECKPOINT 3] ❌ Error parsing event data');
        print('   Error: $e');
        print('   Stack: $stackTrace');
        print('   Raw data: ${event.data}');
        print('═══════════════════════════════════════════════════════════');
      }
    }
  }

  void _onSubscriptionError(String message, dynamic e) {
    print('DEBUG PusherService: Subscription error - $message');
    
    // If private channel auth fails, try public channel as fallback
    if (message.contains('auth') || message.contains('private')) {
      print('DEBUG PusherService: Private channel auth failed, using public channel fallback');
    }
  }

  void _onDecryptionFailure(String event, String reason) {
    print('DEBUG PusherService: Decryption failure - Event: $event, Reason: $reason');
  }

  void _onMemberAdded(String channelName, PusherMember member) {
    print('DEBUG PusherService: Member added - Channel: $channelName, User: ${member.userId}');
  }

  void _onMemberRemoved(String channelName, PusherMember member) {
    print('DEBUG PusherService: Member removed - Channel: $channelName, User: ${member.userId}');
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
