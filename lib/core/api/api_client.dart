import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API client for Laravel backend.
/// Uses baseUrl and POST method for create_users and other auth endpoints.
class ApiClient {
  ApiClient({String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://torko.attoexasolutions.com/api';

  final String _baseUrl;

  String get baseUrl => _baseUrl;

  /// POST request to the given path.
  /// Path should not include leading slash (e.g. 'create_users').
  /// Returns decoded JSON body or throws [ApiException].
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl/$path');
    final mergedHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
    final bodyBytes = body != null ? utf8.encode(jsonEncode(body)) : null;

    try {
      final response = await http
          .post(uri, headers: mergedHeaders, body: bodyBytes)
          .timeout(const Duration(seconds: 15));

      final decoded = _tryDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded ?? <String, dynamic>{};
      }

      final msg = _extractError(decoded) ?? 'Request failed (${response.statusCode})';
      throw ApiException(msg, statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
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

  static String? _extractError(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return json['message']?.toString() ??
          json['error']?.toString() ??
          json['Error']?.toString();
    }
    return json.toString();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
