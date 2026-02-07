import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// ONLINE-ONLY Firestore: disables offline persistence, forces network mode.
/// Call once at app startup after Firebase.initializeApp(), before any Firestore query/stream.
class FirestoreNetworkService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _initialized = false;

  /// Apply Firestore settings and enable network. Call ONCE during app bootstrap.
  /// Order: settings (disable persistence) → enableNetwork().
  static Future<void> initializeOnlineOnly() async {
    if (_initialized) return;
    // 1. Disable offline persistence before any Firestore use
    _firestore.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    // 2. Force online network mode
    try {
      await _firestore.enableNetwork();
      _initialized = true;
      if (kDebugMode) debugPrint('[FS] network enabled');
    } catch (e) {
      if (kDebugMode) debugPrint('[FS] enableNetwork failed: $e');
    }
  }
}
