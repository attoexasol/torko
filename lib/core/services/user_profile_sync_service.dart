import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:torko/core/constants/urls.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/core/services/network_caller.dart';
import 'package:torko/core/services/user_info.dart' as torko_user;

/// Syncs current user profile to Firestore users/{myUid} ONLY.
/// Never writes to friend/other user docs - causes PERMISSION_DENIED.
class UserProfileSyncService {
  static final _firestore = FirebaseFirestore.instance;

  /// Upsert ONLY current user doc. Call after signInWithCustomToken and on app start.
  static Future<void> syncMe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) return;

    final authUid = normalizeUserId(user.uid);
    final token = torko_user.UserInfo.apiToken;
    if (token == null || token.isEmpty) return;

    try {
      final res = await NetworkCaller.postAuth(
        url: Urls.single_users,
        body: {},
      );

      if (!res.isSuccess || res.body == null) return;

      final data = res.body!['data'];
      if (data == null || data is! Map) return;

      final fullname = data['fullname']?.toString() ?? '';
      final profileImage = data['profile_image']?.toString() ?? '';
      final phone = data['phone']?.toString() ?? '';
      final username = data['username']?.toString() ?? '';
      final laravelUserId = data['id'];

      final docRef = _firestore.collection('users').doc(authUid);
      final snap = await docRef.get();

      final payload = <String, dynamic>{
        'fullname': fullname,
        'profileImage': profileImage,
        'phone': phone,
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
        'isOnline': true,
      };
      if (laravelUserId != null) {
        payload['laravelUserId'] = laravelUserId is int
            ? laravelUserId
            : int.tryParse(laravelUserId.toString()) ?? 0;
      }
      if (!snap.exists) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }

      if (kDebugMode) {
        debugPrint('[UserSync] writing users/$authUid payload=$payload');
      }

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserSync] syncMe error: $e');
      }
      rethrow;
    }
  }
}
