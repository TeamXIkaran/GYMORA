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
  // SUBMIT / CREATE PAYMENT
  // POST /api/payment/submit
  //
  // Request:  { "ownerId": "..." }
  // Response: { "success": true, "message": "...", "data": { ... } }
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
      // Try nested data.data first, then fallback to data itself
      final rawData = response.data!['data'] ?? response.data;

      if (rawData is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Invalid payment response data',
          statusCode: response.statusCode,
        );
      }

      final payment = PaymentModel.fromJson(rawData);

      debugPrint('✅ [PaymentService] Parsed: $payment');

      return ApiResponse.success(
        payment,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [PaymentService] Parse error: $e');

      return ApiResponse.error(
        'Failed to parse payment response',
        statusCode: response.statusCode,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // CHECK PAYMENT STATUS
  // GET /api/payment/status/{paymentId}
  //
  // Response:
  // {
  //   "success": true,
  //   "data": {
  //     "paymentId": "...",
  //     "paymentStatus": "APPROVED",
  //     "membershipStatus": "ACTIVE"
  //   }
  // }
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PaymentModel>> checkPaymentStatus(String paymentId) async {
    debugPrint('🔍 [PaymentService] CHECK STATUS: $paymentId');

    final response = await _api.get<Map<String, dynamic>>(
      'api/payment/status/$paymentId',
    );

    debugPrint(
      '📥 [PaymentService] STATUS → '
      'success: ${response.success}, '
      'data: ${response.data}',
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Failed to check payment status',
        statusCode: response.statusCode,
      );
    }

    try {
      // Try nested data.data first, then fallback to data itself
      final rawData = response.data!['data'] ?? response.data;

      if (rawData is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Invalid payment status data',
          statusCode: response.statusCode,
        );
      }

      final payment = PaymentModel.fromJson(rawData);

      debugPrint('✅ [PaymentService] Status: ${payment.paymentStatus}');

      return ApiResponse.success(
        payment,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [PaymentService] Status parse error: $e');

      return ApiResponse.error(
        'Failed to parse payment status response',
        statusCode: response.statusCode,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // APPROVE PAYMENT
  // POST /api/payment/approve
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PaymentModel>> approvePayment(String paymentId) async {
    debugPrint('✅ [PaymentService] APPROVE: $paymentId');

    final response = await _api.post<Map<String, dynamic>>(
      'api/payment/approve',
      {'paymentId': paymentId},
    );

    debugPrint(
      '📥 [PaymentService] APPROVE → '
      'success: ${response.success}, '
      'data: ${response.data}',
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Payment approval failed',
        statusCode: response.statusCode,
      );
    }

    try {
      final rawData = response.data!['data'] ?? response.data;

      if (rawData is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Invalid approve response data',
          statusCode: response.statusCode,
        );
      }

      final payment = PaymentModel.fromJson(rawData);

      debugPrint('✅ [PaymentService] Approved: $payment');

      return ApiResponse.success(
        payment,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [PaymentService] Approve parse error: $e');

      return ApiResponse.error(
        'Failed to parse approve response',
        statusCode: response.statusCode,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // REJECT PAYMENT
  // POST /api/payment/reject
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PaymentModel>> rejectPayment(String paymentId) async {
    debugPrint('❌ [PaymentService] REJECT: $paymentId');

    final response = await _api.post<Map<String, dynamic>>(
      'api/payment/reject',
      {'paymentId': paymentId},
    );

    debugPrint(
      '📥 [PaymentService] REJECT → '
      'success: ${response.success}, '
      'data: ${response.data}',
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Payment rejection failed',
        statusCode: response.statusCode,
      );
    }

    try {
      final rawData = response.data!['data'] ?? response.data;

      if (rawData is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Invalid reject response data',
          statusCode: response.statusCode,
        );
      }

      final payment = PaymentModel.fromJson(rawData);

      debugPrint('✅ [PaymentService] Rejected: $payment');

      return ApiResponse.success(
        payment,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ [PaymentService] Reject parse error: $e');

      return ApiResponse.error(
        'Failed to parse reject response',
        statusCode: response.statusCode,
      );
    }
  }
}
