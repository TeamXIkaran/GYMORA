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

  // ─────────────────────────────────────────────────────────────────────
  // SUBMIT PAYMENT
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> submitPayment({
    required String ownerId,
    required String gymId,
    required String plan,
    required num amount,
  }) async {
    _status = PaymentStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final request = PaymentSubmitRequest(
      ownerId: ownerId,
      gymId: gymId,
      plan: plan,
      amount: amount,
    );

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

    _lastPayment = response.data!;
    _status = PaymentStatus.success;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // APPROVE PAYMENT
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> approvePayment(String paymentId) async {
    _status = PaymentStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.approvePayment(paymentId);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [PaymentProvider] APPROVE RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = PaymentStatus.error;
      _errorMessage = response.message ?? 'Payment approval failed';
      notifyListeners();
      return false;
    }

    _lastPayment = response.data!;
    _status = PaymentStatus.success;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // REJECT PAYMENT
  // ─────────────────────────────────────────────────────────────────────

  Future<bool> rejectPayment(String paymentId) async {
    _status = PaymentStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.rejectPayment(paymentId);

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎯 [PaymentProvider] REJECT RESULT');
    debugPrint('📦 Success: ${response.success}');
    debugPrint('📦 Message: ${response.message}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('═══════════════════════════════════════════');

    if (!response.success || response.data == null) {
      _status = PaymentStatus.error;
      _errorMessage = response.message ?? 'Payment rejection failed';
      notifyListeners();
      return false;
    }

    _lastPayment = response.data!;
    _status = PaymentStatus.success;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────
  // CLEAR ERROR
  // ─────────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
