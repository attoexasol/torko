import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../models/message_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import '../services/user_info.dart';

/// PUSHER SERVICE (FIXED + PRODUCTION-SAFE)
///
/// Goals:
/// ✅ Singleton (1 connection only)
/// ✅ Subscribe exactly once per login/user
/// ✅ No duplicate subscriptions / no duplicate event forwarding
/// ✅ Safe reconnect + safe user switch
/// ✅ Robust event parsing (Laravel style / top-level)
/// ✅ Main-thread delivery for GetX UI
///
/// IMPORTANT:
/// - Call init(userId) ONCE after login (e.g., AppController after token set)
/// - Call disconnect() on logout
class PusherService {
  // =========================
  // Singleton
  // =========================
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  // =========================
  // CONFIG
  // =========================
  static const String _pusherKey = '9df09725d514e737df9a';
  static const String _pusherCluster = 'ap2';
  static const String _messageEventName = 'message.sent';

  static String channelNameForUser(int userId) => 'private-user.$userId';

  // =========================
  // Internal State
  // =========================
  PusherChannelsFlutter? _pusher;

  String? _currentChannel;
  int? _currentUserId;

  bool _connecting = false;
  bool _initialized = false; // pusher.init done at least once
  bool _connected = false;
  bool _subscribed = false;

  /// Prevent duplicate delivery (Pusher reconnect / same event received twice)
  final Set<int> _deliveredMessageIds = <int>{};

  // =========================
  // PUBLIC GETTERS
  // =========================
  bool get isConnected => _connected;
  bool get isSubscribed => _subscribed;
  int? get currentUserId => _currentUserId;
  String? get currentChannel => _currentChannel;

  // =========================
  // CALLBACKS
  // =========================
  Function(MessageModel)? onMessageReceived; // Chat
  Function(MessageModel)? onInboxMessage; // Inbox

  // =========================
  // DEBUG
  // =========================
  void debugPrintConnectionState() {
    if (!kDebugMode) return;
    debugPrint(
      '[PUSHER STATE] init=$_initialized connected=$_connected subscribed=$_subscribed '
      'user=$_currentUserId channel=$_currentChannel connecting=$_connecting',
    );
  }

  // =========================
  // INIT (CALL ONCE AFTER LOGIN)
  // =========================
  Future<void> init({required int userId}) async {
    if (_connecting) {
      if (kDebugMode) debugPrint('[PUSHER] init skipped (already connecting)');
      return;
    }

    // Already connected & subscribed to same user
    if (_connected && _subscribed && _currentUserId == userId) {
      debugPrintConnectionState();
      return;
    }

    _connecting = true;

    try {
      // If switching user or stale state -> full reset
      if (_currentUserId != null && _currentUserId != userId) {
        await disconnect();
      }

      _currentUserId = userId;
      _currentChannel = channelNameForUser(userId);

      _pusher ??= PusherChannelsFlutter.getInstance();

      // Init only once per app lifecycle (plugin init can be expensive)
      if (!_initialized) {
        await _pusher!.init(
          apiKey: _pusherKey,
          cluster: _pusherCluster,
          onAuthorizer: _authorizeChannel,
          onConnectionStateChange: _onConnectionStateChange,
          onEvent: _onEvent,
          onError: (message, code, error) {
            if (kDebugMode) {
              debugPrint('[PUSHER] ERROR($code): $message | $error');
            }
          },
        );
        _initialized = true;
      }

      // Connect (safe to call if already connected, but we guard anyway)
      if (!_connected) {
        await _pusher!.connect();
        if (kDebugMode) debugPrint('[PUSHER] connect() called');
      } else {
        // If connected but not subscribed (edge case), force subscribe
        await _ensureSubscribed();
      }
    } finally {
      _connecting = false;
    }
  }

  // =========================
  // CONNECTION STATE
  // =========================
  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    final state = currentState.toString().toUpperCase();

    if (state.contains('CONNECTED')) {
      _connected = true;

      if (kDebugMode) debugPrint('[PUSHER] CONNECTED');

      // Subscribe once connection is up
      _ensureSubscribed();
      return;
    }

    if (state.contains('DISCONNECTED') || state.contains('FAILED')) {
      _connected = false;
      _subscribed = false;

      if (kDebugMode) debugPrint('[PUSHER] DISCONNECTED/FAILED');

      return;
    }
  }

  // =========================
  // SUBSCRIBE (IDEMPOTENT)
  // =========================
  Future<void> _ensureSubscribed() async {
    final userId = _currentUserId;
    if (userId == null) return;

    final channel = channelNameForUser(userId);

    // already subscribed to the same channel
    if (_subscribed && _currentChannel == channel) {
      return;
    }

    // if subscribed to some other channel (shouldn't happen often), unsubscribe first
    if (_currentChannel != null && _currentChannel != channel) {
      try {
        await _pusher?.unsubscribe(channelName: _currentChannel!);
      } catch (_) {}
      _subscribed = false;
    }

    _currentChannel = channel;

    try {
      await _pusher?.subscribe(channelName: channel);
      _subscribed = true;

      if (kDebugMode) debugPrint('[PUSHER] SUBSCRIBED → $channel');
    } catch (e) {
      _subscribed = false;
      if (kDebugMode) debugPrint('[PUSHER] SUBSCRIBE ERROR: $e');
    }
  }

  // =========================
  // AUTHORIZATION
  // =========================
  Future<Map<String, dynamic>> _authorizeChannel(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      throw Exception('Token missing');
    }

    final response = await NetworkCaller.postBroadcastingAuth(
      url: Urls.pusher_auth,
      socketId: socketId,
      channelName: channelName,
    );

    if (!response.isSuccess || response.body == null) {
      throw Exception('Pusher auth failed');
    }

    final Map<String, dynamic> body = Map<String, dynamic>.from(response.body!);
    final auth = body['auth'];

    if (auth == null) {
      throw Exception('Invalid auth response');
    }

    return {'auth': auth};
  }

  // =========================
  // EVENT ROUTER
  // =========================
  void _onEvent(PusherEvent event) {
    if (event.eventName != _messageEventName) return;
    _handleIncomingEvent(event);
  }

  // =========================
  // EVENT HANDLER (ROBUST)
  // =========================
  void _handleIncomingEvent(PusherEvent event) {
    try {
      final dynamic decoded = jsonDecode(event.data as String);

      if (decoded is! Map) return;

      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

      // Laravel broadcast often wraps inside { message: {...} }
      final dynamic inner = data['message'];
      final Map<String, dynamic> raw = inner is Map
          ? Map<String, dynamic>.from(inner)
          : data;

      final message = MessageModel.fromJson(raw);

      // Dedupe at service level (helps when reconnect duplicates happen)
      if (_deliveredMessageIds.contains(message.id)) {
        if (kDebugMode)
          debugPrint('[PUSHER] duplicate dropped id=${message.id}');
        return;
      }
      _deliveredMessageIds.add(message.id);

      // Deliver on UI frame to avoid GetX update during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        try {
          onMessageReceived?.call(message);
          onInboxMessage?.call(message);

          if (kDebugMode) {
            debugPrint('[PUSHER] MESSAGE FORWARDED id=${message.id}');
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[PUSHER] callback error: $e');
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[PUSHER] EVENT PARSE ERROR: $e');
    }
  }

  // =========================
  // RESET DEDUPE CACHE (OPTIONAL)
  // =========================
  void clearDeliveredCache() {
    _deliveredMessageIds.clear();
  }

  // =========================
  // DISCONNECT (LOGOUT)
  // =========================
  Future<void> disconnect() async {
    try {
      if (_currentChannel != null) {
        try {
          await _pusher?.unsubscribe(channelName: _currentChannel!);
        } catch (_) {}
      }

      try {
        await _pusher?.disconnect();
      } catch (_) {}
    } finally {
      _connected = false;
      _subscribed = false;

      _currentUserId = null;
      _currentChannel = null;

      _deliveredMessageIds.clear();

      if (kDebugMode) debugPrint('[PUSHER] DISCONNECTED CLEAN');
    }
  }
}
