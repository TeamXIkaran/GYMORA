import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/api/network/owner_service.dart';
import 'package:gymora_fitness_management/core/extension/secure_storage_extension.dart';
import 'package:gymora_fitness_management/core/model/owner_login_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// OWNER PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

enum OwnerStatus { initial, loading, authenticated, unauthenticated, error }

class OwnerLoginProvider extends ChangeNotifier {
  final OwnerService _service;
  final SecureStorageExtension _storage;

  OwnerLoginProvider({OwnerService? service, SecureStorageExtension? storage})
    : _service = service ?? OwnerService(),
      _storage = storage ?? SecureStorageExtension();

  // ── State ──
  OwnerStatus _status = OwnerStatus.initial;
  OwnerLoginModel? _owner;
  PurchaseResponse? _purchaseResponse;
  String? _errorMessage;
  int? _statusCode;

  // ── Getters ──
  OwnerStatus get status => _status;
  OwnerLoginModel? get owner => _owner;
  PurchaseResponse? get purchaseResponse => _purchaseResponse;
  String? get errorMessage => _errorMessage;
  int? get statusCode => _statusCode;
  bool get isLoading => _status == OwnerStatus.loading;
  bool get isAuthenticated => _status == OwnerStatus.authenticated;

  // ─────────────────────────────────────────────────────────────────────
  // OWNER LOGIN
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> login({required String gymId, required String password}) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    _statusCode = null;
    notifyListeners();

    final request = OwnerLoginRequest(gymId: gymId, password: password);
    final response = await _service.login(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] LOGIN RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 StatusCode: ${response.statusCode}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Login failed';
      _statusCode = response.statusCode;
      notifyListeners();
      return false;
    }

    final loginData = response.data!;

    // Persist token
    await _storage.saveToken(loginData.token);

    _owner = loginData.owner;
    _status = OwnerStatus.authenticated;
    _errorMessage = null;
    _statusCode = response.statusCode;
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
    _statusCode = null;
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
    debugPrint('📦 StatusCode: ${response.statusCode}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Purchase failed';
      _statusCode = response.statusCode;
      notifyListeners();
      return false;
    }

    _purchaseResponse = response.data!;
    _status = OwnerStatus.initial;
    _errorMessage = null;
    _statusCode = response.statusCode;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // OWNER PROFILE
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> fetchProfile() async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    _statusCode = null;
    notifyListeners();

    final response = await _service.getProfile();

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] PROFILE RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 StatusCode: ${response.statusCode}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Failed to fetch profile';
      _statusCode = response.statusCode;
      notifyListeners();
      return false;
    }

    _owner = response.data!;
    _status = OwnerStatus.authenticated;
    _errorMessage = null;
    _statusCode = response.statusCode;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> forgotPassword({required String email}) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    _statusCode = null;
    notifyListeners();

    final request = ForgotPasswordRequest(email: email);
    final response = await _service.forgotPassword(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] FORGOT PASSWORD RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 StatusCode: ${response.statusCode}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Failed to send OTP';
      _statusCode = response.statusCode;
      notifyListeners();
      return false;
    }

    _status = OwnerStatus.initial;
    _errorMessage = null;
    _statusCode = response.statusCode;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // VERIFY OTP
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _status = OwnerStatus.loading;
    _errorMessage = null;
    _statusCode = null;
    notifyListeners();

    final request = VerifyOtpRequest(email: email, otp: otp);
    final response = await _service.verifyOtp(request);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [OwnerProvider] VERIFY OTP RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 StatusCode: ${response.statusCode}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'OTP verification failed';
      _statusCode = response.statusCode;
      notifyListeners();
      return false;
    }

    _status = OwnerStatus.initial;
    _errorMessage = null;
    _statusCode = response.statusCode;
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
    _statusCode = null;
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
    debugPrint('📦 StatusCode: ${response.statusCode}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      _status = OwnerStatus.error;
      _errorMessage = response.message ?? 'Password reset failed';
      _statusCode = response.statusCode;
      notifyListeners();
      return false;
    }

    _status = OwnerStatus.initial;
    _errorMessage = null;
    _statusCode = response.statusCode;
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
    _statusCode = null;
    _status = OwnerStatus.unauthenticated;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────
  // CLEAR ERROR
  // ─────────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    _statusCode = null;
    notifyListeners();
  }
}
