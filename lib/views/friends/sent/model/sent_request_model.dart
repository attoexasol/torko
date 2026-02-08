/// Model for sent friend request (dummy for now, ready for API).
class SentRequestModel {
  final String id;
  final String name;
  final String username;
  final String? location;
  final String status; // "pending", etc.
  final DateTime? createdAt;

  const SentRequestModel({
    required this.id,
    required this.name,
    required this.username,
    this.location,
    this.status = 'pending',
    this.createdAt,
  });

  String get displayUsername => username.startsWith('@') ? username : '@$username';
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  static List<SentRequestModel> get dummyList => [
        const SentRequestModel(
          id: '1',
          name: 'তানভীর আহমেদ',
          username: 'tanvir_ahmed',
          location: 'ঢাকা, বাংলাদেশ',
          status: 'pending',
        ),
        const SentRequestModel(
          id: '2',
          name: 'নাজনীন সুলতানা',
          username: 'nazneen_s',
          location: 'চট্টগ্রাম, বাংলাদেশ',
          status: 'pending',
        ),
      ];
}
