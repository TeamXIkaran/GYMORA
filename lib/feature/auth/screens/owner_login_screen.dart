import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:karan_fitness/config/theme/app_colors.dart';
import 'package:karan_fitness/feature/auth/providers/auth_provider.dart';
import 'package:karan_fitness/feature/auth/widgets/ShieldLogo_widget.dart';
import 'package:karan_fitness/feature/auth/widgets/auth_background_widget.dart';
import 'package:karan_fitness/feature/auth/widgets/brand_text_widget.dart';
import 'package:karan_fitness/feature/auth/widgets/glassTextField_Widget.dart';
import 'package:karan_fitness/feature/auth/widgets/shimmer_button_widget.dart';

import 'package:karan_fitness/mixins/login_mixins.dart';
import 'package:provider/provider.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen>
    with TickerProviderStateMixin, LoginMixin {
  // ── Theme color ──
  static const Color _accent = AppColors.primary;

  // ── Shield colors ──
  static const _outerShield = [Color(0xFFD4213F), Color(0xFF6B0F20)];
  static const _innerShield = [Color(0xFF2A080F), Color(0xFF120308)];
  static const _buttonGradient = [Color(0xFFE62B52), Color(0xFF8B1528)];

  // ── State ──
  bool _obscurePassword = true;

  final _gymIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _gymIdFocus = FocusNode();
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
  late final Animation<double> _forgotOpacity;
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
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _headingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headingCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _headingSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _headingCtrl, curve: Curves.easeOutCubic),
    );

    _fieldsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _field1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _field2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _forgotOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

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
    _gymIdCtrl.dispose();
    _passwordCtrl.dispose();
    _gymIdFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Login ──

  void _handleLogin() {
    if (isSubmitting) return;

    if (_gymIdCtrl.text.trim().isEmpty) {
      _showMessage('Please enter your Gym ID');
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      _showMessage('Please enter your password');
      return;
    }

    performLogin(
      emailCtrl: _gymIdCtrl,
      passwordCtrl: _passwordCtrl,
      role: 'owner',
      successRoute: 'ownerDashboard',
    );
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

  // ── Build ──

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
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 16.0,
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                    _buildLogo(),
                    const SizedBox(height: 14),
                    _buildBrandText(),
                    const SizedBox(height: 40),
                    _buildHeading(),
                    const SizedBox(height: 32),
                    _buildGymIdField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 12),
                    _buildForgotPassword(),
                    const SizedBox(height: 32),
                    _buildCTA(),
                    const SizedBox(height: 32),
                    _buildPurchaseMembership(),
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

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) => Opacity(
        opacity: _logoOpacity.value,
        child: Transform.scale(scale: _logoScale.value, child: child),
      ),
      child: const ShieldLogo(
        size: 72,
        outerGradientColors: _outerShield,
        innerGradientColors: _innerShield,
        accentColor: _accent,
      ),
    );
  }

  Widget _buildBrandText() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) => Opacity(opacity: _logoOpacity.value, child: child),
      child: const BrandText(accentColor: _accent),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to manage your gym",
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

  Widget _buildGymIdField() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final opacity = _field1Opacity.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - opacity)),
            child: GlassTextField(
              controller: _gymIdCtrl,
              focusNode: _gymIdFocus,
              hint: "Gym ID",
              prefixIcon: Icons.business_rounded,
              accentColor: _accent,
              keyboardType: TextInputType.text,
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
        final opacity = _field2Opacity.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - opacity)),
            child: GlassTextField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              hint: "Password",
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

  Widget _buildForgotPassword() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) => Opacity(
        opacity: _forgotOpacity.value,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.pushNamed('forgetpassword'),
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                color: _accent.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCTA() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
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
                label: auth.isLoading ? "Signing In..." : "Sign In",
                enabled: !auth.isLoading && !isSubmitting,
                onPressed: _handleLogin,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurchaseMembership() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) => Opacity(
        opacity: _ctaOpacity.value,
        child: Column(
          children: [
            Text(
              "Don't have a Gym ID?",
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.pushNamed('purchaseMembership'),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _accent.withValues(alpha: 0.55)),
                  color: _accent.withValues(alpha: 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.08),
                      blurRadius: 18,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.pushNamed('purchaseMembership'),
                    borderRadius: BorderRadius.circular(14),
                    splashColor: _accent.withValues(alpha: 0.12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: _accent,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "PURCHASE MEMBERSHIP",
                          style: TextStyle(
                            color: _accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _accent,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
