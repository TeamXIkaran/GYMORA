import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/feature/auth/screens/QR_payment_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/client_login_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/forgot_password_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/gym_details_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/owner_login_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/purchase_membership_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/role_selection_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/splash_screen.dart';
import 'package:gymora_fitness_management/feature/auth/screens/trainer_login_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/add_member_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/add_trainer_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/member_ship_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_dashboard_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_members_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_notification_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_profile_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_settings_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_trainers_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_clients_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_dashboard_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_profile_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_progress_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_schedule_screen.dart';

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
      // Auth Screens
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
      GoRoute(
        path: AppRoutes.forgetPasswordRoute,
        name: 'forgetpassword',
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.purchaseMemberShipRoute,
        name: 'purchaseMembership',
        builder: (context, state) {
          return const PurchaseMembershipScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.gymDetailedRoute,
        name: 'gymDetailed',
        builder: (context, state) {
          final extra = state.extra;

          final Map<String, dynamic>? planData = extra is Map<String, dynamic>
              ? extra
              : null;

          return GymDetailsScreen(planData: planData);
        },
      ),
      GoRoute(
        path: AppRoutes.qrScreenRoute,
        name: 'qrScreen',
        builder: (context, state) {
          final extra = state.extra;

          final Map<String, dynamic>? planData = extra is Map<String, dynamic>
              ? extra
              : null;

          return QRPaymentScreen(planData: planData);
        },
      ),
      // Owner Screens
      GoRoute(
        path: AppRoutes.ownerDashboardRoute,
        name: 'ownerDashboard',
        builder: (context, state) {
          return const OwnerDashboardScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.ownerMemberRoute,
        name: 'ownerMemberScreen',
        builder: (context, state) {
          return const OwnerMembersScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.ownerTrainerRoute,
        name: 'ownerTrainerScreen',
        builder: (context, state) {
          return const OwnerTrainersScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.memberShipRoute,
        name: 'memberShipScreen',
        builder: (context, state) {
          return const MembershipScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.ownerSettingRoute,
        name: 'onwerSettingScreen',
        builder: (context, state) {
          return const OwnerSettingsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.ownerNotificationRoute,
        name: 'onwerNotificationScreen',
        builder: (context, state) {
          return const OwnerNotificationScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.ownerProfileRoute,
        name: 'ownerProfile',
        builder: (context, state) => const OwnerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMemberRoute,
        name: 'addMember',
        builder: (context, state) => const AddMemberScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTrainerRoute,
        name: 'addTrainer',
        builder: (context, state) => const AddTrainerScreen(),
      ),

      // Trainer Screens
      GoRoute(
        path: AppRoutes.trainerDashboardRoute,
        name: 'trainerDashboardScreen',
        builder: (context, state) {
          return const TrainerDashboardScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.trainerClientRoute,
        name: 'trainerClientScreen',
        builder: (context, state) {
          return const TrainerClientsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.trainerProfileRoute,
        name: 'trainerTrainerScreen',
        builder: (context, state) {
          return const TrainerProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.trainerScheduleRoute,
        name: 'trainerScheduleScreen',
        builder: (context, state) {
          return const TrainerScheduleScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.trainerProgressRoute,
        name: 'trainerProgressScreen',
        builder: (context, state) {
          return const TrainerProgressScreen();
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
