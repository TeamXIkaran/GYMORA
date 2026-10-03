import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/core/widgets/app_shimmer.dart';

/// Loading / error / snack helpers shared by the trainer screens.

const Color _yellow = Color(0xFFFFC107);

class TrainerLoadingView extends StatelessWidget {
  final String message;

  const TrainerLoadingView({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer(message: message);
  }
}

class TrainerErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TrainerErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _yellow, size: 44),
            const SizedBox(height: 14),
            const Text(
              'Could not load data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _yellow,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.roleSelectionRoute),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              icon: const Icon(Icons.switch_account_rounded),
              label: const Text('Back to role selection'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin banner shown above content when a background refresh fails but we
/// still have older data on screen.
class TrainerErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TrainerErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: _yellow, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

void showTrainerErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
