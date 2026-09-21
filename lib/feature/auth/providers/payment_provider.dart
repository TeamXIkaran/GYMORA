import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/api/network/payment_service.dart';
import 'package:gymora_fitness_management/core/model/payment_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

enum PaymentStatus { initial, loading, success, error }

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service;

  PaymentProvider({PaymentService? service})
    : _service = service ?? PaymentService();

  // ── State ──

  PaymentStatus _status = PaymentStatus.initial;

  String? _errorMessage;

  PaymentModel? _lastPayment;

  // ── Getters ──

  PaymentStatus get status => _status;

  String? get errorMessage => _errorMessage;

  PaymentModel? get lastPayment => _lastPayment;

  bool get isLoading => _status == PaymentStatus.loading;

  bool get isPaymentApproved =>
      _lastPayment?.paymentStatus.toUpperCase() == 'APPROVED';

  bool get isPaymentPending =>
      _lastPayment?.paymentStatus.toUpperCase() == 'PENDING';

  bool get isPaymentRejected =>
      _lastPayment?.paymentStatus.toUpperCase() == 'REJECTED';

  // ═══════════════════════════════════════════════════════════════════════
  // SUBMIT / CREATE PAYMENT
  //
  // Updated: backend now only requires ownerId
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> submitPayment({required String ownerId}) async {
    _status = PaymentStatus.loading;
    _errorMessage = null;

    notifyListeners();

    final request = PaymentSubmitRequest(ownerId: ownerId);

    try {
      final response = await _service.submitPayment(request);

      debugPrint('═══════════════════════════════════════════');
      debugPrint('🎯 [PaymentProvider] SUBMIT RESULT');
      debugPrint('📦 Success: ${response.success}');
      debugPrint('📦 Message: ${response.message}');
      debugPrint('📦 Data: ${response.data}');
      debugPrint('═══════════════════════════════════════════');

      if (!response.success || response.data == null) {
        _status = PaymentStatus.error;

        _errorMessage = response.message ?? 'Payment submission failed';

        notifyListeners();

        return false;
      }

      _lastPayment = response.data;

      _status = PaymentStatus.success;
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('❌ [PaymentProvider] Submit exception: $e');

      _status = PaymentStatus.error;

      _errorMessage = 'Unable to create payment request';

      notifyListeners();

      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CHECK PAYMENT STATUS
  // ═══════════════════════════════════════════════════════════════════════

  Future<PaymentModel?> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _service.checkPaymentStatus(paymentId);

      debugPrint(
        '🎯 [PaymentProvider] STATUS → '
        'success: ${response.success}, '
        'status: ${response.data?.paymentStatus}',
      );

      if (!response.success || response.data == null) {
        return null;
      }

      _lastPayment = response.data;

      notifyListeners();

      return response.data;
    } catch (e) {
      debugPrint('❌ [PaymentProvider] Status exception: $e');

      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // APPROVE PAYMENT
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> approvePayment(String paymentId) async {
    _status = PaymentStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await _service.approvePayment(paymentId);

      debugPrint(
        '🎯 [PaymentProvider] APPROVE → '
        'success: ${response.success}',
      );

      if (!response.success || response.data == null) {
        _status = PaymentStatus.error;

        _errorMessage = response.message ?? 'Payment approval failed';

        notifyListeners();

        return false;
      }

      _lastPayment = response.data;

      _status = PaymentStatus.success;
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('❌ [PaymentProvider] Approve exception: $e');

      _status = PaymentStatus.error;

      _errorMessage = 'Payment approval failed';

      notifyListeners();

      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // REJECT PAYMENT
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> rejectPayment(String paymentId) async {
    _status = PaymentStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await _service.rejectPayment(paymentId);

      debugPrint(
        '🎯 [PaymentProvider] REJECT → '
        'success: ${response.success}',
      );

      if (!response.success || response.data == null) {
        _status = PaymentStatus.error;

        _errorMessage = response.message ?? 'Payment rejection failed';

        notifyListeners();

        return false;
      }

      _lastPayment = response.data;

      _status = PaymentStatus.success;
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('❌ [PaymentProvider] Reject exception: $e');

      _status = PaymentStatus.error;

      _errorMessage = 'Payment rejection failed';

      notifyListeners();

      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CLEAR ERROR
  // ═══════════════════════════════════════════════════════════════════════

  void clearError() {
    _errorMessage = null;

    if (_status == PaymentStatus.error) {
      _status = PaymentStatus.initial;
    }

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RESET
  // ═══════════════════════════════════════════════════════════════════════

  void reset() {
    _status = PaymentStatus.initial;
    _errorMessage = null;
    _lastPayment = null;

    notifyListeners();
  }
}
