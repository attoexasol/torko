// lib/data/service/network_caller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
    _logRequest(method: 'GET', url: url, headers: headers);

    try {
      final res = await get(uri, headers: headers).timeout(const Duration(seconds: 10));
      sw.stop();

      final decoded = _tryDecode(res.body);
      final ok = res.statusCode >= 200 && res.statusCode < 300;

      _logResponse(
        method: 'GET', url: url, statusCode: res.statusCode,
        body: res.body, durationMs: sw.elapsedMilliseconds,
        headers: res.request?.headers,
      );

      return NetworkResponse(
        isSuccess: ok, statusCode: res.statusCode,
        body: ok ? decoded : null,
        errorMessage: ok ? null : _extractError(decoded),
      );
    } on TimeoutException {
      sw.stop();
      _logError(method: 'GET', url: url, error: 'Timeout after ${sw.elapsedMilliseconds}ms');
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: "Request timed out. Check your internet.");
    } catch (e) {
      sw.stop();
      _logError(method: 'GET', url: url, error: e.toString());
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
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
    _logRequest(method: 'POST', url: url, headers: mergedHeaders, body: body);

    try {
      final res = await post(uri, headers: mergedHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      sw.stop();

      final decoded = _tryDecode(res.body);
      final ok = res.statusCode >= 200 && res.statusCode < 300;

      _logResponse(
        method: 'POST', url: url, statusCode: res.statusCode,
        body: res.body, durationMs: sw.elapsedMilliseconds,
        headers: res.request?.headers,
      );

      return NetworkResponse(
        isSuccess: ok, statusCode: res.statusCode,
        body: ok ? decoded : null,
        errorMessage: ok ? null : _extractError(decoded),
      );
    } on TimeoutException {
      sw.stop();
      _logError(method: 'POST', url: url, error: 'Timeout after ${sw.elapsedMilliseconds}ms');
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: "Request timed out. Check your internet.");
    } catch (e) {
      sw.stop();
      _logError(method: 'POST', url: url, error: e.toString());
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
    _logRequest(method: 'POST(FORM)', url: url, headers: mergedHeaders, body: fields);

    try {
      final res = await post(uri, headers: mergedHeaders, body: fields)
          .timeout(const Duration(seconds: 10));
      sw.stop();

      final decoded = _tryDecode(res.body);
      final ok = res.statusCode >= 200 && res.statusCode < 300;

      _logResponse(
        method: 'POST(FORM)', url: url, statusCode: res.statusCode,
        body: res.body, durationMs: sw.elapsedMilliseconds,
        headers: res.request?.headers,
      );

      return NetworkResponse(
        isSuccess: ok, statusCode: res.statusCode,
        body: ok ? decoded : null,
        errorMessage: ok ? null : _extractError(decoded),
      );
    } on TimeoutException {
      sw.stop();
      _logError(method: 'POST(FORM)', url: url, error: 'Timeout after ${sw.elapsedMilliseconds}ms');
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: "Request timed out. Check your internet.");
    } catch (e) {
      sw.stop();
      _logError(method: 'POST(FORM)', url: url, error: e.toString());
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  // ---------- helpers ----------
  static String _extractError(dynamic json) {
    if (json == null) return _defaultErrorMessage;
    if (json is Map<String, dynamic>) {
      return json['Error'] ?? json['error'] ?? json['message'] ?? json['detail'] ?? _defaultErrorMessage;
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

  static void _logRequest({required String method, required String url, Map<String, String>? headers, Map? body}) {
    if (!kDebugMode) return;
    debugPrint('================ HTTP REQUEST ================\n'
        'Method  : $method\nURL     : $url\nHeaders : ${_pretty(headers)}\nBody    : ${_pretty(body)}\n'
        '=============================================');
  }

  static void _logResponse({required String method, required String url, required int statusCode, required String body,
    required int durationMs, Map<String, String>? headers}) {
    if (!kDebugMode) return;
    debugPrint('================ HTTP RESPONSE ===============\n'
        'Method   : $method\nURL      : $url\nStatus   : $statusCode\nDuration : ${durationMs}ms\n'
        'Headers  : ${_pretty(headers)}\nBody     : ${body.isEmpty ? "<empty>" : body}\n'
        '=============================================');
  }

  static void _logError({required String method, required String url, required String error}) {
    if (!kDebugMode) return;
    debugPrint('================ HTTP ERROR ==================\n'
        'Method : $method\nURL    : $url\nError  : $error\n'
        '=============================================');
  }

  static String _pretty(Object? obj) {
    if (obj == null) return '{}';
    try { return const JsonEncoder.withIndent('  ').convert(obj); } catch (_) { return obj.toString(); }
  }
}
