import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation Controllers ──
  late final AnimationController _smokeCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _flashCtrl;
  late final AnimationController _brandCtrl;
  late final AnimationController _dividerCtrl;
  late final AnimationController _wordsCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;
  late final AnimationController _shimmerCtrl;

  // ── Animations ──
  late final Animation<double> _smokeScale;
  late final Animation<double> _smokeOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoBrightness;
  late final Animation<double> _flashScale;
  late final Animation<double> _flashOpacity;
  late final Animation<double> _brandSlide;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _fitnessOpacity;
  late final Animation<double> _fitnessSlide;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _word1Opacity;
  late final Animation<double> _word2Opacity;
  late final Animation<double> _word3Opacity;
  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // ── Smoke: 0 → 2s ──
    _smokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _smokeScale = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _smokeCtrl, curve: Curves.easeOut));
    _smokeOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 40),
    ]).animate(_smokeCtrl);

    // ── Logo slam: 600ms ──
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScale = Tween(
      begin: 2.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _logoBrightness = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(_logoCtrl);

    // ── Impact flash: 500ms ──
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flashScale = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 70),
    ]).animate(_flashCtrl);

    // ── Brand text: 800ms ──
    _brandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _brandSlide = Tween(
      begin: -30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _brandCtrl, curve: Curves.easeOutCubic));
    _brandOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandCtrl,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    _fitnessOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandCtrl,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );
    _fitnessSlide = Tween(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _brandCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Divider line: 800ms ──
    _dividerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _dividerWidth = Tween(
      begin: 0.0,
      end: 200.0,
    ).animate(CurvedAnimation(parent: _dividerCtrl, curve: Curves.easeOut));

    // ── Power words: 1500ms (staggered) ──
    _wordsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _word1Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _word2Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );
    _word3Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── CTA button: 700ms ──
    _ctaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctaOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOut));
    _ctaSlide = Tween(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOutCubic));

    // ── Particles (continuous) ──
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // ── Glow pulse (continuous) ──
    _glowPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // ── Button shimmer (continuous) ──
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _smokeCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _logoCtrl.forward();
    _flashCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _brandCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _dividerCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _wordsCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _ctaCtrl.forward();
  }

  @override
  void dispose() {
    _smokeCtrl.dispose();
    _logoCtrl.dispose();
    _flashCtrl.dispose();
    _brandCtrl.dispose();
    _dividerCtrl.dispose();
    _wordsCtrl.dispose();
    _ctaCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    _shimmerCtrl.dispose();
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
            // ── Floating particles ──
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, _) => CustomPaint(
                size: Size.infinite,
                painter: _ParticlePainter(_particleCtrl.value),
              ),
            ),

            // ── Ambient red smoke ──
            _buildSmoke(),

            // ── Glow pulse ──
            _buildGlowPulse(),

            // ── Impact flash ──
            _buildImpactFlash(),

            // ── Scanlines overlay ──
            const _Scanlines(),

            // ── Vignette ──
            const _Vignette(),

            // ── Corner accents ──
            _buildCornerAccents(),

            // ── Main content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Shield Logo ──
                    _buildLogo(),

                    const SizedBox(height: 28),

                    // ── Brand Name ──
                    _buildBrandName(),

                    const SizedBox(height: 32),

                    // ── Divider ──
                    _buildDivider(),

                    const SizedBox(height: 24),

                    // ── Power Words ──
                    _buildPowerWords(),

                    const SizedBox(height: 20),

                    // ── Tagline ──
                    _buildTagline(),

                    const Spacer(flex: 3),

                    // ── CTA ──
                    _buildCTA(),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════════════════════════════

  Widget _buildSmoke() {
    return AnimatedBuilder(
      animation: _smokeCtrl,
      builder: (_, _) => Positioned(
        top: MediaQuery.of(context).size.height * 0.15,
        left: 0,
        right: 0,
        child: Center(
          child: Opacity(
            opacity: _smokeOpacity.value,
            child: Transform.scale(
              scale: _smokeScale.value,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.35),
                      AppColors.primary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.7],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowPulse() {
    return AnimatedBuilder(
      animation: _glowPulseCtrl,
      builder: (_, _) => Positioned(
        top: MediaQuery.of(context).size.height * 0.18,
        left: 0,
        right: 0,
        child: Center(
          child: Opacity(
            opacity: 0.3 + (_glowPulseCtrl.value * 0.4),
            child: Transform.scale(
              scale: 1.0 + (_glowPulseCtrl.value * 0.12),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImpactFlash() {
    return AnimatedBuilder(
      animation: _flashCtrl,
      builder: (_, _) => Positioned(
        top: MediaQuery.of(context).size.height * 0.2,
        left: 0,
        right: 0,
        child: Center(
          child: Opacity(
            opacity: _flashOpacity.value,
            child: Container(
              width: 400 * _flashScale.value,
              height: 400 * _flashScale.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.white.withValues(alpha: 0.9),
                    AppColors.primary.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6],
                ),
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
        child: Transform.scale(
          scale: _logoScale.value,
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(
              _brightnessMatrix(_logoBrightness.value),
            ),
            child: child,
          ),
        ),
      ),
      child: _ShieldLogo(size: 130),
    );
  }

  Widget _buildBrandName() {
    return AnimatedBuilder(
      animation: _brandCtrl,
      builder: (_, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // KARAN — glitch slide in
          Opacity(
            opacity: _brandOpacity.value,
            child: Transform.translate(
              offset: Offset(_brandSlide.value, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "K",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "ARAN",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // FITNESS — fade up
          Opacity(
            opacity: _fitnessOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _fitnessSlide.value),
              child: Text(
                "FITNESS",
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return AnimatedBuilder(
      animation: _dividerCtrl,
      builder: (_, _) => Container(
        width: _dividerWidth.value,
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.primary, Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerWords() {
    return AnimatedBuilder(
      animation: _wordsCtrl,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _wordItem("TRAIN", _word1Opacity.value),
          _dot(_word1Opacity.value),
          _wordItem("TRANSFORM", _word2Opacity.value),
          _dot(_word2Opacity.value),
          _wordItem("TRIUMPH", _word3Opacity.value),
        ],
      ),
    );
  }

  Widget _wordItem(String text, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - opacity)),
        child: Transform.scale(
          scale: 0.8 + (0.2 * opacity),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(double opacity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: opacity,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _wordsCtrl,
      builder: (_, child) => Opacity(
        opacity: _word3Opacity.value,
        child: Transform.translate(
          offset: Offset(0, 15 * (1 - _word3Opacity.value)),
          child: child,
        ),
      ),
      child: const Text(
        "Your fitness journey\nstarts here.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCTA() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) => Opacity(
        opacity: _ctaOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _ctaSlide.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shimmer button
              _ShimmerButton(
                shimmerCtrl: _shimmerCtrl,
                onPressed: () {
                  context.pushNamed('role-selection');
                },
              ),
              const SizedBox(height: 16),
              Text(
                "Already a member?",
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  // Navigate to sign in
                },
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerAccents() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) => Opacity(
        opacity: _ctaOpacity.value * 0.15,
        child: Stack(
          children: [
            Positioned(
              top: 80,
              left: 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.primary, width: 2),
                    left: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary, width: 2),
                    right: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Brightness matrix helper
  List<double> _brightnessMatrix(double brightness) {
    return [
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

// ══════════════════════════════════════════════════════════════════
// SHIELD LOGO (drawn via CustomPainter)
// ══════════════════════════════════════════════════════════════════

class _ShieldLogo extends StatelessWidget {
  final double size;
  const _ShieldLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size * 1.2),
        painter: _ShieldPainter(),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // ── Outer shield ──
    final outerPath = Path()
      ..moveTo(cx, h * 0.03)
      ..lineTo(w * 0.93, h * 0.22)
      ..lineTo(w * 0.93, h * 0.55)
      ..quadraticBezierTo(w * 0.93, h * 0.78, cx, h * 0.97)
      ..quadraticBezierTo(w * 0.07, h * 0.78, w * 0.07, h * 0.55)
      ..lineTo(w * 0.07, h * 0.22)
      ..close();

    final outerGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFFD4213F), const Color(0xFF6B0F20)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(outerPath, Paint()..shader = outerGrad);
    canvas.drawPath(
      outerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.12),
    );

    // ── Inner shield ──
    final innerPath = Path()
      ..moveTo(cx, h * 0.09)
      ..lineTo(w * 0.86, h * 0.26)
      ..lineTo(w * 0.86, h * 0.54)
      ..quadraticBezierTo(w * 0.86, h * 0.74, cx, h * 0.92)
      ..quadraticBezierTo(w * 0.14, h * 0.74, w * 0.14, h * 0.54)
      ..lineTo(w * 0.14, h * 0.26)
      ..close();

    final innerGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFF2A080F), const Color(0xFF120308)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(innerPath, Paint()..shader = innerGrad);
    canvas.drawPath(
      innerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.primary.withValues(alpha: 0.25),
    );

    // ── K letter ──
    final metalGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFEEEEEE),
        const Color(0xFF999999),
        const Color(0xFFCCCCCC),
      ],
    ).createShader(Rect.fromLTWH(w * 0.3, h * 0.3, w * 0.4, h * 0.4));

    final kPath = Path()
      ..moveTo(w * 0.35, h * 0.35)
      ..lineTo(w * 0.35, h * 0.72)
      ..lineTo(w * 0.42, h * 0.72)
      ..lineTo(w * 0.42, h * 0.57)
      ..lineTo(w * 0.60, h * 0.72)
      ..lineTo(w * 0.70, h * 0.72)
      ..lineTo(w * 0.50, h * 0.55)
      ..lineTo(w * 0.67, h * 0.35)
      ..lineTo(w * 0.57, h * 0.35)
      ..lineTo(w * 0.42, h * 0.52)
      ..lineTo(w * 0.42, h * 0.35)
      ..close();

    canvas.drawPath(
      kPath,
      Paint()
        ..shader = metalGrad
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3),
    );
    canvas.drawPath(kPath, Paint()..shader = metalGrad);

    // ── Heartbeat line ──
    final hbPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hbPath = Path()
      ..moveTo(w * 0.22, h * 0.52)
      ..lineTo(w * 0.32, h * 0.52)
      ..lineTo(w * 0.38, h * 0.42)
      ..lineTo(w * 0.43, h * 0.58)
      ..lineTo(w * 0.48, h * 0.44)
      ..lineTo(w * 0.53, h * 0.55)
      ..lineTo(w * 0.58, h * 0.50)
      ..lineTo(w * 0.68, h * 0.50)
      ..lineTo(w * 0.78, h * 0.52);

    canvas.drawPath(hbPath, hbPaint);

    // ── Dumbbells (left) ──
    final dbPaint = Paint()
      ..shader = metalGrad
      ..color = Colors.white.withValues(alpha: 0.5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.47, w * 0.06, h * 0.09),
        const Radius.circular(2),
      ),
      dbPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.21, h * 0.49, w * 0.08, h * 0.05),
        const Radius.circular(1),
      ),
      dbPaint,
    );

    // ── Dumbbells (right) ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.79, h * 0.47, w * 0.06, h * 0.09),
        const Radius.circular(2),
      ),
      dbPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.71, h * 0.49, w * 0.08, h * 0.05),
        const Radius.circular(1),
      ),
      dbPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════════
// SHIMMER CTA BUTTON
// ══════════════════════════════════════════════════════════════════

class _ShimmerButton extends StatelessWidget {
  final AnimationController shimmerCtrl;
  final VoidCallback onPressed;

  const _ShimmerButton({required this.shimmerCtrl, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE62B52), Color(0xFF8B1528)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Shimmer sweep
              AnimatedBuilder(
                animation: shimmerCtrl,
                builder: (_, _) {
                  final dx = (shimmerCtrl.value * 3 - 1);
                  return Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment(dx, 0),
                      widthFactor: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Tap area
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withValues(alpha: 0.12),
                  child: const Center(
                    child: Text(
                      "GET STARTED",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
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

// ══════════════════════════════════════════════════════════════════
// PARTICLES
// ══════════════════════════════════════════════════════════════════

class _ParticlePainter extends CustomPainter {
  final double time;
  final List<_Particle> _particles;

  _ParticlePainter(this.time)
    : _particles = List.generate(50, (i) => _Particle(i));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x =
          (p.baseX * size.width + sin(time * 2 * pi + p.phase) * 15) %
          size.width;
      final rawY = p.baseY * size.height - (time * size.height * p.speed);
      final y = rawY % size.height;

      final lifeFrac = (y / size.height);
      final opacity = p.opacity * lifeFrac;

      final paint = Paint()
        ..color = p.isRed
            ? AppColors.primary.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: opacity * 0.4);

      if (p.isRed) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

class _Particle {
  late final double baseX;
  late final double baseY;
  late final double speed;
  late final double radius;
  late final double opacity;
  late final double phase;
  late final bool isRed;

  _Particle(int seed) {
    final r = Random(seed * 17 + 42);
    baseX = r.nextDouble();
    baseY = r.nextDouble();
    speed = r.nextDouble() * 0.4 + 0.1;
    radius = r.nextDouble() * 2 + 0.5;
    opacity = r.nextDouble() * 0.5 + 0.1;
    phase = r.nextDouble() * 2 * pi;
    isRed = r.nextDouble() > 0.6;
  }
}

// ══════════════════════════════════════════════════════════════════
// SCANLINES
// ══════════════════════════════════════════════════════════════════

class _Scanlines extends StatelessWidget {
  const _Scanlines();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.04,
          child: CustomPaint(size: Size.infinite, painter: _ScanlinePainter()),
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════════
// VIGNETTE
// ══════════════════════════════════════════════════════════════════

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
