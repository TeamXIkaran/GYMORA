import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karan_fitness/config/routes/app_router.dart';

import 'package:karan_fitness/feature/auth/screens/splash_screen.dart';

// Global Key for Contextless Navigation
// Useful for session expiry, push notifications, etc.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splashRoute,

    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splashRoute,
        name: 'splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
    ],

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text(
            'No route defined for ${state.uri}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
  );
}
