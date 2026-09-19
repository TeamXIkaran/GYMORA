import 'dart:math';

import 'package:flutter/material.dart';

/// Floating particle effect — accent-colored and white specks that drift
/// upward with a gentle sine-wave sway.
///
/// Parameters let each screen tweak density, size range, and sway.
class ParticlePainter extends CustomPainter {
  final double time;
  final Color accentColor;
  final List<_Particle> _particles;

  ParticlePainter({
    required this.time,
    required this.accentColor,
    int count = 30,
    double maxRadius = 1.8,
    double minRadius = 0.4,
    double maxOpacity = 0.4,
    double minOpacity = 0.1,
    double swayAmount = 12,
    double nonAccentOpacityFactor = 0.3,
  }) : _particles = List.generate(
         count,
         (i) => _Particle(
           i,
           maxRadius: maxRadius,
           minRadius: minRadius,
           maxOpacity: maxOpacity,
           minOpacity: minOpacity,
         ),
       ),
       _swayAmount = swayAmount,
       _nonAccentFactor = nonAccentOpacityFactor;

  final double _swayAmount;
  final double _nonAccentFactor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x =
          (p.baseX * size.width + sin(time * 2 * pi + p.phase) * _swayAmount) %
          size.width;

      final rawY = p.baseY * size.height - (time * size.height * p.speed);
      final y = rawY % size.height;

      final lifeFrac = y / size.height;
      final opacity = p.opacity * lifeFrac;

      final paint = Paint()
        ..color = p.isAccent
            ? accentColor.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: opacity * _nonAccentFactor);

      if (p.isAccent) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) => true;
}

class _Particle {
  late final double baseX;
  late final double baseY;
  late final double speed;
  late final double radius;
  late final double opacity;
  late final double phase;
  late final bool isAccent;

  _Particle(
    int seed, {
    required double maxRadius,
    required double minRadius,
    required double maxOpacity,
    required double minOpacity,
  }) {
    final r = Random(seed * 17 + 42);
    baseX = r.nextDouble();
    baseY = r.nextDouble();
    speed = r.nextDouble() * 0.4 + 0.1;
    radius = r.nextDouble() * maxRadius + minRadius;
    opacity = r.nextDouble() * maxOpacity + minOpacity;
    phase = r.nextDouble() * 2 * pi;
    isAccent = r.nextDouble() > 0.6;
  }
}
