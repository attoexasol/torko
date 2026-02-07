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
/// Backend returns "id" in requests - treat as request_id for accept/reject.
class FriendRequestItem {
  final int requestId;
  final FriendUser user;

  FriendRequestItem({
    required this.requestId,
    required this.user,
  });

  factory FriendRequestItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['request_id'];
    final requestId = id is int ? id : int.tryParse(id?.toString() ?? '0') ?? 0;
    return FriendRequestItem(
      requestId: requestId,
      user: FriendUser.fromJson(Map<String, dynamic>.from(json)),
    );
  }
}
