import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Friend user model
class FriendUser {
  final String id;
  final String name;
  final String username;
  final String? location;
  final int? mutualFriends;
  final bool isOnline;
  final String? bio;
  final String? avatar;

  FriendUser({
    required this.id,
    required this.name,
    required this.username,
    this.location,
    this.mutualFriends,
    this.isOnline = false,
    this.bio,
    this.avatar,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'location': location,
        'mutualFriends': mutualFriends,
        'isOnline': isOnline,
        'bio': bio,
        'avatar': avatar,
      };

  factory FriendUser.fromJson(Map<String, dynamic> json) => FriendUser(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        location: json['location']?.toString(),
        mutualFriends: json['mutualFriends'] is int
            ? json['mutualFriends'] as int
            : (json['mutualFriends'] is String
                ? int.tryParse(json['mutualFriends'] as String)
                : null),
        isOnline: json['isOnline'] == true || json['isOnline'] == 1,
        bio: json['bio']?.toString(),
        avatar: json['avatar']?.toString(),
      );
}

/// Friend request model
class FriendRequest {
  final String id;
  final FriendUser from;
  final DateTime timestamp;
  final String status; // 'pending' | 'accepted' | 'declined'

  FriendRequest({
    required this.id,
    required this.from,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
        id: json['id']?.toString() ?? '',
        from: FriendUser.fromJson(json['from'] as Map<String, dynamic>),
        timestamp: json['timestamp'] is String
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        status: json['status']?.toString() ?? 'pending',
      );
}

/// Controller for managing friends, friend requests, and sent requests
class FriendsController extends GetxController {
  static const String _friendsKey = 'torko_friends';
  static const String _friendRequestsKey = 'torko_friend_requests';
  static const String _sentRequestsKey = 'torko_sent_requests';

  final _storage = GetStorage();

  final RxList<FriendUser> friends = <FriendUser>[].obs;
  final RxList<FriendRequest> friendRequests = <FriendRequest>[].obs;
  final RxList<FriendRequest> sentRequests = <FriendRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    try {
      // Load friends
      final friendsData = _storage.read(_friendsKey);
      if (friendsData is List) {
        friends.value = friendsData
            .map((e) => FriendUser.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Load friend requests
      final requestsData = _storage.read(_friendRequestsKey);
      if (requestsData is List) {
        friendRequests.value = requestsData
            .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Load sent requests
      final sentData = _storage.read(_sentRequestsKey);
      if (sentData is List) {
        sentRequests.value = sentData
            .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('FriendsController._loadFromStorage error: $e');
    }
  }

  void _saveFriends() {
    _storage.write(_friendsKey, friends.map((f) => f.toJson()).toList());
  }

  void _saveFriendRequests() {
    _storage.write(
        _friendRequestsKey, friendRequests.map((r) => r.toJson()).toList());
  }

  void _saveSentRequests() {
    _storage.write(
        _sentRequestsKey, sentRequests.map((r) => r.toJson()).toList());
  }

  int get pendingCount =>
      friendRequests.where((r) => r.status == 'pending').length;

  List<FriendRequest> get pendingRequests =>
      friendRequests.where((r) => r.status == 'pending').toList();

  List<FriendRequest> get pendingSentRequests =>
      sentRequests.where((r) => r.status == 'pending').toList();

  void acceptFriendRequest(String requestId) {
    final request = friendRequests.firstWhereOrNull((r) => r.id == requestId);
    if (request == null) return;

    // Add to friends
    friends.add(request.from);
    _saveFriends();

    // Remove from requests
    friendRequests.removeWhere((r) => r.id == requestId);
    _saveFriendRequests();

    if (kDebugMode) print('FriendsController: Accepted request $requestId');
  }

  void declineFriendRequest(String requestId) {
    friendRequests.removeWhere((r) => r.id == requestId);
    _saveFriendRequests();

    if (kDebugMode) print('FriendsController: Declined request $requestId');
  }

  void cancelFriendRequest(String requestId) {
    sentRequests.removeWhere((r) => r.id == requestId);
    _saveSentRequests();

    if (kDebugMode) print('FriendsController: Cancelled sent request $requestId');
  }

  void removeFriend(String friendId) {
    friends.removeWhere((f) => f.id == friendId);
    _saveFriends();

    if (kDebugMode) print('FriendsController: Removed friend $friendId');
  }

  void sendFriendRequest(String userId, FriendUser userObject) {
    // Check if already sent
    if (hasSentRequest(userId)) return;

    final request = FriendRequest(
      id: 'sent_${DateTime.now().millisecondsSinceEpoch}_${userId}',
      from: userObject,
      timestamp: DateTime.now(),
      status: 'pending',
    );

    sentRequests.add(request);
    _saveSentRequests();

    if (kDebugMode) print('FriendsController: Sent request to $userId');
  }

  bool isFriend(String userId) => friends.any((f) => f.id == userId);

  bool hasSentRequest(String userId) =>
      sentRequests.any((r) => r.from.id == userId && r.status == 'pending');

  /// Add demo friend requests (for testing)
  void addDemoFriendRequests() {
    final demoUsers = [
      FriendUser(
        id: 'demo_1',
        name: 'শাহরিয়ার কবির',
        username: 'shahriar_kabir',
        location: 'ঢাকা, বাংলাদেশ',
        mutualFriends: 5,
        isOnline: true,
      ),
      FriendUser(
        id: 'demo_2',
        name: 'তাসনিম আহমেদ',
        username: 'tasnim_ahmed',
        location: 'চট্টগ্রাম, বাংলাদেশ',
        mutualFriends: 3,
        isOnline: false,
      ),
      FriendUser(
        id: 'demo_3',
        name: 'নাদিয়া খান',
        username: 'nadia_khan',
        location: 'সিলেট, বাংলাদেশ',
        mutualFriends: 8,
        isOnline: true,
      ),
    ];

    for (final user in demoUsers) {
      final request = FriendRequest(
        id:
            'req_demo_${DateTime.now().millisecondsSinceEpoch}_${user.id}_${DateTime.now().microsecondsSinceEpoch}',
        from: user,
        timestamp: DateTime.now(),
        status: 'pending',
      );
      friendRequests.add(request);
    }

    _saveFriendRequests();
    if (kDebugMode) print('FriendsController: Added ${demoUsers.length} demo requests');
  }
}
