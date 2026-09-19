import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/ShieldLogo_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/auth_background_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/brand_text_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/shimmer_button_widget.dart';


class _RoleOption {
  final String key;
  final String label;
  final String subtitle;
  final IconData icon;

  const _RoleOption({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────
  // COLORS
  // ─────────────────────────────────────────────

  static const Color _accent = AppColors.primary;

  static const _outerShield = [
    Color(0xFFFF3158),
    Color(0xFF9C1833),
    Color(0xFF4B0A19),
  ];

  static const _innerShield = [Color(0xFF310914), Color(0xFF100208)];

  static const _buttonGradient = [
    Color(0xFFFF3158),
    Color(0xFFE11D45),
    Color(0xFF8B1027),
  ];

  // ─────────────────────────────────────────────
  // ROLES
  // ─────────────────────────────────────────────

  static const _roles = [
    _RoleOption(
      key: 'owner',
      label: 'Owner',
      subtitle: 'Manage your entire gym',
      icon: Icons.business_rounded,
    ),
    _RoleOption(
      key: 'trainer',
      label: 'Trainer',
      subtitle: 'Train & manage your clients',
      icon: Icons.fitness_center_rounded,
    ),
    _RoleOption(
      key: 'client',
      label: 'Client',
      subtitle: 'Track your fitness journey',
      icon: Icons.person_rounded,
    ),
  ];

  String? _selectedRole;

  // ─────────────────────────────────────────────
  // ANIMATION CONTROLLERS
  // ─────────────────────────────────────────────

  late final AnimationController _logoCtrl;
  late final AnimationController _headingCtrl;
  late final AnimationController _rolesCtrl;
  late final AnimationController _ctaCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowPulseCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _selectionCtrl;

  // ─────────────────────────────────────────────
  // ANIMATIONS
  // ─────────────────────────────────────────────

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  late final Animation<double> _headingOpacity;
  late final Animation<double> _headingSlide;

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
      duration: const Duration(milliseconds: 850),
    );

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    _logoScale = Tween<double>(
      begin: 0.55,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _headingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headingOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _headingCtrl, curve: Curves.easeOut));

    _headingSlide = Tween<double>(begin: 25, end: 0).animate(
      CurvedAnimation(parent: _headingCtrl, curve: Curves.easeOutCubic),
    );

    _rolesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
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
      begin: 35,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOutCubic));

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _glowPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _selectionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    _headingCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    _rolesCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 550));

    if (!mounted) return;
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
    _selectionCtrl.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────

  void _onContinue() {
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
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });

    _selectionCtrl.forward(from: 0);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.035),

                        _buildPremiumLogo(),

                        const SizedBox(height: 12),

                        _buildBrandText(),

                        const SizedBox(height: 30),

                        _buildHeading(),

                        const SizedBox(height: 28),

                        _buildRoleCards(),

                        const SizedBox(height: 28),

                        _buildCTA(),

                        const SizedBox(height: 18),

                        _buildBottomHint(),

                        SizedBox(height: height * 0.025),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PREMIUM LOGO
  // ─────────────────────────────────────────────

  Widget _buildPremiumLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoCtrl, _glowPulseCtrl]),
      builder: (_, child) {
        final pulse = _glowPulseCtrl.value;

        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.08 + (pulse * 0.08)),
                    blurRadius: 55,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.05 + (pulse * 0.05)),
                    blurRadius: 90,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: ShieldLogo(
                  size: 94,
                  outerGradientColors: _outerShield,
                  innerGradientColors: _innerShield,
                  accentColor: _accent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // BRAND
  // ─────────────────────────────────────────────

  Widget _buildBrandText() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, child) {
        return Opacity(opacity: _logoOpacity.value, child: child);
      },
      child: const BrandText(
        accentColor: _accent,
        karanFontSize: 30,
        fitnessFontSize: 10,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADING
  // ─────────────────────────────────────────────

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
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _accent.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'ACCESS PORTAL',
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

                const SizedBox(height: 14),

                const Text(
                  'Choose Your Role',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'Enter GYMO as a',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Owner • Trainer • Client',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // ROLE CARDS
  // ─────────────────────────────────────────────

  Widget _buildRoleCards() {
    return AnimatedBuilder(
      animation: _rolesCtrl,
      builder: (_, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: List.generate(_roles.length, (index) {
              final start = index * 0.22;
              final end = min(start + 0.42, 1.0);

              final opacity = CurvedAnimation(
                parent: _rolesCtrl,
                curve: Interval(start, end, curve: Curves.easeOut),
              ).value;

              final role = _roles[index];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _roles.length - 1 ? 0 : 13,
                ),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - opacity)),
                    child: _RoleCard(
                      role: role,
                      selected: _selectedRole == role.key,
                      accent: _accent,
                      onTap: () => _selectRole(role.key),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // CTA
  // ─────────────────────────────────────────────

  Widget _buildCTA() {
    return AnimatedBuilder(
      animation: _ctaCtrl,
      builder: (_, _) {
        final enabled = _selectedRole != null;

        return Opacity(
          opacity: _ctaOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _ctaSlide.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: enabled
                      ? [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.22),
                            blurRadius: 28,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: enabled ? 1 : 0.45,
                  child: ShimmerButton(
                    shimmerCtrl: _shimmerCtrl,
                    gradientColors: _buttonGradient,
                    accentColor: _accent,
                    label: enabled
                        ? 'Continue as ${_roles.firstWhere((e) => e.key == _selectedRole).label}'
                        : 'Select Your Role',
                    enabled: enabled,
                    onPressed: _onContinue,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM HINT
  // ─────────────────────────────────────────────

  Widget _buildBottomHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 12,
          color: Colors.white.withValues(alpha: 0.28),
        ),
        const SizedBox(width: 6),
        Text(
          'Secure GYMO authentication',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.28),
            fontSize: 10,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// ROLE CARD
// ═════════════════════════════════════════════════════════════

class _RoleCard extends StatelessWidget {
  final _RoleOption role;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.14),
                    accent.withValues(alpha: 0.035),
                    Colors.white.withValues(alpha: 0.025),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.055),
                    Colors.white.withValues(alpha: 0.018),
                  ],
                ),

          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.09),
            width: selected ? 1.4 : 1,
          ),

          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.16),
                    blurRadius: 26,
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 50,
                    spreadRadius: -10,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
        ),
        child: Row(
          children: [
            // ICON
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.30),
                          accent.withValues(alpha: 0.08),
                        ],
                      )
                    : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.045),
                border: Border.all(
                  color: selected
                      ? accent.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.09),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.20),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                role.icon,
                size: 24,
                color: selected ? accent : Colors.white.withValues(alpha: 0.50),
              ),
            ),

            const SizedBox(width: 15),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.76),
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: selected ? 0.55 : 0.35,
                      ),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // CHECK
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? accent : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? accent
                      : Colors.white.withValues(alpha: 0.18),
                  width: selected ? 0 : 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        key: ValueKey('selected'),
                        color: Colors.white,
                        size: 17,
                      )
                    : const SizedBox(key: ValueKey('unselected')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
