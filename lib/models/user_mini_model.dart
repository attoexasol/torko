/// Mini user model for message/conversation contexts
class UserMiniModel {
  final int id;
  final String fullname;
  final String? profileImage;

  UserMiniModel({
    required this.id,
    required this.fullname,
    this.profileImage,
  });

  factory UserMiniModel.fromJson(Map<String, dynamic> json) {
    return UserMiniModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,
      fullname: json['fullname']?.toString() ?? json['name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'profile_image': profileImage,
    };
  }
}
