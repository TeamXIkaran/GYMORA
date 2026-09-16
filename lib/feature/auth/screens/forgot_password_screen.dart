import 'dart:math';

import 'package:flutter/material.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();

  // ============================================================
  // STATE
  // ============================================================

  bool _otpSent = false;
  bool _isLoading = false;

  String? _errorMessage;

  // ============================================================
  // ANIMATION CONTROLLERS
  // ============================================================

  late final AnimationController _logoCtrl;
  late final AnimationController _headingCtrl;
  late final AnimationController _fieldsCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;
  late final AnimationController _shimmerCtrl;

  // ============================================================
  // ANIMATIONS
  // ============================================================

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  late final Animation<double> _headingOpacity;
  late final Animation<double> _headingSlide;

  late final Animation<double> _fieldOpacity;
  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;

  @override
  void initState() {
    super.initState();

    _initAnimations();
    _startSequence();
  }

  // ============================================================
  // ANIMATIONS
  // ============================================================

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

    _headingOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headingCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _headingSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _headingCtrl, curve: Curves.easeOutCubic),
    );

    _fieldsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fieldOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fieldsCtrl, curve: Curves.easeOut));

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

    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    _headingCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    _fieldsCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    _ctaCtrl.forward();
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    /*
     * TODO:
     * Call your backend Send OTP API here.
     *
     * Example:
     *
     * final response = await AuthService().sendForgotPasswordOtp(email);
     *
     * if (!response.success) {
     *   setState(() {
     *     _errorMessage = response.message;
     *     _isLoading = false;
     *   });
     *   return;
     * }
     */

    // Temporary delay so UI can be tested.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _otpSent = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _otpFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();
    final otp = _otpCtrl.text.trim();

    if (otp.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP.';
      });
      return;
    }

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit OTP.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    /*
     * TODO:
     * Call your backend Verify OTP API here.
     *
     * Example:
     *
     * final response = await AuthService().verifyForgotPasswordOtp(
     *   email: email,
     *   otp: otp,
     * );
     *
     * if (!response.success) {
     *   setState(() {
     *     _errorMessage = response.message;
     *     _isLoading = false;
     *   });
     *   return;
     * }
     */

    // Temporary delay so UI can be tested.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    /*
     * After successful OTP verification:
     *
     * Navigator.pushReplacementNamed(
     *   context,
     *   'ownerLogin',
     * );
     *
     * Replace 'ownerLogin' with your actual login route.
     */

    Navigator.pop(context);
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // ============================================================
  // BACK TO LOGIN
  // ============================================================

  void _backToLogin() {
    Navigator.pop(context);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

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
    _otpCtrl.dispose();

    _emailFocus.dispose();
    _otpFocus.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

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
            // PARTICLES
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _ParticlePainter(_particleCtrl.value),
                );
              },
            ),

            // GLOW
            _buildGlowPulse(),

            const _Scanlines(),
            const _Vignette(),

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

                      // LOGO
                      _buildLogo(),

                      const SizedBox(height: 14),

                      // BRAND
                      _buildBrandText(),

                      const SizedBox(height: 40),

                      // HEADING
                      _buildHeading(),

                      const SizedBox(height: 32),

                      // EMAIL
                      if (!_otpSent) _buildEmailField(),

                      // OTP
                      if (_otpSent) _buildOtpSection(),

                      const SizedBox(height: 32),

                      // BUTTON
                      _buildCTA(),

                      const SizedBox(height: 24),

                      // ERROR
                      if (_errorMessage != null) _buildErrorMessage(),

                      const SizedBox(height: 24),

                      // BACK TO LOGIN
                      _buildBackToLogin(),

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

  // ============================================================
  // GLOW
  // ============================================================

  Widget _buildGlowPulse() {
    return AnimatedBuilder(
      animation: _glowPulseCtrl,
      builder: (_, _) {
        return Positioned(
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
                        AppColors.primary.withValues(alpha: 0.25),
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(scale: _logoScale.value, child: child),
        );
      },
      child: const _ShieldLogo(size: 72),
    );
  }

  // ============================================================
  // BRAND
  // ============================================================

  Widget _buildBrandText() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) {
        return Opacity(opacity: _logoOpacity.value, child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'K',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const Text(
                'ARAN',
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
            'FITNESS',
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADING
  // ============================================================

  Widget _buildHeading() {
    return AnimatedBuilder(
      animation: _headingCtrl,
      builder: (_, _) {
        return Opacity(
          opacity: _headingOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _headingSlide.value),
            child: Column(
              children: [
                Text(
                  _otpSent ? 'Verify OTP' : 'Forgot Password?',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Enter the OTP sent to your email'
                      : 'Enter your email to receive an OTP',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EMAIL FIELD
  // ============================================================

  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final opacity = _fieldOpacity.value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - opacity)),
            child: _GlassTextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              hint: 'Email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendOtp(),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // OTP SECTION
  // ============================================================

  Widget _buildOtpSection() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final opacity = _fieldOpacity.value;

        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              // EMAIL DISPLAY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: AppColors.primary.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _emailCtrl.text.trim(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _otpSent = false;
                          _otpCtrl.clear();
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // OTP FIELD
              _GlassTextField(
                controller: _otpCtrl,
                focusNode: _otpFocus,
                hint: 'Enter 6-digit OTP',
                prefixIcon: Icons.verified_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verifyOtp(),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _isLoading ? null : _sendOtp,
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CTA
  // ============================================================

  Widget _buildCTA() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) {
        return Opacity(
          opacity: _ctaOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _ctaSlide.value),
            child: _ShimmerButton(
              shimmerCtrl: _shimmerCtrl,
              label: _isLoading
                  ? 'Please Wait...'
                  : _otpSent
                  ? 'Verify OTP'
                  : 'Send OTP',
              enabled: !_isLoading,
              onPressed: _otpSent ? _verifyOtp : _sendOtp,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACK TO LOGIN
  // ============================================================

  Widget _buildBackToLogin() {
    return GestureDetector(
      onTap: _backToLogin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 17),
          const SizedBox(width: 7),
          Text(
            'Back to Login',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              shadows: [
                Shadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// GLASS TEXT FIELD
// ================================================================

class _GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _GlassTextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<_GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<_GlassTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;

    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
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
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        maxLength: widget.hint.contains('OTP') ? 6 : null,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        cursorColor: AppColors.primary,
        cursorWidth: 1.5,
        decoration: InputDecoration(
          counterText: '',
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
                  ? AppColors.primary.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
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

// ================================================================
// SHIMMER BUTTON
// ================================================================

class _ShimmerButton extends StatelessWidget {
  final AnimationController shimmerCtrl;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _ShimmerButton({
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
            colors: [Color(0xFFE62B52), Color(0xFF8B1528)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
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
                    final dx = shimmerCtrl.value * 3 - 1;

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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? onPressed : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SHIELD LOGO
// ================================================================

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
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 3,
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

    final outerPath = Path()
      ..moveTo(cx, h * 0.03)
      ..lineTo(w * 0.93, h * 0.22)
      ..lineTo(w * 0.93, h * 0.55)
      ..quadraticBezierTo(w * 0.93, h * 0.78, cx, h * 0.97)
      ..quadraticBezierTo(w * 0.07, h * 0.78, w * 0.07, h * 0.55)
      ..lineTo(w * 0.07, h * 0.22)
      ..close();

    final outerGrad = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD4213F), Color(0xFF6B0F20)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(outerPath, Paint()..shader = outerGrad);

    final innerPath = Path()
      ..moveTo(cx, h * 0.09)
      ..lineTo(w * 0.86, h * 0.26)
      ..lineTo(w * 0.86, h * 0.54)
      ..quadraticBezierTo(w * 0.86, h * 0.74, cx, h * 0.92)
      ..quadraticBezierTo(w * 0.14, h * 0.74, w * 0.14, h * 0.54)
      ..lineTo(w * 0.14, h * 0.26)
      ..close();

    final innerGrad = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2A080F), Color(0xFF120308)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(innerPath, Paint()..shader = innerGrad);

    final metalGrad = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFEEEEEE), Color(0xFF999999), Color(0xFFCCCCCC)],
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

    canvas.drawPath(kPath, Paint()..shader = metalGrad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ================================================================
// PARTICLES
// ================================================================

class _ParticlePainter extends CustomPainter {
  final double time;
  final List<_Particle> _particles;

  _ParticlePainter(this.time)
    : _particles = List.generate(30, (i) => _Particle(i));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x =
          (p.baseX * size.width + sin(time * 2 * pi + p.phase) * 12) %
          size.width;

      final rawY = p.baseY * size.height - (time * size.height * p.speed);

      final y = rawY % size.height;

      final lifeFrac = y / size.height;

      final opacity = p.opacity * lifeFrac;

      final paint = Paint()
        ..color = p.isRed
            ? AppColors.primary.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: opacity * 0.3);

      if (p.isRed) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return true;
  }
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
    radius = r.nextDouble() * 1.8 + 0.4;
    opacity = r.nextDouble() * 0.4 + 0.1;
    phase = r.nextDouble() * 2 * pi;
    isRed = r.nextDouble() > 0.6;
  }
}

// ================================================================
// SCANLINES
// ================================================================

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ================================================================
// VIGNETTE
// ================================================================

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [Colors.transparent, Colors.black],
              stops: [0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
