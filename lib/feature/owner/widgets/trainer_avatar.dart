import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

/// Trainer-specific avatar with pink/red gradient tones and border.
class TrainerAvatar extends StatelessWidget {
  final String initials;
  final int index;
  final double size;

  const TrainerAvatar({
    super.key,
    required this.initials,
    required this.index,
    this.size = 48,
  });

  static const List<List<Color>> gradients = [
    [Color(0xFFFF3158), Color(0xFF6A1025)],
    [Color(0xFFFF7043), Color(0xFF72152A)],
    [Color(0xFFE91E63), Color(0xFF54102B)],
    [Color(0xFFFF456B), Color(0xFF63152A)],
    [Color(0xFFC9274D), Color(0xFF4D0E1E)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = gradients[index % gradients.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.18),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.27,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
