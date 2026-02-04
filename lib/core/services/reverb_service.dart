import 'package:flutter/foundation.dart';

import 'package:torko/data/models/message_model.dart';

/// No-op realtime adapter. Realtime (Pusher/Reverb) removed.
///
/// Same public API as before so controllers and bindings do not break.
/// - init(userId), disconnect() do nothing and never throw.
/// - onMessageReceived, onInboxMessage are never called.
/// - incomingMessages equivalent: callbacks never fire.
///
/// Realtime receiving is disabled until another service is integrated.
class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  static String channelNameForUser(int userId) => 'private-user.$userId';

  bool get isConnected => false;
  bool get isSubscribed => false;
  int? get currentUserId => null;
  String? get currentChannel => null;

  Function(MessageModel)? onMessageReceived;
  Function(MessageModel)? onInboxMessage;

  void debugPrintConnectionState() {
    if (kDebugMode) {
      debugPrint('[REVERB] Realtime disabled (Pusher removed)');
    }
  }

  Future<void> init({required int userId}) async {
    if (kDebugMode) {
      debugPrint('[REVERB] Realtime disabled (Pusher removed)');
    }
  }

  void clearDeliveredCache() {}

  Future<void> disconnect() async {
    if (kDebugMode) {
      debugPrint('[REVERB] Realtime disabled (Pusher removed)');
    }
  }

  /// Health check: no-op.
  static Future<void> healthCheck() async {
    if (kDebugMode) {
      debugPrint('[REVERB] Realtime disabled (Pusher removed)');
    }
  }
}
