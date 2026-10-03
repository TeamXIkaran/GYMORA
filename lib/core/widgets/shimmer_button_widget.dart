import 'package:flutter/material.dart';

/// Gradient CTA button with a sweeping shimmer animation.
///
/// When [label] is null the button shows only [child] (used by splash screen
/// for its hardcoded "GET STARTED" text). Otherwise it renders the label in
/// uppercase with an arrow icon.
class ShimmerButton extends StatelessWidget {
  final AnimationController shimmerCtrl;
  final List<Color> gradientColors;
  final Color textColor;
  final Color accentColor;
  final String? label;
  final bool enabled;
  final VoidCallback onPressed;
  final Widget? child;
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerButton({
    super.key,
    required this.shimmerCtrl,
    required this.gradientColors,
    required this.accentColor,
    required this.onPressed,
    this.textColor = Colors.white,
    this.label,
    this.enabled = true,
    this.child,
    this.width,
    this.height = 54,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Shimmer sweep
              if (enabled)
                AnimatedBuilder(
                  animation: shimmerCtrl,
                  builder: (_, _) {
                    final dx = shimmerCtrl.value * 3 - 1;
                    return Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment(dx, 0),
                        widthFactor: 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Tap area
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? onPressed : null,
                  borderRadius: BorderRadius.circular(borderRadius),
                  splashColor: Colors.white.withValues(alpha: 0.12),
                  child: Center(
                    child:
                        child ??
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (label ?? '').toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: textColor,
                              size: 20,
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
