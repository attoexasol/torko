/// Minimal user info within a group member record.
class UserMini {
  final int id;
  final String? fullname;
  final String? profileImage;

  UserMini({
    required this.id,
    this.fullname,
    this.profileImage,
  });

  factory UserMini.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final idInt = id is int
        ? id
        : (id is num ? id.toInt() : (id is String ? int.tryParse(id) : null));
    return UserMini(
      id: idInt ?? 0,
      fullname: json['fullname']?.toString(),
      profileImage: json['profile_image']?.toString(),
    );
  }
}

/// Minimal group info within a member record.
class GroupMini {
  final int id;
  final String? name;
  final String? username;

  GroupMini({
    required this.id,
    this.name,
    this.username,
  });

  factory GroupMini.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final idInt = id is int
        ? id
        : (id is num ? id.toInt() : (id is String ? int.tryParse(id) : null));
    return GroupMini(
      id: idInt ?? 0,
      name: json['name']?.toString(),
      username: json['username']?.toString(),
    );
  }
}

/// Single group member from get-all-members API.
class GroupMemberModel {
  final int id;
  final String status;
  final DateTime? createdAt;
  final GroupMini group;
  final UserMini user;

  GroupMemberModel({
    required this.id,
    required this.status,
    this.createdAt,
    required this.group,
    required this.user,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final idInt = id is int
        ? id
        : (id is num ? id.toInt() : (id is String ? int.tryParse(id) : null));
    DateTime? createdAt;
    final ca = json['created_at'];
    if (ca != null) {
      if (ca is DateTime) {
        createdAt = ca;
      } else {
        createdAt = DateTime.tryParse(ca.toString());
      }
    }
    return GroupMemberModel(
      id: idInt ?? 0,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      createdAt: createdAt,
      group: json['group'] != null && json['group'] is Map
          ? GroupMini.fromJson(Map<String, dynamic>.from(json['group'] as Map))
          : GroupMini(id: idInt ?? 0, name: null, username: null),
      user: json['user'] != null && json['user'] is Map
          ? UserMini.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : UserMini(id: 0, fullname: null, profileImage: null),
    );
  }
}

/// Response from get-all-members API.
class GroupMembersResponse {
  final int totalMembers;
  final List<GroupMemberModel> members;

  GroupMembersResponse({
    required this.totalMembers,
    required this.members,
  });
}
