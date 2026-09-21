import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_helper.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_response.dart';
import 'package:gymora_fitness_management/core/model/owner_login_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// OWNER SERVICE
// ═══════════════════════════════════════════════════════════════════════════

class OwnerService {
  final ApiHelper _api;

  OwnerService({ApiHelper? api}) : _api = api ?? ApiHelper();

  // ─────────────────────────────────────────────────────────────────────
  // OWNER LOGIN
  // POST /api/owner/login
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<OwnerLoginResponse>> login(
    OwnerLoginRequest request,
  ) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔐 [OwnerService] LOGIN');
    debugPrint('📤 Request: ${request.toJson()}');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/owner/login',
      request.toJson(),
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [OwnerService] LOGIN RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Login failed',
        statusCode: response.statusCode,
      );
    }

    try {
      final loginData = OwnerLoginResponse.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      debugPrint('✅ [OwnerService] Parsed: $loginData');
      return ApiResponse.success(
        loginData,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [OwnerService] Parse error: $e');
      return ApiResponse.error('Failed to parse login response');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // OWNER PURCHASE
  // POST /api/owner/purchase
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PurchaseResponse>> purchase(
    PurchaseRequest request,
  ) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🛒 [OwnerService] PURCHASE');
    debugPrint('📤 Request: ${request.toJson()}');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/owner/purchase',
      request.toJson(),
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [OwnerService] PURCHASE RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Purchase failed',
        statusCode: response.statusCode,
      );
    }

    try {
      final purchaseData = PurchaseResponse.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      debugPrint('✅ [OwnerService] Parsed: $purchaseData');
      return ApiResponse.success(
        purchaseData,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [OwnerService] Parse error: $e');
      return ApiResponse.error('Failed to parse purchase response');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // OWNER PROFILE
  // GET /api/owner/profile
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<OwnerLoginModel>> getProfile() async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('👤 [OwnerService] GET PROFILE');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.get<Map<String, dynamic>>('api/owner/profile');

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [OwnerService] PROFILE RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Failed to fetch profile',
        statusCode: response.statusCode,
      );
    }

    try {
      // Profile endpoint returns: data.owner (nested inside data)
      final data = response.data!['data'] as Map<String, dynamic>;
      final ownerJson = data['owner'] as Map<String, dynamic>? ?? data;
      final owner = OwnerLoginModel.fromJson(ownerJson);
      debugPrint('✅ [OwnerService] Parsed: $owner');
      return ApiResponse.success(
        owner,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [OwnerService] Parse error: $e');
      return ApiResponse.error('Failed to parse profile response');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // POST /api/owner/forgot-password
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<String>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔑 [OwnerService] FORGOT PASSWORD');
    debugPrint('📤 Request: ${request.toJson()}');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/owner/forgot-password',
      request.toJson(),
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [OwnerService] FORGOT PASSWORD RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to send OTP',
        statusCode: response.statusCode,
      );
    }

    final msg =
        response.data?['message']?.toString() ?? 'OTP sent successfully';
    debugPrint('✅ [OwnerService] $msg');
    return ApiResponse.success(msg, message: msg);
  }

  // ─────────────────────────────────────────────────────────────────────
  // VERIFY OTP
  // POST /api/owner/verify-otp
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<String>> verifyOtp(VerifyOtpRequest request) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔢 [OwnerService] VERIFY OTP');
    debugPrint('📤 Request: ${request.toJson()}');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/owner/verify-otp',
      request.toJson(),
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [OwnerService] VERIFY OTP RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'OTP verification failed',
        statusCode: response.statusCode,
      );
    }

    final msg = response.data?['message']?.toString() ?? 'OTP verified';
    debugPrint('✅ [OwnerService] $msg');
    return ApiResponse.success(msg, message: msg);
  }

  // ─────────────────────────────────────────────────────────────────────
  // RESET PASSWORD
  // POST /api/owner/reset-password
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<String>> resetPassword(
    ResetPasswordRequest request,
  ) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔒 [OwnerService] RESET PASSWORD');
    debugPrint('📤 Request: ${request.toJson()}');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/owner/reset-password',
      request.toJson(),
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [OwnerService] RESET PASSWORD RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Password reset failed',
        statusCode: response.statusCode,
      );
    }

    final msg =
        response.data?['message']?.toString() ?? 'Password reset successfully';
    debugPrint('✅ [OwnerService] $msg');
    return ApiResponse.success(msg, message: msg);
  }
}
