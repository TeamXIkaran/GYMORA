import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

/// Reusable detail row widget used in bottom sheets across member,
/// trainer, and membership screens.
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isStatus;

  const DetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: isStatus ? const Color(0xFF42D982) : AppColors.primary,
          ),
          const SizedBox(width: 11),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isStatus ? const Color(0xFF42D982) : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
