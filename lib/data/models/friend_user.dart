/// Friend user model for Friends module (API format).
class FriendUser {
  final int id;
  final String? fullname;
  final String? username;
  final String? profileImage;
  final String? address;
  final int mutualFriends;

  FriendUser({
    required this.id,
    this.fullname,
    this.username,
    this.profileImage,
    this.address,
    this.mutualFriends = 0,
  });

  String get displayName => fullname ?? 'User';

  /// Alias for profile_view compatibility.
  String get name => displayName;

  /// Alias for profile_view compatibility.
  String? get avatar => profileImage;

  /// Alias for profile_view compatibility.
  String? get location => address;

  /// UI-only: show green online dot. Not from API.
  bool get isOnline => true;

  String get displayUsername {
    final u = username;
    if (u == null || u.isEmpty) return '';
    return u.startsWith('@') ? u : '@$u';
  }

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullname: json['fullname']?.toString(),
      username: json['username']?.toString(),
      profileImage: json['profile_image']?.toString(),
      address: json['address']?.toString(),
      mutualFriends: json['mutual_friends'] is int
          ? json['mutual_friends'] as int
          : int.tryParse(json['mutual_friends']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'username': username,
        'profile_image': profileImage,
        'address': address,
        'mutual_friends': mutualFriends,
      };
}

/// Pending friend request item (from API).
/// API returns: id=USER_ID, request_id=FRIEND_REQUEST_ROW_ID (use for accept).
class FriendRequestItem {
  /// User ID from json["id"] - for display/profile.
  final int userId;
  /// Friend request row ID from json["request_id"] - required for accept API.
  final int requestId;
  final FriendUser user;

  FriendRequestItem({
    required this.userId,
    required this.requestId,
    required this.user,
  });

  factory FriendRequestItem.fromJson(Map<String, dynamic> json) {
    final userId = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    // request_id from JSON - Accept API requires this, NOT id (user id).
    final requestId = json['request_id'] is int
        ? json['request_id'] as int
        : int.tryParse(json['request_id']?.toString() ?? '0') ?? 0;
    return FriendRequestItem(
      userId: userId,
      requestId: requestId,
      user: FriendUser.fromJson(Map<String, dynamic>.from(json)),
    );
  }
}
