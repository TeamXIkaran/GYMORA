import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/providers/payment_provider.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/auth_background_widget.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ═══════════════════════════════════════════════════════════════════════════
// QR PAYMENT SCREEN — Dynamic UPI QR with PaymentProvider Integration
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

  // ═══════════════════════════════════════════════════════════════════════
  // UPI CONFIG — Replace with your actual UPI details
  // ═══════════════════════════════════════════════════════════════════════
  static const String _upiId = 'yourupi@bank'; // ← your UPI ID
  static const String _payeeName = 'GYMORA'; // ← display name on UPI apps
  static const String _merchantCode = ''; // optional merchant code

  // ── State ──
  bool _paymentSubmitted = false;
  bool _isProcessing = false;

  // ── Animation Controllers ──
  late final AnimationController _logoCtrl;
  late final AnimationController _qrCtrl;
  late final AnimationController _detailsCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;
  late final AnimationController _scanLineCtrl;

  // ── Animations ──
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _qrOpacity;
  late final Animation<double> _qrScale;
  late final Animation<double> _detailsOpacity;
  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD UPI DEEP-LINK WITH AMOUNT
  // ═══════════════════════════════════════════════════════════════════════

  String _buildUpiUri() {
    final data = widget.planData ?? {};
    final amount = data['amount']?.toString() ?? '0';
    final plan = data['plan']?.toString() ?? 'GYMORA';

    // Standard UPI intent URI — works with GPay, PhonePe, Paytm, etc.
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

  // ═══════════════════════════════════════════════════════════════════════
  // ANIMATIONS (unchanged logic)
  // ═══════════════════════════════════════════════════════════════════════

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
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _qrCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _detailsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _ctaCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _qrCtrl.dispose();
    _detailsCtrl.dispose();
    _ctaCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    _scanLineCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SUBMIT PAYMENT VIA PROVIDER
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _submitPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final paymentProvider = context.read<PaymentProvider>();

    final data = widget.planData ?? {};
    final ownerId = data['ownerId']?.toString() ?? '';
    final gymId = data['gymId']?.toString() ?? '';
    final plan = data['plan']?.toString() ?? '';
    final amount = data['amount'] is num
        ? data['amount'] as num
        : num.tryParse(data['amount']?.toString() ?? '0') ?? 0;

    debugPrint('═══════════════════════════════════════════');
    debugPrint('QR PAYMENT SCREEN: Submitting payment...');
    debugPrint('ownerId: $ownerId');
    debugPrint('gymId: $gymId');
    debugPrint('plan: $plan');
    debugPrint('amount: $amount');
    debugPrint('═══════════════════════════════════════════');

    final success = await paymentProvider.submitPayment(
      ownerId: ownerId,
      gymId: gymId,
      plan: plan,
      amount: amount,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _paymentSubmitted = success;
    });

    if (success) {
      debugPrint('QR PAYMENT: Payment submitted successfully!');
      debugPrint('Last Payment: ${paymentProvider.lastPayment}');

      _showMessage('Payment submitted successfully! Awaiting approval.');

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.goNamed('ownerLogin');
      }
    } else {
      debugPrint('QR PAYMENT: Payment submission failed!');
      debugPrint('Error: ${paymentProvider.errorMessage}');
      _showMessage(
        paymentProvider.errorMessage ?? 'Payment failed. Please try again.',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

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
                      onTap: () => Navigator.of(context).pop(),
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

                  // ── GYMORA Logo ──
                  _buildLogo(),
                  const SizedBox(height: 14),
                  _buildBrandText(),
                  const SizedBox(height: 30),

                  // ── Dynamic QR Code ──
                  _buildQRCode(),
                  const SizedBox(height: 24),

                  // ── Payment Details ──
                  _buildPaymentDetails(planName, amount),
                  const SizedBox(height: 32),

                  // ── Submit Button ──
                  _buildSubmitButton(),
                  const SizedBox(height: 16),

                  // ── Info Text ──
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

  // ── GYMORA LOGO ──
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) => Opacity(
        opacity: _logoOpacity.value,
        child: Transform.scale(scale: _logoScale.value, child: child),
      ),
      child: Image.asset(
        'assets/images/gymora_logo.png',
        width: 70,
        height: 70,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Container(
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
        ),
      ),
    );
  }

  // ── GYMORA BRAND TEXT ──
  Widget _buildBrandText() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) => Opacity(opacity: _logoOpacity.value, child: child),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [_accent, _accent.withValues(alpha: 0.7)],
            ).createShader(bounds),
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

  // ═══════════════════════════════════════════════════════════════════════
  // DYNAMIC UPI QR — Generated from plan amount
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildQRCode() {
    final upiUri = _buildUpiUri();
    final data = widget.planData ?? {};
    final amount = data['amount']?.toString() ?? '0';

    return AnimatedBuilder(
      animation: _qrCtrl,
      builder: (_, child) => Opacity(
        opacity: _qrOpacity.value,
        child: Transform.scale(scale: _qrScale.value, child: child),
      ),
      child: Column(
        children: [
          // ── QR Container ──
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
                // ── Dynamic QR from UPI URI ──
                QrImageView(
                  data: upiUri,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(color: const Color(0xFF1A1A2E)),
                  dataModuleStyle: const QrDataModuleStyle(
                    color: Color(0xFF1A1A2E),
                  ),
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  // Optional: GYMORA logo in the center of QR
                  embeddedImage: const AssetImage(
                    'assets/images/gymora_logo.png',
                  ),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(36, 36),
                  ),
                  errorStateBuilder: (_, _) => const Center(
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
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Scan-line animation overlay ──
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

          // ── Amount badge below QR ──
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

  // ── PAYMENT DETAILS CARD ──
  Widget _buildPaymentDetails(String planName, String amount) {
    return AnimatedBuilder(
      animation: _detailsCtrl,
      builder: (_, child) =>
          Opacity(opacity: _detailsOpacity.value, child: child),
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
            _detailRow('Status', _paymentSubmitted ? 'Submitted' : 'Pending'),
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

  // ── SUBMIT BUTTON ──
  Widget _buildSubmitButton() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProv, _) {
        final loading = paymentProv.isLoading || _isProcessing;

        return AnimatedBuilder(
          animation: _ctaCtrl,
          builder: (_, _) => Opacity(
            opacity: _ctaOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _ctaSlide.value),
              child: GestureDetector(
                onTap: loading || _paymentSubmitted ? null : _submitPayment,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: _paymentSubmitted
                          ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                          : [const Color(0xFFE62B52), const Color(0xFF8B1528)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_paymentSubmitted
                                    ? const Color(0xFF2ECC71)
                                    : _accent)
                                .withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: -4,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _paymentSubmitted
                                    ? Icons.check_circle_rounded
                                    : Icons.payment_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _paymentSubmitted
                                    ? 'PAYMENT SUBMITTED'
                                    : 'CONFIRM PAYMENT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── INFO TEXT ──
  Widget _buildInfoText() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, child) => Opacity(opacity: _ctaOpacity.value, child: child),
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
                'Your GYMORA membership will be activated once payment is approved.',
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
