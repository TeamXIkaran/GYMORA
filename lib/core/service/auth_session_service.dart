import 'dart:convert';

import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/core/extension/secure_storage_extension.dart';

/// Restores a saved role session and returns the dashboard path when usable.
class AuthSessionService {
  AuthSessionService({SecureStorageExtension? storage})
    : _storage = storage ?? SecureStorageExtension();

  final SecureStorageExtension _storage;

  Future<String?> restoreDashboardRoute() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return null;

    final claims = _readClaims(token);
    final expiry = _readExpiry(claims?['exp']);
    if (claims == null || (expiry != null && !expiry.isAfter(DateTime.now()))) {
      await _storage.deleteToken();
      return null;
    }

    final savedRole = await _storage.getRole();
    var role = savedRole?.trim() ?? '';
    if (role.isEmpty) {
      role = claims['role']?.toString() ?? '';
    }
    role = role.trim().toLowerCase();

    switch (role) {
      case 'owner':
        return AppRoutes.ownerDashboardRoute;
      case 'trainer':
        return AppRoutes.trainerDashboardRoute;
      case 'client':
      case 'member':
        return AppRoutes.memberHomeRoute;
      default:
        await _storage.deleteToken();
        return null;
    }
  }

  Map<String, dynamic>? _readClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  DateTime? _readExpiry(dynamic value) {
    final seconds = value is num ? value.toInt() : int.tryParse('$value');
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}