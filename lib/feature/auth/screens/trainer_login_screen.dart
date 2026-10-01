import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/providers/trainer_login_provider.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/auth_background_widget.dart';
import 'package:gymora_fitness_management/core/widgets/glassTextField_widget.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';

import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRAINER LOGIN SCREEN — GYMORA
// Backend:
// POST /api/trainers/login
//
// Request:
// {
//   "trainerId": "0002",
//   "password": "Barani00"
// }
// ═══════════════════════════════════════════════════════════════════════════

class TrainerLoginScreen extends StatefulWidget {
  const TrainerLoginScreen({super.key});

  @override
  State<TrainerLoginScreen> createState() => _TrainerLoginScreenState();
}

class _TrainerLoginScreenState extends State<TrainerLoginScreen>
    with TickerProviderStateMixin {
  // ───────────────────────────────────────────────────────────────────────
  // THEME
  // ───────────────────────────────────────────────────────────────────────

  static const Color _accent = AppColors.trainerBright;

  static const List<Color> _buttonGradient = [
    AppColors.trainerBright,
    AppColors.trainerPrimary,
  ];

  // ───────────────────────────────────────────────────────────────────────
  // STATE
  // ───────────────────────────────────────────────────────────────────────

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  final _trainerIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _trainerIdFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ───────────────────────────────────────────────────────────────────────
  // ANIMATION CONTROLLERS
  // ───────────────────────────────────────────────────────────────────────

  late final AnimationController _logoCtrl;
  late final AnimationController _headingCtrl;
  late final AnimationController _fieldsCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;
  late final AnimationController _shimmerCtrl;

  // ───────────────────────────────────────────────────────────────────────
  // ANIMATIONS
  // ───────────────────────────────────────────────────────────────────────

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  late final Animation<double> _headingOpacity;
  late final Animation<double> _headingSlide;

  late final Animation<double> _field1Opacity;
  late final Animation<double> _field2Opacity;

  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;

  // ───────────────────────────────────────────────────────────────────────
  // INIT
  // ───────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Logo
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

    // Heading
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

    // Fields
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

    // CTA
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

    // Particles
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Glow
    _glowPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Button shimmer
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

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    _ctaCtrl.forward();
  }

  // ───────────────────────────────────────────────────────────────────────
  // DISPOSE
  // ───────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _logoCtrl.dispose();
    _headingCtrl.dispose();
    _fieldsCtrl.dispose();
    _ctaCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    _shimmerCtrl.dispose();

    _trainerIdCtrl.dispose();
    _passwordCtrl.dispose();

    _trainerIdFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────
  // LOGIN
  // ───────────────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;

    final trainerId = _trainerIdCtrl.text.trim();
    final password = _passwordCtrl.text;

    // Trainer ID validation
    if (trainerId.isEmpty) {
      _showMessage('Please enter your Trainer ID');
      _trainerIdFocus.requestFocus();
      return;
    }

    // Password validation
    if (password.isEmpty) {
      _showMessage('Please enter your password');
      _passwordFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final trainerProvider = context.read<TrainerLoginProvider>();

      final success = await trainerProvider.loginTrainer(
        trainerId: trainerId,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        final trainer = trainerProvider.loggedInTrainer;

        debugPrint('TRAINER_LOGIN_SUCCESS');

        debugPrint('Trainer ID: ${trainer?.trainerId}');

        debugPrint('Trainer Name: ${trainer?.fullName}');

        debugPrint('Trainer Email: ${trainer?.email}');

        context.goNamed('trainerDashboardScreen');
      } else {
        _showMessage(
          trainerProvider.errorMessage ?? 'Invalid Trainer ID or password',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      debugPrint('TRAINER_LOGIN_SCREEN_ERROR: ${e.runtimeType}');

      _showMessage('Unable to sign in. Check your connection and try again.');
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // SNACKBAR
  // ───────────────────────────────────────────────────────────────────────

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 740;

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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    SizedBox(height: compact ? 6 : 16),

                    // ─────────────────────────────────────────────
                    // BACK BUTTON
                    // ─────────────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
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

                    SizedBox(height: compact ? 12 : 20),

                    // ─────────────────────────────────────────────
                    // LOGO
                    // ─────────────────────────────────────────────
                    _buildLogo(),

                    SizedBox(height: compact ? 18 : 26),

                    // ─────────────────────────────────────────────
                    // HEADING
                    // ─────────────────────────────────────────────
                    _buildHeading(),

                    SizedBox(height: compact ? 24 : 32),

                    // ─────────────────────────────────────────────
                    // TRAINER ID
                    // ─────────────────────────────────────────────
                    _buildTrainerIdField(),

                    const SizedBox(height: 16),

                    // ─────────────────────────────────────────────
                    // PASSWORD
                    // ─────────────────────────────────────────────
                    _buildPasswordField(),

                    SizedBox(height: compact ? 24 : 30),

                    // ─────────────────────────────────────────────
                    // LOGIN BUTTON
                    // ─────────────────────────────────────────────
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

  // ───────────────────────────────────────────────────────────────────────
  // LOGO
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(scale: _logoScale.value, child: child),
        );
      },
      child: Image.asset(
        'assets/images/gym_logo.png',
        width: 126,
        height: 126,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return Icon(Icons.fitness_center_rounded, color: _accent, size: 48);
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // HEADING
  // ───────────────────────────────────────────────────────────────────────

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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withValues(alpha: 0.26)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: _accent, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'TRAINER PORTAL',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Trainer Login',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to lead your clients forward.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // TRAINER ID FIELD
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildTrainerIdField() {
    return AnimatedBuilder(
      animation: _fieldsCtrl,
      builder: (_, _) {
        final opacity = _field1Opacity.value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - opacity)),
            child: GlassTextField(
              controller: _trainerIdCtrl,
              focusNode: _trainerIdFocus,
              hint: 'Trainer ID',
              prefixIcon: Icons.badge_outlined,
              accentColor: _accent,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocus);
              },
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // PASSWORD FIELD
  // ───────────────────────────────────────────────────────────────────────

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
              hint: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              accentColor: _accent,
              obscure: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
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

  // ───────────────────────────────────────────────────────────────────────
  // CTA
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildCTA() {
    return Consumer<TrainerLoginProvider>(
      builder: (context, trainerProvider, _) {
        final loading = trainerProvider.isLoading || _isSubmitting;

        return AnimatedBuilder(
          animation: _ctaCtrl,
          builder: (_, _) {
            return Opacity(
              opacity: _ctaOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _ctaSlide.value),
                child: AnimatedBuilder(
                  animation: _glowPulseCtrl,
                  builder: (context, child) {
                    final pulse = _glowPulseCtrl.value;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(
                              alpha: 0.10 + pulse * 0.14,
                            ),
                            blurRadius: 18 + pulse * 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
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
      },
    );
  }
}
