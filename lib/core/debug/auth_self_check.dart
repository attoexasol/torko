import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/core/services/user_info.dart' as torko_user_info;

/// Debug self-check after login. Verifies firebaseUid and FirebaseAuth consistency.
void runAuthSelfCheck() {
  if (!kDebugMode) return;

  final storedUid = torko_user_info.UserInfo.firebaseUid;
  final authUid = FirebaseAuth.instance.currentUser?.uid;

  if (storedUid == null || storedUid.isEmpty) {
    debugPrint('❌ [AUTH SELF-CHECK] FAIL: firebaseUid is empty');
    return;
  }

  String normalizedStored = storedUid;
  try {
    normalizedStored = normalizeUserId(storedUid);
  } catch (_) {
    debugPrint('❌ [AUTH SELF-CHECK] FAIL: firebaseUid invalid: $storedUid');
    return;
  }

  if (authUid == null || authUid.isEmpty) {
    debugPrint('❌ [AUTH SELF-CHECK] FAIL: FirebaseAuth.currentUser.uid is null');
    return;
  }

  String normalizedAuth = authUid;
  try {
    normalizedAuth = normalizeUserId(authUid);
  } catch (_) {
    debugPrint('❌ [AUTH SELF-CHECK] FAIL: auth uid invalid: $authUid');
    return;
  }

  final match = normalizedStored == normalizedAuth;
  if (match) {
    debugPrint('✅ [AUTH SELF-CHECK] PASS: firebaseUid=$normalizedStored, FirebaseAuth.uid=$authUid');
    debugPrint('✅ [AUTH SELF-CHECK] User doc path: users/$normalizedStored');
  } else {
    debugPrint('⚠️ [AUTH SELF-CHECK] WARN: stored=$normalizedStored vs auth=$authUid (normalized=$normalizedAuth)');
  }
}
