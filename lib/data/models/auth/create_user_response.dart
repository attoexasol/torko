/// Response from create_users API
/// Backend contract: { status, message, data: { otp_code, token, firebase_uid, firebase_custom_token, exist } }
class CreateUserResponse {
  final bool status;
  final String message;
  final String token;
  final bool exist;
  final String? otpCode; // Debug only; don't show in prod UI
  final String? firebaseUid;
  final String? firebaseCustomToken;

  const CreateUserResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.exist,
    this.otpCode,
    this.firebaseUid,
    this.firebaseCustomToken,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CreateUserResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      exist: data['exist'] == true,
      otpCode: data['otp_code']?.toString(),
      firebaseUid: data['firebase_uid']?.toString(),
      firebaseCustomToken: data['firebase_custom_token']?.toString(),
    );
  }
}
