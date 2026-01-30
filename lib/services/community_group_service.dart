import 'package:flutter/foundation.dart';

import '../models/community_group_model.dart';
import 'network_caller.dart';
import 'urls.dart';
import 'user_info.dart';

/// Community groups API: GET get_all_groups (api_token query), POST create_group.
class CommunityGroupService {
  /// GET get_all_groups with api_token as query param. Token from UserInfo.
  static Future<List<CommunityGroupModel>> fetchAllGroups() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }
    final url = '${Urls.get_all_groups}?api_token=${Uri.encodeComponent(token)}';
    if (kDebugMode) {
      debugPrint('[CommunityGroupService] fetchAllGroups GET (api_token in query)');
    }
    final res = await NetworkCaller.getRequest(url: url);
    final json = res.body;
    final status = json?['status'];
    final msg = json?['message']?.toString();
    if (kDebugMode) {
      debugPrint('[CommunityGroupService] fetchAllGroups status=$status message=$msg');
    }
    if (!res.isSuccess || json == null) {
      throw Exception(msg ?? res.errorMessage ?? 'Failed to load groups');
    }
    if (status != true) {
      throw Exception(msg ?? 'Failed to load groups');
    }
    final data = json['data'];
    if (data == null || data is! List) {
      if (kDebugMode) debugPrint('[CommunityGroupService] fetchAllGroups data not list');
      return [];
    }
    final list = (data as List)
        .map((e) => CommunityGroupModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (kDebugMode) {
      debugPrint('[CommunityGroupService] fetchAllGroups count=${list.length}');
    }
    return list;
  }

  /// POST create_group. api_token added via postAuth. Body: name, bio, visibility, status, location?, lat?, lng?, image?.
  static Future<CommunityGroupModel> createGroup({
    required String name,
    required String bio,
    required String visibility,
    required String status,
    String? location,
    double? lat,
    double? lng,
    String? imageDataUri,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'bio': bio,
      'visibility': visibility,
      'status': status,
    };
    if (location != null && location.isNotEmpty) body['location'] = location;
    if (lat != null) body['lat'] = lat;
    if (lng != null) body['lng'] = lng;
    if (imageDataUri != null && imageDataUri.isNotEmpty) body['image'] = imageDataUri;

    if (kDebugMode) {
      debugPrint('[CommunityGroupService] createGroup keys=${body.keys.toList()}');
    }
    final res = await NetworkCaller.postAuth(url: Urls.create_group, body: body);
    if (kDebugMode) {
      debugPrint('[CommunityGroupService] createGroup status=${res.body?['status']} message=${res.body?['message']}');
    }
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message']?.toString() ?? res.errorMessage ?? 'Create group failed');
    }
    if (res.body!['status'] != true) {
      throw Exception(res.body!['message']?.toString() ?? 'Create group failed');
    }
    final data = res.body!['data'];
    if (data == null || data is! Map) {
      throw Exception(res.body!['message']?.toString() ?? 'Invalid create response');
    }
    return CommunityGroupModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
