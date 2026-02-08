/// Dummy model for friend suggestion card (ready for API later).
class FriendSuggestionModel {
  final String id;
  final String name;
  final String username;
  final String? profileImageUrl;
  final String? location;
  final String? bio;
  final int mutualFriends;

  const FriendSuggestionModel({
    required this.id,
    required this.name,
    required this.username,
    this.profileImageUrl,
    this.location,
    this.bio,
    this.mutualFriends = 0,
  });

  String get displayUsername => username.startsWith('@') ? username : '@$username';
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  /// Dummy list for UI development.
  static List<FriendSuggestionModel> get dummyList => [
        const FriendSuggestionModel(
          id: '1',
          name: 'আহমেদ করিম',
          username: 'ahmed_karim',
          location: 'ঢাকা, বাংলাদেশ',
          bio: 'টেক এনথুসিয়াস্ট | স্টার্টআপ ফাউন্ডার',
          mutualFriends: 12,
        ),
        const FriendSuggestionModel(
          id: '2',
          name: 'ফাতিমা আক্তার',
          username: 'fatima_a',
          location: 'চট্টগ্রাম, বাংলাদেশ',
          bio: 'ডিজাইনার | ক্রিয়েটিভ ডিরেক্টর',
          mutualFriends: 8,
        ),
        const FriendSuggestionModel(
          id: '3',
          name: 'রাজিব হোসেন',
          username: 'rajib_h',
          location: 'সিলেট, বাংলাদেশ',
          bio: 'ডেভেলপার | অপেন সোর্স লাভার',
          mutualFriends: 5,
        ),
        const FriendSuggestionModel(
          id: '4',
          name: 'নাজনীন সুলতানা',
          username: 'nazneen_s',
          location: 'ঢাকা, বাংলাদেশ',
          bio: 'মার্কেটার | কনটেন্ট ক্রিয়েটর',
          mutualFriends: 15,
        ),
      ];
}
