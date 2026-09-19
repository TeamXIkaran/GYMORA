import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/ShieldLogo_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/Vignette_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/particle_painter_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/scan_line_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/shimmer_button_widget.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Theme color ──
  static const Color _accent = AppColors.primary;
  static const _outerShield = [Color(0xFFD4213F), Color(0xFF6B0F20)];
  static const _innerShield = [Color(0xFF2A080F), Color(0xFF120308)];
  static const _buttonGradient = [Color(0xFFE62B52), Color(0xFF8B1528)];

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
  late final Animation<double> _smokeOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoBrightness;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _flashOpacity;
  late final Animation<double> _flashScale;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _brandSlide;
  late final Animation<double> _fitnessOpacity;
  late final Animation<double> _fitnessSlide;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _word1Opacity;
  late final Animation<double> _word1Scale;
  late final Animation<double> _word1Slide;
  late final Animation<double> _word2Opacity;
  late final Animation<double> _word2Scale;
  late final Animation<double> _word2Slide;
  late final Animation<double> _word3Opacity;
  late final Animation<double> _word3Scale;
  late final Animation<double> _word3Slide;
  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Smoke
    _smokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _smokeOpacity = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.6),
        weight: 40.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.6, end: 0.0),
        weight: 60.0,
      ),
    ]).animate(CurvedAnimation(parent: _smokeCtrl, curve: Curves.easeOut));

    // Logo slam
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(
      begin: 2.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _logoBrightness = Tween<double>(
      begin: 3.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Flash
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.8),
        weight: 30.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.8, end: 0.0),
        weight: 70.0,
      ),
    ]).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));

    _flashScale = Tween<double>(
      begin: 0.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));

    // Brand text
    _brandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _brandSlide = Tween<double>(
      begin: -30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _brandCtrl, curve: Curves.easeOutCubic));

    _fitnessOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandCtrl,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _fitnessSlide = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _brandCtrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Divider
    _dividerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dividerWidth = Tween<double>(begin: 0.0, end: 200.0).animate(
      CurvedAnimation(parent: _dividerCtrl, curve: Curves.easeOutCubic),
    );

    // Power words
    _wordsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _word1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _word1Scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _word1Slide = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _word2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    _word2Scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _word2Slide = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    _word3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    _word3Scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _word3Slide = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _wordsCtrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    // CTA
    _ctaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _ctaOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOut));

    _ctaSlide = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOutCubic));

    // Background loops
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _glowPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    _smokeCtrl.forward();
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    _flashCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    _brandCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    _dividerCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    _wordsCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

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

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Stack(
          children: [
            // ── Particles ──
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, _) => CustomPaint(
                size: size,
                painter: ParticlePainter(
                  time: _particleCtrl.value,
                  accentColor: _accent,
                  count: 50,
                  maxRadius: 2,
                  minRadius: 0.5,
                  maxOpacity: 0.5,
                  swayAmount: 15,
                  nonAccentOpacityFactor: 0.4,
                ),
              ),
            ),

            // ── Glow ──
            AnimatedBuilder(
              animation: _glowPulseCtrl,
              builder: (_, _) {
                final v = _glowPulseCtrl.value;

                return Positioned(
                  top: size.height * 0.18,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 0.3 + 0.4 * v,
                    child: Transform.scale(
                      scale: 1.0 + 0.12 * v,
                      child: Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _accent.withValues(alpha: 0.15),
                              _accent.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Scanlines & Vignette ──
            const Scanlines(),
            const Vignette(),

            // ── Corner accents ──
            _buildCornerAccents(),

            // ─────────────────────────────────────────
            // SMOKE - BACKGROUND ONLY
            // Does not take layout space anymore.
            // ─────────────────────────────────────────
            Positioned.fill(
              child: IgnorePointer(child: Center(child: _buildSmoke())),
            ),

            // ─────────────────────────────────────────
            // FLASH - BACKGROUND ONLY
            // Does not take layout space anymore.
            // ─────────────────────────────────────────
            Positioned.fill(
              child: IgnorePointer(child: Center(child: _buildFlash())),
            ),

            // ─────────────────────────────────────────
            // MAIN CONTENT - EXACT CENTER
            // ─────────────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),

                      const SizedBox(height: 20),

                      _buildBrandText(),

                      const SizedBox(height: 24),

                      _buildDivider(),

                      const SizedBox(height: 24),

                      _buildPowerWords(),

                      const SizedBox(height: 48),

                      _buildCTA(),
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

  Widget _buildCornerAccents() {
    return Stack(
      children: [
        // Top-left
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                colors: [_accent.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
          ),
        ),

        // Top-right
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                colors: [_accent.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
          ),
        ),

        // Bottom-left
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomLeft,
                colors: [_accent.withValues(alpha: 0.06), Colors.transparent],
              ),
            ),
          ),
        ),

        // Bottom-right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                colors: [_accent.withValues(alpha: 0.06), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmoke() {
    return AnimatedBuilder(
      animation: _smokeCtrl,
      builder: (_, _) => Opacity(
        opacity: _smokeOpacity.value,
        child: Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _accent.withValues(alpha: 0.15),
                _accent.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
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
      child: const ShieldLogo(
        size: 130,
        outerGradientColors: _outerShield,
        innerGradientColors: _innerShield,
        accentColor: _accent,
        shadowAlpha: 0.4,
        blurRadius: 40,
        spreadRadius: 5,
      ),
    );
  }

  Widget _buildFlash() {
    return AnimatedBuilder(
      animation: _flashCtrl,
      builder: (_, _) {
        if (_flashOpacity.value <= 0.01) {
          return const SizedBox.shrink();
        }

        return Opacity(
          opacity: _flashOpacity.value,
          child: Transform.scale(
            scale: _flashScale.value,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.6),
                    _accent.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandText() {
    return AnimatedBuilder(
      animation: _brandCtrl,
      builder: (_, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // KARAN
          Opacity(
            opacity: _brandOpacity.value,
            child: Transform.translate(
              offset: Offset(_brandSlide.value, 0),
              child: Text(
                'KARAN',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: _accent.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // FITNESS
          Opacity(
            opacity: _fitnessOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _fitnessSlide.value),
              child: Text(
                'F I T N E S S',
                style: TextStyle(
                  color: _accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 8,
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
            colors: [
              Colors.transparent,
              _accent.withValues(alpha: 0.6),
              Colors.transparent,
            ],
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
          _buildWord('TRAIN', _word1Opacity, _word1Scale, _word1Slide),
          _buildDot(_word1Opacity),

          _buildWord('TRANSFORM', _word2Opacity, _word2Scale, _word2Slide),
          _buildDot(_word2Opacity),

          _buildWord('TRIUMPH', _word3Opacity, _word3Scale, _word3Slide),
        ],
      ),
    );
  }

  Widget _buildWord(
    String text,
    Animation<double> opacity,
    Animation<double> scale,
    Animation<double> slide,
  ) {
    return Opacity(
      opacity: opacity.value,
      child: Transform.translate(
        offset: Offset(0, slide.value),
        child: Transform.scale(
          scale: scale.value,
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Animation<double> opacity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Opacity(
        opacity: opacity.value,
        child: Text(
          '·',
          style: TextStyle(
            color: _accent,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
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
          child: ShimmerButton(
            shimmerCtrl: _shimmerCtrl,
            gradientColors: _buttonGradient,
            accentColor: _accent,
            onPressed: () => context.pushNamed('role-selection'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'GET STARTED',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white.withValues(alpha: 0.9),
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
