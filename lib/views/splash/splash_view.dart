import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller - it will handle navigation in onInit()
    Get.put(SplashController());
    
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth < 350 ? 150.0 : 200.0;

    
    return Scaffold(
      backgroundColor: AppColors.lightSecondary, // #B8DED6
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: logoSize,
          height: logoSize,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(logoSize * 0.2),
              ),
              child: Center(
                child: Text(
                  'তর্ক',
                  style: TextStyle(
                    fontSize: logoSize * 0.24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
