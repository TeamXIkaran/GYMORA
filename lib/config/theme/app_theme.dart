import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';

import 'app_text.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: GymColors.background,

    primaryColor: GymColors.primary,

    colorScheme: const ColorScheme.dark(
      primary: GymColors.ownerPrimary,
      secondary: GymColors.ownerBright,
      surface: GymColors.surface,
      onPrimary: GymColors.background,
      onSecondary: Colors.white,
      onSurface: GymColors.text,
      error: GymColors.error,
    ),

    // ==========================================================
    // APP BAR
    // ==========================================================
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: GymColors.text,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),

    // ==========================================================
    // CARDS
    // ==========================================================
    cardTheme: const CardThemeData(
      color: GymColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        side: BorderSide(color: GymColors.stroke),
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GymColors.surface,

      hintStyle: const TextStyle(color: GymColors.muted, fontSize: 14),

      labelStyle: const TextStyle(color: GymColors.textSecondary, fontSize: 14),

      floatingLabelStyle: const TextStyle(
        color: GymColors.ownerPrimary,
        fontWeight: FontWeight.w600,
      ),

      prefixIconColor: GymColors.textSecondary,

      suffixIconColor: GymColors.textSecondary,

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: GymColors.stroke),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: GymColors.ownerPrimary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: GymColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: GymColors.error, width: 1.5),
      ),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // ==========================================================
    // DIVIDER
    // ==========================================================
    dividerTheme: const DividerThemeData(
      color: GymColors.stroke,
      thickness: 1,
      space: 1,
    ),

    // ==========================================================
    // ICONS
    // ==========================================================
    iconTheme: const IconThemeData(color: GymColors.textSecondary),

    // ==========================================================
    // TEXT
    // ==========================================================
    textTheme: const TextTheme(
      displayLarge: GymText.h1,

      displayMedium: TextStyle(
        color: GymColors.text,
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ),

      headlineLarge: GymText.h1,

      headlineMedium: GymText.h2,

      headlineSmall: GymText.h3,

      titleLarge: GymText.h2,

      titleMedium: GymText.title,

      titleSmall: TextStyle(
        color: GymColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),

      bodyLarge: TextStyle(
        color: GymColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),

      bodyMedium: GymText.body,

      bodySmall: GymText.caption,

      labelLarge: GymText.button,

      labelMedium: TextStyle(
        color: GymColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),

      labelSmall: TextStyle(
        color: GymColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),

    // ==========================================================
    // BUTTON
    // ==========================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GymColors.ownerPrimary,
        foregroundColor: GymColors.background,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GymText.button,
      ),
    ),

    // ==========================================================
    // TEXT BUTTON
    // ==========================================================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GymColors.ownerPrimary,
        textStyle: GymText.button,
      ),
    ),

    // ==========================================================
    // SNACKBAR
    // ==========================================================
    snackBarTheme: SnackBarThemeData(
      backgroundColor: GymColors.surfaceHigh,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentTextStyle: const TextStyle(
        color: GymColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ==========================================================
    // PROGRESS
    // ==========================================================
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: GymColors.ownerPrimary,
      linearTrackColor: GymColors.surfaceHigh,
    ),

    // ==========================================================
    // RIPPLE
    // ==========================================================
    splashFactory: InkRipple.splashFactory,
  );
}
