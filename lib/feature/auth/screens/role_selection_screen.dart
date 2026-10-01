import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  static const Color _accent = AppColors.ownerPrimary;

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ===========================================================
            // BACKGROUND
            // ===========================================================
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.darkGradient,
                ),
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
                padding: EdgeInsets.fromLTRB(22, 18, 22, bottomInset + 24),
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

                        SizedBox(height: size.height < 700 ? 18 : 28),

                        // ------------------------------------------------
                        // HEADING
                        // ------------------------------------------------
                        _buildHeading(),

                        const SizedBox(height: 22),

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
                          color: AppColors.ownerPrimary,
                          routeName: 'ownerLogin',
                        ),

                        const SizedBox(height: 12),

                        _buildRoleCard(
                          index: 1,
                          animation: _card2,
                          number: '02',
                          icon: Icons.fitness_center_rounded,
                          title: 'TRAINER',
                          subtitle: 'BUILD YOUR ATHLETES',
                          description:
                              'Clients • Programs • Progress • Sessions',
                          color: AppColors.trainerBright,
                          routeName: 'trainerLogin',
                        ),

                        const SizedBox(height: 12),

                        _buildRoleCard(
                          index: 2,
                          animation: _card3,
                          number: '03',
                          icon: Icons.directions_run_rounded,
                          title: 'CLIENT',
                          subtitle: 'BUILD YOURSELF',
                          description: 'Workouts • Goals • Progress • Results',
                          color: AppColors.clientPrimary,
                          routeName: 'clientLogin',
                        ),

                        const SizedBox(height: 22),

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
                Container(
                  width: 196,
                  height: 148,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    gradient: RadialGradient(
                      colors: [
                        _accent.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/gym_logo.png',
                  width: 174,
                  height: 144,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.fitness_center_rounded,
                    color: _accent,
                    size: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'TRAIN  /  COACH  /  GROW',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2),
                  ),
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
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  'SELECT YOUR SPACE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose your\nstarting point.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'One platform, shaped around your role.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
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
        offset: Offset(0, 24 * (1 - progress)),
        child: AnimatedScale(
          scale: isPressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 160),
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
            child: Semantics(
              button: true,
              label: '$title. $description',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 126,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(
                            alpha: isPressed ? 0.13 : 0.075,
                          ),
                          color.withValues(alpha: isPressed ? 0.18 : 0.105),
                          AppColors.surface.withValues(alpha: 0.62),
                        ],
                        stops: const [0, 0.46, 1],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: isPressed ? 0.34 : 0.18,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(
                            alpha: isPressed ? 0.14 : 0.07,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 58,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 13),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: color.withValues(alpha: 0.12),
                              border: Border.all(
                                color: color.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Icon(icon, color: color, size: 23),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.48),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                number,
                                style: TextStyle(
                                  color: color.withValues(alpha: 0.72),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.14),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.28),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: color,
                                  size: 17,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
          'BUILT FOR YOUR NEXT REP',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.34),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
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
                AppColors.clientPrimary.withValues(alpha: 0.045),
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
