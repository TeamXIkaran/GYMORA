import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // COMMON COLORS
  // ============================================================

  static const Color background = Color(0xFF03070F);

  static const Color backgroundSecondary = Color(0xFF081521);

  static const Color card = Color(0xFF1A2C38);

  static const Color cardLight = Color(0xFF263946);

  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF000000);

  static const Color textPrimary = Color(0xFFFFFFFF);

  static const Color textSecondary = Color(0xFFBDB9BA);

  static const Color textMuted = Color(0xFF6F6C6F);

  static const Color divider = Color(0xFF263946);

  // ============================================================
  // COMMON ACTION COLORS
  // ============================================================

  static const Color primary = Color(0xFFE62B52);

  static const Color errorRed = Color(0xFFFF174F);

  static const Color success = Color(0xFF22C55E);

  static const Color warning = Color(0xFFFFB31A);

  static const Color info = Color(0xFF0BAFE7);

  // ============================================================
  // OWNER THEME
  // Red / Pink
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
  // Orange / Yellow
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
  // Cyan / Blue
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
  // COMMON DARK GRADIENT
  // ============================================================

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF03070F), Color(0xFF081521)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
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
