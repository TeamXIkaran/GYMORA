import 'package:flutter/material.dart';
import 'package:karan_fitness/core/api/network/auth_service.dart';
import 'package:karan_fitness/core/extension/secure_storage_extension.dart';
import 'package:karan_fitness/core/model/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecureStorageExtension _storage;

  AuthProvider({AuthService? authService, SecureStorageExtension? storage})
    : _authService = authService ?? AuthService(),
      _storage = storage ?? SecureStorageExtension();

  // ── State ──
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isCreatingUser = false;

  // ── Getters ──
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isCreatingUser => _isCreatingUser;

  // ── Login ──
  Future<bool> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequest(email: email, password: password);
    final response = await _authService.login(request);

    if (!response.success || response.data == null) {
      _status = AuthStatus.error;
      _errorMessage = response.message ?? 'Login failed';
      notifyListeners();
      return false;
    }

    final loginData = response.data!;

    // Validate role matches the screen they logged in from
    if (loginData.user.role != expectedRole) {
      _status = AuthStatus.error;
      _errorMessage =
          'This account is registered as "${loginData.user.role}". '
          'Please use the correct login.';
      notifyListeners();
      return false;
    }

    // Persist token
    await _storage.saveToken(loginData.token);

    _user = loginData.user;
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ── Create Trainer (owner only) ──
  Future<(bool, String)> createTrainer({
    required String name,
    required String email,
    required String password,
  }) async {
    _isCreatingUser = true;
    notifyListeners();

    final request = CreateUserRequest(
      name: name,
      email: email,
      password: password,
    );
    final response = await _authService.createTrainer(request);

    _isCreatingUser = false;
    notifyListeners();

    if (response.success && response.data != null) {
      return (true, response.message ?? 'Trainer created successfully');
    }
    return (false, response.message ?? 'Failed to create trainer');
  }

  // ── Create Client (owner or trainer) ──
  Future<(bool, String)> createClient({
    required String name,
    required String email,
    required String password,
  }) async {
    _isCreatingUser = true;
    notifyListeners();

    final request = CreateUserRequest(
      name: name,
      email: email,
      password: password,
    );
    final response = await _authService.createClient(request);

    _isCreatingUser = false;
    notifyListeners();

    if (response.success && response.data != null) {
      return (true, response.message ?? 'Client created successfully');
    }
    return (false, response.message ?? 'Failed to create client');
  }

  // ── Logout ──
  Future<void> logout() async {
    await _storage.deleteToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Clear error ──
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Try auto-login from stored token ──
  Future<void> tryAutoLogin() async {
    final token = await _storage.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    // Token exists but we don't have user info cached —
    // you could add a /me endpoint later. For now, remain unauthenticated
    // so the user picks a role and logs in fresh.
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
