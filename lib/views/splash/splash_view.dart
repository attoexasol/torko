import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'dart:async';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
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
