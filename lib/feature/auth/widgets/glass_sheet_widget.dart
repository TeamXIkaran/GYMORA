// ── Reusable Private Widgets ──

import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';


class GlassSheet extends StatelessWidget {
  final Widget child;
  const GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}
