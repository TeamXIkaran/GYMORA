import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/auth_background_widget.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PURCHASE MEMBERSHIP SCREEN — GYMORA Branding
// ═══════════════════════════════════════════════════════════════════════════

class PurchaseMembershipScreen extends StatefulWidget {
  const PurchaseMembershipScreen({super.key});

  @override
  State<PurchaseMembershipScreen> createState() =>
      _PurchaseMembershipScreenState();
}

class _PurchaseMembershipScreenState extends State<PurchaseMembershipScreen>
    with TickerProviderStateMixin {
  static const Color _accent = AppColors.primary;

  int _selectedPlanIndex = -1;

  // Plan data
  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'STARTER',
      'price': '5',
      'duration': '1 Month',
      'icon': Icons.flash_on_rounded,
      'gradient': [const Color(0xFFE62B52), const Color(0xFF8B1528)],
      'features': ['Basic Dashboard', 'Up to 50 Members', 'Email Support'],
    },
    {
      'name': 'PRO',
      'price': '10',
      'duration': '3 Months',
      'icon': Icons.star_rounded,
      'gradient': [const Color(0xFF2196F3), const Color(0xFF1565C0)],
      'features': [
        'Advanced Dashboard',
        'Up to 200 Members',
        'Priority Support',
        'Trainer Module',
      ],
    },
    {
      'name': 'ELITE',
      'price': '15',
      'duration': '6 Months',
      'icon': Icons.workspace_premium_rounded,
      'gradient': [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
      'features': [
        'Full Dashboard',
        'Unlimited Members',
        '24/7 Support',
        'All Modules',
        'Analytics',
      ],
    },
  ];

  // ── Animation Controllers ──
  late final AnimationController _logoCtrl;
  late final AnimationController _headingCtrl;
  late final AnimationController _cardsCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;

  // ── Animations ──
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _headingOpacity;
  late final Animation<double> _headingSlide;
  late final Animation<double> _card1Opacity;
  late final Animation<double> _card2Opacity;
  late final Animation<double> _card3Opacity;
  late final Animation<double> _ctaOpacity;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

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

    _headingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headingOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _headingCtrl, curve: Curves.easeOut));
    _headingSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _headingCtrl, curve: Curves.easeOutCubic),
    );

    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _card1Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsCtrl,
        curve: const Interval(0, 0.35, curve: Curves.easeOut),
      ),
    );
    _card2Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsCtrl,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _card3Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsCtrl,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    _ctaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctaOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOut));

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _glowPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _headingCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _cardsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _ctaCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _headingCtrl.dispose();
    _cardsCtrl.dispose();
    _ctaCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    super.dispose();
  }

  void _selectPlan(int index) {
    setState(() => _selectedPlanIndex = index);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FIX: Pass correct keys so GymDetailsScreen and QR screen read them
  // ═══════════════════════════════════════════════════════════════════════
  void _proceedToGymDetails() {
    if (_selectedPlanIndex < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a plan first'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final plan = _plans[_selectedPlanIndex];
    context.pushNamed(
      'gymDetailed',
      extra: {
        'name': plan['name'], // plan name for display & API
        'price': plan['price'], // formatted price for display
        'amount': plan['price'].replaceAll(
          ',',
          '',
        ), // raw number for payment API
        'duration': plan['duration'], // duration for display
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // ── Back ──
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

                  // ── Logo ──
                  _buildLogo(),
                  const SizedBox(height: 14),
                  _buildBrandText(),
                  const SizedBox(height: 30),

                  // ── Heading ──
                  _buildHeading(),
                  const SizedBox(height: 28),

                  // ── Plan Cards ──
                  _buildPlanCard(0, _card1Opacity),
                  const SizedBox(height: 14),
                  _buildPlanCard(1, _card2Opacity),
                  const SizedBox(height: 14),
                  _buildPlanCard(2, _card3Opacity),
                  const SizedBox(height: 32),

                  // ── Continue Button ──
                  _buildContinueButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildHeading() {
    return AnimatedBuilder(
      animation: _headingCtrl,
      builder: (_, _) => Opacity(
        opacity: _headingOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _headingSlide.value),
          child: Column(
            children: [
              const Text(
                'Choose Your Plan',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the plan that fits your gym',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(int index, Animation<double> opacity) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;
    final gradient = plan['gradient'] as List<Color>;
    final features = plan['features'] as List<String>;

    return AnimatedBuilder(
      animation: _cardsCtrl,
      builder: (_, _) {
        final o = opacity.value;
        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - o)),
            child: GestureDetector(
              onTap: () => _selectPlan(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? gradient[0].withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? gradient[0].withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: gradient[0].withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: -4,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(colors: gradient),
                          ),
                          child: Icon(
                            plan['icon'] as IconData,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan['name'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? gradient[0]
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan['duration'] as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${plan['price']}',
                          style: TextStyle(
                            color: isSelected
                                ? gradient[0]
                                : Colors.white.withValues(alpha: 0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 14),
                      Divider(
                        color: gradient[0].withValues(alpha: 0.2),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      ...features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: gradient[0],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                f,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) => Opacity(
        opacity: _ctaOpacity.value,
        child: GestureDetector(
          onTap: _proceedToGymDetails,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: _selectedPlanIndex >= 0
                    ? [const Color(0xFFE62B52), const Color(0xFF8B1528)]
                    : [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
              ),
              boxShadow: _selectedPlanIndex >= 0
                  ? [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: -4,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE',
                    style: TextStyle(
                      color: _selectedPlanIndex >= 0
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: _selectedPlanIndex >= 0
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
