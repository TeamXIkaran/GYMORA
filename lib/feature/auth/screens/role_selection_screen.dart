import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ROLE SELECTION SCREEN — GYMORA Branding
// ═══════════════════════════════════════════════════════════════════════════

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  static const Color _accent = AppColors.primary;

  // ── Animation Controllers ──
  late final AnimationController _logoCtrl;
  late final AnimationController _headingCtrl;
  late final AnimationController _cardsCtrl;
  late final AnimationController _footerCtrl;
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
  late final Animation<double> _footerOpacity;

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

    _footerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _footerOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _footerCtrl, curve: Curves.easeOut));

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
    _footerCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _headingCtrl.dispose();
    _cardsCtrl.dispose();
    _footerCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Stack(
          children: [
            // ── Animated glow ──
            AnimatedBuilder(
              animation: _glowPulseCtrl,
              builder: (_, _) => Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _accent.withValues(
                          alpha: 0.1 + (_glowPulseCtrl.value * 0.06),
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Particles ──
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _RoleParticlePainter(
                  progress: _particleCtrl.value,
                  color: _accent,
                ),
              ),
            ),

            // ── Content ──
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        32,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),

                      // ── GYMORA Logo ──
                      _buildLogo(),
                      const SizedBox(height: 14),
                      _buildBrandText(),
                      const SizedBox(height: 40),

                      // ── Heading ──
                      _buildHeading(),
                      const SizedBox(height: 36),

                      // ── Role Cards ──
                      _buildRoleCard(
                        opacity: _card1Opacity,
                        icon: Icons.business_rounded,
                        title: 'Gym Owner',
                        subtitle: 'Manage your gym empire',
                        routeName: 'ownerLogin',
                        gradient: const [Color(0xFFE62B52), Color(0xFF8B1528)],
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        opacity: _card2Opacity,
                        icon: Icons.sports_gymnastics_rounded,
                        title: 'Trainer',
                        subtitle: 'Coach & train your clients',
                        routeName: 'trainerLogin',
                        gradient: const [Color(0xFF2196F3), Color(0xFF1565C0)],
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        opacity: _card3Opacity,
                        icon: Icons.person_rounded,
                        title: 'Client',
                        subtitle: 'Track your fitness journey',
                        routeName: 'clientLogin',
                        gradient: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),

                      const SizedBox(height: 40),

                      // ── Footer ──
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        width: 90,
        height: 90,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_accent, _accent.withValues(alpha: 0.6)],
            ),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 40,
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
                fontSize: 28,
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
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADING ──
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
                'Enter GYMORA as a',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your role to continue',
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

  // ── ROLE CARD ──
  Widget _buildRoleCard({
    required Animation<double> opacity,
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
    required List<Color> gradient,
  }) {
    return AnimatedBuilder(
      animation: _cardsCtrl,
      builder: (_, _) {
        final o = opacity.value;
        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - o)),
            child: GestureDetector(
              onTap: () => context.pushNamed(routeName),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: gradient[0].withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(colors: gradient),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: gradient[0].withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── FOOTER ──
  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _footerCtrl,
      builder: (_, child) =>
          Opacity(opacity: _footerOpacity.value, child: child),
      child: Text(
        'Powered by GYMORA FITNESS MANAGEMENT',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ROLE PARTICLE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _RoleParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Random _random = Random(99);

  _RoleParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;
      final speed = 0.2 + _random.nextDouble() * 0.5;
      final radius = 0.8 + _random.nextDouble() * 1.5;
      final alpha = 0.04 + _random.nextDouble() * 0.1;

      final y = (baseY - progress * speed * size.height) % size.height;

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoleParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
