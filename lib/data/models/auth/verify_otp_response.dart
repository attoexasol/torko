/// Response from verify_otp API
class VerifyOtpResponse {
  final bool status;
  final String message;
  final String apiToken;

  const VerifyOtpResponse({
    required this.status,
    required this.message,
    required this.apiToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return VerifyOtpResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      apiToken: data['api_token']?.toString() ?? data['token']?.toString() ?? '',
    );
  }
}
