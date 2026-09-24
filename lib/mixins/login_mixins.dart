import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/feature/auth/providers/auth_provider.dart';

import 'package:provider/provider.dart';

/// Shared login logic for Owner / Trainer / Client screens.
/// Mix into any login screen State to get [performLogin] and [showSnackBar].
mixin LoginMixin<T extends StatefulWidget> on State<T> {
  bool isSubmitting = false;

  /// Validates inputs, calls AuthProvider.login, and navigates on success.
  Future<void> performLogin({
    required TextEditingController emailCtrl,
    required TextEditingController passwordCtrl,
    required String role,
    required String successRoute,
  }) async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar('Please enter email and password', isError: true);
      return;
    }

    setState(() => isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: email,
      password: password,
      expectedRole: role,
    );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (success) {
      showSnackBar('Welcome back, ${auth.user?.name ?? ''}!');
      context.goNamed(successRoute);
    } else {
      showSnackBar(auth.errorMessage ?? 'Login failed', isError: true);
    }
  }

  void showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError
            ? const Color(0xFFCF2942)
            : const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}
