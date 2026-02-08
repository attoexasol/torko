/// Model for friend request card (dummy for now, ready for API).
class FriendRequestModel {
  final String id;
  final String name;
  final String? location;
  final int mutualFriends;

  const FriendRequestModel({
    required this.id,
    required this.name,
    this.location,
    this.mutualFriends = 0,
  });

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  static List<FriendRequestModel> get dummyList => [
        const FriendRequestModel(
          id: '1',
          name: 'আহমেদ করিম',
          location: 'ঢাকা, বাংলাদেশ',
          mutualFriends: 12,
        ),
        const FriendRequestModel(
          id: '2',
          name: 'ফাতিমা আক্তার',
          location: 'চট্টগ্রাম, বাংলাদেশ',
          mutualFriends: 8,
        ),
        const FriendRequestModel(
          id: '3',
          name: 'রাজিব হোসেন',
          location: 'সিলেট, বাংলাদেশ',
          mutualFriends: 5,
        ),
      ];
}
