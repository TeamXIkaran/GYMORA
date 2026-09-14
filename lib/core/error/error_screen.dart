import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:karan_fitness/config/constants/app_constants.dart';
import 'package:karan_fitness/config/routes/app_router.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, required this.error, this.title, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ============================================================
                // ERROR ICON
                // ============================================================
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.20),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: AppColors.errorRed,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLarge),

                // ============================================================
                // ERROR TITLE
                // ============================================================
                Text(
                  title ?? 'Oops! Something went wrong',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingMedium),

                // ============================================================
                // ERROR MESSAGE
                // ============================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.20),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getFormattedError(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXLarge),

                // ============================================================
                // ACTION BUTTONS
                // ============================================================
                Column(
                  children: [
                    // Retry Button
                    if (onRetry != null) ...[
                      CustomButton(
                        text: 'Try Again',
                        onPressed: onRetry,
                        icon: Icons.refresh_rounded,
                        color: AppColors.errorRed,
                        height: AppConstants.buttonHeightLarge,
                        borderRadius: AppConstants.borderRadiusLarge,
                      ),

                      const SizedBox(height: AppConstants.spacingMedium),
                    ],

                    // Go Home Button
                    CustomButton(
                      text: 'Go to Home',
                      onPressed: () {
                        context.go(AppRoutes.splashRoute);
                      },
                      icon: Icons.home_rounded,
                      color: AppColors.cardLight,
                      textColor: AppColors.textPrimary,
                      height: AppConstants.buttonHeightLarge,
                      borderRadius: AppConstants.borderRadiusLarge,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingLarge),

                // ============================================================
                // CONTACT SUPPORT
                // ============================================================
                TextButton.icon(
                  onPressed: () {
                    // Add support navigation later.
                  },
                  icon: const Icon(
                    Icons.support_agent_rounded,
                    size: AppConstants.iconSizeMedium,
                    color: AppColors.textSecondary,
                  ),
                  label: const Text(
                    'Contact Support',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR FORMATTER
  // ============================================================

  String _getFormattedError() {
    final lowerError = error.toLowerCase();

    // Network
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Please check your internet connection and try again.';
    }

    // Timeout
    if (lowerError.contains('timeout')) {
      return 'The request took too long to complete. Please try again.';
    }

    // Not Found
    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return 'The page you\'re looking for could not be found.';
    }

    // Unauthorized
    if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return 'You need to log in to access this page.';
    }

    // Forbidden
    if (lowerError.contains('forbidden') || lowerError.contains('403')) {
      return 'You don\'t have permission to access this page.';
    }

    // Server
    if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'Our servers are experiencing issues. Please try again later.';
    }

    // Empty error
    if (error.trim().isEmpty) {
      return 'Something unexpected happened. Please try again.';
    }

    // Long error
    if (error.length > 100) {
      return '${error.substring(0, 100)}...';
    }

    return error;
  }
}

// ============================================================================
// NETWORK ERROR
// ============================================================================

class NetworkErrorScreen extends ErrorScreen {
  const NetworkErrorScreen({super.key, super.onRetry})
    : super(
        error: 'Please check your internet connection and try again.',
        title: 'No Internet Connection',
      );
}

// ============================================================================
// NOT FOUND ERROR
// ============================================================================

class NotFoundErrorScreen extends ErrorScreen {
  const NotFoundErrorScreen({super.key})
    : super(
        error: 'The page you\'re looking for could not be found.',
        title: 'Page Not Found',
      );
}

// ============================================================================
// SERVER ERROR
// ============================================================================

class ServerErrorScreen extends ErrorScreen {
  const ServerErrorScreen({super.key, super.onRetry})
    : super(
        error: 'Our servers are experiencing issues. Please try again later.',
        title: 'Server Error',
      );
}

// ============================================================================
// UNAUTHORIZED ERROR
// ============================================================================

class UnauthorizedErrorScreen extends ErrorScreen {
  const UnauthorizedErrorScreen({super.key, super.onRetry})
    : super(
        error: 'You need to log in to access this page.',
        title: 'Authentication Required',
      );
}
