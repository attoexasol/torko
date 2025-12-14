import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.lightPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: GoogleFonts.notoSansBengali().fontFamily,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightCard,
        error: AppColors.lightDestructive,
        onPrimary: AppColors.lightPrimaryForeground,
        onSecondary: AppColors.lightSecondaryForeground,
        onSurface: AppColors.lightForeground,
        onError: AppColors.lightDestructiveForeground,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      // inputDecorationTheme: InputDecorationTheme(
      //   filled: true,
      //   fillColor: AppColors.lightInputBackground,
      //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radius), borderSide: BorderSide(color: AppColors.lightBorder),),
      //   enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radius), borderSide: BorderSide(color: AppColors.lightBorder),),
      //   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radius), borderSide: BorderSide(color: AppColors.lightRing, width: 0),),
      // ),

      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppSizes.fontSize2xl,
          fontWeight: FontWeight.w500,
          color: AppColors.lightForeground,
          height: 1.5,
        ),
        displayMedium: TextStyle(
          fontSize: AppSizes.fontSizeXl,
          fontWeight: FontWeight.w500,
          color: AppColors.lightForeground,
          height: 1.5,
        ),
        displaySmall: TextStyle(
          fontSize: AppSizes.fontSizeLg,
          fontWeight: FontWeight.w500,
          color: AppColors.lightForeground,
          height: 1.5,
        ),
        headlineMedium: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w500,
          color: AppColors.lightForeground,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w400,
          color: AppColors.lightForeground,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w400,
          color: AppColors.lightForeground,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w500,
          color: AppColors.lightForeground,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightForeground),
        titleTextStyle: TextStyle(
          color: AppColors.lightForeground,
          fontSize: AppSizes.fontSizeLg,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: AppColors.lightBorder,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: GoogleFonts.notoSansBengali().fontFamily,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkCard,
        error: AppColors.darkDestructive,
        onPrimary: AppColors.darkPrimaryForeground,
        onSecondary: AppColors.darkSecondaryForeground,
        onSurface: AppColors.darkForeground,
        onError: AppColors.darkDestructiveForeground,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          borderSide: BorderSide(color: AppColors.darkRing, width: 2),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppSizes.fontSize2xl,
          fontWeight: FontWeight.w500,
          color: AppColors.darkForeground,
          height: 1.5,
        ),
        displayMedium: TextStyle(
          fontSize: AppSizes.fontSizeXl,
          fontWeight: FontWeight.w500,
          color: AppColors.darkForeground,
          height: 1.5,
        ),
        displaySmall: TextStyle(
          fontSize: AppSizes.fontSizeLg,
          fontWeight: FontWeight.w500,
          color: AppColors.darkForeground,
          height: 1.5,
        ),
        headlineMedium: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w500,
          color: AppColors.darkForeground,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w400,
          color: AppColors.darkForeground,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w400,
          color: AppColors.darkForeground,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: AppSizes.fontSizeBase,
          fontWeight: FontWeight.w500,
          color: AppColors.darkForeground,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkForeground),
        titleTextStyle: TextStyle(
          color: AppColors.darkForeground,
          fontSize: AppSizes.fontSizeLg,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: AppColors.darkBorder,
    );
  }
}

