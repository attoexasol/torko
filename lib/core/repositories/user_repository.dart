import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/data/models/firestore/firestore_user.dart';

/// Firestore user repository.
/// users/{firebase_uid} - uid is numeric string e.g. "65"
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Upsert user document. Uses serverTimestamp for createdAt/updatedAt.
  Future<void> upsertUserDoc(
    String firebaseUid,
    String phone, {
    String? fullname,
    String? profileImage,
  }) async {
    final uid = normalizeUserId(firebaseUid);
    final ref = _users.doc(uid);
    final snap = await ref.get();

    final data = <String, dynamic>{
      'phone': phone,
      'fullname': fullname,
      'profileImage': profileImage,
      'isOnline': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await ref.set(data, SetOptions(merge: true));
  }

  /// Fetches user doc. Returns null on permission-denied or not-found.
  /// Never throws: permission-denied is caught and logged.
  Future<FirestoreUser?> getUser(String uid) async {
    final normalizedUid = normalizeUserId(uid);
    try {
      final snap = await _users.doc(normalizedUid).get();
      if (!snap.exists) return null;
      return FirestoreUser.fromDoc(snap);
    } on FirebaseException catch (e) {
      final code = e.code.toLowerCase();
      if (code.contains('permission') && code.contains('denied')) {
        if (kDebugMode) {
          debugPrint('[FS] getUser denied for users/$normalizedUid');
        }
        return null;
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FS] getUser error for users/$normalizedUid: $e');
      }
      return null;
    }
  }
}
