import 'package:flutter/material.dart';
import 'package:karan_fitness/config/routes/app_routes.dart';
import 'package:karan_fitness/config/theme/app_theme.dart';
import 'package:karan_fitness/feature/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
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

      title: 'GYMO Fitness',

      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      routerConfig: AppRouter.router,
    );
  }
}
