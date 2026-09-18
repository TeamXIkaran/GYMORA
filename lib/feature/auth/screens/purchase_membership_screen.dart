import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

class PurchaseMembershipScreen extends StatefulWidget {
  const PurchaseMembershipScreen({super.key});

  @override
  State<PurchaseMembershipScreen> createState() =>
      _PurchaseMembershipScreenState();
}

class _PurchaseMembershipScreenState extends State<PurchaseMembershipScreen>
    with TickerProviderStateMixin {
  int _selectedPlan = 1;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _pulseCtrl;

  final _gymNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _gymIdController = TextEditingController();
  final _passwordController = TextEditingController();

  final _gymNameFocus = FocusNode();
  final _ownerNameFocus = FocusNode();
  final _ownerEmailFocus = FocusNode();
  final _ownerPhoneFocus = FocusNode();
  final _gymIdFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final List<_MembershipPlan> _plans = const [
    _MembershipPlan(
      name: 'STARTER',
      price: '₹5,000',
      priceValue: 5000,
      duration: '1 Month',
      description: 'Perfect for small gyms',
      icon: Icons.flash_on_rounded,
      accentColors: [Color(0xFF6366F1), Color(0xFF818CF8)],
      features: ['Gym management', 'Member management', 'Basic dashboard'],
    ),
    _MembershipPlan(
      name: 'PRO',
      price: '₹10,000',
      priceValue: 10000,
      duration: '3 Months',
      description: 'For growing fitness businesses',
      icon: Icons.diamond_rounded,
      badge: 'POPULAR',
      accentColors: [Color(0xFFE62B52), Color(0xFFFF6B81)],
      features: [
        'Everything in Starter',
        'Trainer management',
        'Revenue reports',
        'Attendance tracking',
      ],
    ),
    _MembershipPlan(
      name: 'ELITE',
      price: '₹15,000',
      priceValue: 15000,
      duration: '6 Months',
      description: 'Complete gym management suite',
      icon: Icons.auto_awesome_rounded,
      accentColors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      features: [
        'Everything in Pro',
        'Advanced analytics',
        'Priority support',
        'Multi-branch ready',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _gymNameController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    _gymIdController.dispose();
    _passwordController.dispose();
    _gymNameFocus.dispose();
    _ownerNameFocus.dispose();
    _ownerEmailFocus.dispose();
    _ownerPhoneFocus.dispose();
    _gymIdFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── FLOW: Select → Gym Details → QR Payment ──

  void _continueToDetails() {
    final plan = _plans[_selectedPlan];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _GlassSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Plan badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: plan.accentColors),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                plan.price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'for ${plan.duration}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _SummaryRow(title: 'Plan', value: plan.name),
              _SummaryRow(title: 'Duration', value: plan.duration),
              _SummaryRow(title: 'Amount', value: plan.price),
              const SizedBox(height: 24),
              _GradientButton(
                label: 'CONTINUE',
                colors: plan.accentColors,
                onPressed: () {
                  Navigator.pop(ctx);
                  _showGymDetails();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGymDetails() {
    final plan = _plans[_selectedPlan];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _GlassSheet(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: plan.accentColors),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gym Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Enter your gym information',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Gym Info Section ──
                  _SectionLabel(label: 'GYM INFORMATION'),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _gymNameController,
                    focusNode: _gymNameFocus,
                    hint: 'Gym Name',
                    icon: Icons.fitness_center_rounded,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(ctx).requestFocus(_gymIdFocus),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _gymIdController,
                    focusNode: _gymIdFocus,
                    hint: 'Gym ID (used for sign-in)',
                    icon: Icons.badge_outlined,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(ctx).requestFocus(_passwordFocus),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(ctx).requestFocus(_ownerNameFocus),
                  ),

                  const SizedBox(height: 24),

                  // ── Owner Info Section ──
                  _SectionLabel(label: 'OWNER INFORMATION'),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _ownerNameController,
                    focusNode: _ownerNameFocus,
                    hint: 'Owner Full Name',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(ctx).requestFocus(_ownerEmailFocus),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _ownerEmailController,
                    focusNode: _ownerEmailFocus,
                    hint: 'Gmail (used for sign-in)',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(ctx).requestFocus(_ownerPhoneFocus),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _ownerPhoneController,
                    focusNode: _ownerPhoneFocus,
                    hint: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 20),

                  // Sign-in hint
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: plan.accentColors[0].withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: plan.accentColors[0].withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: plan.accentColors[0],
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Use your Gym ID & Password to sign in next time',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _GradientButton(
                    label: 'PROCEED TO PAYMENT',
                    colors: plan.accentColors,
                    onPressed: () {
                      if (_gymNameController.text.trim().isEmpty ||
                          _gymIdController.text.trim().isEmpty ||
                          _passwordController.text.trim().isEmpty ||
                          _ownerNameController.text.trim().isEmpty ||
                          _ownerEmailController.text.trim().isEmpty ||
                          _ownerPhoneController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please fill all details'),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      _showQRPayment();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQRPayment() {
    final plan = _plans[_selectedPlan];

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) => _QRPaymentScreen(
          plan: plan,
          gymName: _gymNameController.text.trim(),
          gymId: _gymIdController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          ownerEmail: _ownerEmailController.text.trim(),
          ownerPhone: _ownerPhoneController.text.trim(),
        ),
        transitionsBuilder: (_, anim, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom App Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Membership',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ── Body ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFE62B52)],
                        ).createShader(bounds),
                        child: const Text(
                          'Choose Your\nPlan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start managing your gym with KARAN FITNESS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Plan cards
                      ...List.generate(
                        _plans.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _PlanCard(
                            plan: _plans[i],
                            selected: _selectedPlan == i,
                            shimmerCtrl: _shimmerCtrl,
                            onTap: () => setState(() => _selectedPlan = i),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // CTA
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (context, child) {
                          final scale = 1.0 + (_pulseCtrl.value * 0.015);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: _GradientButton(
                          label: 'GET STARTED',
                          colors: _plans[_selectedPlan].accentColors,
                          onPressed: _continueToDetails,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure & encrypted payment',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ══════════════════════════════════════════════════════════════════
// QR PAYMENT SCREEN (Full-screen overlay)
// ══════════════════════════════════════════════════════════════════

class _QRPaymentScreen extends StatefulWidget {
  final _MembershipPlan plan;
  final String gymName;
  final String gymId;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;

  const _QRPaymentScreen({
    required this.plan,
    required this.gymName,
    required this.gymId,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
  });

  @override
  State<_QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<_QRPaymentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanLineCtrl;
  late final AnimationController _glowCtrl;
  bool _paymentDone = false;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _simulatePayment() {
    setState(() => _paymentDone = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Payment successful! Gym ID generated.'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              plan.accentColors[0].withValues(alpha: 0.12),
              const Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Complete Payment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Amount display
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: plan.accentColors,
                        ).createShader(bounds),
                        child: Text(
                          plan.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: plan.accentColors[0].withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${plan.name} • ${plan.duration}',
                          style: TextStyle(
                            color: plan.accentColors[0],
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // QR Code card
                      AnimatedBuilder(
                        animation: _glowCtrl,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: plan.accentColors[0].withValues(
                                    alpha: 0.08 + _glowCtrl.value * 0.12,
                                  ),
                                  blurRadius: 40 + _glowCtrl.value * 20,
                                  spreadRadius: -8,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            children: [
                              // QR Code with scan animation
                              _paymentDone
                                  ? _buildSuccessBadge(plan)
                                  : _buildQRCode(plan),
                              const SizedBox(height: 20),
                              Text(
                                _paymentDone
                                    ? 'Payment Received!'
                                    : 'Scan to pay with any UPI app',
                                style: TextStyle(
                                  color: _paymentDone
                                      ? const Color(0xFF10B981)
                                      : Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!_paymentDone) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'UPI ID: karanfitness@upi',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Details card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(title: 'Gym', value: widget.gymName),
                            _SummaryRow(title: 'Gym ID', value: widget.gymId),
                            _SummaryRow(
                              title: 'Owner',
                              value: widget.ownerName,
                            ),
                            _SummaryRow(
                              title: 'Email',
                              value: widget.ownerEmail,
                            ),
                            _SummaryRow(
                              title: 'Phone',
                              value: widget.ownerPhone,
                            ),
                            _SummaryRow(title: 'Plan', value: plan.name),
                            _SummaryRow(
                              title: 'Duration',
                              value: plan.duration,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: plan.accentColors,
                                  ).createShader(bounds),
                                  child: Text(
                                    plan.price,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Simulate payment button (for dev/testing)
                      if (!_paymentDone)
                        _GradientButton(
                          label: 'SIMULATE PAYMENT',
                          colors: plan.accentColors,
                          onPressed: _simulatePayment,
                        ),
                      const SizedBox(height: 12),
                      if (!_paymentDone)
                        Text(
                          'Connect your payment gateway to replace this',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge(_MembershipPlan plan) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.15),
            const Color(0xFF10B981).withValues(alpha: 0.05),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildQRCode(_MembershipPlan plan) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // QR placeholder — replace with real QR from `qr_flutter` or your backend
        CustomPaint(
          size: const Size(200, 200),
          painter: _QRPlaceholderPainter(color: plan.accentColors[0]),
        ),
        // Scan line animation
        SizedBox(
          width: 200,
          height: 200,
          child: AnimatedBuilder(
            animation: _scanLineCtrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _ScanLinePainter(
                  progress: _scanLineCtrl.value,
                  color: plan.accentColors[0],
                ),
              );
            },
          ),
        ),
        // Center logo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: plan.accentColors[0].withValues(alpha: 0.4),
            ),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: plan.accentColors[0],
            size: 22,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// QR PLACEHOLDER PAINTER
// ══════════════════════════════════════════════════════════════════

class _QRPlaceholderPainter extends CustomPainter {
  final Color color;
  _QRPlaceholderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // deterministic "random"
    const modules = 21;
    final moduleSize = size.width / modules;

    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final accentPaint = Paint()..color = color.withValues(alpha: 0.3);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.05),
    );

    // Draw finder patterns (corners)
    _drawFinderPattern(canvas, paint, 0, 0, moduleSize);
    _drawFinderPattern(
      canvas,
      paint,
      (modules - 7) * moduleSize,
      0,
      moduleSize,
    );
    _drawFinderPattern(
      canvas,
      paint,
      0,
      (modules - 7) * moduleSize,
      moduleSize,
    );

    // Data modules
    for (int row = 0; row < modules; row++) {
      for (int col = 0; col < modules; col++) {
        // Skip finder patterns
        if ((row < 8 && col < 8) ||
            (row < 8 && col > modules - 9) ||
            (row > modules - 9 && col < 8)) {
          continue;
        }
        if (rng.nextBool()) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * moduleSize + 1,
              row * moduleSize + 1,
              moduleSize - 2,
              moduleSize - 2,
            ),
            const Radius.circular(2),
          );
          canvas.drawRRect(rect, rng.nextDouble() > 0.85 ? accentPaint : paint);
        }
      }
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double ms,
  ) {
    // Outer
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, ms * 7, ms * 7),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ms * 0.9,
    );
    // Inner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + ms * 2, y + ms * 2, ms * 3, ms * 3),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════════
// SCAN LINE PAINTER
// ══════════════════════════════════════════════════════════════════

class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.7),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));

    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter old) =>
      old.progress != progress;
}

// ══════════════════════════════════════════════════════════════════
// MEMBERSHIP PLAN MODEL
// ══════════════════════════════════════════════════════════════════

class _MembershipPlan {
  final String name;
  final String price;
  final int priceValue;
  final String duration;
  final String description;
  final IconData icon;
  final String? badge;
  final List<Color> accentColors;
  final List<String> features;

  const _MembershipPlan({
    required this.name,
    required this.price,
    required this.priceValue,
    required this.duration,
    required this.description,
    required this.icon,
    required this.accentColors,
    required this.features,
    this.badge,
  });
}

// ══════════════════════════════════════════════════════════════════
// PLAN CARD (with shimmer on selected)
// ══════════════════════════════════════════════════════════════════

class _PlanCard extends StatelessWidget {
  final _MembershipPlan plan;
  final bool selected;
  final AnimationController shimmerCtrl;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.shimmerCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? plan.accentColors[0].withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? plan.accentColors[0].withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: plan.accentColors[0].withValues(alpha: 0.12),
                    blurRadius: 30,
                    spreadRadius: -6,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon with gradient
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: selected
                          ? plan.accentColors
                          : [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.white.withValues(alpha: 0.03),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    plan.icon,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (plan.badge != null) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: plan.accentColors,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                plan.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plan.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected
                        ? LinearGradient(colors: plan.accentColors)
                        : null,
                    border: selected
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 2,
                          ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Price row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: selected
                        ? plan.accentColors
                        : [Colors.white, Colors.white70],
                  ).createShader(bounds),
                  child: Text(
                    plan.price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    plan.duration,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Features
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: selected
                            ? plan.accentColors[0].withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: selected
                            ? plan.accentColors[0]
                            : Colors.white.withValues(alpha: 0.3),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: selected ? 0.7 : 0.4,
                          ),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// GLASS BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════

class _GlassSheet extends StatelessWidget {
  final Widget child;
  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151520),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SECTION LABEL
// ══════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// INPUT FIELD
// ══════════════════════════════════════════════════════════════════

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: _focused ? 0.06 : 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.06),
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        obscureText: widget.obscureText && _obscured,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: _focused
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.25),
            size: 20,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// GRADIENT BUTTON
// ══════════════════════════════════════════════════════════════════

class _GradientButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.colors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SUMMARY ROW
// ══════════════════════════════════════════════════════════════════

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
