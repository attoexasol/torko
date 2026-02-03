import 'package:flutter/foundation.dart';

import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/data/models/community_group_model.dart';

class CommunityGroupApiService {
  static bool _isOk(NetworkResponse res) => res.isSuccess && res.body != null;

  static String _err(NetworkResponse res) =>
      res.body?['message']?.toString() ?? res.errorMessage ?? 'Request failed';

  /// Fetch all groups. POST to get_all_groups. api_token from UserInfo via postAuth.
  static Future<List<CommunityGroupModel>> fetchAllGroups() async {
    if (kDebugMode) {
      debugPrint('[CommunityGroupApiService] fetchAllGroups request keys: api_token (from UserInfo)');
    }
    final res = await NetworkCaller.postAuth(
      url: Urls.get_all_groups,
      body: <String, dynamic>{},
    );
    final status = res.body?['status'];
    final msg = res.body?['message']?.toString();
    if (kDebugMode) {
      debugPrint('[CommunityGroupApiService] fetchAllGroups response status=$status message=$msg');
    }
    if (!res.isSuccess || res.body == null) throw Exception(_err(res));
    if (status == false) throw Exception(_err(res));
    final data = res.body!['data'];
    if (data == null || data is! List) {
      if (kDebugMode) debugPrint('[CommunityGroupApiService] fetchAllGroups data not list, returning []');
      return [];
    }
    final list = (data as List)
        .map((e) => CommunityGroupModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
    if (kDebugMode) {
      debugPrint('[CommunityGroupApiService] fetchAllGroups group count=${list.length}');
    }
    return list;
  }

  /// Fetch single group by id. POST to get_single_group with id (api_token added by postAuth).
  static Future<CommunityGroupModel?> fetchSingleGroup(int id) async {
    final res = await NetworkCaller.postAuth(
      url: Urls.get_single_group,
      body: <String, dynamic>{'id': id},
    );
    if (!_isOk(res)) throw Exception(_err(res));
    final data = res.body!['data'];
    if (data == null || data is! Map) return null;
    return CommunityGroupModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Create group. POST to create_group. api_token from UserInfo via postAuth.
  /// Body: name, bio, visibility, status, location?, lat?, lng?, image? (data:image/...;base64,...).
  static Future<CommunityGroupModel> createGroup({
    required String name,
    required String bio,
    String visibility = 'public',
    String status = 'active',
    String? location,
    double? lat,
    double? lng,
    String? imageBase64,
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
    if (imageBase64 != null && imageBase64.isNotEmpty) body['image'] = imageBase64;

    if (kDebugMode) {
      debugPrint('[CommunityGroupApiService] createGroup request keys: ${body.keys.toList()}');
    }
    final res = await NetworkCaller.postAuth(
      url: Urls.create_group,
      body: body,
    );
    if (kDebugMode) {
      debugPrint(
          '[CommunityGroupApiService] createGroup response status=${res.body?['status']} message=${res.body?['message']}');
    }
    if (!_isOk(res)) throw Exception(_err(res));
    final data = res.body!['data'];
    if (data == null || data is! Map) {
      throw Exception(res.body!['message']?.toString() ?? 'Invalid create response');
    }
    return CommunityGroupModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
