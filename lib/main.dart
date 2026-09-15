import 'package:flutter/material.dart';
import 'package:karan_fitness/config/routes/app_routes.dart';
import 'package:karan_fitness/config/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
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