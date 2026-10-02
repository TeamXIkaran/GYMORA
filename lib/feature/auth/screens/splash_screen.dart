import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/service/auth_session_service.dart';

import 'package:gymora_fitness_management/config/theme/app_colors.dart';

import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _accent = AppColors.primary;

  // ================================================================
  // CONTROLLERS
  // ================================================================

  late final AnimationController _logoCtrl;
  late final AnimationController _subtitleCtrl;
  late final AnimationController _buttonCtrl;
  late final AnimationController _buttonPulseCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;

  // ================================================================
  // ANIMATIONS
  // ================================================================

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  late final Animation<double> _subtitleOpacity;

  late final Animation<double> _buttonOpacity;
  late final Animation<double> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
    _restoreSavedSession();
  }

  // ================================================================
  // INITIALIZE ANIMATIONS
  // ================================================================

  void _initAnimations() {
    // ---------------------------------------------------------------
    // LOGO
    // ---------------------------------------------------------------

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.65, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.65,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    // ---------------------------------------------------------------
    // SUBTITLE
    // ---------------------------------------------------------------

    _subtitleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _subtitleOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut));

    // ---------------------------------------------------------------
    // BUTTON
    // ---------------------------------------------------------------

    _buttonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _buttonOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeOut));

    _buttonSlide = Tween<double>(
      begin: 35,
      end: 0,
    ).animate(CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeOutBack));

    _buttonPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // ---------------------------------------------------------------
    // PARTICLES
    // ---------------------------------------------------------------

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // ---------------------------------------------------------------
    // BACKGROUND GLOW
    // ---------------------------------------------------------------

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // ---------------------------------------------------------------
    // LOGO PULSE
    // ---------------------------------------------------------------

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // ---------------------------------------------------------------
    // SHIMMER
    // ---------------------------------------------------------------

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  Future<void> _restoreSavedSession() async {
    try {
      final destination = await AuthSessionService().restoreDashboardRoute();
      if (!mounted || destination == null) return;
      context.go(destination);
    } catch (_) {
      debugPrint('AUTH_SESSION_RESTORE_ERROR');
    }
  }
  // ================================================================
  // START ANIMATION SEQUENCE
  // ================================================================

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    _subtitleCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    await _buttonCtrl.forward();

    if (mounted) {
      _buttonPulseCtrl.repeat(reverse: true);
    }
  }

  // ================================================================
  // GET STARTED
  // ================================================================

  void _getStarted() {
    FocusScope.of(context).unfocus();

    context.pushNamed('role-selection');
  }

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    _logoCtrl.dispose();
    _subtitleCtrl.dispose();
    _buttonCtrl.dispose();
    _buttonPulseCtrl.dispose();
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();

    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ============================================================
          // MAIN BACKGROUND
          // ============================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          // ============================================================
          // AMBIENT BACKGROUND
          // ============================================================
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, _) {
                final glowValue = _glowCtrl.value;

                return Stack(
                  children: [
                    // Top red glow
                    Positioned(
                      top: -130,
                      left: size.width * 0.15,
                      child: Container(
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _accent.withValues(
                                alpha: 0.075 + glowValue * 0.055,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom red glow
                    Positioned(
                      bottom: -180,
                      right: -100,
                      child: Container(
                        width: 380,
                        height: 380,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _accent.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Blue secondary glow
                    Positioned(
                      top: size.height * 0.38,
                      right: -130,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF2563EB).withValues(alpha: 0.035),
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

          // ============================================================
          // GRID
          // ============================================================
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
          ),

          // ============================================================
          // PARTICLES
          // ============================================================
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, _) {
                  return CustomPaint(
                    painter: _SplashParticlePainter(
                      progress: _particleCtrl.value,
                      color: _accent,
                    ),
                  );
                },
              ),
            ),
          ),

          // ============================================================
          // MAIN CONTENT
          // ============================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ======================================================
                  // LOGO
                  // ======================================================
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
                    builder: (_, child) {
                      final pulseScale = 1.0 + (_pulseCtrl.value * 0.025);

                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value * pulseScale,
                          child: child,
                        ),
                      );
                    },
                    child: _buildLogo(),
                  ),

                  const SizedBox(height: 12),

                  // ======================================================
                  // SUBTITLE
                  // ======================================================
                  FadeTransition(
                    opacity: _subtitleOpacity,
                    child: _buildSubtitle(),
                  ),

                  const Spacer(flex: 3),

                  // ======================================================
                  // GET STARTED BUTTON
                  // ======================================================
                  AnimatedBuilder(
                    animation: _buttonCtrl,
                    builder: (_, child) {
                      return Opacity(
                        opacity: _buttonOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _buttonSlide.value),
                          child: child,
                        ),
                      );
                    },
                    child: _buildGetStartedButton(),
                  ),

                  const SizedBox(height: 20),

                  // ======================================================
                  // BOTTOM TEXT
                  // ======================================================
                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: _buildBottomText(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOGO
  // ================================================================

  Widget _buildLogo() {
    final logoSize = (MediaQuery.sizeOf(context).width - 48)
        .clamp(220.0, 330.0)
        .toDouble();

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: logoSize * 0.76,
            height: logoSize * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _accent.withValues(alpha: 0.16),
                  _accent.withValues(alpha: 0.035),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Image.asset(
            'assets/images/gym_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                Icon(Icons.fitness_center_rounded, color: _accent, size: 72),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SUBTITLE
  // ================================================================

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          'YOUR GYM. YOUR PEOPLE. YOUR PROGRESS.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.52),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'One powerful platform to manage your fitness journey.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.28),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // GET STARTED
  // ================================================================

  Widget _buildGetStartedButton() {
    return AnimatedBuilder(
      animation: _buttonPulseCtrl,
      builder: (context, child) {
        final pulse = _buttonPulseCtrl.value;
        return Transform.scale(
          scale: 1 + pulse * 0.012,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.20 + pulse * 0.16),
                  blurRadius: 22 + pulse * 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: ShimmerButton(
        shimmerCtrl: _shimmerCtrl,
        gradientColors: [
          AppColors.ownerBright,
          AppColors.ownerPrimary,
          Color.lerp(_accent, Colors.black, 0.25) ?? _accent,
        ],
        accentColor: _accent,
        textColor: Colors.white,
        label: 'Get Started',
        onPressed: _getStarted,
      ),
    );
  }

  // ================================================================
  // BOTTOM TEXT
  // ================================================================

  Widget _buildBottomText() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              color: Colors.white.withValues(alpha: 0.25),
              size: 13,
            ),
            const SizedBox(width: 6),
            Text(
              'SECURE • FAST • POWERFUL',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.22),
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        Text(
          'STRONGER TOGETHER',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.13),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.8,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// GRID PAINTER
// =====================================================================

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1;

    const double spacing = 42;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// =====================================================================
// PARTICLE PAINTER
// =====================================================================

class _SplashParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  final Random _random = Random(42);

  _SplashParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 32; i++) {
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;

      final speed = 0.2 + _random.nextDouble() * 0.8;
      final radius = 0.7 + _random.nextDouble() * 1.7;
      final alpha = 0.025 + _random.nextDouble() * 0.11;

      final y = (baseY - progress * speed * size.height) % size.height;

      paint.color = color.withValues(alpha: alpha);

      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
