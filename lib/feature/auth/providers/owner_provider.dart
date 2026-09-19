import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/api/network/owner_service.dart';
import 'package:gymora_fitness_management/core/extension/secure_storage_extension.dart';
import 'package:gymora_fitness_management/core/model/owner_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// OWNER PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

enum OwnerStatus { initial, loading, authenticated, unauthenticated, error }

class OwnerProvider extends ChangeNotifier {
  final OwnerService _service;
  final SecureStorageExtension _storage;

  OwnerProvider({OwnerService? service, SecureStorageExtension? storage})
    : _service = service ?? OwnerService(),
      _storage = storage ?? SecureStorageExtension();

  // ── State ──
  OwnerStatus _status = OwnerStatus.initial;
  OwnerModel? _owner;
  PurchaseResponse? _purchaseResponse;
  String? _errorMessage;

  // ── Getters ──
  OwnerStatus get status => _status;
  OwnerModel? get owner => _owner;
  PurchaseResponse? get purchaseResponse => _purchaseResponse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == OwnerStatus.loading;
  bool get isAuthenticated => _status == OwnerStatus.authenticated;

  // ─────────────────────────────────────────────────────────────────────
  // OWNER LOGIN
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> login({required String gymId, required String password}) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final request = OwnerLoginRequest(gymId: gymId, password: password);
    final response = await _service.login(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] LOGIN RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Login failed';
      notifyListeners();
      return false;
    }

    final loginData = response.data!;

    // Persist token
    await _storage.saveToken(loginData.token);

    _owner = loginData.owner;
    _status = OwnerStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // OWNER PURCHASE
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> purchase({
    required String gymName,
    required String gymId,
    required String password,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
    required String plan,
  }) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final request = PurchaseRequest(
      gymName: gymName,
      gymId: gymId,
      password: password,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      ownerPhone: ownerPhone,
      plan: plan,
    );

    final response = await _service.purchase(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] PURCHASE RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Purchase failed';
      notifyListeners();
      return false;
    }

    _purchaseResponse = response.data!;
    _status = OwnerStatus.initial;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // OWNER PROFILE
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> fetchProfile() async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getProfile();

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] PROFILE RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Failed to fetch profile';
      notifyListeners();
      return false;
    }

    _owner = response.data!;
    _status = OwnerStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> forgotPassword({required String email}) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final request = ForgotPasswordRequest(email: email);
    final response = await _service.forgotPassword(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] FORGOT PASSWORD RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Failed to send OTP';
      notifyListeners();
      return false;
    }

    _status = OwnerStatus.initial;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // VERIFY OTP
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final request = VerifyOtpRequest(email: email, otp: otp);
    final response = await _service.verifyOtp(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] VERIFY OTP RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'OTP verification failed';
      notifyListeners();
      return false;
    }

    _status = OwnerStatus.initial;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final request = ResetPasswordRequest(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    final response = await _service.resetPassword(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] RESET PASSWORD RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Password reset failed';
      notifyListeners();
      return false;
    }

    _status = OwnerStatus.initial;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.deleteToken();
    _owner = null;
    _purchaseResponse = null;
    _errorMessage = null;
    _status = OwnerStatus.unauthenticated;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────
  // CLEAR ERROR
  // ─────────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
