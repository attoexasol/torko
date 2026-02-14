// lib/services/network_caller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/core/utils/app_logger.dart';

/// Thrown when postAuth is called without a valid token.
class NetworkAuthException implements Exception {
  final String message;
  NetworkAuthException(this.message);
}

class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? body;
  final String? errorMessage;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
  });
}

class NetworkCaller {
  static const String _defaultErrorMessage = "Something went wrong";

  static Future<NetworkResponse> getRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final sw = Stopwatch()..start();

    try {
      final res = await get(uri, headers: headers).timeout(const Duration(seconds: 10));
      sw.stop();

      final decoded = _tryDecode(res.body);
      final ok = res.statusCode >= 200 && res.statusCode < 300;

      _logApi(method: 'GET', url: url, statusCode: res.statusCode, durationMs: sw.elapsedMilliseconds);

      return NetworkResponse(
        isSuccess: ok,
        statusCode: res.statusCode,
        body: decoded,
        errorMessage: ok ? null : _extractError(decoded),
      );
    } on TimeoutException {
      sw.stop();
      _logApiError(method: 'GET', url: url, error: 'Timeout');
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: "Request timed out. Check your internet.");
    } catch (e) {
      sw.stop();
      _logApiError(method: 'GET', url: url, error: e.toString());
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  /// POST with auth: adds Authorization: Bearer and api_token in body. Token from UserInfo.
  /// Throws [NetworkAuthException] if token is null/empty.
  static Future<NetworkResponse> postAuth({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      throw NetworkAuthException('Session expired. Please login again.');
    }
    final fullBody = <String, dynamic>{...?body, 'api_token': token};
    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };
    return postRequest(url: url, body: fullBody, headers: mergedHeaders);
  }

  /// POST for Reverb/Pusher broadcasting auth. Body: socket_id, channel_name (and api_token if backend requires).
  /// Sends Authorization: Bearer. Used by custom auth flows; ReverbService uses authorizer (Bearer only).
  static Future<NetworkResponse> postBroadcastingAuth({
    required String url,
    required String socketId,
    required String channelName,
  }) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      throw NetworkAuthException('Session expired. Please login again.');
    }
    final body = <String, dynamic>{
      'socket_id': socketId,
      'channel_name': channelName,
      'api_token': token,
    };
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return postRequest(url: url, body: body, headers: headers);
  }

  /// JSON POST
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final mergedHeaders = {'Content-Type': 'application/json', ...?headers};
    final sw = Stopwatch()..start();

    try {
      final res = await post(uri, headers: mergedHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      sw.stop();

      final decoded = _tryDecode(res.body);
      final ok = res.statusCode >= 200 && res.statusCode < 300;

      _logApi(method: 'POST', url: url, statusCode: res.statusCode, durationMs: sw.elapsedMilliseconds);

      return NetworkResponse(
        isSuccess: ok,
        statusCode: res.statusCode,
        body: decoded,
        errorMessage: ok ? null : _extractError(decoded),
      );
    } on TimeoutException {
      sw.stop();
      _logApiError(method: 'POST', url: url, error: 'Timeout');
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: "Request timed out. Check your internet.");
    } catch (e) {
      sw.stop();
      _logApiError(method: 'POST', url: url, error: e.toString());
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  /// 🔸 NEW: FORM POST (application/x-www-form-urlencoded)
  static Future<NetworkResponse> postForm({
    required String url,
    required Map<String, String> fields,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final mergedHeaders = {'Content-Type': 'application/x-www-form-urlencoded', ...?headers};
    final sw = Stopwatch()..start();

    try {
      final res = await post(uri, headers: mergedHeaders, body: fields)
          .timeout(const Duration(seconds: 10));
      sw.stop();

      final decoded = _tryDecode(res.body);
      final ok = res.statusCode >= 200 && res.statusCode < 300;

      _logApi(method: 'POST(FORM)', url: url, statusCode: res.statusCode, durationMs: sw.elapsedMilliseconds);

      return NetworkResponse(
        isSuccess: ok, statusCode: res.statusCode,
        body: ok ? decoded : null,
        errorMessage: ok ? null : _extractError(decoded),
      );
    } on TimeoutException {
      sw.stop();
      _logApiError(method: 'POST(FORM)', url: url, error: 'Timeout');
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: "Request timed out. Check your internet.");
    } catch (e) {
      sw.stop();
      _logApiError(method: 'POST(FORM)', url: url, error: e.toString());
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  // ---------- helpers ----------

  /// Safely extract error message from API response. Handles message as String OR Map.
  /// Laravel 422: { "message": "...", "errors": {...} } or { "error": { "field": ["msg"] } }.
  static String extractMessage(dynamic data) {
    if (data == null) return _defaultErrorMessage;
    if (data is String) return data.isNotEmpty ? data : _defaultErrorMessage;
    if (data is Map) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) return m;
      if (m is Map || m is List) return m.toString();
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstVal = errors[firstKey];
        if (firstVal is List && firstVal.isNotEmpty) {
          return firstVal.first.toString();
        }
        return errors.toString();
      }
      final errorObj = data['error'];
      if (errorObj is Map && errorObj.isNotEmpty) {
        final firstKey = errorObj.keys.first;
        final firstVal = errorObj[firstKey];
        if (firstVal is List && firstVal.isNotEmpty) {
          return firstVal.first.toString();
        }
        return errorObj.toString();
      }
      final err = data['Error'] ?? data['detail'];
      if (err is String) return err;
      return data.toString();
    }
    return data.toString();
  }

  static String _extractError(dynamic json) {
    if (json == null) return _defaultErrorMessage;
    if (json is Map) {
      return extractMessage(json['message'] ?? json['Error'] ?? json['error'] ?? json['detail'] ?? json);
    }
    return json.toString().isNotEmpty ? json.toString() : _defaultErrorMessage;
  }

  static Map<String, dynamic>? _tryDecode(String body) {
    if (body.isEmpty) return null;
    try {
      final dyn = jsonDecode(body);
      if (dyn is Map<String, dynamic>) return dyn;
      return {'data': dyn};
    } catch (_) {
      return null;
    }
  }

  static String _path(String url) {
    try {
      final u = Uri.parse(url);
      return u.path.isEmpty ? url : u.path;
    } catch (_) { return url; }
  }

  static void _logApi({required String method, required String url, required int statusCode, required int durationMs}) {
    if (!kDebugMode) return;
    if (statusCode >= 400) {
      AppLog.e('API', 'ERROR $method ${_path(url)} status=$statusCode ms=$durationMs');
    }
  }

  static void _logApiError({required String method, required String url, required Object error}) {
    if (!kDebugMode) return;
    final msg = error is String ? error : error.toString();
    AppLog.e('API', 'ERROR $method ${_path(url)} msg=$msg');
  }
}
