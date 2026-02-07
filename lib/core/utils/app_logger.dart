import 'package:flutter/foundation.dart';

/// Mask token for safe debug logging: first 12 + "..." + last 6 chars.
String maskToken(String? token) {
  if (token == null || token.isEmpty) return 'null';
  if (token.length <= 20) return '${token.substring(0, token.length ~/ 2)}***';
  return '${token.substring(0, 12)}...${token.substring(token.length - 6)}';
}

/// Centralized logging. Use instead of print() for production-safe logs.
/// In release mode, logs are stripped by tree-shaking when kDebugMode is false.
class AppLogger {
  static void log(String tag, String message, {Object? error, StackTrace? stack}) {
    if (kDebugMode) {
      final buf = StringBuffer('[$tag] $message');
      if (error != null) buf.write(' | error=$error');
      if (stack != null) buf.write('\n$stack');
      debugPrint(buf.toString());
    }
  }

  static void auth(String message, {Object? error}) =>
      log('AUTH', message, error: error);

  static void fs(String message, {Object? error}) =>
      log('FS', message, error: error);

  static void nav(String message, {Object? error}) =>
      log('NAV', message, error: error);

  static void ctrl(String message, {Object? error}) =>
      log('CTRL', message, error: error);

  static void ui(String message, {Object? error}) =>
      log('UI', message, error: error);

  static void err(String message, {Object? error, StackTrace? stack}) =>
      log('ERR', message, error: error, stack: stack);

  /// User-safe error message: no raw Firebase/API messages in UI.
  static String toUserMessage(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('permission') && s.contains('denied')) return 'Permission denied';
    if (s.contains('unavailable') || s.contains('network')) return 'Network error';
    if (s.contains('timeout')) return 'Request timed out';
    return 'Something went wrong. Please try again.';
  }
}

/// Lightweight structured logger with d/i/w/e. Use AppLog.d('TAG','msg').
class AppLog {
  /// Debug - kDebugMode only.
  static void d(String tag, String message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  /// Info - kDebugMode only.
  static void i(String tag, String message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  /// Warn - kDebugMode only.
  static void w(String tag, String message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  /// Error - always prints (short). Optional error + stackTrace.
  static void e(String tag, String message, [Object? error, StackTrace? stack]) {
    final buf = StringBuffer('[$tag] $message');
    if (error != null) buf.write(' error=$error');
    debugPrint(buf.toString());
    if (kDebugMode && stack != null) debugPrint(stack.toString());
  }
}
