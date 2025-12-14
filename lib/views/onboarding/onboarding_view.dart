import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    return Scaffold(
      body: Obx(() {
        final language = appController.language;
        
        return Stack(
          children: [
            // Full-Screen Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/064b2e909a16e9c01aeefc0200a24a582996e060.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF2E7D32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Language Toggle - Top Right
            Positioned(
              top: MediaQuery.of(context).padding.top + 24,
              right: 24,
              child: GestureDetector(
                onTap: () => appController.toggleLanguage(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        language == AppLanguage.bn ? 'EN' : 'বাংলা',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content Area - Top
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 20,
              right: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 350;
                  final titleSize = isSmallScreen ? 36.0 : 48.0;
                  final subtitleSize = isSmallScreen ? 15.0 : 18.0;
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main Title
                      Text(
                        language == AppLanguage.bn ? 'তর্কে স্বাগতম' : 'Welcome to Torko',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.17,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        language == AppLanguage.bn
                            ? 'আপনার চিন্তা শেয়ার করুন, বন্ধুদের সাথে যুক্ত থাকুন'
                            : 'Share your thoughts, stay connected with friends',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFF2F2F2),
                          height: 1.56,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Get Started Button
                      GestureDetector(
                        onTap: () => Get.offNamed(AppRoutes.login),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary, // #D6775C
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                language == AppLanguage.bn ? 'শুরু করুন' : 'Get Started',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  height: 1.33,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
