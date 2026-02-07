import 'package:torko/core/api/api_client.dart';
import 'package:torko/data/models/auth/create_user_response.dart';

/// Auth API for Laravel backend.
/// create_users: POST { phone } -> AuthResponse (CreateUserResponse).
class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Create user / send OTP.
  /// POST create_users with body { "phone": "01712345678" }.
  /// Returns [CreateUserResponse] with token, firebase_uid, firebase_custom_token, exist, otp_code.
  Future<CreateUserResponse> createUser(String phone) async {
    final body = <String, dynamic>{'phone': phone};
    final json = await _client.post('create_users', body: body);

    final res = CreateUserResponse.fromJson(
      Map<String, dynamic>.from(json),
    );

    if (!res.status) {
      throw ApiException(res.message.isNotEmpty ? res.message : 'OTP request failed');
    }

    if (res.token.isEmpty) {
      throw ApiException('No token received');
    }

    return res;
  }
}
