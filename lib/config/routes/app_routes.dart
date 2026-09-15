import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karan_fitness/config/routes/app_router.dart';
import 'package:karan_fitness/feature/auth/screens/client_login_screen.dart';
import 'package:karan_fitness/feature/auth/screens/owner_login_screen.dart';
import 'package:karan_fitness/feature/auth/screens/role_selection_screen.dart';

import 'package:karan_fitness/feature/auth/screens/splash_screen.dart';
import 'package:karan_fitness/feature/auth/screens/trainer_login_screen.dart';

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
        name: 'splash-screen',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.roleSelectionRoute,
        name: 'role-selection',
        builder: (context, state) {
          return const RoleSelectionScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.roleSelectionRoute,
        name: 'roleSelection',
        builder: (context, state) {
          return const RoleSelectionScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.ownerloginRoute,
        name: 'ownerLogin',
        builder: (context, state) {
          return const OwnerLoginScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.trainerloginRoute,
        name: 'trainerLogin',
        builder: (context, state) {
          return const TrainerLoginScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.clientloginRoute,
        name: 'clientLogin',
        builder: (context, state) {
          return const ClientLoginScreen();
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
