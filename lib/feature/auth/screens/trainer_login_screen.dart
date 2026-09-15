import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

class TrainerLoginScreen extends StatefulWidget {
  const TrainerLoginScreen({super.key});

  @override
  State<TrainerLoginScreen> createState() => _TrainerLoginScreenState();
}

class _TrainerLoginScreenState extends State<TrainerLoginScreen>
    with TickerProviderStateMixin {
  // ── Theme color ──
  static const Color _accent = AppColors.trainerPrimary;
  static const Color _accentBright = AppColors.trainerBright;
  static const Color _accentDark = AppColors.trainerDark;

  // ── State ──
  bool _obscurePassword = true;
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
  late final Animation<double> _forgotOpacity;
  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;
  late final Animation<double> _socialOpacity;

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
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _headingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headingOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headingCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _headingSlide = Tween(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _headingCtrl, curve: Curves.easeOutCubic),
    );

    _fieldsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _field1Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _field2Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _forgotOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _socialOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fieldsCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, _) => CustomPaint(
                size: Size.infinite,
                painter: _TrainerParticlePainter(_particleCtrl.value),
              ),
            ),
            _buildGlowPulse(),
            const _Scanlines(),
            const _Vignette(),
            SafeArea(
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                      _buildLogo(),
                      const SizedBox(height: 14),
                      _buildBrandText(),
                      const SizedBox(height: 40),
                      _buildHeading(),
                      const SizedBox(height: 32),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      _buildForgotPassword(),
                      const SizedBox(height: 32),
                      _buildCTA(),
                      const SizedBox(height: 28),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildSocialRow(),
                      const SizedBox(height: 32),
                      _buildSignUpLink(),
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

  // ════════════════════════════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════════════════════════════

  Widget _buildGlowPulse() {
    return AnimatedBuilder(
      animation: _glowPulseCtrl,
      builder: (_, _) => Positioned(
        top: MediaQuery.of(context).size.height * 0.08,
        left: 0,
        right: 0,
        child: Center(
          child: Opacity(
            opacity: 0.25 + (_glowPulseCtrl.value * 0.3),
            child: Transform.scale(
              scale: 1.0 + (_glowPulseCtrl.value * 0.1),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accent.withValues(alpha: 0.25),
                      _accent.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
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
      child: _TrainerShieldLogo(size: 72),
    );
  }

  Widget _buildBrandText() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) => Opacity(opacity: _logoOpacity.value, child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "K",
                style: TextStyle(
                  color: _accent,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: _accent.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const Text(
                "ARAN",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "FITNESS",
            style: TextStyle(
              color: _accent.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 8,
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
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Trainer ",
                    style: TextStyle(
                      color: _accent,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text("💪", style: TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Track your clients, workouts and progress.",
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
        final opacity = _field1Opacity.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - opacity)),
            child: _TrainerGlassTextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              hint: "Email or Phone",
              prefixIcon: Icons.email_outlined,
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
        final opacity = _field2Opacity.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - opacity)),
            child: _TrainerGlassTextField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              hint: "Password",
              prefixIcon: Icons.lock_outline_rounded,
              obscure: _obscurePassword,
              textInputAction: TextInputAction.done,
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
            onTap: () {},
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
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) => Opacity(
        opacity: _ctaOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _ctaSlide.value),
          child: _TrainerShimmerButton(
            shimmerCtrl: _shimmerCtrl,
            label: "Sign In",
            enabled: true,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) => Opacity(
        opacity: _socialOpacity.value,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.transparent,
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

  Widget _buildSocialRow() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final opacity = _socialOpacity.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - opacity)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TrainerSocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: "Google",
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _TrainerSocialButton(
                  icon: Icons.apple_rounded,
                  label: "Apple",
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _TrainerSocialButton(
                  icon: Icons.phone_android_rounded,
                  label: "Phone",
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpLink() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) => Opacity(
        opacity: _ctaOpacity.value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                "Contact Admin",
                style: TextStyle(
                  color: _accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: _accent.withValues(alpha: 0.4),
                      blurRadius: 10,
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
// TRAINER GLASS TEXT FIELD
// ══════════════════════════════════════════════════════════════════

class _TrainerGlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _TrainerGlassTextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<_TrainerGlassTextField> createState() => _TrainerGlassTextFieldState();
}

class _TrainerGlassTextFieldState extends State<_TrainerGlassTextField> {
  static const Color _accent = AppColors.trainerPrimary;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _isFocused
            ? _accent.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused
              ? _accent.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        cursorColor: _accent,
        cursorWidth: 1.5,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              widget.prefixIcon,
              color: _isFocused
                  ? _accent.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIcon: widget.suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: widget.suffixIcon,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TRAINER SOCIAL BUTTON
// ══════════════════════════════════════════════════════════════════

class _TrainerSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TrainerSocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TRAINER SHIELD LOGO — Orange/Yellow themed
// ══════════════════════════════════════════════════════════════════

class _TrainerShieldLogo extends StatelessWidget {
  final double size;
  const _TrainerShieldLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.trainerPrimary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 3,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size * 1.2),
        painter: _TrainerShieldPainter(),
      ),
    );
  }
}

class _TrainerShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final outerPath = Path()
      ..moveTo(cx, h * 0.03)
      ..lineTo(w * 0.93, h * 0.22)
      ..lineTo(w * 0.93, h * 0.55)
      ..quadraticBezierTo(w * 0.93, h * 0.78, cx, h * 0.97)
      ..quadraticBezierTo(w * 0.07, h * 0.78, w * 0.07, h * 0.55)
      ..lineTo(w * 0.07, h * 0.22)
      ..close();

    // Orange/amber gradient
    final outerGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFFEE9D2D), const Color(0xFF6B4A0F)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(outerPath, Paint()..shader = outerGrad);
    canvas.drawPath(
      outerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.12),
    );

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
      colors: [const Color(0xFF2A1A08), const Color(0xFF120A03)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(innerPath, Paint()..shader = innerGrad);
    canvas.drawPath(
      innerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.trainerPrimary.withValues(alpha: 0.25),
    );

    final metalGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFEEEEEE),
        const Color(0xFF999999),
        const Color(0xFFCCCCCC),
      ],
    ).createShader(Rect.fromLTWH(w * 0.3, h * 0.3, w * 0.4, h * 0.4));

    // K letter
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

    // Heartbeat line — orange accent
    final hbPaint = Paint()
      ..color = AppColors.trainerPrimary.withValues(alpha: 0.45)
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

    // Dumbbell ornaments
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
// TRAINER SHIMMER CTA — Orange/Yellow gradient
// ══════════════════════════════════════════════════════════════════

class _TrainerShimmerButton extends StatelessWidget {
  final AnimationController shimmerCtrl;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _TrainerShimmerButton({
    required this.shimmerCtrl,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB31A), Color(0xFF8B6415)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.trainerPrimary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (enabled)
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
                                Colors.white.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? onPressed : null,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withValues(alpha: 0.12),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1A0F00),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF1A0F00),
                          size: 20,
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

// ══════════════════════════════════════════════════════════════════
// TRAINER PARTICLES — Orange/Yellow
// ══════════════════════════════════════════════════════════════════

class _TrainerParticlePainter extends CustomPainter {
  final double time;
  final List<_TrainerParticle> _particles;

  _TrainerParticlePainter(this.time)
    : _particles = List.generate(30, (i) => _TrainerParticle(i));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x =
          (p.baseX * size.width + sin(time * 2 * pi + p.phase) * 12) %
          size.width;
      final rawY = p.baseY * size.height - (time * size.height * p.speed);
      final y = rawY % size.height;

      final lifeFrac = (y / size.height);
      final opacity = p.opacity * lifeFrac;

      final paint = Paint()
        ..color = p.isAccent
            ? AppColors.trainerPrimary.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: opacity * 0.3);

      if (p.isAccent) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrainerParticlePainter old) => true;
}

class _TrainerParticle {
  late final double baseX;
  late final double baseY;
  late final double speed;
  late final double radius;
  late final double opacity;
  late final double phase;
  late final bool isAccent;

  _TrainerParticle(int seed) {
    final r = Random(seed * 17 + 42);
    baseX = r.nextDouble();
    baseY = r.nextDouble();
    speed = r.nextDouble() * 0.4 + 0.1;
    radius = r.nextDouble() * 1.8 + 0.4;
    opacity = r.nextDouble() * 0.4 + 0.1;
    phase = r.nextDouble() * 2 * pi;
    isAccent = r.nextDouble() > 0.6;
  }
}

// ══════════════════════════════════════════════════════════════════
// SCANLINES & VIGNETTE (shared)
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
