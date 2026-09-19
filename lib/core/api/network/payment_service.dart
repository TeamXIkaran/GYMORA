import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_helper.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_response.dart';
import 'package:gymora_fitness_management/core/model/payment_model.dart';


// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT SERVICE
// ═══════════════════════════════════════════════════════════════════════════

class PaymentService {
  final ApiHelper _api;

  PaymentService({ApiHelper? api}) : _api = api ?? ApiHelper();

  // ─────────────────────────────────────────────────────────────────────
  // SUBMIT PAYMENT
  // POST /api/payment/submit
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PaymentModel>> submitPayment(
    PaymentSubmitRequest request,
  ) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('💳 [PaymentService] SUBMIT PAYMENT');
    debugPrint('📤 Request: ${request.toJson()}');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/payment/submit',
      request.toJson(),
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [PaymentService] SUBMIT RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Payment submission failed',
        statusCode: response.statusCode,
      );
    }

    try {
      final payment = PaymentModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      debugPrint('✅ [PaymentService] Parsed: $payment');
      return ApiResponse.success(
        payment,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [PaymentService] Parse error: $e');
      return ApiResponse.error('Failed to parse payment response');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // APPROVE PAYMENT
  // POST /api/payment/approve
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PaymentModel>> approvePayment(String paymentId) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('✅ [PaymentService] APPROVE PAYMENT');
    debugPrint('📤 PaymentId: $paymentId');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/payment/approve',
      {'paymentId': paymentId},
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [PaymentService] APPROVE RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Payment approval failed',
        statusCode: response.statusCode,
      );
    }

    try {
      final payment = PaymentModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      debugPrint('✅ [PaymentService] Parsed: $payment');
      return ApiResponse.success(
        payment,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [PaymentService] Parse error: $e');
      return ApiResponse.error('Failed to parse approve response');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // REJECT PAYMENT
  // POST /api/payment/reject
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PaymentModel>> rejectPayment(String paymentId) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('❌ [PaymentService] REJECT PAYMENT');
    debugPrint('📤 PaymentId: $paymentId');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.post<Map<String, dynamic>>(
      'api/payment/reject',
      {'paymentId': paymentId},
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [PaymentService] REJECT RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Payment rejection failed',
        statusCode: response.statusCode,
      );
    }

    try {
      final payment = PaymentModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      debugPrint('✅ [PaymentService] Parsed: $payment');
      return ApiResponse.success(
        payment,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [PaymentService] Parse error: $e');
      return ApiResponse.error('Failed to parse reject response');
    }
  }
}
