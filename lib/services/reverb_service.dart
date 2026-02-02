import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';

import '../config/realtime_config.dart';
import '../models/message_model.dart';
import 'user_info.dart';

/// Realtime service using Laravel Reverb (Pusher protocol).
///
/// Same public API as before: init(userId), disconnect(), onMessageReceived,
/// onInboxMessage, channelNameForUser. Channel naming and events unchanged:
/// - Channel: private-user.<userId>
/// - Event: message.sent
///
/// Auth: POST to AUTH_ENDPOINT with socket_id, channel_name; backend must
/// accept Authorization: Bearer and return JSON with key "auth" (value:
/// app key and signature). Reverb expects response key "auth" to match app key.
class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  static const String _messageEventName = 'message.sent';

  static String channelNameForUser(int userId) => 'private-user.$userId';

  ReverbClient? _client;
  String? _currentChannel;
  int? _currentUserId;
  bool _connecting = false;
  bool _connected = false;
  bool _subscribed = false;
  final Set<int> _deliveredMessageIds = <int>{};

  bool get isConnected => _connected;
  bool get isSubscribed => _subscribed;
  int? get currentUserId => _currentUserId;
  String? get currentChannel => _currentChannel;

  Function(MessageModel)? onMessageReceived;
  Function(MessageModel)? onInboxMessage;

  void debugPrintConnectionState() {
    if (!kDebugMode) return;
    final socketId = _client?.socketId;
    debugPrint(
      '[REVERB STATE] connected=$_connected subscribed=$_subscribed '
      'user=$_currentUserId channel=$_currentChannel connecting=$_connecting socketId=$socketId',
    );
  }

  /// Authorizer for private channels. Returns headers for the auth request.
  /// Backend must return { "auth": "appKey:signature" }.
  Future<Map<String, String>> _authorizer(String channelName, String socketId) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      if (kDebugMode) debugPrint('[REVERB] Authorizer: token missing');
      throw Exception('Token missing');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Ensure ReverbClient singleton is created with current config.
  ReverbClient _getOrCreateClient() {
    if (_client != null) return _client!;

    if (kDebugMode) {
      RealtimeConfig.logConfig();
      debugPrint('[REVERB] Creating client host=${RealtimeConfig.host} port=${RealtimeConfig.port} useTLS=${RealtimeConfig.useTLS}');
    }

    _client = ReverbClient.instance(
      host: RealtimeConfig.host,
      port: RealtimeConfig.port,
      appKey: RealtimeConfig.appKey,
      useTLS: RealtimeConfig.useTLS,
      authEndpoint: RealtimeConfig.authEndpoint,
      authorizer: _authorizer,
      onConnecting: () {
        if (kDebugMode) debugPrint('[REVERB] Connecting...');
      },
      onConnected: (socketId) {
        _connected = true;
        if (kDebugMode) debugPrint('[REVERB] CONNECTED Socket ID: $socketId');
        _ensureSubscribed();
      },
      onReconnecting: () {
        if (kDebugMode) debugPrint('[REVERB] Reconnecting...');
      },
      onDisconnected: () {
        _connected = false;
        _subscribed = false;
        if (kDebugMode) debugPrint('[REVERB] DISCONNECTED');
      },
      onError: (error) {
        if (kDebugMode) debugPrint('[REVERB] ERROR: $error');
      },
    );
    return _client!;
  }

  Future<void> init({required int userId}) async {
    if (_connecting) {
      if (kDebugMode) debugPrint('[REVERB] init skipped (already connecting)');
      return;
    }
    if (_connected && _subscribed && _currentUserId == userId) {
      debugPrintConnectionState();
      return;
    }

    _connecting = true;
    try {
      if (_currentUserId != null && _currentUserId != userId) {
        await disconnect();
      }

      _currentUserId = userId;
      _currentChannel = channelNameForUser(userId);

      final client = _getOrCreateClient();
      if (!_connected) {
        try {
          await client.connect();
          if (kDebugMode) debugPrint('[REVERB] connect() called');
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint('[REVERB] connect failed: $e');
            debugPrint('[REVERB] stack: $st');
          }
          rethrow;
        }
      } else {
        await _ensureSubscribed();
      }
    } finally {
      _connecting = false;
    }
  }

  Future<void> _ensureSubscribed() async {
    final userId = _currentUserId;
    if (userId == null || _client == null) return;

    final channel = channelNameForUser(userId);
    if (_subscribed && _currentChannel == channel) return;

    if (_currentChannel != null && _currentChannel != channel) {
      try {
        _client!.unsubscribeFromChannel(_currentChannel!);
      } catch (_) {}
      _subscribed = false;
    }

    _currentChannel = channel;

    try {
      final privateChannel = _client!.subscribeToPrivateChannel(channel);
      await privateChannel.subscribe();
      _subscribed = true;
      if (kDebugMode) debugPrint('[REVERB] SUBSCRIBED → $channel');

      privateChannel.bind(_messageEventName, (String eventName, dynamic data) {
        _handleEventData(data);
      });
    } catch (e) {
      _subscribed = false;
      if (kDebugMode) debugPrint('[REVERB] SUBSCRIBE ERROR: $e');
    }
  }

  void _handleEventData(dynamic data) {
    try {
      final String raw = data is String ? data : data?.toString() ?? '{}';
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
      final dynamic inner = map['message'];
      final Map<String, dynamic> rawMap =
          inner is Map ? Map<String, dynamic>.from(inner) : map;

      final message = MessageModel.fromJson(rawMap);

      if (_deliveredMessageIds.contains(message.id)) {
        if (kDebugMode) debugPrint('[REVERB] duplicate dropped id=${message.id}');
        return;
      }
      _deliveredMessageIds.add(message.id);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        try {
          onMessageReceived?.call(message);
          onInboxMessage?.call(message);
          if (kDebugMode) debugPrint('[REVERB] MESSAGE FORWARDED id=${message.id}');
        } catch (e) {
          if (kDebugMode) debugPrint('[REVERB] callback error: $e');
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[REVERB] EVENT PARSE ERROR: $e');
    }
  }

  void clearDeliveredCache() {
    _deliveredMessageIds.clear();
  }

  Future<void> disconnect() async {
    try {
      if (_currentChannel != null && _client != null) {
        try {
          _client!.unsubscribeFromChannel(_currentChannel!);
        } catch (_) {}
      }
      _client?.disconnect();
    } catch (_) {}
    _connected = false;
    _subscribed = false;
    _currentUserId = null;
    _currentChannel = null;
    _deliveredMessageIds.clear();
    if (kDebugMode) debugPrint('[REVERB] DISCONNECTED CLEAN');
  }

  /// Health check: log config and attempt connection (for QA).
  static Future<void> healthCheck() async {
    if (!kDebugMode) return;
    RealtimeConfig.logConfig();
    final userId = UserInfo.userId;
    if (userId == null) {
      debugPrint('[REVERB HEALTH] No userId, skip connect');
      return;
    }
    final svc = ReverbService();
    try {
      await svc.init(userId: userId);
      svc.debugPrintConnectionState();
    } catch (e) {
      debugPrint('[REVERB HEALTH] Connect failed: $e');
    }
  }
}
