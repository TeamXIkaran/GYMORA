import 'package:flutter/material.dart';

import 'package:karan_fitness/config/theme/app_colors.dart';

/// "KARAN FITNESS" brand wordmark with the "K" highlighted in [accentColor].
class BrandText extends StatelessWidget {
  final Color accentColor;
  final double karanFontSize;
  final double fitnessFontSize;

  const BrandText({
    super.key,
    required this.accentColor,
    this.karanFontSize = 26,
    this.fitnessFontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "K",
              style: TextStyle(
                color: accentColor,
                fontSize: karanFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                shadows: [
                  Shadow(
                    color: accentColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            Text(
              "ARAN",
              style: TextStyle(
                color: AppColors.white,
                fontSize: karanFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          "FITNESS",
          style: TextStyle(
            color: accentColor.withValues(alpha: 0.7),
            fontSize: fitnessFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }
}
