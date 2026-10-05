import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymora_fitness_management/config/routes/app_routes.dart';
import 'package:gymora_fitness_management/config/theme/app_theme.dart';
import 'package:gymora_fitness_management/core/layout/app_responsive_frame.dart';
import 'package:gymora_fitness_management/feature/auth/providers/auth_provider.dart';
import 'package:gymora_fitness_management/feature/auth/providers/owner_login_provider.dart';
import 'package:gymora_fitness_management/feature/auth/providers/payment_provider.dart';
import 'package:gymora_fitness_management/feature/auth/providers/trainer_login_provider.dart'
    hide OwnerTrainerProvider;
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
import 'package:gymora_fitness_management/feature/trainer/providers/trainer_dashboard_provider.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // ENVIRONMENT
  // ===========================================================================
  //
  // Development:
  // flutter run
  //
  // Production:
  // flutter run --dart-define=ENV=prod
  //
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  try {
    await dotenv.load(fileName: 'env/.env.$env');

    debugPrint('✅ Loaded environment: $env');
  } catch (e) {
    debugPrint('⚠️ Could not load env/.env.$env: $e');
  }

  // ===========================================================================
  // APP
  // ===========================================================================

  runApp(
    MultiProvider(
      providers: [
        // ---------------------------------------------------------------------
        // AUTH
        // ---------------------------------------------------------------------
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => OwnerLoginProvider()),

        ChangeNotifierProvider(create: (_) => TrainerLoginProvider()),

        // ---------------------------------------------------------------------
        // PAYMENT
        // ---------------------------------------------------------------------
        ChangeNotifierProvider(create: (_) => PaymentProvider()),

        // ---------------------------------------------------------------------
        // OWNER
        // ---------------------------------------------------------------------
        ChangeNotifierProvider(create: (_) => OwnerDashboardProvider()),

        ChangeNotifierProvider(create: (_) => OwnerTrainerProvider()),

        ChangeNotifierProvider(create: (_) => OwnerMemberProvider()),

        // ---------------------------------------------------------------------
        // TRAINER
        // ---------------------------------------------------------------------
        //
        // TrainerDashboardProvider is a singleton.
        // Therefore use `.value` instead of creating another instance.
        //
        ChangeNotifierProvider.value(value: TrainerDashboardProvider.instance),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'GYMORA',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
      builder: (context, child) => AppResponsiveFrame(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
