import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';

import 'package:gymora_fitness_management/feature/owner/widgets/trainer_avatar.dart';


/// Card widget displaying a trainer's info in the trainers list.
class TrainerCard extends StatelessWidget {
  final OwnerTrainerModel trainer;
  final int index;
  final VoidCallback onTap;

  const TrainerCard({
    super.key,
    required this.trainer,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = trainer.status == 'Active';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                TrainerAvatar(initials: trainer.initials, index: index),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        trainer.specialization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC107),
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${trainer.rating}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Icon(
                            Icons.people_alt_outlined,
                            color: Colors.white30,
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${trainer.clients} Clients',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF36D57D).withValues(alpha: 0.09)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF42D982)
                                  : Colors.white30,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            trainer.status,
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF48DF8B)
                                  : Colors.white38,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white24,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.primary,
                    size: 15,
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Experience',
                    style: TextStyle(color: Colors.white30, fontSize: 8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    trainer.experience,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF42D982)
                          : Colors.white30,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isActive ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF42D982)
                          : Colors.white30,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
