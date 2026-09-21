import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

/// Generic particle used across all owner screens.
/// Each screen passes a different [seedMultiplier] and [seedOffset]
/// to produce visually distinct particle layouts.
class OwnerParticle {
  late final double x;
  late final double y;
  late final double speed;
  late final double radius;
  late final double opacity;
  late final double phase;
  late final bool isRed;

  OwnerParticle(int seed, {int seedMultiplier = 17, int seedOffset = 100}) {
    final random = Random(seed * seedMultiplier + seedOffset);

    x = random.nextDouble();
    y = random.nextDouble();
    speed = random.nextDouble() * 0.35 + 0.08;
    radius = random.nextDouble() * 1.5 + 0.4;
    opacity = random.nextDouble() * 0.35 + 0.08;
    phase = random.nextDouble() * 2 * pi;
    isRed = random.nextDouble() > 0.55;
  }
}

/// Generic particle painter for owner screens.
/// Customize with [particleCount], [seedMultiplier], [seedOffset],
/// and [whiteOpacityFactor].
class OwnerParticlePainter extends CustomPainter {
  final double time;
  final List<OwnerParticle> particles;

  OwnerParticlePainter(
    this.time, {
    int particleCount = 28,
    int seedMultiplier = 17,
    int seedOffset = 100,
    double whiteOpacityFactor = 0.20,
  }) : particles = List.generate(
         particleCount,
         (index) => OwnerParticle(
           index,
           seedMultiplier: seedMultiplier,
           seedOffset: seedOffset,
         ),
       ),
       _whiteOpacityFactor = whiteOpacityFactor;

  final double _whiteOpacityFactor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x =
          particle.x * size.width + sin(time * 2 * pi + particle.phase) * 10;

      final y =
          (particle.y * size.height - time * size.height * particle.speed) %
          size.height;

      final paint = Paint()
        ..color = particle.isRed
            ? AppColors.primary.withValues(alpha: particle.opacity)
            : Colors.white.withValues(
                alpha: particle.opacity * _whiteOpacityFactor,
              );

      if (particle.isRed) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawCircle(Offset(x, y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OwnerParticlePainter oldDelegate) {
    return true;
  }
}

/// Dashboard particles: 28 particles, seed * 17 + 100
class DashboardParticlePainter extends OwnerParticlePainter {
  DashboardParticlePainter(super.time)
    : super(
        particleCount: 28,
        seedMultiplier: 17,
        seedOffset: 100,
        whiteOpacityFactor: 0.20,
      );
}

/// Members particles: 24 particles, seed * 21 + 150
class MembersParticlePainter extends OwnerParticlePainter {
  MembersParticlePainter(super.time)
    : super(
        particleCount: 24,
        seedMultiplier: 21,
        seedOffset: 150,
        whiteOpacityFactor: 0.18,
      );
}

/// Trainers particles: 24 particles, seed * 23 + 200
class TrainersParticlePainter extends OwnerParticlePainter {
  TrainersParticlePainter(super.time)
    : super(
        particleCount: 24,
        seedMultiplier: 23,
        seedOffset: 200,
        whiteOpacityFactor: 0.18,
      );
}

/// Membership particles: 24 particles, seed * 27 + 300
class MembershipParticlePainter extends OwnerParticlePainter {
  MembershipParticlePainter(super.time)
    : super(
        particleCount: 24,
        seedMultiplier: 27,
        seedOffset: 300,
        whiteOpacityFactor: 0.18,
      );
}

/// Profile particles: 22 particles, seed * 31 + 400
class ProfileParticlePainter extends OwnerParticlePainter {
  ProfileParticlePainter(super.time)
    : super(
        particleCount: 22,
        seedMultiplier: 31,
        seedOffset: 400,
        whiteOpacityFactor: 0.16,
      );
}
