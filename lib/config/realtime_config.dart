// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

import '../services/urls.dart';

/// Realtime (Laravel Reverb) configuration.
///
/// Values are read from dart-define or defaults. Use for debug/QA overrides.
///
/// README – .env / dart-define mapping:
///   REVERB_APP_KEY   → --dart-define=REVERB_APP_KEY=your_key (same as server REVERB_APP_ID)
///   REVERB_HOST      → --dart-define=REVERB_HOST=your.domain.com
///   REVERB_PORT      → --dart-define=REVERB_PORT=8080 (ws) or 443 (wss)
///   REVERB_SCHEME    → --dart-define=REVERB_SCHEME=wss
///   AUTH_ENDPOINT    → --dart-define=AUTH_ENDPOINT=https://api.example.com/api/broadcasting/auth
///
/// If not set via --dart-define, defaults below are used (suitable for debug).
class RealtimeConfig {
  RealtimeConfig._();

  static const String _defaultAppKey = '6065ff9c08eb7a38bcb4';
  static const String _defaultHost = 'torko.attoexasolutions.com';
  static const int _defaultPort = 8080;
  static const String _defaultScheme = 'wss';

  /// Same app key as Laravel Reverb server (REVERB_APP_ID in .env).
  static String get appKey =>
      const String.fromEnvironment('REVERB_APP_KEY', defaultValue: _defaultAppKey);

  /// Reverb WebSocket host (domain or IP). No protocol.
  static String get host =>
      const String.fromEnvironment('REVERB_HOST', defaultValue: _defaultHost);

  /// Reverb WebSocket port (e.g. 8080 for ws, 443 for wss).
  static int get port =>
      int.tryParse(const String.fromEnvironment('REVERB_PORT', defaultValue: '$_defaultPort')) ??
      _defaultPort;

  /// Scheme: 'ws' or 'wss'. Use wss for production.
  static String get scheme =>
      const String.fromEnvironment('REVERB_SCHEME', defaultValue: _defaultScheme);

  /// Whether to use TLS (wss). Derived from scheme.
  static bool get useTLS => scheme == 'wss';

  /// Broadcasting auth URL. Must return { "auth": "appKey:signature" }.
  static String get authEndpoint =>
      const String.fromEnvironment('AUTH_ENDPOINT', defaultValue: Urls.broadcastingAuth);

  /// Log current config (for QA / health check).
  static void logConfig() {
    if (!kDebugMode) return;
    debugPrint('[REALTIME CONFIG] appKey=${appKey.substring(0, 8)}... host=$host port=$port scheme=$scheme useTLS=$useTLS authEndpoint=$authEndpoint');
  }
}
