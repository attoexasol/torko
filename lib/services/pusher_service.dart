import 'dart:async';
import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

/// Service for managing Pusher real-time connections
/// 
/// Handles connection, subscription, and event streaming for real-time messaging
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  PusherChannel? _currentChannel;
  final StreamController<Map<String, dynamic>> _eventController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  bool _isConnected = false;
  int? _currentUserId;

  // Pusher configuration
  static const String _pusherKey = 'f252ee4951f42b5ce3b5';
  static const String _pusherCluster = 'ap2';
  
  /// Stream of events from Pusher
  Stream<Map<String, dynamic>> get onEventStream => _eventController.stream;

  /// Check if Pusher is connected
  bool get isConnected => _isConnected;

  /// Connect to Pusher and subscribe to user's private channel
  /// 
  /// [currentUserId] - Current user's ID for channel subscription
  /// 
  /// Note: For private channels, backend must provide auth endpoint
  /// Currently uses public channel as fallback (see TODOs below)
  Future<void> connect({required int currentUserId}) async {
    if (_isConnected && _currentUserId == currentUserId) {
      print('DEBUG PusherService: Already connected for user $currentUserId');
      return;
    }

    _currentUserId = currentUserId;

    try {
      // Initialize Pusher instance
      _pusher ??= PusherChannelsFlutter.getInstance();

      // Configure Pusher options
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

      // Connect to Pusher
      await _pusher!.connect();

      // Wait a bit for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));

      // Subscribe to user channel
      await subscribeToUserChannel(currentUserId: currentUserId);

      _isConnected = true;
      print('DEBUG PusherService: Connected to Pusher for user $currentUserId');
    } catch (e) {
      print('DEBUG PusherService: Connection error - $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// Subscribe to user's private channel
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
      // TODO: Replace with private channel once backend provides auth endpoint
      // Private channel: "private-user.$currentUserId"
      // For now, using public channel as fallback
      final channelName = 'user.$currentUserId';
      
      print('DEBUG PusherService: Subscribing to channel: $channelName');

      _currentChannel = await _pusher!.subscribe(
        channelName: channelName,
        onEvent: _onEvent,
      );

      print('DEBUG PusherService: Subscribed to channel: $channelName');
    } catch (e) {
      print('DEBUG PusherService: Subscription error - $e');
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
    print('DEBUG PusherService: Connection state changed: $previousState -> $currentState');
    if (currentState == 'CONNECTED') {
      _isConnected = true;
    } else if (currentState == 'DISCONNECTED' || currentState == 'FAILED') {
      _isConnected = false;
    }
  }

  void _onError(String message, int? code, dynamic e) {
    print('DEBUG PusherService: Error - $message (code: $code)');
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    print('DEBUG PusherService: Subscription succeeded: $channelName');
  }

  void _onEvent(PusherEvent event) {
    print('DEBUG PusherService: Event received - Channel: ${event.channelName}, Event: ${event.eventName}');
    
    try {
      // Parse event data
      Map<String, dynamic> eventData;
      if (event.data is String) {
        eventData = jsonDecode(event.data);
      } else if (event.data is Map) {
        eventData = Map<String, dynamic>.from(event.data);
      } else {
        print('DEBUG PusherService: Unknown event data type: ${event.data.runtimeType}');
        return;
      }

      // Expected event structure:
      // {
      //   "from_user_id": <int>,
      //   "to_user_id": <int>,
      //   "message_content": "<string>",
      //   "id": <int>,
      //   "created_at": "<ISO8601 string>"
      // }
      // 
      // Event name expected: "message.sent" or "App\\Events\\MessageSent" (depends on backend)

      // Forward event to stream
      _eventController.add({
        'eventName': event.eventName,
        'channelName': event.channelName,
        'data': eventData,
      });
    } catch (e) {
      print('DEBUG PusherService: Error parsing event data - $e');
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
  void dispose() {
    _eventController.close();
    disconnect();
  }
}
