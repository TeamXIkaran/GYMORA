import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // GYMORA MEMBER THEME
  // Cyan / Blue / Violet
  // ============================================================

  static const Color background = Color(0xFF050912);
  static const Color backgroundSecondary = Color(0xFF091321);

  // Main surfaces
  static const Color card = Color(0xFF0D1726);
  static const Color cardLight = Color(0xFF142236);

  static const Color surface = Color(0xFF0D1726);
  static const Color surfaceHigh = Color(0xFF142236);
  static const Color surfaceHighest = Color(0xFF1A2B42);

  // ============================================================
  // TEXT
  // ============================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color textPrimary = Color(0xFFF5F9FF);
  static const Color textSecondary = Color(0xFF9AAAC0);
  static const Color textMuted = Color(0xFF64748B);

  static const Color text = Color(0xFFF5F9FF);
  static const Color muted = Color(0xFF64748B);

  // ============================================================
  // BORDERS / DIVIDERS
  // ============================================================

  static const Color divider = Color(0xFF1B2B40);

  static const Color stroke = Color(0xFF1B2B40);
  static const Color strokeStrong = Color(0xFF2A405C);

  // ============================================================
  // MAIN BRAND COLORS
  // ============================================================

  static const Color primary = Color(0xFF00C8FF);

  static const Color cyan = Color(0xFF00C8FF);
  static const Color blue = Color(0xFF287BFF);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFFF3D81);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color success = Color(0xFF22C55E);
  static const Color green = Color(0xFF22C55E);

  static const Color warning = Color(0xFFFFB31A);
  static const Color amber = Color(0xFFFFB31A);

  static const Color info = Color(0xFF0BAFE7);

  static const Color orange = Color(0xFFFF7A18);

  static const Color lime = Color(0xFFA3E635);

  static const Color errorRed = Color(0xFFFF174F);

  // ============================================================
  // MEMBER GRADIENTS
  // ============================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C8FF), Color(0xFF287BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF287BFF), Color(0xFF5B5FEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF287BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFFB31A), Color(0xFFFF5A1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // OWNER THEME
  // ============================================================

  static const Color ownerPrimary = Color(0xFFE62B52);
  static const Color ownerBright = Color(0xFFFF174F);
  static const Color ownerDark = Color(0xFF7D2E30);

  static const LinearGradient ownerGradient = LinearGradient(
    colors: [Color(0xFFFF174F), Color(0xFFE62B52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // TRAINER THEME
  // ============================================================

  static const Color trainerPrimary = Color(0xFFEE9D2D);
  static const Color trainerBright = Color(0xFFFFB31A);
  static const Color trainerDark = Color(0xFF43211E);

  static const LinearGradient trainerGradient = LinearGradient(
    colors: [Color(0xFFFFB31A), Color(0xFFEE9D2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // CLIENT THEME
  // ============================================================

  static const Color clientPrimary = Color(0xFF0BAFE7);
  static const Color clientBright = Color(0xFF00C8FF);
  static const Color clientDark = Color(0xFF075B78);

  static const LinearGradient clientGradient = LinearGradient(
    colors: [Color(0xFF00C8FF), Color(0xFF0BAFE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // DARK BACKGROUND GRADIENT
  // ============================================================

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF050912), Color(0xFF091321)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // GYMORA ALIASES
  // ============================================================

  static const Color gymBackground = background;
  static const Color gymSurface = surface;
  static const Color gymSurfaceHigh = surfaceHigh;
  static const Color gymSurfaceHighest = surfaceHighest;
  static const Color gymText = text;
  static const Color gymMuted = muted;
  static const Color gymStroke = stroke;
  static const Color gymStrokeStrong = strokeStrong;
}

// ============================================================================
// CUSTOM BUTTON
// ============================================================================

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final IconData? icon;

  /// Solid button color.
  ///
  /// If [gradient] is provided, gradient will be used instead.
  final Color? color;

  /// Text and icon color.
  final Color? textColor;

  /// Optional custom gradient.
  final Gradient? gradient;

  final double height;
  final double borderRadius;

  final bool isLoading;

  /// Button shadow can be disabled when required.
  final bool showShadow;

  /// Button opacity when disabled.
  final double disabledOpacity;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.gradient,
    this.height = 54,
    this.borderRadius = 16,
    this.isLoading = false,
    this.showShadow = true,
    this.disabledOpacity = 0.55,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = color ?? AppColors.primary;

    final bool isDisabled = onPressed == null || isLoading;

    final Gradient buttonGradient =
        gradient ??
        LinearGradient(
          colors: [buttonColor, buttonColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Opacity(
      opacity: isDisabled ? disabledOpacity : 1.0,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: buttonGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: showShadow && !isDisabled
                ? [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.28),
                      blurRadius: 14,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: AppColors.white.withValues(alpha: 0.12),
              highlightColor: AppColors.white.withValues(alpha: 0.05),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : _buildButtonContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final Color contentColor = textColor ?? AppColors.white;

    if (icon == null) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: contentColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: contentColor),

        const SizedBox(width: 9),

        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: contentColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
