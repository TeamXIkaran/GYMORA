import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/Vignette_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/particle_painter_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/scan_line_widget.dart';



/// Standard dark background stack used by every auth screen.
///
/// Layers (bottom → top): solid black, particle field, accent glow,
/// scanlines, vignette, then [child] content.
class AuthBackground extends StatelessWidget {
  final Color accentColor;
  final Animation<double> particleAnimation;
  final Animation<double> glowPulseAnimation;
  final double glowTopFraction;
  final Widget child;

  // Particle tuning
  final int particleCount;
  final double particleMaxRadius;
  final double particleMinRadius;
  final double particleMaxOpacity;
  final double particleMinOpacity;
  final double particleSwayAmount;
  final double particleNonAccentOpacityFactor;

  const AuthBackground({
    super.key,
    required this.accentColor,
    required this.particleAnimation,
    required this.glowPulseAnimation,
    required this.child,
    this.glowTopFraction = 0.08,
    this.particleCount = 30,
    this.particleMaxRadius = 1.8,
    this.particleMinRadius = 0.4,
    this.particleMaxOpacity = 0.4,
    this.particleMinOpacity = 0.1,
    this.particleSwayAmount = 12,
    this.particleNonAccentOpacityFactor = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Solid background
        Positioned.fill(child: ColoredBox(color: AppColors.background)),

        // Particles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: particleAnimation,
            builder: (_, _) => CustomPaint(
              size: Size.infinite,
              painter: ParticlePainter(
                time: particleAnimation.value,
                accentColor: accentColor,
                count: particleCount,
                maxRadius: particleMaxRadius,
                minRadius: particleMinRadius,
                maxOpacity: particleMaxOpacity,
                minOpacity: particleMinOpacity,
                swayAmount: particleSwayAmount,
                nonAccentOpacityFactor: particleNonAccentOpacityFactor,
              ),
            ),
          ),
        ),

        // Accent glow
        AnimatedBuilder(
          animation: glowPulseAnimation,
          builder: (_, _) {
            final glowOpacity = 0.12 + glowPulseAnimation.value * 0.08;
            return Positioned(
              top: size.height * glowTopFraction,
              left: size.width / 2 - 150,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: glowOpacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Scanlines + Vignette
        const Scanlines(),
        const Vignette(),

        // Content
        child,
      ],
    );
  }
}
