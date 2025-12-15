// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../../core/controllers/app_controller.dart';
// import '../../core/routes/app_routes.dart';
// import '../../core/theme/app_colors.dart';
//
// class LoginView extends StatefulWidget {
//   const LoginView({super.key});
//
//   @override
//   State<LoginView> createState() => _LoginViewState();
// }
//
// class _LoginViewState extends State<LoginView> {
//   final appController = Get.find<AppController>();
//
//   String step = 'phone'; // 'phone' or 'otp'
//   String phoneNumber = '';
//   String otp = '';
//   int resendTimer = 0;
//   bool canResend = true;
//   bool cookiesAccepted = false;
//   bool showPhoneError = false;
//   bool termsAccepted = false;
//   bool showOtpResentConfirm = false;
//
//   final phoneController = TextEditingController();
//   final List<TextEditingController> otpControllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );
//   final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
//
//   bool isValidPhoneNumber(String phone) {
//     final digits = phone.replaceAll(RegExp(r'\D'), '');
//     if (digits.length != 11) return false;
//     if (!digits.startsWith('0')) return false;
//
//     final validPrefixes = ['017', '018', '013', '012', '016', '014', '015', '019',];
//     final prefix = digits.substring(0, 3);
//
//     return validPrefixes.contains(prefix);
//   }
//
//   void handlePhoneSubmit() {
//     if (isValidPhoneNumber(phoneNumber) && termsAccepted) {
//       setState(() {
//         step = 'otp';
//         resendTimer = 0;
//         canResend = true;
//         showPhoneError = false;
//       });
//     } else {
//       if (!isValidPhoneNumber(phoneNumber)) {
//         setState(() => showPhoneError = true);
//       }
//     }
//   }
//
//   void handleOTPComplete() {
//     final fullOtp = otpControllers.map((c) => c.text).join();
//     if (fullOtp.length == 6) {
//       Get.offAllNamed(AppRoutes.profileData);
//     }
//   }
//
//   void handleResendOTP() {
//     if (canResend) {
//       setState(() {
//         resendTimer = 60;
//         canResend = false;
//         otp = '';
//         for (var controller in otpControllers) {
//           controller.clear();
//         }
//         showOtpResentConfirm = true;
//       });
//
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() => showOtpResentConfirm = false);
//         }
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     phoneController.dispose();
//     for (var controller in otpControllers) {
//       controller.dispose();
//     }
//     for (var node in otpFocusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final isDark = appController.isDarkMode;
//       final language = appController.language;
//
//       return Scaffold(
//         resizeToAvoidBottomInset: true,
//         backgroundColor: isDark
//             ? AppColors.darkBackground
//             : const Color(0xFFF5F5F5),
//         body: SafeArea(
//           child: Stack(
//             children: [
//               SingleChildScrollView(
//                 padding: EdgeInsets.only(
//                   bottom: cookiesAccepted ? 0 : 140, // space for cookie card
//                 ),
//                 child: step == 'phone'
//                     ? _buildPhoneStep(isDark, language)
//                     : _buildOtpStep(isDark, language),
//               ),
//
//               if (!cookiesAccepted)
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Card(
//                     margin: EdgeInsets.zero,
//                     child: _buildCookieNotice(isDark, language),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//
//
//
//
//
//
//
//
//
//
//
//
//     });
//   }
//
//   Widget _buildPhoneStep(bool isDark, AppLanguage language) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Back Button & Theme Toggle Row
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Back Button
//               GestureDetector(
//                 onTap: () => Get.back(),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.arrow_back,
//                       color: isDark
//                           ? const Color(0xFF9B9B9B)
//                           : const Color(0xFF6B6B6B),
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       appController.t('back'),
//                       style: TextStyle(
//                         color: isDark
//                             ? const Color(0xFF9B9B9B)
//                             : const Color(0xFF6B6B6B),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Theme Toggle
//               GestureDetector(
//                 onTap: () => appController.toggleTheme(),
//                 child: Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? const Color(0xFF0a2f3d)
//                         : const Color(0xFFFAFAF8),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isDark
//                           ? const Color(0xFF0d3a4a)
//                           : Colors.black.withOpacity(0.1),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 15,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     isDark ? Icons.wb_sunny : Icons.nightlight_round,
//                     color: isDark
//                         ? const Color(0xFFF5F5F5)
//                         : const Color(0xFF2C2C2E),
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Content
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 24),
//
//               // Title
//               Text(
//                 appController.t('enterPhone'),
//                 style: TextStyle(
//                   color: isDark
//                       ? const Color(0xFFF5F5F5)
//                       : const Color(0xFF2C2C2E),
//                   fontSize: 36,
//                   fontWeight: FontWeight.w700,
//                   height: 1.11,
//                   letterSpacing: -0.9,
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Subtitle
//               Text(
//                 appController.t('sendOTPDescription'),
//                 style: TextStyle(
//                   color: isDark
//                       ? const Color(0xFF9B9B9B)
//                       : const Color(0xFF6B6B6B),
//                   fontSize: 16,
//                   height: 1.63,
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               // Phone Number Label
//               Text(
//                 appController.t('phoneNumberLabel'),
//                 style: TextStyle(
//                   color: isDark
//                       ? const Color(0xFFF5F5F5)
//                       : const Color(0xFF2C2C2E),
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Phone Input Row
//               Row(
//                 children: [
//                   // Country Code
//                   Container(
//                     height: 56,
//                     padding: const EdgeInsets.symmetric(horizontal: 18),
//                     decoration: BoxDecoration(
//                       color: isDark
//                           ? const Color(0xFF0a2f3d)
//                           : const Color(0xFFFAFAF8),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: isDark
//                             ? const Color(0xFF0d3a4a)
//                             : Colors.black.withOpacity(0.1),
//                         width: 2,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.phone,
//                           color: isDark
//                               ? const Color(0xFF9B9B9B)
//                               : const Color(0xFF6B6B6B),
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           '+88',
//                           style: TextStyle(
//                             color: isDark
//                                 ? const Color(0xFF9B9B9B)
//                                 : const Color(0xFF6B6B6B),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   // Phone Input
//                   Expanded(
//                     child: Container(
//                       height: 56,
//                       padding: const EdgeInsets.symmetric(horizontal: 18),
//                       decoration: BoxDecoration(
//                         color: isDark
//                             ? const Color(0xFF0a2f3d)
//                             : const Color(0xFFFAFAF8),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: isDark
//                               ? const Color(0xFF0d3a4a)
//                               : Colors.black.withOpacity(0.1),
//                           width: 2,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: phoneController,
//                               keyboardType: TextInputType.phone,
//                               style: TextStyle(
//                                 color: isDark
//                                     ? const Color(0xFFF5F5F5)
//                                     : const Color(0xFF2C2C2E),
//                                 fontSize: 16,
//                               ),
//
//                               decoration: InputDecoration(
//                                 hintText: '01XXX-XXXXXX',
//                                 hintStyle: TextStyle(
//                                   color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
//                                 ),
//
//                                 filled: false,
//
//                                 border: InputBorder.none,
//                                 enabledBorder: InputBorder.none,
//                                 focusedBorder: InputBorder.none,
//                                 disabledBorder: InputBorder.none,
//                                 errorBorder: InputBorder.none,
//                               ),
//
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r'[0-9-]'),
//                                 ),
//                                 LengthLimitingTextInputFormatter(12),
//                               ],
//                               onChanged: (value) {
//                                 final digitsOnly = value.replaceAll('-', '');
//                                 if (digitsOnly.length > 5) {
//                                   phoneController.text =
//                                       '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5)}';
//                                   phoneController.selection =
//                                       TextSelection.fromPosition(
//                                         TextPosition(
//                                           offset: phoneController.text.length,
//                                         ),
//                                       );
//                                 }
//                                 setState(() {
//                                   phoneNumber = phoneController.text;
//                                   if (showPhoneError) showPhoneError = false;
//                                 });
//                               },
//                             ),
//                           ),
//                           if (isValidPhoneNumber(phoneNumber))
//                             Container(
//                               width: 22,
//                               height: 22,
//                               decoration: const BoxDecoration(
//                                 color: Colors.green,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.check,
//                                 color: Colors.white,
//                                 size: 14,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Error or Example Text
//               const SizedBox(height: 4),
//               Text(
//                 showPhoneError
//                     ? appController.t('invalidPhone')
//                     : appController.t('phoneExample'),
//                 style: TextStyle(
//                   color: showPhoneError
//                       ? Colors.red
//                       : (isDark
//                             ? const Color(0xFF9B9B9B)
//                             : const Color(0xFF6B6B6B)),
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Terms Checkbox
//               GestureDetector(
//                 onTap: () => setState(() => termsAccepted = !termsAccepted),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: termsAccepted
//                             ? AppColors.lightPrimary
//                             : (isDark
//                                   ? const Color(0xFF0a2f3d)
//                                   : const Color(0xFFFAFAF8)),
//                         borderRadius: BorderRadius.circular(4),
//                         border: Border.all(
//                           color: termsAccepted
//                               ? AppColors.lightPrimary
//                               : (isDark
//                                     ? const Color(0xFF0d3a4a)
//                                     : Colors.black.withOpacity(0.2)),
//                           width: 2,
//                         ),
//                       ),
//                       child: termsAccepted
//                           ? const Icon(
//                               Icons.check,
//                               color: Colors.white,
//                               size: 14,
//                             )
//                           : null,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text.rich(
//                         TextSpan(
//                           style: TextStyle(
//                             color: isDark
//                                 ? const Color(0xFF9B9B9B)
//                                 : const Color(0xFF6B6B6B),
//                             fontSize: 13,
//                           ),
//                           children: language == AppLanguage.bn
//                               ? [
//                                   const TextSpan(text: 'আমি '),
//                                   TextSpan(
//                                     text: 'শর্তাবলী',
//                                     style: TextStyle(
//                                       color: AppColors.lightPrimary,
//                                     ),
//                                   ),
//                                   const TextSpan(text: ' এবং '),
//                                   TextSpan(
//                                     text: 'গোপনীয়তা নীতিতে',
//                                     style: TextStyle(
//                                       color: AppColors.lightPrimary,
//                                     ),
//                                   ),
//                                   const TextSpan(text: ' সম্মত আছি'),
//                                 ]
//                               : [
//                                   const TextSpan(text: 'I agree to the '),
//                                   TextSpan(
//                                     text: 'Terms and Conditions',
//                                     style: TextStyle(
//                                       color: AppColors.lightPrimary,
//                                     ),
//                                   ),
//                                   const TextSpan(text: ' and '),
//                                   TextSpan(
//                                     text: 'Privacy Policy',
//                                     style: TextStyle(
//                                       color: AppColors.lightPrimary,
//                                     ),
//                                   ),
//                                 ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Continue Button
//               GestureDetector(
//                 onTap: (isValidPhoneNumber(phoneNumber) && termsAccepted)
//                     ? handlePhoneSubmit
//                     : null,
//                 child: Container(
//                   width: double.infinity,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: AppColors.lightPrimary.withOpacity(
//                       (isValidPhoneNumber(phoneNumber) && termsAccepted)
//                           ? 1.0
//                           : 0.4,
//                     ),
//                     borderRadius: BorderRadius.circular(28),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 6,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         appController.t('continue'),
//                         style: const TextStyle(
//                           color: Color(0xFFF5F5F5),
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Icon(
//                         Icons.arrow_forward,
//                         color: Color(0xFFF5F5F5),
//                         size: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOtpStep(bool isDark, AppLanguage language) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Back Button & Theme Toggle Row
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               GestureDetector(
//                 onTap: () => setState(() => step = 'phone'),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.arrow_back,
//                       color: isDark
//                           ? const Color(0xFF9B9B9B)
//                           : const Color(0xFF6B6B6B),
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       appController.t('back'),
//                       style: TextStyle(
//                         color: isDark
//                             ? const Color(0xFF9B9B9B)
//                             : const Color(0xFF6B6B6B),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => appController.toggleTheme(),
//                 child: Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? const Color(0xFF0a2f3d)
//                         : const Color(0xFFFAFAF8),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isDark
//                           ? const Color(0xFF0d3a4a)
//                           : Colors.black.withOpacity(0.1),
//                     ),
//                   ),
//                   child: Icon(
//                     isDark ? Icons.wb_sunny : Icons.nightlight_round,
//                     color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 24),
//
//               Text(
//                 appController.t('verifyOTP'),
//                 style: TextStyle(
//                   color: isDark
//                       ? const Color(0xFFF5F5F5)
//                       : const Color(0xFF2C2C2E),
//                   fontSize: 36,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: -0.9,
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               Text(
//                 '+88 $phoneNumber ${appController.t('otpSentTo')}',
//                 style: TextStyle(
//                   color: isDark
//                       ? const Color(0xFF9B9B9B)
//                       : const Color(0xFF6B6B6B),
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               // OTP Input
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ...List.generate(3, (i) => _buildOtpBox(i, isDark)),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Text(
//                         '-',
//                         style: TextStyle(
//                           color: isDark
//                               ? const Color(0xFF9B9B9B)
//                               : const Color(0xFF6B6B6B),
//                           fontSize: 18,
//                         ),
//                       ),
//                     ),
//                     ...List.generate(3, (i) => _buildOtpBox(i + 3, isDark)),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Resend OTP
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       appController.t('didntGetCode'),
//                       style: TextStyle(
//                         color: isDark
//                             ? const Color(0xFF9B9B9B)
//                             : const Color(0xFF6B6B6B),
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     GestureDetector(
//                       onTap: canResend ? handleResendOTP : null,
//                       child: Text(
//                         canResend
//                             ? appController.t('resendOTP')
//                             : '${appController.t('resendOTP')} (${resendTimer ~/ 60}:${(resendTimer % 60).toString().padLeft(2, '0')})',
//                         style: TextStyle(
//                           color: canResend
//                               ? AppColors.lightPrimary
//                               : (isDark
//                                     ? const Color(0xFF9B9B9B)
//                                     : const Color(0xFF6B6B6B)),
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               if (showOtpResentConfirm)
//                 Container(
//                   margin: const EdgeInsets.only(top: 16),
//                   child: Center(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 18,
//                           height: 18,
//                           decoration: const BoxDecoration(
//                             color: AppColors.lightSecondary,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.check,
//                             color: Color(0xFF1A1A1A),
//                             size: 12,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           appController.t('otpResent'),
//                           style: TextStyle(
//                             color: isDark
//                                 ? AppColors.lightSecondary
//                                 : const Color(0xFF7BC3B8),
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 24),
//
//               // Continue Button
//               GestureDetector(
//                 onTap: otpControllers.every((c) => c.text.isNotEmpty)
//                     ? handleOTPComplete
//                     : null,
//                 child: Container(
//                   width: double.infinity,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: AppColors.lightPrimary.withOpacity(
//                       otpControllers.every((c) => c.text.isNotEmpty)
//                           ? 1.0
//                           : 0.4,
//                     ),
//                     borderRadius: BorderRadius.circular(28),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         appController.t('continue'),
//                         style: const TextStyle(
//                           color: Color(0xFFF5F5F5),
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Icon(
//                         Icons.arrow_forward,
//                         color: Color(0xFFF5F5F5),
//                         size: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOtpBox(int index, bool isDark) {
//     return Container(
//       width: 48,
//       height: 48,
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isDark
//               ? const Color(0xFF0d3a4a)
//               : Colors.black.withOpacity(0.1),
//           width: 2,
//         ),
//       ),
//       child: TextField(
//         controller: otpControllers[index],
//         focusNode: otpFocusNodes[index],
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.number,
//         maxLength: 1,
//         style: TextStyle(
//           color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//         decoration: const InputDecoration(
//        //   border: InputBorder.none,
//           counterText: '',
//           border: InputBorder.none,
//           enabledBorder: InputBorder.none,
//           focusedBorder: InputBorder.none,
//           disabledBorder: InputBorder.none,
//           errorBorder: InputBorder.none,
//         ),
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//         onChanged: (value) {
//           if (value.isNotEmpty && index < 5) {
//             otpFocusNodes[index + 1].requestFocus();
//           }
//           if (otpControllers.every((c) => c.text.isNotEmpty)) {
//             handleOTPComplete();
//           }
//           setState(() {});
//         },
//       ),
//     );
//   }
//
//   Widget _buildCookieNotice(bool isDark, AppLanguage language) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark
//             ? const Color(0xFF052029).withOpacity(0.95)
//             : const Color(0xFFE8E8E8).withOpacity(0.95),
//         border: Border(
//           top: BorderSide(
//             color: isDark
//                 ? const Color(0xFF0d3a4a)
//                 : Colors.black.withOpacity(0.1),
//           ),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Text('🍪', style: TextStyle(fontSize: 12)),
//               const SizedBox(width: 8),
//               Text(
//                 appController.t('cookiesAbout'),
//                 style: TextStyle(
//                   color: isDark
//                       ? const Color(0xFFF5F5F5)
//                       : const Color(0xFF2C2C2E),
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             appController.t('cookiesDescription'),
//             style: TextStyle(
//               color: isDark ? const Color(0xFF9B9B9B) : const Color(0xFF6B6B6B),
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 12),
//           GestureDetector(
//             onTap: () => setState(() => cookiesAccepted = true),
//             child: Container(
//               width: double.infinity,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: AppColors.lightPrimary,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Center(
//                 child: Text(
//                   appController.t('acceptCookies'),
//                   style: const TextStyle(
//                     color: Color(0xFFF5F5F5),
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



















import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final appController = Get.find<AppController>();

  String step = 'phone'; // 'phone' or 'otp'
  String phoneNumber = '';
  String otp = '';
  int resendTimer = 0;
  bool canResend = true;
  bool cookiesAccepted = false;
  bool showPhoneError = false;
  bool termsAccepted = false;
  bool showOtpResentConfirm = false;

  final phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool isValidPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return false;
    if (!digits.startsWith('0')) return false;

    final validPrefixes = ['017', '018', '013', '012', '016', '014', '015', '019',];
    final prefix = digits.substring(0, 3);

    return validPrefixes.contains(prefix);
  }

  void handlePhoneSubmit() {
    if (isValidPhoneNumber(phoneNumber) && termsAccepted) {
      setState(() {
        step = 'otp';
        resendTimer = 0;
        canResend = true;
        showPhoneError = false;
      });
    } else {
      if (!isValidPhoneNumber(phoneNumber)) {
        setState(() => showPhoneError = true);
      }
    }
  }

  void handleOTPComplete() {
    final fullOtp = otpControllers.map((c) => c.text).join();
    if (fullOtp.length == 6) {
      Get.offAllNamed(AppRoutes.profileData);
    }
  }

  void handleResendOTP() {
    if (canResend) {
      setState(() {
        resendTimer = 60;
        canResend = false;
        otp = '';
        for (var controller in otpControllers) {
          controller.clear();
        }
        showOtpResentConfirm = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => showOtpResentConfirm = false);
        }
      });
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;

      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: isDark
            ? AppColors.darkBackground
            : const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Stack(
            children: [
              // SingleChildScrollView(
              //   padding: EdgeInsets.only(
              //     bottom: cookiesAccepted ? 0 : 140, // space for cookie card
              //   ),
              //   child: step == 'phone'
              //       ? _buildPhoneStep(isDark, language)
              //       : _buildOtpStep(isDark, language),
              // ),

              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(
                      bottom: cookiesAccepted ? 24 : 160,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: step == 'phone'
                            ? _buildPhoneStep(isDark, language)
                            : _buildOtpStep(isDark, language),
                      ),
                    ),
                  );
                },
              ),


              if (!cookiesAccepted)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: _buildCookieNotice(isDark, language),
                  ),
                ),
            ],
          ),
        ),
      );












    });
  }

  Widget _buildPhoneStep(bool isDark, AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button & Theme Toggle Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: isDark
                          ? const Color(0xFF9B9B9B)
                          : const Color(0xFF6B6B6B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appController.t('back'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF6B6B6B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Theme Toggle
              GestureDetector(
                onTap: () => appController.toggleTheme(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0a2f3d)
                        : const Color(0xFFFAFAF8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0d3a4a)
                          : Colors.black.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny : Icons.nightlight_round,
                    color: isDark
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFF2C2C2E),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Title
              Text(
                appController.t('enterPhone'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.11,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                appController.t('sendOTPDescription'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9B9B9B)
                      : const Color(0xFF6B6B6B),
                  fontSize: 16,
                  height: 1.63,
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number Label
              Text(
                appController.t('phoneNumberLabel'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Phone Input Row
              Row(
                children: [
                  // Country Code
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0a2f3d)
                          : const Color(0xFFFAFAF8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF0d3a4a)
                            : Colors.black.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: isDark
                              ? const Color(0xFF9B9B9B)
                              : const Color(0xFF6B6B6B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+88',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF9B9B9B)
                                : const Color(0xFF6B6B6B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Phone Input
                  Expanded(
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0a2f3d)
                            : const Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF0d3a4a)
                              : Colors.black.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFF5F5F5)
                                    : const Color(0xFF2C2C2E),
                                fontSize: 16,
                              ),

                              decoration: InputDecoration(
                                hintText: '01XXX-XXXXXX',
                                hintStyle: TextStyle(
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                                ),

                                filled: false,

                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                              ),

                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9-]'),
                                ),
                                LengthLimitingTextInputFormatter(12),
                              ],
                              onChanged: (value) {
                                final digitsOnly = value.replaceAll('-', '');
                                if (digitsOnly.length > 5) {
                                  phoneController.text =
                                  '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5)}';
                                  phoneController.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(
                                          offset: phoneController.text.length,
                                        ),
                                      );
                                }
                                setState(() {
                                  phoneNumber = phoneController.text;
                                  if (showPhoneError) showPhoneError = false;
                                });
                              },
                            ),
                          ),
                          if (isValidPhoneNumber(phoneNumber))
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Error or Example Text
              const SizedBox(height: 4),
              Text(
                showPhoneError
                    ? appController.t('invalidPhone')
                    : appController.t('phoneExample'),
                style: TextStyle(
                  color: showPhoneError
                      ? Colors.red
                      : (isDark
                      ? const Color(0xFF9B9B9B)
                      : const Color(0xFF6B6B6B)),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // Terms Checkbox
              GestureDetector(
                onTap: () => setState(() => termsAccepted = !termsAccepted),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: termsAccepted
                            ? AppColors.lightPrimary
                            : (isDark
                            ? const Color(0xFF0a2f3d)
                            : const Color(0xFFFAFAF8)),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: termsAccepted
                              ? AppColors.lightPrimary
                              : (isDark
                              ? const Color(0xFF0d3a4a)
                              : Colors.black.withOpacity(0.2)),
                          width: 2,
                        ),
                      ),
                      child: termsAccepted
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF9B9B9B)
                                : const Color(0xFF6B6B6B),
                            fontSize: 13,
                          ),
                          children: language == AppLanguage.bn
                              ? [
                            const TextSpan(text: 'আমি '),
                            TextSpan(
                              text: 'শর্তাবলী',
                              style: TextStyle(
                                color: AppColors.lightPrimary,
                              ),
                            ),
                            const TextSpan(text: ' এবং '),
                            TextSpan(
                              text: 'গোপনীয়তা নীতিতে',
                              style: TextStyle(
                                color: AppColors.lightPrimary,
                              ),
                            ),
                            const TextSpan(text: ' সম্মত আছি'),
                          ]
                              : [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: AppColors.lightPrimary,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button
              GestureDetector(
                onTap: (isValidPhoneNumber(phoneNumber) && termsAccepted)
                    ? handlePhoneSubmit
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(
                      (isValidPhoneNumber(phoneNumber) && termsAccepted)
                          ? 1.0
                          : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appController.t('continue'),
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFFF5F5F5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(bool isDark, AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button & Theme Toggle Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => step = 'phone'),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: isDark
                          ? const Color(0xFF9B9B9B)
                          : const Color(0xFF6B6B6B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appController.t('back'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF6B6B6B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => appController.toggleTheme(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0a2f3d)
                        : const Color(0xFFFAFAF8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0d3a4a)
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny : Icons.nightlight_round,
                    color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                appController.t('verifyOTP'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '+88 $phoneNumber ${appController.t('otpSentTo')}',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9B9B9B)
                      : const Color(0xFF6B6B6B),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(3, (i) => _buildOtpBox(i, isDark)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '-',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF9B9B9B)
                              : const Color(0xFF6B6B6B),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ...List.generate(3, (i) => _buildOtpBox(i + 3, isDark)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: Column(
                  children: [
                    Text(
                      appController.t('didntGetCode'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF6B6B6B),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: canResend ? handleResendOTP : null,
                      child: Text(
                        canResend
                            ? appController.t('resendOTP')
                            : '${appController.t('resendOTP')} (${resendTimer ~/ 60}:${(resendTimer % 60).toString().padLeft(2, '0')})',
                        style: TextStyle(
                          color: canResend
                              ? AppColors.lightPrimary
                              : (isDark
                              ? const Color(0xFF9B9B9B)
                              : const Color(0xFF6B6B6B)),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (showOtpResentConfirm)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.lightSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF1A1A1A),
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appController.t('otpResent'),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.lightSecondary
                                : const Color(0xFF7BC3B8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Continue Button
              GestureDetector(
                onTap: otpControllers.every((c) => c.text.isNotEmpty)
                    ? handleOTPComplete
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(
                      otpControllers.every((c) => c.text.isNotEmpty)
                          ? 1.0
                          : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appController.t('continue'),
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFFF5F5F5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? const Color(0xFF0d3a4a)
              : Colors.black.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: TextField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          //   border: InputBorder.none,
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            otpFocusNodes[index + 1].requestFocus();
          }
          if (otpControllers.every((c) => c.text.isNotEmpty)) {
            handleOTPComplete();
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCookieNotice(bool isDark, AppLanguage language) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF052029).withOpacity(0.95)
            : const Color(0xFFE8E8E8).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF0d3a4a)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍪', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Text(
                appController.t('cookiesAbout'),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2C2C2E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appController.t('cookiesDescription'),
            style: TextStyle(
              color: isDark ? const Color(0xFF9B9B9B) : const Color(0xFF6B6B6B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => cookiesAccepted = true),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  appController.t('acceptCookies'),
                  style: const TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

