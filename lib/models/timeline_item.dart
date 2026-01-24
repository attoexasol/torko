import 'post_model.dart';

/// Timeline item from user_own_posts (own posts + shared posts).
/// type "post" = own post, type "share" = shared post.
class TimelineItem {
  final String type; // "post" | "share"
  final DateTime? timelineTime;
  final int? sharedByUserId;
  final DateTime? sharedAt;
  final PostModel post;

  TimelineItem({
    required this.type,
    this.timelineTime,
    this.sharedByUserId,
    this.sharedAt,
    required this.post,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? 'post';
    DateTime? timelineTime;
    final tt = json['timeline_time'];
    if (tt != null && tt.toString().isNotEmpty) {
      timelineTime = DateTime.tryParse(tt.toString());
    }
    int? sharedByUserId;
    final sbu = json['shared_by_user_id'];
    if (sbu != null) {
      sharedByUserId = sbu is int ? sbu : int.tryParse(sbu.toString());
    }
    DateTime? sharedAt;
    final sa = json['shared_at'];
    if (sa != null && sa.toString().isNotEmpty) {
      sharedAt = DateTime.tryParse(sa.toString());
    }
    final map = Map<String, dynamic>.from(json);
    if (map['post_title'] == null && map['title'] != null) map['post_title'] = map['title'];
    if (map['post_description'] == null && map['description'] != null) map['post_description'] = map['description'];
    final post = PostModel.fromJson(map);
    return TimelineItem(
      type: type,
      timelineTime: timelineTime,
      sharedByUserId: sharedByUserId,
      sharedAt: sharedAt,
      post: post,
    );
  }

  bool get isShared => type == 'share';
}
