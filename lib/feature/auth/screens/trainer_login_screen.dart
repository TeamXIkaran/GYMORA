import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/providers/auth_provider.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/auth_background_widget.dart';
import 'package:gymora_fitness_management/core/widgets/glassTextField_widget.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';
import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRAINER LOGIN SCREEN — GYMORA Branding
// ═══════════════════════════════════════════════════════════════════════════

class TrainerLoginScreen extends StatefulWidget {
  const TrainerLoginScreen({super.key});

  @override
  State<TrainerLoginScreen> createState() => _TrainerLoginScreenState();
}

class _TrainerLoginScreenState extends State<TrainerLoginScreen>
    with TickerProviderStateMixin {
  // ── Theme ──
  static const Color _accent = Color(0xFF2196F3);
  static const _buttonGradient = [Color(0xFF2196F3), Color(0xFF1565C0)];

  // ── State ──
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ── Animation Controllers ──
  late final AnimationController _logoCtrl;
  late final AnimationController _headingCtrl;
  late final AnimationController _fieldsCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;
  late final AnimationController _shimmerCtrl;

  // ── Animations ──
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _headingOpacity;
  late final Animation<double> _headingSlide;
  late final Animation<double> _field1Opacity;
  late final Animation<double> _field2Opacity;
  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;

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

    _fieldsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _field1Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _field2Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
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

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _headingCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fieldsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _ctaCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _headingCtrl.dispose();
    _fieldsCtrl.dispose();
    _ctaCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // login handleing

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.login(
        email: email,
        password: password,
        expectedRole: 'trainer',
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (success) {
        // Trainer successfully authenticated
        context.goNamed('trainerDashboardScreen');
      } else {
        _showMessage(
          authProvider.errorMessage ?? 'Invalid trainer email or password.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      _showMessage('Unable to login. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),

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

                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                    _buildLogo(),
                    const SizedBox(height: 14),
                    _buildBrandText(),
                    const SizedBox(height: 40),
                    _buildHeading(),
                    const SizedBox(height: 32),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    _buildCTA(),
                    const SizedBox(height: 20),
                  ],
                ),
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
                'Trainer Login',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to coach your clients',
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

  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final o = _field1Opacity.value;
        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - o)),
            child: GlassTextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
              accentColor: _accent,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final o = _field2Opacity.value;
        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - o)),
            child: GlassTextField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              hint: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              accentColor: _accent,
              obscure: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white.withValues(alpha: 0.35),
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCTA() {
    return Consumer<AuthProvider>(
      builder: (context, authProv, _) {
        final loading = authProv.isLoading || _isSubmitting;

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
                label: loading ? 'Signing In...' : 'Sign In',
                enabled: !loading,
                onPressed: _handleLogin,
              ),
            ),
          ),
        );
      },
    );
  }
}
