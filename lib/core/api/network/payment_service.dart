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
      final rawData = response.data!['data'];

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
  //
  // IMPORTANT:
  // Backend must provide:
  //
  // GET /api/payment/status/{paymentId}
  //
  // Example response:
  //
  // {
  //   "success": true,
  //   "message": "Payment status fetched",
  //   "data": {
  //     "paymentId": "...",
  //     "paymentStatus": "APPROVED",
  //     "membershipStatus": "ACTIVE"
  //   }
  // }
  // ─────────────────────────────────────────────────────────────────────

  Future<ApiResponse<PaymentModel>> checkPaymentStatus(String paymentId) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔍 [PaymentService] CHECK PAYMENT STATUS');
    debugPrint('📤 PaymentId: $paymentId');
    debugPrint('═══════════════════════════════════════════');

    final response = await _api.get<Map<String, dynamic>>(
      'api/payment/status/$paymentId',
    );

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [PaymentService] STATUS RESPONSE');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Failed to check payment status',
        statusCode: response.statusCode,
      );
    }

    try {
      final rawData = response.data!['data'];

      if (rawData is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Invalid payment status data',
          statusCode: response.statusCode,
        );
      }

      final payment = PaymentModel.fromJson(rawData);

      debugPrint(
        '✅ [PaymentService] Payment Status: '
        '${payment.paymentStatus}',
      );

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
  //
  // Keep this method for OWNER/ADMIN approval if needed.
  // QR screen will NOT call this.
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
      final rawData = response.data!['data'];

      if (rawData is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Invalid approve response data',
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
        'Failed to parse approve response',
        statusCode: response.statusCode,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // REJECT PAYMENT
  // POST /api/payment/reject
  //
  // Keep this method for OWNER/ADMIN rejection if needed.
  // QR screen will NOT call this.
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
      final rawData = response.data!['data'];

      if (rawData is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Invalid reject response data',
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
        'Failed to parse reject response',
        statusCode: response.statusCode,
      );
    }
  }
}
