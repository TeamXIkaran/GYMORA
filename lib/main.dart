import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymora_fitness_management/config/routes/app_routes.dart';
import 'package:gymora_fitness_management/config/theme/app_theme.dart';
import 'package:gymora_fitness_management/feature/auth/providers/auth_provider.dart';
import 'package:gymora_fitness_management/feature/auth/providers/owner_login_provider.dart';
import 'package:gymora_fitness_management/feature/auth/providers/payment_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load the correct .env file based on build flavor ──

  // Production:   flutter run --dart-define=ENV=prod
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  try {
    await dotenv.load(fileName: 'env/.env.$env');
  } catch (e) {
    debugPrint('⚠️ Could not load env/.env.$env: $e');
    // Optionally load a fallback or continue with defaults
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OwnerLoginProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
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
    );
  }
}
