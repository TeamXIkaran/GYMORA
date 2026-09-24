import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
/// Reads values from the loaded .env file — no code changes needed
/// when switching between dev / staging / production.
class EnvConfig {
  EnvConfig._();

  // ── Core URLs ──────────────────────────────────────────────
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/';

  // ── App Identity ───────────────────────────────────────────
  static String get appName => dotenv.env['APP_NAME'] ?? 'GYMORA';

  static String get environment => dotenv.env['ENV'] ?? 'development';

  // ── Convenience Flags ──────────────────────────────────────
  static bool get isDev => environment == 'development';

  // ── Add more keys here as needed ───────────────────────────
  // static String get firebaseKey => dotenv.env['FIREBASE_KEY'] ?? '';
  // static String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
  // static String get awsFrontendUrl => dotenv.env['AWS_FRONTEND_URL'] ?? '';
}
