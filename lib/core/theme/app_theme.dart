import 'package:flutter/material.dart';
import 'package:med_sync/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.warmWhite,
      onSurface: AppColors.navyText,
    );

    final textTheme = Typography.blackCupertino.apply(
      fontFamily: 'Inter',
      bodyColor: AppColors.navyText,
      displayColor: AppColors.navyText,
    );

    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.warmWhite,
      fontFamily: 'Inter',
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(fontFamily: 'Manrope'),
        displayMedium: textTheme.displayMedium?.copyWith(fontFamily: 'Manrope'),
        displaySmall: textTheme.displaySmall?.copyWith(fontFamily: 'Manrope'),
        headlineLarge: textTheme.headlineLarge?.copyWith(fontFamily: 'Manrope'),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontFamily: 'Manrope',
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(fontFamily: 'Manrope'),
        titleLarge: textTheme.titleLarge?.copyWith(fontFamily: 'Manrope'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmWhite,
        foregroundColor: AppColors.navyText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 2,
        shadowColor: AppColors.navyText.withValues(alpha: 0.08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColors.slateLabel),
      ),
    );
  }
}
