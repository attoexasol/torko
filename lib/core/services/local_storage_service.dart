import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for api_token and firebase_uid.
/// Uses SharedPreferences. Clear on logout.
class LocalStorageService {
  static const String _keyApiToken = 'torko_api_token';
  static const String _keyFirebaseUid = 'torko_firebase_uid';

  SharedPreferences? _prefs;
  SharedPreferences get prefs {
    if (_prefs != null) return _prefs!;
    throw StateError('LocalStorageService not initialized. Call init() first.');
  }

  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  String? get laravelApiToken => prefs.getString(_keyApiToken);
  Future<void> setLaravelApiToken(String token) async {
    await prefs.setString(_keyApiToken, token);
  }

  String? get firebaseUid => prefs.getString(_keyFirebaseUid);
  Future<void> setFirebaseUid(String uid) async {
    await prefs.setString(_keyFirebaseUid, uid);
  }

  Future<void> clear() async {
    await prefs.remove(_keyApiToken);
    await prefs.remove(_keyFirebaseUid);
  }

  bool get hasAuth => laravelApiToken != null && laravelApiToken!.isNotEmpty;
}
