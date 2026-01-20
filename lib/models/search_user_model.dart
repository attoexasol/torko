/// Model for search result user
class SearchUserModel {
  final int id;
  final String fullname;
  final String? profileImage;

  SearchUserModel({
    required this.id,
    required this.fullname,
    this.profileImage,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,
      fullname: json['fullname']?.toString() ?? '',
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
