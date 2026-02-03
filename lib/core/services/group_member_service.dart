import 'package:flutter/foundation.dart';

import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/group_member_model.dart';

class GroupMemberService {
  /// GET get-all-members with api_token and group_id as query params.
  /// If 422/400 or status false, falls back to GET with only api_token and filters by group_id client-side.
  static Future<GroupMembersResponse> getAllMembers({required int groupId}) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }

    // Try GET with api_token + group_id
    var url =
        '${Urls.Get_All_Group_Members}?api_token=${Uri.encodeComponent(token)}&group_id=$groupId';

    if (kDebugMode) {
      debugPrint('[GroupMemberService] getAllMembers groupId=$groupId (with group_id in query)');
    }

    var res = await NetworkCaller.getRequest(url: url);

    // If 4xx or status false, fallback: GET with only api_token, then filter client-side
    final needsFallback = !res.isSuccess ||
        res.statusCode == 422 ||
        res.statusCode == 400 ||
        (res.body != null && res.body!['status'] == false);

    if (needsFallback && res.body != null) {
      if (kDebugMode) {
        debugPrint('[GroupMemberService] getAllMembers fallback: GET without group_id, filter client-side');
      }
      url = '${Urls.Get_All_Group_Members}?api_token=${Uri.encodeComponent(token)}';
      res = await NetworkCaller.getRequest(url: url);
    }

    if (!res.isSuccess) {
      final raw = res.errorMessage ?? '';
      if (raw.contains('html') || (res.body == null && raw.isNotEmpty)) {
        throw Exception('Wrong method or endpoint. Please try again.');
      }
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Failed to load members');
    }

    final json = res.body;
    if (json == null) {
      throw Exception('Wrong method or endpoint. Please try again.');
    }

    if (json['status'] == false) {
      throw Exception(json['message']?.toString() ?? 'Failed to load members');
    }

    final totalMembers = _toInt(json['total_members']);
    final data = json['data'];
    List<GroupMemberModel> members = [];
    if (data != null && data is List) {
      members = data
          .map((e) => GroupMemberModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      // If we used fallback, filter by group_id
      if (needsFallback) {
        members = members.where((m) => m.group.id == groupId).toList();
      }
    }

    if (kDebugMode) {
      debugPrint('[GroupMemberService] getAllMembers loaded ${members.length} members');
    }

    return GroupMembersResponse(totalMembers: totalMembers, members: members);
  }

  /// POST approve member. Body: api_token (auto), member_id, status="approved".
  static Future<GroupMemberModel> approveMember({required int memberId}) async {
    final body = <String, dynamic>{
      'member_id': memberId,
      'status': 'approved',
    };

    if (kDebugMode) {
      debugPrint('[GroupMemberService] approveMember memberId=$memberId');
    }

    final res = await NetworkCaller.postAuth(url: Urls.Approve_Member, body: body);

    if (kDebugMode) {
      debugPrint('[GroupMemberService] approveMember status=${res.body?['status']} message=${res.body?['message']}');
    }

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Failed to approve member');
    }
    if (res.body!['status'] != true) {
      throw Exception(res.body!['message']?.toString() ?? 'Failed to approve member');
    }

    final data = res.body!['data'];
    if (data != null && data is Map) {
      return GroupMemberModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception(res.body!['message']?.toString() ?? 'Invalid approve response');
  }

  /// POST delete member. Primary: member_id. Fallback: group_id if backend requires it.
  static Future<void> deleteMember({required int groupId, required int memberId}) async {
    // Primary: api_token + member_id
    var body = <String, dynamic>{'member_id': memberId};

    if (kDebugMode) {
      debugPrint('[GroupMemberService] deleteMember memberId=$memberId groupId=$groupId');
    }

    var res = await NetworkCaller.postAuth(url: Urls.Delete_Group_Member, body: body);

    // Fallback: if backend returns error about missing group_id, retry with group_id
    if (!res.isSuccess &&
        res.body != null &&
        (res.body!['message']?.toString().toLowerCase().contains('group_id') ?? false)) {
      if (kDebugMode) {
        debugPrint('[GroupMemberService] deleteMember fallback: sending group_id');
      }
      body = <String, dynamic>{'group_id': groupId};
      res = await NetworkCaller.postAuth(url: Urls.Delete_Group_Member, body: body);
    }

    // Also try both if still failing
    if (!res.isSuccess && res.body != null) {
      body = <String, dynamic>{'group_id': groupId, 'member_id': memberId};
      res = await NetworkCaller.postAuth(url: Urls.Delete_Group_Member, body: body);
    }

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Failed to remove member');
    }
    if (res.body!['status'] != true) {
      throw Exception(res.body!['message']?.toString() ?? 'Failed to remove member');
    }
  }

  /// POST leave group. Body: api_token (auto), group_id.
  static Future<void> leaveGroup({required int groupId}) async {
    final body = <String, dynamic>{'group_id': groupId};

    if (kDebugMode) {
      debugPrint('[GroupMemberService] leaveGroup groupId=$groupId');
    }

    final res = await NetworkCaller.postAuth(url: Urls.Leave_Group, body: body);

    if (kDebugMode) {
      debugPrint('[GroupMemberService] leaveGroup status=${res.body?['status']} message=${res.body?['message']}');
    }

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Failed to leave group');
    }
    if (res.body!['status'] != true) {
      throw Exception(res.body!['message']?.toString() ?? 'Failed to leave group');
    }
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
