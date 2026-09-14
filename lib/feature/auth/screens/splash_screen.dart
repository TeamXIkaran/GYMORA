import 'package:flutter/material.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                // --- Middle Brand Logo & Taglines ---
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dumbbell Icon Branding
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // App Title: GYMO
                    const Text(
                      "GYMO",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle / Tagline
                    const Text(
                      "STRONGER TOGETHER",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Main Value Proposition Headline
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: 1.0,
                        ),
                        children: [
                          TextSpan(
                            text: "BUILD\nTRAIN\n",
                            style: TextStyle(color: AppColors.white),
                          ),
                          TextSpan(
                            text: "ACHIEVE",
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // --- Bottom Action Area ---
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Motivational Caption
                    const Text(
                      "Fitness isn't a destination.\nIt's a lifestyle.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Get Started Button
                    CustomButton(text: "Get Started", onPressed: () {}),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
