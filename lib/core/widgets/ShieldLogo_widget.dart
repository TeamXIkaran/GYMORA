import 'package:flutter/material.dart';

/// Shield-shaped logo with K letter, optional heartbeat line & dumbbell plates.
///
/// Color scheme is parameterized so the same widget serves every role:
///   Owner  → red   gradients
///   Trainer → gold  gradients
///   Client  → blue  gradients
class ShieldLogo extends StatelessWidget {
  final double size;
  final List<Color> outerGradientColors;
  final List<Color> innerGradientColors;
  final Color accentColor;
  final double shadowAlpha;
  final double blurRadius;
  final double spreadRadius;
  final bool drawHeartbeat;
  final bool drawDumbbells;

  const ShieldLogo({
    super.key,
    required this.size,
    required this.outerGradientColors,
    required this.innerGradientColors,
    required this.accentColor,
    this.shadowAlpha = 0.3,
    this.blurRadius = 30,
    this.spreadRadius = 3,
    this.drawHeartbeat = true,
    this.drawDumbbells = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: shadowAlpha),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size * 1.2),
        painter: _ShieldPainter(
          outerColors: outerGradientColors,
          innerColors: innerGradientColors,
          accentColor: accentColor,
          drawHeartbeat: drawHeartbeat,
          drawDumbbells: drawDumbbells,
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final List<Color> outerColors;
  final List<Color> innerColors;
  final Color accentColor;
  final bool drawHeartbeat;
  final bool drawDumbbells;

  const _ShieldPainter({
    required this.outerColors,
    required this.innerColors,
    required this.accentColor,
    required this.drawHeartbeat,
    required this.drawDumbbells,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // ── Outer shield ──
    final outerPath = Path()
      ..moveTo(cx, h * 0.03)
      ..lineTo(w * 0.93, h * 0.22)
      ..lineTo(w * 0.93, h * 0.55)
      ..quadraticBezierTo(w * 0.93, h * 0.78, cx, h * 0.97)
      ..quadraticBezierTo(w * 0.07, h * 0.78, w * 0.07, h * 0.55)
      ..lineTo(w * 0.07, h * 0.22)
      ..close();

    final outerGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: outerColors,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(outerPath, Paint()..shader = outerGrad);
    canvas.drawPath(
      outerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.12),
    );

    // ── Inner shield ──
    final innerPath = Path()
      ..moveTo(cx, h * 0.09)
      ..lineTo(w * 0.86, h * 0.26)
      ..lineTo(w * 0.86, h * 0.54)
      ..quadraticBezierTo(w * 0.86, h * 0.74, cx, h * 0.92)
      ..quadraticBezierTo(w * 0.14, h * 0.74, w * 0.14, h * 0.54)
      ..lineTo(w * 0.14, h * 0.26)
      ..close();

    final innerGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: innerColors,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(innerPath, Paint()..shader = innerGrad);
    canvas.drawPath(
      innerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = accentColor.withValues(alpha: 0.25),
    );

    // ── K letter ──
    final metalGrad = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFEEEEEE), Color(0xFF999999), Color(0xFFCCCCCC)],
    ).createShader(Rect.fromLTWH(w * 0.3, h * 0.3, w * 0.4, h * 0.4));

    final kPath = Path()
      ..moveTo(w * 0.35, h * 0.35)
      ..lineTo(w * 0.35, h * 0.72)
      ..lineTo(w * 0.42, h * 0.72)
      ..lineTo(w * 0.42, h * 0.57)
      ..lineTo(w * 0.60, h * 0.72)
      ..lineTo(w * 0.70, h * 0.72)
      ..lineTo(w * 0.50, h * 0.55)
      ..lineTo(w * 0.67, h * 0.35)
      ..lineTo(w * 0.57, h * 0.35)
      ..lineTo(w * 0.42, h * 0.52)
      ..lineTo(w * 0.42, h * 0.35)
      ..close();

    canvas.drawPath(
      kPath,
      Paint()
        ..shader = metalGrad
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3),
    );
    canvas.drawPath(kPath, Paint()..shader = metalGrad);

    if (!drawHeartbeat && !drawDumbbells) return;

    // ── Heartbeat line ──
    if (drawHeartbeat) {
      final hbPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.45)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final hbPath = Path()
        ..moveTo(w * 0.22, h * 0.52)
        ..lineTo(w * 0.32, h * 0.52)
        ..lineTo(w * 0.38, h * 0.42)
        ..lineTo(w * 0.43, h * 0.58)
        ..lineTo(w * 0.48, h * 0.44)
        ..lineTo(w * 0.53, h * 0.55)
        ..lineTo(w * 0.58, h * 0.50)
        ..lineTo(w * 0.68, h * 0.50)
        ..lineTo(w * 0.78, h * 0.52);

      canvas.drawPath(hbPath, hbPaint);
    }

    // ── Dumbbell plates ──
    if (drawDumbbells) {
      final dbPaint = Paint()
        ..shader = metalGrad
        ..color = Colors.white.withValues(alpha: 0.5);

      // Left
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, h * 0.47, w * 0.06, h * 0.09),
          const Radius.circular(2),
        ),
        dbPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.21, h * 0.49, w * 0.08, h * 0.05),
          const Radius.circular(1),
        ),
        dbPaint,
      );

      // Right
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.79, h * 0.47, w * 0.06, h * 0.09),
          const Radius.circular(2),
        ),
        dbPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.71, h * 0.49, w * 0.08, h * 0.05),
          const Radius.circular(1),
        ),
        dbPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}