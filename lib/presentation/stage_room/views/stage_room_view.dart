import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';

class StageRoomView extends StatelessWidget {
  const StageRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            language == AppLanguage.bn ? 'স্টেজ রুম' : 'Stage Room',
            style: TextStyle(
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Text(
            language == AppLanguage.bn ? 'স্টেজ রুম পেজ' : 'Stage Room Page',
            style: TextStyle(
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
        ),
      );
    });
  }
}
