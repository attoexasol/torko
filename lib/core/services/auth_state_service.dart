import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/foundation.dart';
import 'package:torko/core/utils/app_logger.dart';
import 'package:torko/core/services/user_info.dart' as torko_user_info;

/// Centralized auth state. FirebaseAuth is the source of truth after login.
/// Ensures Firestore is NEVER queried before FirebaseAuth.currentUser is available.
class AuthStateService {
  static final AuthStateService _instance = AuthStateService._internal();
  factory AuthStateService() => _instance;
  AuthStateService._internal();

  /// Wait for Firebase Auth to stabilize (rehydrate persisted session).
  /// Call before Firestore queries on app cold start. Timeout prevents indefinite wait.
  static Future<void> waitForAuthReady({Duration timeout = const Duration(seconds: 3)}) async {
    if (FirebaseAuth.instance.currentUser != null) {
      if (kDebugMode) AppLogger.auth('Auth ready (uid present)');
      return;
    }

    if (kDebugMode) AppLogger.auth('Waiting for Firebase auth rehydration');
    final completer = Completer<void>();
    late StreamSubscription sub;
    sub = FirebaseAuth.instance.authStateChanges().listen((u) {
      if (!completer.isCompleted) {
        completer.complete();
        if (kDebugMode) AppLogger.auth('Auth ready (uid=${u?.uid != null ? "present" : "null"})');
      }
    });
    try {
      await completer.future.timeout(
        timeout,
        onTimeout: () {
          if (kDebugMode) AppLogger.auth('Auth timeout, proceeding safely');
          if (!completer.isCompleted) completer.complete();
        },
      );
    } finally {
      await sub.cancel();
    }
  }

  /// Returns true if we can safely run Firestore queries (uid available).
  static bool get isReadyForFirestore {
    final uid = torko_user_info.UserInfo.myUidString;
    return uid != null && uid.isNotEmpty;
  }

  /// Stream of auth state changes. Use to react to login/logout.
  static Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();
}
