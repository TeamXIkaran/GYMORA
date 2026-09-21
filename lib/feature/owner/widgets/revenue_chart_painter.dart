import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

/// Custom painter that draws the revenue area chart on the dashboard.
class RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = (size.height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(size.width * 0.00, size.height * 0.72),
      Offset(size.width * 0.18, size.height * 0.48),
      Offset(size.width * 0.36, size.height * 0.62),
      Offset(size.width * 0.54, size.height * 0.30),
      Offset(size.width * 0.72, size.height * 0.46),
      Offset(size.width * 0.88, size.height * 0.15),
      Offset(size.width * 1.00, size.height * 0.25),
    ];

    final areaPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }

    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary.withValues(alpha: 0.20), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = AppColors.primary;

    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
      canvas.drawCircle(
        point,
        7,
        Paint()..color = AppColors.primary.withValues(alpha: 0.10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// Small chart label widget for month names below the revenue chart.
class ChartLabel extends StatelessWidget {
  final String text;

  const ChartLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white24, fontSize: 9),
    );
  }
}
