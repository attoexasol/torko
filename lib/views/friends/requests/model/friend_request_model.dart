import 'package:torko/data/models/friend_user.dart';

/// Model for friend request card (from API via FriendRequestItem).
/// userId=json["id"], requestId=json["request_id"] (use for accept).
class FriendRequestModel {
  final String id;
  final int userId;
  final String name;
  final String? location;
  final int mutualFriends;
  /// request_id from API - required for accept.
  final int requestId;

  const FriendRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    this.location,
    this.mutualFriends = 0,
    required this.requestId,
  });

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory FriendRequestModel.fromRequestItem(FriendRequestItem item) {
    return FriendRequestModel(
      id: item.requestId.toString(),
      userId: item.userId,
      requestId: item.requestId,
      name: item.user.displayName,
      location: item.user.address,
      mutualFriends: item.user.mutualFriends,
    );
  }
}
