/// Response from create_users API
class CreateUserResponse {
  final bool status;
  final String message;
  final String token;
  final bool exist;
  final String? otpCode; // Debug only; don't show in prod UI

  const CreateUserResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.exist,
    this.otpCode,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CreateUserResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      exist: data['exist'] == true,
      otpCode: data['otp_code']?.toString(),
    );
  }
}
