import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  static const Color _accent = AppColors.primary;

  late final AnimationController _entranceController;
  late final AnimationController _ambientController;
  late final AnimationController _pulseController;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _headingFade;
  late final Animation<Offset> _headingSlide;

  late final Animation<double> _card1;
  late final Animation<double> _card2;
  late final Animation<double> _card3;

  int? _pressedCard;

  @override
  void initState() {
    super.initState();

    // ---------------------------------------------------------------
    // ENTRANCE ANIMATION
    // ---------------------------------------------------------------
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _heroFade = _interval(0.0, 0.22, Curves.easeOut);

    _heroScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
      ),
    );

    _headingFade = _interval(0.15, 0.42, Curves.easeOut);

    _headingSlide =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.15, 0.42, curve: Curves.easeOutCubic),
          ),
        );

    _card1 = _interval(0.25, 0.52, Curves.easeOutCubic);

    _card2 = _interval(0.36, 0.63, Curves.easeOutCubic);

    _card3 = _interval(0.47, 0.74, Curves.easeOutCubic);

    // ---------------------------------------------------------------
    // AMBIENT BACKGROUND
    // ---------------------------------------------------------------
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // ---------------------------------------------------------------
    // LOGO PULSE
    // ---------------------------------------------------------------
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  Animation<double> _interval(double begin, double end, Curve curve) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(begin, end, curve: curve),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ambientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ===========================================================
          // BACKGROUND
          // ===========================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          Positioned.fill(
            child: _AmbientBackground(
              animation: _ambientController,
              accent: _accent,
            ),
          ),

          // Subtle grid
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
          ),

          // ===========================================================
          // CONTENT
          // ===========================================================
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 28, 20, bottomInset + 30),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _entranceController,
                  _pulseController,
                ]),
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ------------------------------------------------
                      // HERO
                      // ------------------------------------------------
                      _buildHero(),

                      SizedBox(height: size.height < 700 ? 32 : 48),

                      // ------------------------------------------------
                      // HEADING
                      // ------------------------------------------------
                      _buildHeading(),

                      const SizedBox(height: 28),

                      // ------------------------------------------------
                      // ROLE CARDS
                      // ------------------------------------------------
                      _buildRoleCard(
                        index: 0,
                        animation: _card1,
                        number: '01',
                        icon: Icons.storefront_rounded,
                        title: 'GYM OWNER',
                        subtitle: 'RUN YOUR EMPIRE',
                        description: 'Members • Trainers • Revenue • Plans',
                        color: const Color(0xFFE62B52),
                        routeName: 'ownerLogin',
                      ),

                      const SizedBox(height: 16),

                      _buildRoleCard(
                        index: 1,
                        animation: _card2,
                        number: '02',
                        icon: Icons.fitness_center_rounded,
                        title: 'TRAINER',
                        subtitle: 'BUILD YOUR ATHLETES',
                        description: 'Clients • Programs • Progress • Sessions',
                        color: const Color(0xFF3B82F6),
                        routeName: 'trainerLogin',
                      ),

                      const SizedBox(height: 16),

                      _buildRoleCard(
                        index: 2,
                        animation: _card3,
                        number: '03',
                        icon: Icons.directions_run_rounded,
                        title: 'CLIENT',
                        subtitle: 'BUILD YOURSELF',
                        description: 'Workouts • Goals • Progress • Results',
                        color: const Color(0xFF22C55E),
                        routeName: 'clientLogin',
                      ),

                      const SizedBox(height: 30),

                      // ------------------------------------------------
                      // BOTTOM BRAND
                      // ------------------------------------------------
                      _buildBottomBrand(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // HERO
  // =================================================================

  Widget _buildHero() {
    final pulse = 1.0 + (_pulseController.value * 0.035);

    return FadeTransition(
      opacity: _heroFade,
      child: Transform.scale(
        scale: _heroScale.value * pulse,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.12),
                        blurRadius: 55,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // Logo ring
                Container(
                  width: 94,
                  height: 94,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accent.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.08),
                        _accent.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF07101A),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/gymora_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) {
                          return Icon(
                            Icons.fitness_center_rounded,
                            color: _accent,
                            size: 38,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Brand
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.white, Color(0xFFE9EDF2), Color(0xFF9BA7B5)],
                ).createShader(bounds);
              },
              child: const Text(
                'GYMORA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 7,
                  height: 1,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 1,
                  color: _accent.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 9),
                Text(
                  'FITNESS MANAGEMENT',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.2,
                  ),
                ),
                const SizedBox(width: 9),
                Container(
                  width: 24,
                  height: 1,
                  color: _accent.withValues(alpha: 0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // HEADING
  // =================================================================

  Widget _buildHeading() {
    return FadeTransition(
      opacity: _headingFade,
      child: SlideTransition(
        position: _headingSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHOOSE YOUR',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text(
                    'WORLD.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _accent.withValues(alpha: 0.22)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'GYMORA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              'Choose how you want to experience your fitness journey.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.36),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // ROLE CARD
  // =================================================================

  Widget _buildRoleCard({
    required int index,
    required Animation<double> animation,
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required String routeName,
  }) {
    final progress = animation.value;
    final isPressed = _pressedCard == index;

    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, 35 * (1 - progress)),
        child: AnimatedScale(
          scale: isPressed ? 0.975 : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              setState(() {
                _pressedCard = index;
              });
            },
            onTapCancel: () {
              setState(() {
                _pressedCard = null;
              });
            },
            onTapUp: (_) {
              setState(() {
                _pressedCard = null;
              });

              context.pushNamed(routeName);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: 142,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: Colors.white.withValues(alpha: 0.045),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.085),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.045),
                        blurRadius: 30,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // ------------------------------------------------
                      // Accent glow
                      // ------------------------------------------------
                      Positioned(
                        left: -55,
                        top: -55,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                color.withValues(alpha: 0.16),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // Right vertical accent
                      // ------------------------------------------------
                      Positioned(
                        right: 0,
                        top: 18,
                        bottom: 18,
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(3),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withValues(alpha: 0.0),
                                color.withValues(alpha: 0.8),
                                color.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
                        child: Row(
                          children: [
                            // --------------------------------------------
                            // NUMBER + ICON
                            // --------------------------------------------
                            SizedBox(
                              width: 72,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      number,
                                      style: TextStyle(
                                        color: color.withValues(alpha: 0.28),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(19),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          color.withValues(alpha: 0.19),
                                          color.withValues(alpha: 0.05),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: color.withValues(alpha: 0.22),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.10),
                                          blurRadius: 18,
                                        ),
                                      ],
                                    ),
                                    child: Icon(icon, color: color, size: 27),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // --------------------------------------------
                            // TEXT
                            // --------------------------------------------
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: color.withValues(alpha: 0.9),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // --------------------------------------------
                            // ARROW
                            // --------------------------------------------
                            Container(
                              width: 39,
                              height: 39,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: color,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // =================================================================
  // BOTTOM BRAND
  // =================================================================

  Widget _buildBottomBrand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        const SizedBox(width: 10),
        Text(
          'STRONGER TOGETHER',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.22),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 34,
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ],
    );
  }
}

// =====================================================================
// AMBIENT BACKGROUND
// =====================================================================

class _AmbientBackground extends StatelessWidget {
  final Animation<double> animation;
  final Color accent;

  const _AmbientBackground({required this.animation, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final width = MediaQuery.sizeOf(context).width;
        final height = MediaQuery.sizeOf(context).height;

        return Stack(
          children: [
            // Top right red glow
            Positioned(
              top: -120 + sin(t * 2 * pi) * 20,
              right: -100 + cos(t * 2 * pi) * 25,
              child: _orb(300, accent.withValues(alpha: 0.075)),
            ),

            // Bottom left red glow
            Positioned(
              bottom: -160 + cos(t * 2 * pi) * 30,
              left: -130 + sin(t * 2 * pi) * 25,
              child: _orb(340, accent.withValues(alpha: 0.045)),
            ),

            // Blue glow
            Positioned(
              top: height * 0.38 + sin(t * 2 * pi + 2) * 35,
              right: -110,
              child: _orb(
                230,
                const Color(0xFF2563EB).withValues(alpha: 0.035),
              ),
            ),

            // Small accent light
            Positioned(
              top: height * 0.18 + cos(t * 2 * pi) * 20,
              left: width * 0.15,
              child: _orb(100, accent.withValues(alpha: 0.025)),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0.0, 0.72],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// SUBTLE GRID
// =====================================================================

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 1;

    const spacing = 42.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
