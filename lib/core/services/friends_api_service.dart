import 'package:flutter/foundation.dart';
import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/data/models/friend_user.dart';

/// Safe message extraction from API body. Handles message as String or Map.
String _safeMsg(dynamic body, String fallback) {
  if (body == null || body is! Map) return fallback;
  final s = NetworkCaller.extractMessage(body).trim();
  if (s.isEmpty || s == 'Something went wrong' || s == '{}') return fallback;
  return s;
}

/// Exception thrown when friends API fails.
class FriendsApiException implements Exception {
  final String message;
  FriendsApiException(this.message);
}

/// Friends API service - all endpoints use POST with api_token in body.
class FriendsApiService {
  /// Search friends by query. Returns list of FriendSearchItem.
  /// Uses UserInfo.apiToken via postAuth.
  static Future<List<FriendSearchItem>> searchFriends({
    required String query,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final res = await NetworkCaller.postAuth(
      url: Urls.friend_search,
      body: {'search_content': q},
    );

    if (!res.isSuccess) {
      if (kDebugMode) {
        debugPrint('[FriendsSearch] status=${res.statusCode} query=$q results=0');
      }
      throw FriendsApiException(
        res.errorMessage ?? _safeMsg(res.body ?? {}, 'Search failed'),
      );
    }

    final body = res.body ?? {};
    final status = body['status'] == true;

    if (!status) {
      if (kDebugMode) {
        debugPrint('[FriendsSearch] status=${res.statusCode} query=$q results=0');
      }
      final msg = _safeMsg(body, 'Search failed');
      if (msg.isNotEmpty && msg != 'Search failed') {
        throw FriendsApiException(msg);
      }
      return [];
    }

    final data = body['data'];
    if (data == null || data is! List) return [];

    final list = (data as List)
        .map((e) => FriendSearchItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (kDebugMode) {
      debugPrint('[FriendsSearch] status=${res.statusCode} query=$q results=${list.length}');
      for (final item in list) {
        debugPrint('[FriendsSearch] item.id=${item.id} isConnected=${item.isConnected}');
      }
    }

    return list;
  }

  /// Fetch mutual friend suggestions.
  static Future<List<FriendUser>> fetchSuggestions(String token) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.mutual_friend_suggestion,
      body: {},
    );
    if (!res.isSuccess) {
      throw FriendsApiException(
        res.errorMessage ?? 'Failed to load suggestions',
      );
    }
    final body = res.body;
    if (body == null) return [];

    final status = body['status'];
    if (status == false) {
      throw FriendsApiException(
        _safeMsg(body, 'Failed to load suggestions'),
      );
    }

    final data = body['data'];
    if (data == null || data is! List) return [];

    return (data as List)
        .map((e) => FriendUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Fetch friends list.
  static Future<List<FriendUser>> fetchFriends(String token) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.friend_lists,
      body: {},
    );
    if (!res.isSuccess) {
      throw FriendsApiException(
        res.errorMessage ?? 'Failed to load friends',
      );
    }
    final body = res.body;
    if (body == null) return [];

    final status = body['status'];
    if (status == false) {
      throw FriendsApiException(
        _safeMsg(body, 'Failed to load friends'),
      );
    }

    final friends = body['friends'];
    if (friends == null || friends is! List) return [];

    return (friends as List)
        .map((e) => FriendUser.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Fetch pending friend requests.
  static Future<List<FriendRequestItem>> fetchRequests(String token) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.pending_friend_requests,
      body: {},
    );
    if (!res.isSuccess) {
      throw FriendsApiException(
        res.errorMessage ?? 'Failed to load requests',
      );
    }
    final body = res.body;
    if (body == null) return [];

    final status = body['status'];
    if (status == false) {
      throw FriendsApiException(
        _safeMsg(body, 'Failed to load requests'),
      );
    }

    final requests = body['requests'];
    if (requests == null || requests is! List) return [];

    return (requests as List)
        .map((e) =>
            FriendRequestItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Send friend request.
  /// Returns (success, message). If success=false and message contains
  /// "already exists", treat as "Request already exists".
  static Future<(bool success, String message)> sendFriendRequest(
    String token,
    int receiverId,
  ) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.friend_request,
      body: {'receiver_id': receiverId},
    );
    final body = res.body ?? {};
    final status = body['status'] == true;
    final message = _safeMsg(body, res.errorMessage ?? 'Unknown error');
    return (status, message);
  }

  /// Accept friend request.
  static Future<(bool success, String message, FriendUser? data)> acceptRequest(
    String token,
    int requestId,
  ) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.accept_friend_request,
      body: {'request_id': requestId},
    );
    final body = res.body ?? {};
    final status = body['status'] == true;
    final message = _safeMsg(body, res.errorMessage ?? 'Unknown error');

    FriendUser? user;
    final data = body['data'];
    if (data != null && data is Map<String, dynamic>) {
      user = FriendUser.fromJson(data);
    }
    return (status, message, user);
  }

  /// Fetch pending outgoing (sent) friend requests.
  /// Alias: fetchSentFriendRequests.
  static Future<List<FriendRequestItem>> fetchPendingOutgoingRequests(
    String token,
  ) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.pending_friend_requests,
      body: {},
    );

    if (kDebugMode) {
      debugPrint('[Sent][API] statusCode=${res.statusCode}');
      debugPrint('[Sent][API] body=${res.body}');
      final body = res.body;
      if (body != null && body is Map) {
        debugPrint('[Sent][API] keys=${body.keys.toList()}');
        final reqs = body['requests'];
        debugPrint('[Sent][API] requestsType=${reqs?.runtimeType}');
        debugPrint('[Sent][API] requestsLen=${reqs is List ? reqs.length : "N/A"}');
      }
    }

    if (!res.isSuccess) {
      throw FriendsApiException(
        res.errorMessage ?? 'Failed to load sent requests',
      );
    }
    final body = res.body;
    if (body == null) {
      if (kDebugMode) debugPrint('[Sent] ERROR: body is null');
      return [];
    }

    final status = body['status'];
    if (status != true) {
      if (kDebugMode) debugPrint('[Sent] ERROR: status not true OR \'requests\' missing');
      throw FriendsApiException(
        _safeMsg(body, 'Failed to load sent requests'),
      );
    }

    final requests = body['requests'];
    if (requests == null || requests is! List) {
      if (kDebugMode) debugPrint('[Sent] ERROR: requests missing or not a list');
      return [];
    }

    return (requests as List)
        .map((e) =>
            FriendRequestItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Cancel a sent friend request.
  static Future<(bool success, String message)> cancelSentRequest(
    String token,
    int requestId,
  ) async {
    const _cancelUrl = 'https://torko.attoexasolutions.com/api/friend/cancel-or-delete';
    final res = await NetworkCaller.postAuth(
      url: _cancelUrl,
      body: {'request_id': requestId},
    );
    final body = res.body ?? {};
    final status = body['status'] == true;
    final message = _safeMsg(body, res.errorMessage ?? 'Unknown error');
    return (status, message);
  }

  /// Reject friend request.
  static Future<(bool success, String message)> rejectRequest(
    String token,
    int requestId,
  ) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.reject_friend_reject,
      body: {'request_id': requestId},
    );
    final body = res.body ?? {};
    final status = body['status'] == true;
    final message = _safeMsg(body, res.errorMessage ?? 'Unknown error');
    return (status, message);
  }
}
