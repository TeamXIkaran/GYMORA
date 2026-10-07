import 'package:flutter/material.dart';

class ShimmerButton extends StatefulWidget {
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
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<double> _slideAnimation;

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Right -> Left slide animation set to 1.2 seconds (1200ms).
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<double>(begin: 1.4, end: -1.4).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOutCubic),
    );

    // Quick spring shrink animation on tap
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handlePressed() async {
    if (!widget.enabled) return;

    // Trigger shrink scale
    _scaleController.forward();

    // Restart the 1.2s right-to-left slide
    _slideController.forward(from: 0.0);

    // Pop back to full scale
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _scaleController.reverse();
    }

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                // ============================================================
                // ORIGINAL SHIMMER
                // ============================================================
                if (widget.enabled)
                  AnimatedBuilder(
                    animation: widget.shimmerCtrl,
                    builder: (_, _) {
                      final dx = widget.shimmerCtrl.value * 3 - 1;

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

                // ============================================================
                // CLICK SLIDE EFFECT - RIGHT TO LEFT (1.2s)
                // ============================================================
                if (widget.enabled)
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: FractionallySizedBox(
                          widthFactor: 0.45,
                          alignment: Alignment(_slideAnimation.value, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.28),
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // ============================================================
                // BUTTON CONTENT
                // ============================================================
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.enabled ? _handlePressed : null,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    splashColor: Colors.white.withValues(alpha: 0.12),
                    highlightColor: Colors.white.withValues(alpha: 0.04),
                    child: Center(
                      child:
                          widget.child ??
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (widget.label ?? '').toUpperCase(),
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: widget.textColor,
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
      ),
    );
  }
}
