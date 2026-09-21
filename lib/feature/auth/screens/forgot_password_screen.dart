import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/providers/owner_login_provider.dart';
import 'package:gymora_fitness_management/feature/auth/screens/reset_password_screen.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/auth_background_widget.dart';
import 'package:gymora_fitness_management/core/widgets/glassTextField_widget.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';

import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  // ── Theme color ──
  static const Color _accent = AppColors.primary;
  static const _buttonGradient = [Color(0xFFE62B52), Color(0xFF8B1528)];

  // ── Controllers ──
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _otpFocus = FocusNode();

  // ── State ──
  bool _otpSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

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
  late final Animation<double> _fieldOpacity;
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

  // ══════════════════════════════════════════════════════════════════════
  // VALIDATORS
  // ══════════════════════════════════════════════════════════════════════

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Please enter your email address.';
    if (email.length < 5) return 'Email is too short.';
    if (!_isValidEmail(email)) return 'Please enter a valid email address.';
    if (email.length > 100) return 'Email address is too long.';
    return null;
  }

  String? _validateOtp(String otp) {
    if (otp.isEmpty) return 'Please enter the OTP.';
    if (otp.contains(RegExp(r'[^0-9]'))) return 'OTP must contain only digits.';
    if (otp.length != 6) return 'Please enter the 6-digit OTP.';
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPER — sanitize raw API error messages
  // ══════════════════════════════════════════════════════════════════════

  String _sanitizeErrorMessage(String raw) {
    // If the server returned raw HTML or a route-not-found page, show a
    // user-friendly message instead of leaking markup to the UI.
    if (raw.contains('<!DOCTYPE') ||
        raw.contains('<html') ||
        raw.contains('<pre>') ||
        raw.contains('Cannot POST') ||
        raw.contains('Cannot GET') ||
        raw.contains('ECONNREFUSED') ||
        raw.contains('502') ||
        raw.contains('503')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    return raw;
  }

  // ══════════════════════════════════════════════════════════════════════
  // OTP LOGIC (API INTEGRATION)
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();

    // ── Validate email ──
    final emailError = _validateEmail(email);
    if (emailError != null) {
      setState(() {
        _errorMessage = emailError;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final ownerProvider = context.read<OwnerLoginProvider>();
    final success = await ownerProvider.forgotPassword(email: email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _otpSent = true;
        _errorMessage = null;
        _successMessage = 'OTP sent successfully to your registered email.';
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _otpFocus.requestFocus();
      });

      // Clear success message after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _successMessage = null);
      });
    } else {
      final errorMsg = ownerProvider.errorMessage ?? 'Failed to send OTP.';
      setState(() {
        if (errorMsg.contains('not found') ||
            errorMsg.contains('not registered') ||
            errorMsg.contains('No account')) {
          _errorMessage =
              'No purchased account found with this email. Only registered gym owners can reset their password.';
        } else {
          _errorMessage = _sanitizeErrorMessage(errorMsg);
        }
      });
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    final otp = _otpCtrl.text.trim();

    // ── Validate OTP ──
    final otpError = _validateOtp(otp);
    if (otpError != null) {
      setState(() {
        _errorMessage = otpError;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final ownerProvider = context.read<OwnerLoginProvider>();
    final success = await ownerProvider.verifyOtp(
      email: _emailCtrl.text.trim(),
      otp: otp,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // ── Navigate to Reset Password Screen ──
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              ResetPasswordScreen(email: _emailCtrl.text.trim(), otp: otp),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      final errorMsg =
          ownerProvider.errorMessage ?? 'Invalid OTP. Please try again.';
      setState(() {
        _errorMessage = _sanitizeErrorMessage(errorMsg);
      });
    }
  }

  void _backToLogin() => Navigator.pop(context);

  // ══════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════

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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                    _buildLogo(),
                    const SizedBox(height: 14),
                    _buildBrandText(),
                    const SizedBox(height: 40),
                    _buildHeading(),
                    const SizedBox(height: 10),
                    _buildPurchaseNotice(),
                    const SizedBox(height: 24),
                    if (!_otpSent) _buildEmailField(),
                    if (_otpSent) _buildOtpSection(),
                    const SizedBox(height: 32),
                    _buildCTA(),
                    const SizedBox(height: 16),
                    if (_successMessage != null) _buildSuccessMessage(),
                    if (_errorMessage != null) _buildErrorMessage(),
                    const SizedBox(height: 24),
                    _buildBackToLogin(),
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
        width: 72,
        height: 72,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_accent, _accent.withValues(alpha: 0.6)],
            ),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 36,
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
                    : 'Enter your registered email to receive an OTP',
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
      ),
    );
  }

  // ── Purchase-only notice ──
  Widget _buildPurchaseNotice() {
    return AnimatedBuilder(
      animation: _headingCtrl,
      builder: (_, child) =>
          Opacity(opacity: _headingOpacity.value, child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accent.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: _accent.withValues(alpha: 0.7),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Password reset is available only for purchased gym accounts.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final opacity = _fieldOpacity.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - opacity)),
            child: GlassTextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              hint: 'Email address',
              prefixIcon: Icons.email_outlined,
              accentColor: _accent,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendOtp(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpSection() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final opacity = _fieldOpacity.value;
        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              // Email display
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
                      color: _accent.withValues(alpha: 0.8),
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
                          _successMessage = null;
                        });
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // OTP field
              GlassTextField(
                controller: _otpCtrl,
                focusNode: _otpFocus,
                hint: 'Enter 6-digit OTP',
                prefixIcon: Icons.verified_outlined,
                accentColor: _accent,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
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
                      color: _accent.withValues(alpha: 0.9),
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
            label: _isLoading
                ? 'Please Wait...'
                : _otpSent
                ? 'Verify OTP'
                : 'Send OTP',
            enabled: !_isLoading,
            onPressed: _otpSent ? _verifyOtp : _sendOtp,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade400,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _successMessage!,
                style: TextStyle(color: Colors.green.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildBackToLogin() {
    return GestureDetector(
      onTap: _backToLogin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back_rounded, color: _accent, size: 17),
          const SizedBox(width: 7),
          Text(
            'Back to Login',
            style: TextStyle(
              color: _accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              shadows: [
                Shadow(color: _accent.withValues(alpha: 0.4), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
