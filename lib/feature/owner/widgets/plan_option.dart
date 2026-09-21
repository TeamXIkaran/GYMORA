import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

/// Selectable plan option widget used in add/renew membership bottom sheets.
class PlanOption extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final bool selected;
  final VoidCallback onTap;

  const PlanOption({
    super.key,
    required this.title,
    required this.price,
    required this.duration,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : Colors.white30,
              size: 17,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              duration,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white30, fontSize: 7),
            ),
          ],
        ),
      ),
    );
  }
}
