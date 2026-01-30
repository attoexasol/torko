import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/message_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import '../services/user_info.dart';

/// Singleton PusherService – real-time messaging lifecycle.
/// Protocol: private channel "private-user.{userId}", event "message.sent",
/// auth via POST /api/broadcasting/auth (Bearer + body socket_id, channel_name).
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  PusherChannel? _channel;
  String? _currentChannelName;

  StreamController<MessageModel> _controller =
      StreamController<MessageModel>.broadcast();

  bool _initialized = false;
  bool _connected = false;
  int? _currentUserId;

  bool _initializing = false;
  bool _disconnecting = false;

  static const String _pusherKey = '9df09725d514e737df9a';
  static const String _pusherCluster = 'ap2';

  /// Channel name per protocol: Laravel PrivateChannel('user.{id}') → private-user.{id}
  static String channelNameForUser(int userId) => 'private-user.$userId';

  Stream<MessageModel> get stream => _controller.stream;
  Stream<MessageModel> get incomingMessages => stream;
  Stream<MessageModel> get messagesStream => stream;

  bool get isConnected => _connected;
  int? get currentUserId => _currentUserId;
  String? get currentChannelName => _currentChannelName;

  /// Debug helper: print connection state and subscribed channel.
  void debugPrintConnectionState() {
    if (!kDebugMode) return;
    debugPrint('[PUSHER] debug state: connected=$_connected userId=$_currentUserId '
        'channel=$_currentChannelName initializing=$_initializing disconnecting=$_disconnecting');
  }

  Future<void> init({required int userId}) async {
    if (_initializing) {
      if (kDebugMode) debugPrint('[PUSHER] init skipped: already initializing');
      return;
    }
    if (_connected && _currentUserId == userId) {
      if (kDebugMode) debugPrint('[PUSHER] init skipped: already connected for user $userId');
      return;
    }

    _initializing = true;
    if (kDebugMode) debugPrint('[PUSHER] init start for userId=$userId');

    try {
      if (_connected || _initialized) {
        if (kDebugMode) debugPrint('[PUSHER] init: disconnecting previous (userId=$_currentUserId)');
        await disconnect();
      }

      _currentUserId = userId;
      _pusher = PusherChannelsFlutter.getInstance();

      await _pusher!.init(
        apiKey: _pusherKey,
        cluster: _pusherCluster,
        onAuthorizer: _onAuthorizer,
        onConnectionStateChange: (currentState, previousState) {
          final stateStr = currentState.toString();
          final u = stateStr.toUpperCase();
          final isConn = u.contains('CONNECTED') && !u.contains('CONNECTING');
          final isDisc = u.contains('DISCONNECTED') || u.contains('FAILED');

          if (isConn) {
            _connected = true;
            if (kDebugMode) debugPrint('[PUSHER] connection state: CONNECTED (userId=$_currentUserId)');
            _subscribe(userId);
          } else {
            _connected = false;
            if (kDebugMode) {
              if (isDisc) debugPrint('[PUSHER] connection state: DISCONNECTED/FAILED ($stateStr)');
              else debugPrint('[PUSHER] connection state: $stateStr');
            }
          }
        },
        onError: (message, code, error) {
          if (kDebugMode) debugPrint('[PUSHER] error: $message (code: $code)');
        },
        onSubscriptionSucceeded: (channelName, data) {
          if (kDebugMode) debugPrint('[PUSHER] subscribe success: $channelName');
        },
        onEvent: (event) {
          if (event.eventName != 'message.sent') return;
          if (kDebugMode) debugPrint('[PUSHER] event received: message.sent');
          _handleEvent(event);
        },
        onSubscriptionError: (message, error) {
          if (kDebugMode) debugPrint('[PUSHER] subscribe error: $message');
        },
      );

      await _pusher!.connect();
      if (kDebugMode) debugPrint('[PUSHER] connect() called');
      await Future.delayed(const Duration(seconds: 1));

      _initialized = true;
      if (kDebugMode) debugPrint('[PUSHER] init end for userId=$userId');
    } catch (e) {
      _initialized = false;
      _connected = false;
      _currentUserId = null;
      _currentChannelName = null;
      if (kDebugMode) debugPrint('[PUSHER] init error: $e');
      rethrow;
    } finally {
      _initializing = false;
    }
  }

  Future<void> _subscribe(int userId) async {
    _currentChannelName = channelNameForUser(userId);
    if (kDebugMode) debugPrint('[PUSHER] subscribing to $_currentChannelName');
    try {
      _channel = await _pusher!.subscribe(channelName: _currentChannelName!);
      if (kDebugMode) debugPrint('[PUSHER] subscribed to $_currentChannelName');
    } catch (e) {
      _currentChannelName = null;
      if (kDebugMode) debugPrint('[PUSHER] subscribe error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    if (kDebugMode) {
      debugPrint('[PUSHER] auth request channel=$channelName socketId=${socketId.length > 12 ? '${socketId.substring(0, 12)}...' : socketId}');
    }
    try {
      final token = UserInfo.apiToken;
      if (token == null || token.isEmpty) {
        if (kDebugMode) debugPrint('[PUSHER] auth failed: no token');
        throw Exception('No API token');
      }
      final response = await NetworkCaller.postBroadcastingAuth(
        url: Urls.pusher_auth,
        socketId: socketId,
        channelName: channelName,
      );
      if (!response.isSuccess) {
        if (kDebugMode) debugPrint('[PUSHER] auth response status: ${response.statusCode} ${response.errorMessage}');
        throw Exception('Auth failed: ${response.errorMessage ?? 'Unknown'}');
      }
      final body = response.body;
      if (body == null) {
        if (kDebugMode) debugPrint('[PUSHER] auth response: null body');
        throw Exception('Invalid auth response: null body');
      }
      final auth = body['auth'] as String?;
      if (auth == null || auth.isEmpty) {
        if (kDebugMode) debugPrint('[PUSHER] auth response: missing auth field');
        throw Exception('Invalid auth response: missing auth field');
      }
      if (kDebugMode) debugPrint('[PUSHER] auth success: $channelName');
      return {'auth': auth};
    } catch (e) {
      if (kDebugMode) debugPrint('[PUSHER] auth failed: $e');
      rethrow;
    }
  }

  void _handleEvent(PusherEvent event) {
    try {
      Map<String, dynamic> raw;
      if (event.data is String) {
        raw = jsonDecode(event.data as String) as Map<String, dynamic>;
      } else if (event.data is Map) {
        raw = Map<String, dynamic>.from(event.data as Map);
      } else {
        if (kDebugMode) debugPrint('[PUSHER] parse error: invalid event data type ${event.data.runtimeType}');
        return;
      }

      // Protocol: flat JSON. Unwrap data/message only if root lacks id/from_user_id.
      Map<String, dynamic> payload = raw;
      if (!raw.containsKey('id') || !raw.containsKey('from_user_id')) {
        if (raw.containsKey('data') && raw['data'] is Map) {
          payload = Map<String, dynamic>.from(raw['data'] as Map);
        } else if (raw.containsKey('message') && raw['message'] is Map) {
          payload = Map<String, dynamic>.from(raw['message'] as Map);
        }
      }
      if (!payload.containsKey('id') || !payload.containsKey('from_user_id')) {
        if (kDebugMode) debugPrint('[PUSHER] parse error: payload missing id/from_user_id raw=$raw');
        return;
      }

      final message = MessageModel.fromJson(payload);
      _controller.add(message);
      if (kDebugMode) {
        debugPrint('[PUSHER] event received | id=${message.id} from=${message.fromUserId} to=${message.toUserId}');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PUSHER] payload parse error: $e');
        debugPrint('[PUSHER] raw event.data: ${event.data}');
        debugPrint('[PUSHER] stack: $st');
      }
    }
  }

  Future<void> disconnect() async {
    if (_disconnecting) {
      if (kDebugMode) debugPrint('[PUSHER] disconnect skipped: already disconnecting');
      return;
    }
    if (!_initialized && _channel == null && _pusher == null && _currentChannelName == null) {
      if (kDebugMode) debugPrint('[PUSHER] disconnect skipped: already disconnected');
      return;
    }

    _disconnecting = true;
    final prevUserId = _currentUserId;
    if (kDebugMode) debugPrint('[PUSHER] disconnecting (userId=$prevUserId)');

    try {
      if (_currentChannelName != null && _pusher != null) {
        try {
          if (kDebugMode) debugPrint('[PUSHER] unsubscribing from $_currentChannelName');
          await _pusher!.unsubscribe(channelName: _currentChannelName!);
          if (kDebugMode) debugPrint('[PUSHER] unsubscribed from $_currentChannelName');
        } catch (e) {
          if (kDebugMode) debugPrint('[PUSHER] unsubscribe error: $e');
        }
        _channel = null;
        _currentChannelName = null;
      }
      if (_pusher != null) {
        try {
          await _pusher!.disconnect();
        } catch (e) {
          if (kDebugMode) debugPrint('[PUSHER] disconnect error: $e');
        }
        _pusher = null;
      }
      _initialized = false;
      _connected = false;
      _currentUserId = null;
      _currentChannelName = null;
      if (kDebugMode) debugPrint('[PUSHER] disconnected (was userId=$prevUserId)');
    } finally {
      _disconnecting = false;
    }
  }

  void dispose() {
    _controller.close();
    disconnect();
    _initialized = false;
    _connected = false;
    _currentUserId = null;
    _currentChannelName = null;
  }
}
