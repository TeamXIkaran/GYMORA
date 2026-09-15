import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  // ── State ──
  String? _selectedRole;

  // ── Animation Controllers ──
  late final AnimationController _logoCtrl;
  late final AnimationController _headingCtrl;
  late final AnimationController _rolesCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;
  late final AnimationController _shimmerCtrl;

  // ── Animations ──
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _headingOpacity;
  late final Animation<double> _headingSlide;
  late final Animation<double> _role1Opacity;
  late final Animation<double> _role2Opacity;
  late final Animation<double> _role3Opacity;
  late final Animation<double> _ctaOpacity;
  late final Animation<double> _ctaSlide;

  final List<_RoleOption> _roles = const [
    _RoleOption(key: 'owner', label: 'Owner', icon: Icons.business_rounded),
    _RoleOption(
      key: 'trainer',
      label: 'Trainer',
      icon: Icons.fitness_center_rounded,
    ),
    _RoleOption(key: 'client', label: 'Client', icon: Icons.person_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // ── Logo: 700ms ──
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

    // ── Heading: 600ms ──
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

    // ── Roles: 1200ms (staggered) ──
    _rolesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _role1Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rolesCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _role2Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rolesCtrl,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );
    _role3Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rolesCtrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    // ── CTA: 700ms ──
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
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _headingCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _rolesCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _ctaCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _headingCtrl.dispose();
    _rolesCtrl.dispose();
    _ctaCtrl.dispose();
    _particleCtrl.dispose();
    _glowPulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() => _selectedRole = role);
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

            // ── Ambient glow behind logo ──
            _buildGlowPulse(),

            // ── Scanlines overlay ──
            const _Scanlines(),

            // ── Vignette ──
            const _Vignette(),

            // ── Main content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Shield Logo ──
                    _buildLogo(),

                    const SizedBox(height: 16),

                    // ── Brand Name ──
                    _buildBrandText(),

                    const SizedBox(height: 48),

                    // ── Heading ──
                    _buildHeading(),

                    const SizedBox(height: 32),

                    // ── Role Cards ──
                    _buildRoleSelector(),

                    const Spacer(flex: 3),

                    // ── CTA ──
                    _buildCTA(),

                    const SizedBox(height: 20),
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

  Widget _buildGlowPulse() {
    return AnimatedBuilder(
      animation: _glowPulseCtrl,
      builder: (_, _) => Positioned(
        top: MediaQuery.of(context).size.height * 0.12,
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
      child: _ShieldLogo(size: 90),
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
                  color: AppColors.primary,
                  fontSize: 28,
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
                "ARAN",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
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
              color: AppColors.primary.withValues(alpha: 0.7),
              fontSize: 10,
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
                "Select Your Role",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose how you want to use the app",
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

  Widget _buildRoleSelector() {
    final opacities = [_role1Opacity, _role2Opacity, _role3Opacity];

    return AnimatedBuilder(
      animation: _rolesCtrl,
      builder: (_, _) => Row(
        children: List.generate(_roles.length, (i) {
          final role = _roles[i];
          final opacity = opacities[i].value;
          final isSelected = _selectedRole == role.key;

          return Expanded(
            child: Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, 25 * (1 - opacity)),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 6,
                    right: i == _roles.length - 1 ? 0 : 6,
                  ),
                  child: _RoleCard(
                    label: role.label,
                    icon: role.icon,
                    isSelected: isSelected,
                    onTap: () => _selectRole(role.key),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCTA() {
    final isEnabled = _selectedRole != null;

    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) => Opacity(
        opacity: _ctaOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _ctaSlide.value),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isEnabled ? 1.0 : 0.4,
            child: _ShimmerButton(
              shimmerCtrl: _shimmerCtrl,
              label: "Continue",
              enabled: isEnabled,
              onPressed: () {
                if (_selectedRole == null) return;

                switch (_selectedRole) {
                  case 'owner':
                    context.pushNamed('ownerLogin');
                    break;

                  case 'trainer':
                    context.pushNamed('trainerLogin');
                    break;

                  case 'client':
                    context.pushNamed('clientLogin');
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ROLE OPTION MODEL
// ══════════════════════════════════════════════════════════════════

class _RoleOption {
  final String key;
  final String label;
  final IconData icon;

  const _RoleOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

// ══════════════════════════════════════════════════════════════════
// ROLE CARD
// ══════════════════════════════════════════════════════════════════

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: -2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.5),
                size: 22,
              ),
            ),
            const SizedBox(height: 12),

            // ── Label ──
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),

            // ── Selection indicator ──
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SHIELD LOGO (reused from splash)
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
// SHIMMER CTA BUTTON
// ══════════════════════════════════════════════════════════════════

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

// ══════════════════════════════════════════════════════════════════
// PARTICLES
// ══════════════════════════════════════════════════════════════════

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

      final lifeFrac = (y / size.height);
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
    radius = r.nextDouble() * 1.8 + 0.4;
    opacity = r.nextDouble() * 0.4 + 0.1;
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
