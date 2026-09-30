import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ===============================================================
/// GYMORA MEMBER / TRAINER UI COLORS
/// ===============================================================
///
/// This file is a bridge between the new member UI widgets
/// and the existing AppColors of GYMORA.
///
/// Use:
///   GymColors.cyan
///   GymColors.blue
///   GymColors.violet
///   GymColors.surface
///   GymColors.primaryGradient
///
/// ===============================================================

class GymColors {
  GymColors._();

  // ---------------------------------------------------------------
  // BACKGROUND
  // ---------------------------------------------------------------

  static const Color background = AppColors.background;

  static const Color backgroundSecondary = AppColors.backgroundSecondary;

  // ---------------------------------------------------------------
  // SURFACE / CARDS
  // ---------------------------------------------------------------

  static const Color surface = AppColors.surface;

  static const Color surfaceHigh = AppColors.surfaceHigh;

  static const Color surfaceHighest = AppColors.surfaceHighest;

  // ---------------------------------------------------------------
  // TEXT
  // ---------------------------------------------------------------

  static const Color text = AppColors.text;

  static const Color textPrimary = AppColors.textPrimary;

  static const Color textSecondary = AppColors.textSecondary;

  static const Color muted = AppColors.muted;

  static const Color textMuted = AppColors.textMuted;

  // ---------------------------------------------------------------
  // BORDERS / STROKES
  // ---------------------------------------------------------------

  static const Color stroke = AppColors.stroke;

  static const Color strokeStrong = AppColors.strokeStrong;

  static const Color divider = AppColors.divider;

  // ---------------------------------------------------------------
  // MAIN MEMBER UI COLORS
  // ---------------------------------------------------------------

  static const Color primary = AppColors.primary;

  static const Color cyan = AppColors.cyan;

  static const Color blue = AppColors.blue;

  static const Color violet = AppColors.violet;

  // ---------------------------------------------------------------
  // ACCENT COLORS
  // ---------------------------------------------------------------

  static const Color pink = AppColors.pink;

  static const Color green = AppColors.green;

  static const Color success = AppColors.success;

  static const Color amber = AppColors.amber;

  static const Color warning = AppColors.warning;

  static const Color orange = AppColors.orange;

  static const Color lime = AppColors.lime;

  static const Color error = AppColors.errorRed;

  // ---------------------------------------------------------------
  // GRADIENTS
  // ---------------------------------------------------------------

  /// Main Cyan → Blue gradient
  static const LinearGradient primaryGradient = AppColors.primaryGradient;

  /// Blue → Violet gradient
  static const LinearGradient blueGradient = AppColors.blueGradient;

  /// Violet → Blue gradient
  static const LinearGradient violetGradient = AppColors.violetGradient;

  /// Orange → Red/Orange gradient
  static const LinearGradient fireGradient = AppColors.fireGradient;

  /// Existing dark background gradient
  static const LinearGradient darkGradient = AppColors.darkGradient;

  // ---------------------------------------------------------------
  // GLOW COLORS
  // ---------------------------------------------------------------

  static Color cyanGlow(double opacity) {
    return cyan.withValues(alpha: opacity);
  }

  static Color blueGlow(double opacity) {
    return blue.withValues(alpha: opacity);
  }

  static Color violetGlow(double opacity) {
    return violet.withValues(alpha: opacity);
  }

  static Color pinkGlow(double opacity) {
    return pink.withValues(alpha: opacity);
  }

  static Color greenGlow(double opacity) {
    return green.withValues(alpha: opacity);
  }

  // ---------------------------------------------------------------
  // COMMON TRANSPARENT COLORS
  // ---------------------------------------------------------------

  static Color cyanSoft = cyan.withValues(alpha: 0.10);

  static Color blueSoft = blue.withValues(alpha: 0.10);

  static Color violetSoft = violet.withValues(alpha: 0.10);

  static Color pinkSoft = pink.withValues(alpha: 0.10);

  static Color greenSoft = green.withValues(alpha: 0.10);

  // ---------------------------------------------------------------
  // MEMBER STATUS COLORS
  // ---------------------------------------------------------------

  static const Color active = AppColors.green;

  static const Color inactive = AppColors.textMuted;

  static const Color pending = AppColors.amber;

  static const Color expired = AppColors.errorRed;

  // ---------------------------------------------------------------
  // CHART COLORS
  // ---------------------------------------------------------------

  static const List<Color> chartGradient = [AppColors.cyan, AppColors.blue];

  static const List<Color> chartColors = [
    AppColors.cyan,
    AppColors.blue,
    AppColors.violet,
    AppColors.pink,
    AppColors.green,
    AppColors.amber,
  ];
}
