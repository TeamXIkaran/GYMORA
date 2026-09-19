import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:karan_fitness/config/theme/app_colors.dart';
import 'package:karan_fitness/feature/auth/widgets/gradient_button_widget.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PLAN MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _Plan {
  final String name;
  final String price;
  final String duration;
  final Color color;
  final String? badge;

  const _Plan({
    required this.name,
    required this.price,
    required this.duration,
    required this.color,
    this.badge,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// QR PAYMENT SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class QRPaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? planData;

  const QRPaymentScreen({super.key, this.planData});

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════
  // ANIMATION
  // ═══════════════════════════════════════════════════════════════════════

  late final AnimationController _shimmerCtrl;
  late final AnimationController _pulseCtrl;

  // ═══════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════

  bool _isProcessing = false;

  // ═══════════════════════════════════════════════════════════════════════
  // PLAN
  // ═══════════════════════════════════════════════════════════════════════

  late final _Plan _plan;

  // ═══════════════════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    _plan = _createPlan();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CREATE PLAN
  // ═══════════════════════════════════════════════════════════════════════

  _Plan _createPlan() {
    final data = widget.planData;

    // Fallback only if no plan was passed.
    if (data == null) {
      return const _Plan(
        name: 'PRO',
        price: '10,000',
        duration: '3 Months',
        color: Color(0xFFE62B52),
        badge: 'POPULAR',
      );
    }

    final planName = data['name']?.toString() ?? 'PRO';

    final price = data['price']?.toString() ?? '10,000';

    final duration = data['duration']?.toString() ?? '3 Months';

    final badge = data['badge']?.toString();

    Color color;

    // First try to use the actual color sent from
    // PurchaseMembershipScreen.

    final colorValue = data['color'];

    if (colorValue is int) {
      color = Color(colorValue);
    } else {
      // Fallback based on plan name.

      switch (planName.toUpperCase()) {
        case 'STARTER':
          color = const Color(0xFF9C27B0);
          break;

        case 'ELITE':
          color = const Color(0xFFFFB31A);
          break;

        case 'PRO':
        default:
          color = const Color(0xFFE62B52);
          break;
      }
    }

    return _Plan(
      name: planName,
      price: price,
      duration: duration,
      color: color,
      badge: badge,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAYMENT
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _simulatePayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // TODO:
    // Replace this with your actual payment gateway.

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Successful! '
          '${_plan.name} plan activated.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // After payment → Owner Login

    context.goNamed('ownerLogin');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();

    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final plan = _plan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ═══════════════════════════════════════════════════════════
              // APP BAR
              // ═══════════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!_isProcessing) {
                          context.pop();
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      'Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════════════════════
              // CONTENT
              // ═══════════════════════════════════════════════════════════
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // ═══════════════════════════════
                        // QR CODE
                        // ═══════════════════════════════
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (context, child) {
                            final value = _pulseCtrl.value;

                            return Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: plan.color.withValues(
                                      alpha: 0.1 + (0.1 * value),
                                    ),
                                    blurRadius: 30 + (10 * value),
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedBuilder(
                                  animation: _shimmerCtrl,
                                  builder: (context, child) {
                                    return Stack(
                                      children: [
                                        CustomPaint(
                                          size: const Size(220, 220),
                                          painter: _QRPlaceholderPainter(),
                                        ),

                                        CustomPaint(
                                          size: const Size(220, 220),
                                          painter: _ScanLinePainter(
                                            progress: _shimmerCtrl.value,
                                            color: plan.color,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // ═══════════════════════════════
                        // PLAN NAME
                        // ═══════════════════════════════
                        Text(
                          '${plan.name} Plan',
                          style: TextStyle(
                            color: plan.color,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '₹${plan.price}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          plan.duration,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ═══════════════════════════════
                        // ORDER SUMMARY
                        // ═══════════════════════════════
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: plan.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.workspace_premium_rounded,
                                      color: plan.color,
                                      size: 22,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        Text(
                                          plan.duration,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.4,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    '₹${plan.price}',
                                    style: TextStyle(
                                      color: plan.color,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Divider(
                                color: Colors.white.withValues(alpha: 0.07),
                                height: 1,
                              ),

                              const SizedBox(height: 18),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Amount to Pay',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),

                                  Text(
                                    '₹${plan.price}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ═══════════════════════════════
                        // SCAN INFO
                        // ═══════════════════════════════
                        Text(
                          'Scan the QR code with any UPI app to pay',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // ═══════════════════════════════
                        // PAY BUTTON
                        // ═══════════════════════════════
                        GradientButton(
                          label: _isProcessing
                              ? 'Processing...'
                              : 'I Have Paid',
                          color: plan.color,
                          onPressed: _isProcessing ? null : _simulatePayment,
                        ),

                        const SizedBox(height: 16),

                        // ═══════════════════════════════
                        // SECURITY
                        // ═══════════════════════════════
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),

                            const SizedBox(width: 5),

                            Text(
                              'Secure payment',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QR PLACEHOLDER
// ═══════════════════════════════════════════════════════════════════════════

class _QRPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);

    final paint = Paint()..color = Colors.black.withValues(alpha: 0.8);

    const cellSize = 8.0;

    final padding = size.width * 0.15;

    final gridSize = size.width - (padding * 2);

    final cols = (gridSize / cellSize).floor();

    for (int row = 0; row < cols; row++) {
      for (int col = 0; col < cols; col++) {
        if (rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(
              padding + (col * cellSize),
              padding + (row * cellSize),
              cellSize - 1,
              cellSize - 1,
            ),
            paint,
          );
        }
      }
    }

    final markerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const markerSize = 22.0;

    final positions = [
      Offset(padding, padding),
      Offset(size.width - padding - markerSize, padding),
      Offset(padding, size.height - padding - markerSize),
    ];

    for (final position in positions) {
      canvas.drawRect(
        Rect.fromLTWH(position.dx, position.dy, markerSize, markerSize),
        markerPaint,
      );

      canvas.drawRect(
        Rect.fromLTWH(position.dx + 5, position.dy + 5, 12, 12),
        Paint()..color = Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCAN LINE
// ═══════════════════════════════════════════════════════════════════════════

class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));

    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
