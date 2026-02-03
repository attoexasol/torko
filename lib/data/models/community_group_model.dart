import 'dart:convert';

class CommunityGroupModel {
  final int id;
  final String name;
  final String username;
  final String? bio;
  final String? visibility;
  final String? status;
  final String? role;
  final int membersCount;
  final String? location;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? coverImage;
  final CommunityGroupUser? user;
  final CommunityGroupUser? createdBy;
  final CommunityGroupUser? updatedBy;
  final List<CommunityGroupPostModel>? posts;

  CommunityGroupModel({
    required this.id,
    required this.name,
    required this.username,
    this.bio,
    this.visibility,
    this.status,
    this.role,
    required this.membersCount,
    this.location,
    this.lat,
    this.lng,
    this.createdAt,
    this.updatedAt,
    this.coverImage,
    this.user,
    this.createdBy,
    this.updatedBy,
    this.posts,
  });

  static CommunityGroupUser? _userFromJson(dynamic v) {
    if (v == null) return null;
    if (v is Map) return CommunityGroupUser.fromJson(Map<String, dynamic>.from(v));
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v is String ? v : v.toString();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  factory CommunityGroupModel.fromJson(Map<String, dynamic> json) {
    final postsJson = json['posts'] as List<dynamic>?;
    return CommunityGroupModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      bio: json['bio']?.toString(),
      visibility: json['visibility']?.toString(),
      status: json['status']?.toString(),
      role: json['role']?.toString(),
      membersCount: _toInt(json['members_count']),
      location: json['location']?.toString(),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      coverImage: json['cover_image']?.toString(),
      user: _userFromJson(json['user']),
      createdBy: _userFromJson(json['created_by']),
      updatedBy: _userFromJson(json['updated_by']),
      posts: postsJson != null
          ? postsJson
              .map((e) => CommunityGroupPostModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : null,
    );
  }
}

class CommunityGroupUser {
  final int id;
  final String fullname;
  final String? profileImage;

  CommunityGroupUser({
    required this.id,
    required this.fullname,
    this.profileImage,
  });

  factory CommunityGroupUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final idInt = id is int
        ? id
        : (id is num
            ? id.toInt()
            : (id is String ? int.tryParse(id) : null));
    return CommunityGroupUser(
      id: idInt ?? 0,
      fullname: json['fullname']?.toString() ?? json['name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
    );
  }
}

class CommunityGroupPostModel {
  final int groupPostId;
  final int postId;
  final String approvedByAdmin;
  final String createdAt;
  final String postTitle;
  final String postDescription;
  final List<String> postImages;
  final CommunityGroupUser? user;

  CommunityGroupPostModel({
    required this.groupPostId,
    required this.postId,
    required this.approvedByAdmin,
    required this.createdAt,
    required this.postTitle,
    required this.postDescription,
    required this.postImages,
    this.user,
  });

  factory CommunityGroupPostModel.fromJson(Map<String, dynamic> json) {
    final images = _parsePostImages(json['post_images']);
    return CommunityGroupPostModel(
      groupPostId: _toInt(json['group_post_id'] ?? json['id']),
      postId: _toInt(json['post_id'] ?? json['id']),
      approvedByAdmin: json['approved_by_admin']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      postTitle: json['post_title']?.toString() ?? '',
      postDescription: json['post_description']?.toString() ?? '',
      postImages: images,
      user: json['user'] != null
          ? CommunityGroupUser.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }

  static List<String> _parsePostImages(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String) {
      if (v.isEmpty) return [];
      try {
        final decoded = jsonDecode(v.replaceAll(r'\/', '/'));
        if (decoded is List) return List<String>.from(decoded.map((e) => e.toString()));
        return [v];
      } catch (_) {
        return [v];
      }
    }
    return [];
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
