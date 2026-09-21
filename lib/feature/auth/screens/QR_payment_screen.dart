import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/providers/payment_provider.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/auth_background_widget.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ═══════════════════════════════════════════════════════════════════════════
// QR PAYMENT SCREEN
// Automatic payment detection
// ═══════════════════════════════════════════════════════════════════════════

class QRPaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? planData;

  const QRPaymentScreen({super.key, this.planData});

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen>
    with TickerProviderStateMixin {
  // ── Theme ──

  static const Color _accent = AppColors.primary;

  // ═══════════════════════════════════════════════════════════════════════════
  // UPI CONFIG
  // ═══════════════════════════════════════════════════════════════════════════

  static const String _upiId = 'bishtkaran819-1@okicici';

  static const String _payeeName = 'GYMORA';

  static const String _merchantCode = '';

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT STATE
  // ═══════════════════════════════════════════════════════════════════════════

  bool _paymentSubmitted = false;

  bool _isProcessing = false;

  bool _paymentApproved = false;

  bool _paymentRejected = false;

  String? _paymentId;

  Timer? _paymentTimer;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION CONTROLLERS
  // ═══════════════════════════════════════════════════════════════════════════

  late final AnimationController _logoCtrl;

  late final AnimationController _qrCtrl;

  late final AnimationController _detailsCtrl;

  late final AnimationController _ctaCtrl;

  late final AnimationController _particleCtrl;

  late final AnimationController _glowPulseCtrl;

  late final AnimationController _scanLineCtrl;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  late final Animation<double> _logoOpacity;

  late final Animation<double> _logoScale;

  late final Animation<double> _qrOpacity;

  late final Animation<double> _qrScale;

  late final Animation<double> _detailsOpacity;

  late final Animation<double> _ctaOpacity;

  late final Animation<double> _ctaSlide;

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    _initAnimations();

    _startSequence();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createPaymentAndStartChecking();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD UPI URI
  // ═══════════════════════════════════════════════════════════════════════════

  String _buildUpiUri() {
    final data = widget.planData ?? {};

    final amount = data['amount']?.toString() ?? '0';

    final plan = data['plan']?.toString() ?? 'GYMORA';

    final uri = StringBuffer('upi://pay?')
      ..write('pa=${Uri.encodeComponent(_upiId)}')
      ..write('&pn=${Uri.encodeComponent(_payeeName)}')
      ..write('&am=$amount')
      ..write('&cu=INR')
      ..write('&tn=${Uri.encodeComponent('GYMORA $plan Plan')}');

    if (_merchantCode.isNotEmpty) {
      uri.write('&mc=${Uri.encodeComponent(_merchantCode)}');
    }

    return uri.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void _initAnimations() {
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.6,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _qrCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _qrOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _qrCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _qrScale = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _qrCtrl, curve: Curves.easeOutBack));

    _detailsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _detailsOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _detailsCtrl, curve: Curves.easeOut));

    _ctaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _ctaOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOut));

    _ctaSlide = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOutCubic));

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _glowPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    _qrCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    _detailsCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    _ctaCtrl.forward();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTOMATICALLY CREATE PAYMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _createPaymentAndStartChecking() async {
    if (_isProcessing || _paymentId != null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    final paymentProvider = context.read<PaymentProvider>();

    final data = widget.planData ?? {};

    final ownerId = data['ownerId']?.toString() ?? '';

    final gymId = data['gymId']?.toString() ?? '';

    final plan = data['plan']?.toString() ?? '';

    final amount = data['amount'] is num
        ? data['amount'] as num
        : num.tryParse(data['amount']?.toString() ?? '0') ?? 0;

    debugPrint('═══════════════════════════════════════════');
    debugPrint('💳 QR PAYMENT - CREATE PAYMENT');
    debugPrint('ownerId: $ownerId');
    debugPrint('gymId: $gymId');
    debugPrint('plan: $plan');
    debugPrint('amount: $amount');
    debugPrint('═══════════════════════════════════════════');

    if (ownerId.isEmpty || gymId.isEmpty || plan.isEmpty || amount <= 0) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showMessage('Invalid payment details. Please go back and try again.');

      return;
    }

    final success = await paymentProvider.submitPayment(
      ownerId: ownerId,
      gymId: gymId,
      plan: plan,
      amount: amount,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (!success) {
      debugPrint('❌ QR PAYMENT - CREATE PAYMENT FAILED');

      _showMessage(
        paymentProvider.errorMessage ?? 'Unable to create payment request.',
      );

      return;
    }

    final payment = paymentProvider.lastPayment;

    if (payment == null || payment.paymentId.isEmpty) {
      _showMessage('Payment ID was not received from server.');

      return;
    }

    _paymentId = payment.paymentId;

    setState(() {
      _paymentSubmitted = true;
    });

    debugPrint('═══════════════════════════════════════════');
    debugPrint('✅ PAYMENT CREATED');
    debugPrint('Payment ID: $_paymentId');
    debugPrint('Initial Status: ${payment.paymentStatus}');
    debugPrint('═══════════════════════════════════════════');

    _startPaymentStatusChecking();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // START AUTOMATIC STATUS CHECK
  // ═══════════════════════════════════════════════════════════════════════════

  void _startPaymentStatusChecking() {
    _paymentTimer?.cancel();

    if (_paymentId == null || _paymentId!.isEmpty) {
      return;
    }

    debugPrint('🔄 Starting automatic payment status checking...');

    _paymentTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkPaymentStatus();
    });

    // Check immediately as well.
    _checkPaymentStatus();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECK PAYMENT STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _checkPaymentStatus() async {
    if (_paymentId == null ||
        _paymentId!.isEmpty ||
        _paymentApproved ||
        _paymentRejected) {
      return;
    }

    final paymentProvider = context.read<PaymentProvider>();

    final payment = await paymentProvider.checkPaymentStatus(_paymentId!);

    if (!mounted || payment == null) {
      return;
    }

    final status = payment.paymentStatus.trim().toUpperCase();

    debugPrint('🔍 Payment $_paymentId status: $status');

    // ─────────────────────────────────────────────
    // PAYMENT APPROVED
    // ─────────────────────────────────────────────

    if (status == 'APPROVED' ||
        status == 'PAID' ||
        status == 'SUCCESS' ||
        status == 'COMPLETED') {
      await _handlePaymentSuccess(payment);

      return;
    }

    // ─────────────────────────────────────────────
    // PAYMENT REJECTED
    // ─────────────────────────────────────────────

    if (status == 'REJECTED' || status == 'FAILED' || status == 'CANCELLED') {
      _paymentTimer?.cancel();

      if (!mounted) return;

      setState(() {
        _paymentRejected = true;
      });

      _showMessage('Payment was not approved. Please try again.');

      return;
    }

    // ─────────────────────────────────────────────
    // PAYMENT STILL PENDING
    // ─────────────────────────────────────────────

    if (status == 'PENDING' || status == 'PROCESSING' || status.isEmpty) {
      debugPrint('⏳ Payment still waiting for confirmation...');

      return;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT SUCCESS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handlePaymentSuccess(dynamic payment) async {
    if (_paymentApproved) {
      return;
    }

    _paymentTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _paymentApproved = true;
      _paymentSubmitted = true;
    });

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🎉 PAYMENT RECEIVED SUCCESSFULLY');
    debugPrint('Payment ID: $_paymentId');
    debugPrint('Payment Status: ${payment.paymentStatus}');
    debugPrint('Membership Status: ${payment.membershipStatus}');
    debugPrint('═══════════════════════════════════════════');

    _showSuccessMessage('Membership purchased successfully!');

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    context.goNamed('ownerLogin');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGE
  // ═══════════════════════════════════════════════════════════════════════════

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF27AE60),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _paymentTimer?.cancel();

    _logoCtrl.dispose();
    _qrCtrl.dispose();
    _detailsCtrl.dispose();
    _ctaCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    _scanLineCtrl.dispose();

    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final data = widget.planData ?? {};

    final planName = data['plan']?.toString() ?? 'Plan';

    final amount = data['amount']?.toString() ?? '0';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: AuthBackground(
          accentColor: _accent,
          particleAnimation: _particleCtrl,
          glowPulseAnimation: _glowPulseCtrl,
          glowTopFraction: 0.08,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  // ── Back Button ──
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        _paymentTimer?.cancel();

                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Logo ──
                  _buildLogo(),

                  const SizedBox(height: 14),

                  _buildBrandText(),

                  const SizedBox(height: 30),

                  // ── QR ──
                  _buildQRCode(),

                  const SizedBox(height: 24),

                  // ── Details ──
                  _buildPaymentDetails(planName, amount),

                  const SizedBox(height: 24),

                  // ── AUTOMATIC PAYMENT STATUS ──
                  _buildPaymentStatus(),

                  const SizedBox(height: 16),

                  // ── Info ──
                  _buildInfoText(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGO
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(scale: _logoScale.value, child: child),
        );
      },
      child: Image.asset(
        'assets/images/gymora_logo.png',
        width: 70,
        height: 70,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_accent, _accent.withValues(alpha: 0.6)],
              ),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 32,
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND TEXT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBrandText() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) {
        return Opacity(opacity: _logoOpacity.value, child: child);
      },
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [_accent, _accent.withValues(alpha: 0.7)],
              ).createShader(bounds);
            },
            child: const Text(
              'GYMORA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'F I T N E S S   M A N A G E M E N T',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QR CODE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQRCode() {
    final upiUri = _buildUpiUri();

    final data = widget.planData ?? {};

    final amount = data['amount']?.toString() ?? '0';

    return AnimatedBuilder(
      animation: _qrCtrl,
      builder: (_, child) {
        return Opacity(
          opacity: _qrOpacity.value,
          child: Transform.scale(scale: _qrScale.value, child: child),
        );
      },
      child: Column(
        children: [
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  data: upiUri,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(color: Color(0xFF1A1A2E)),
                  dataModuleStyle: const QrDataModuleStyle(
                    color: Color(0xFF1A1A2E),
                  ),
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  embeddedImage: const AssetImage(
                    'assets/images/gymora_logo.png',
                  ),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(36, 36),
                  ),
                  errorStateBuilder: (_, _) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 80,
                            color: Colors.black54,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Could not generate QR',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ── Scan Line ──
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _scanLineCtrl,
                    builder: (_, _) {
                      final y = _scanLineCtrl.value * 220;

                      return Stack(
                        children: [
                          Positioned(
                            top: y,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    _accent.withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.currency_rupee_rounded, color: _accent, size: 16),
                const SizedBox(width: 4),
                Text(
                  amount,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT DETAILS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPaymentDetails(String planName, String amount) {
    String statusText;

    if (_paymentApproved) {
      statusText = 'Approved';
    } else if (_paymentRejected) {
      statusText = 'Rejected';
    } else if (_paymentSubmitted) {
      statusText = 'Waiting for Payment';
    } else if (_isProcessing) {
      statusText = 'Creating Payment';
    } else {
      statusText = 'Pending';
    }

    return AnimatedBuilder(
      animation: _detailsCtrl,
      builder: (_, child) {
        return Opacity(opacity: _detailsOpacity.value, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Text(
              'Payment Details',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            _detailRow('Plan', planName),

            const SizedBox(height: 10),

            _detailRow('Amount', '₹$amount'),

            const SizedBox(height: 10),

            _detailRow('Pay To', _upiId),

            const SizedBox(height: 10),

            _detailRow('Status', statusText),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: _accent.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTOMATIC PAYMENT STATUS CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPaymentStatus() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, child) {
        return Opacity(
          opacity: _ctaOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _ctaSlide.value),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _paymentApproved
              ? const Color(0xFF27AE60).withValues(alpha: 0.12)
              : _paymentRejected
              ? Colors.red.withValues(alpha: 0.10)
              : _accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _paymentApproved
                ? const Color(0xFF27AE60).withValues(alpha: 0.3)
                : _paymentRejected
                ? Colors.red.withValues(alpha: 0.25)
                : _accent.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            if (_paymentApproved)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2ECC71),
                size: 28,
              )
            else if (_paymentRejected)
              const Icon(
                Icons.cancel_rounded,
                color: Colors.redAccent,
                size: 28,
              )
            else
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: _accent,
                  strokeWidth: 2.5,
                ),
              ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _paymentApproved
                        ? 'Payment Successful'
                        : _paymentRejected
                        ? 'Payment Rejected'
                        : _isProcessing
                        ? 'Preparing Payment'
                        : 'Waiting for Payment',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _paymentApproved
                        ? 'Membership purchased successfully.'
                        : _paymentRejected
                        ? 'Please try the payment again.'
                        : _isProcessing
                        ? 'Please wait...'
                        : 'After your payment is received, we will automatically confirm it.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INFO TEXT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoText() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, child) {
        return Opacity(opacity: _ctaOpacity.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accent.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: _accent.withValues(alpha: 0.7),
              size: 18,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Scan the QR code to pay ₹${widget.planData?['amount'] ?? '0'}. '
                'Your GYMORA membership will be activated automatically once payment is received and approved.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
