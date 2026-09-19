import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SPLASH SCREEN — GYMORA Branding
// ═══════════════════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _accent = AppColors.primary;

  // ── Animation Controllers ──
  late final AnimationController _logoCtrl;
  late final AnimationController _brandCtrl;
  late final AnimationController _subtitleCtrl;
  late final AnimationController _footerCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _pulseCtrl;

  // ── Animations ──
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _brandSlide;
  late final Animation<double> _subtitleOpacity;
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
      duration: const Duration(milliseconds: 1000),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _brandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _brandOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _brandCtrl, curve: Curves.easeOut));
    _brandSlide = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _brandCtrl, curve: Curves.easeOutCubic));

    _subtitleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut));

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

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _brandCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _subtitleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _footerCtrl.forward();

    // Navigate after splash
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.pushNamed('role-selection');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _brandCtrl.dispose();
    _subtitleCtrl.dispose();
    _footerCtrl.dispose();
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
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
              animation: _glowCtrl,
              builder: (_, _) => Positioned(
                top: -80,
                left: MediaQuery.of(context).size.width * 0.2,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _accent.withValues(
                          alpha: 0.12 + (_glowCtrl.value * 0.08),
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
                painter: _SplashParticlePainter(
                  progress: _particleCtrl.value,
                  color: _accent,
                ),
              ),
            ),

            // ── Content ──
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // ── Logo ──
                    AnimatedBuilder(
                      animation: _logoCtrl,
                      builder: (_, child) => Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, child) {
                          final scale = 1.0 + (_pulseCtrl.value * 0.03);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Image.asset(
                          'assets/images/gymora_logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _accent,
                                  _accent.withValues(alpha: 0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── Brand Name ──
                    AnimatedBuilder(
                      animation: _brandCtrl,
                      builder: (_, _) => Opacity(
                        opacity: _brandOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _brandSlide.value),
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    _accent,
                                    _accent.withValues(alpha: 0.7),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'GYMORA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'F I T N E S S   M A N A G E M E N T',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Subtitle ──
                    AnimatedBuilder(
                      animation: _subtitleCtrl,
                      builder: (_, child) => Opacity(
                        opacity: _subtitleOpacity.value,
                        child: child,
                      ),
                      child: Text(
                        'Complete Gym Management Solution',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Footer ──
                    AnimatedBuilder(
                      animation: _footerCtrl,
                      builder: (_, child) =>
                          Opacity(opacity: _footerOpacity.value, child: child),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: _accent.withValues(alpha: 0.5),
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Secure GYMORA authentication',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
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

// ═══════════════════════════════════════════════════════════════════════════
// SPLASH PARTICLE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _SplashParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Random _random = Random(42);

  _SplashParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;
      final speed = 0.3 + _random.nextDouble() * 0.7;
      final radius = 1.0 + _random.nextDouble() * 2;
      final alpha = 0.05 + _random.nextDouble() * 0.15;

      final y = (baseY - progress * speed * size.height) % size.height;

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
