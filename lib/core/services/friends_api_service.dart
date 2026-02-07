import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/data/models/friend_user.dart';

/// Exception thrown when friends API fails.
class FriendsApiException implements Exception {
  final String message;
  FriendsApiException(this.message);
}

/// Friends API service - all endpoints use POST with api_token in body.
class FriendsApiService {
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
        body['message']?.toString() ?? 'Failed to load suggestions',
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
        body['message']?.toString() ?? 'Failed to load friends',
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
        body['message']?.toString() ?? 'Failed to load requests',
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
    final message =
        body['message']?.toString() ?? (res.errorMessage ?? 'Unknown error');
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
    final message =
        body['message']?.toString() ?? (res.errorMessage ?? 'Unknown error');

    FriendUser? user;
    final data = body['data'];
    if (data != null && data is Map<String, dynamic>) {
      user = FriendUser.fromJson(data);
    }
    return (status, message, user);
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
    final message =
        body['message']?.toString() ?? (res.errorMessage ?? 'Unknown error');
    return (status, message);
  }
}
