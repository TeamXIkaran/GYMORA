import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/screens/member_ship_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_members_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_profile_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_trainers_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late final AnimationController _glowController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          // Animated particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, _) {
                return CustomPaint(
                  painter: _DashboardParticlePainter(_particleController.value),
                );
              },
            ),
          ),

          // Red glow
          Positioned(
            top: -100,
            right: -80,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                return Container(
                  width: 280 + (_glowController.value * 30),
                  height: 280 + (_glowController.value * 30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.20),
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                _OwnerDashboardBody(),
                _MembersBody(),
                _TrainersBody(),
                _PlansBody(),
                OwnerProfileScreen(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final items = [
      const _NavItem(icon: Icons.home_rounded, label: 'Home'),
      const _NavItem(icon: Icons.people_alt_rounded, label: 'Members'),
      const _NavItem(icon: Icons.fitness_center_rounded, label: 'Trainers'),
      const _NavItem(icon: Icons.card_membership_rounded, label: 'Plans'),
      const _NavItem(icon: Icons.person, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF090C13).withValues(alpha: 0.97),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = _selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: selected ? 42 : 34,
                        height: 4,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        items[index].icon,
                        size: 21,
                        color: selected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OWNER DASHBOARD
// ============================================================

class _OwnerDashboardBody extends StatelessWidget {
  const _OwnerDashboardBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 22),

          _buildStats(),
          const SizedBox(height: 22),

          _buildRevenueCard(),
          const SizedBox(height: 22),

          _buildSectionTitle(title: 'Quick Actions', action: 'View All'),
          const SizedBox(height: 12),

          _buildQuickActions(),
          const SizedBox(height: 24),

          _buildSectionTitle(title: 'Recent Members', action: 'See All'),
          const SizedBox(height: 12),

          _buildRecentMembers(),
          const SizedBox(height: 24),

          _buildSectionTitle(title: 'Trainer Overview', action: 'See All'),
          const SizedBox(height: 12),

          _buildTrainerOverview(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Profile
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE62B52), Color(0xFF761326)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.30),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'RM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning 👋',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              SizedBox(height: 3),
              Text(
                'Rohan Mehta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Owner • GYMO Fitness',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ),

        // Notification
        _circleButton(context, Icons.notifications_none_rounded, () {
          context.pushNamed('onwerNotificationScreen');
        }),

        const SizedBox(width: 8),

        // Settings
        _circleButton(context, Icons.settings_outlined, () {
          context.pushNamed('onwerSettingScreen');
        }),
      ],
    );
  }

  Widget _circleButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Members',
            value: '248',
            change: '+12%',
            icon: Icons.people_alt_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Active Trainers',
            value: '08',
            change: '+2%',
            icon: Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Monthly Revenue',
            value: '₹2.48L',
            change: '+18%',
            icon: Icons.currency_rupee_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 30,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monthly performance',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: const Text(
                  '2026',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹2,48,000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '+18%',
                  style: TextStyle(
                    color: Color(0xFF4DDB88),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: _RevenueChartPainter(),
            ),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ChartLabel('Jan'),
              _ChartLabel('Feb'),
              _ChartLabel('Mar'),
              _ChartLabel('Apr'),
              _ChartLabel('May'),
              _ChartLabel('Jun'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String action}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          action,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.90,
      children: [
        _QuickAction(
          icon: Icons.person_add_alt_1_rounded,
          title: 'Add\nMember',
        ),
        _QuickAction(
          icon: Icons.manage_accounts_rounded,
          title: 'Manage\nTrainers',
        ),
        _QuickAction(
          icon: Icons.card_membership_rounded,
          title: 'Plans &\nPricing',
        ),
        _QuickAction(icon: Icons.bar_chart_rounded, title: 'Reports'),
      ],
    );
  }

  Widget _buildRecentMembers() {
    final members = [
      ['Aarav Sharma', 'Premium Plan', 'AS'],
      ['Neha Singh', 'Standard Plan', 'NS'],
      ['Sneha Joshi', 'Premium Plan', 'SJ'],
      ['Priya Patel', 'Basic Plan', 'PP'],
    ];

    return Container(
      decoration: _glassDecoration(),
      child: Column(
        children: List.generate(members.length, (index) {
          final member = members[index];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    _Avatar(initials: member[2], index: index),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member[1],
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF36D57D).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFF48DF8B),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index != members.length - 1)
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTrainerOverview() {
    final trainers = [
      ['Amit Verma', 'Strength & Conditioning', 'AV'],
      ['Rakesh Yadav', 'Weight Training', 'RY'],
      ['Sneha Joshi', 'Yoga & Mobility', 'SJ'],
    ];

    return Container(
      decoration: _glassDecoration(),
      child: Column(
        children: List.generate(trainers.length, (index) {
          final trainer = trainers[index];

          return Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                _Avatar(initials: trainer[2], index: index + 2),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainer[1],
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.circle, color: Color(0xFF3BDD82), size: 9),
                const SizedBox(width: 5),
                const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF3BDD82),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.035),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 8),
          ),
          const SizedBox(height: 4),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            change,
            style: const TextStyle(
              color: Color(0xFF43D982),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK ACTION
// ============================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickAction({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 19),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// AVATAR
// ============================================================

class _Avatar extends StatelessWidget {
  final String initials;
  final int index;

  const _Avatar({required this.initials, required this.index});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFFE52A50), Color(0xFF671022)],
      const [Color(0xFFB91D3D), Color(0xFF49101C)],
      const [Color(0xFFE94C69), Color(0xFF7D1830)],
      const [Color(0xFF8D2941), Color(0xFF3B0D19)],
      const [Color(0xFFD83355), Color(0xFF651125)],
    ];

    final colors = gradients[index % gradients.length];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OTHER TABS
// ============================================================

class _MembersBody extends StatelessWidget {
  const _MembersBody();

  @override
  Widget build(BuildContext context) {
    return const OwnerMembersScreen();
  }
}

class _TrainersBody extends StatelessWidget {
  const _TrainersBody();

  @override
  Widget build(BuildContext context) {
    return const OwnerTrainersScreen();
  }
}

class _PlansBody extends StatelessWidget {
  const _PlansBody();

  @override
  Widget build(BuildContext context) {
    return const MemberShipScreen();
  }
}

// ============================================================
// NAV ITEM
// ============================================================

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

// ============================================================
// CHART LABEL
// ============================================================

class _ChartLabel extends StatelessWidget {
  final String text;

  const _ChartLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white24, fontSize: 9),
    );
  }
}

// ============================================================
// REVENUE CHART
// ============================================================

class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = (size.height / 3) * i;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(size.width * 0.00, size.height * 0.72),
      Offset(size.width * 0.18, size.height * 0.48),
      Offset(size.width * 0.36, size.height * 0.62),
      Offset(size.width * 0.54, size.height * 0.30),
      Offset(size.width * 0.72, size.height * 0.46),
      Offset(size.width * 0.88, size.height * 0.15),
      Offset(size.width * 1.00, size.height * 0.25),
    ];

    final areaPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }

    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary.withValues(alpha: 0.20), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = AppColors.primary;

    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);

      canvas.drawCircle(
        point,
        7,
        Paint()..color = AppColors.primary.withValues(alpha: 0.10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// PARTICLES
// ============================================================

class _DashboardParticlePainter extends CustomPainter {
  final double time;
  final List<_DashboardParticle> particles;

  _DashboardParticlePainter(this.time)
    : particles = List.generate(28, (index) => _DashboardParticle(index));

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x =
          particle.x * size.width + sin(time * 2 * pi + particle.phase) * 10;

      final y =
          (particle.y * size.height - time * size.height * particle.speed) %
          size.height;

      final paint = Paint()
        ..color = particle.isRed
            ? AppColors.primary.withValues(alpha: particle.opacity)
            : Colors.white.withValues(alpha: particle.opacity * 0.20);

      if (particle.isRed) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawCircle(Offset(x, y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardParticlePainter oldDelegate) {
    return true;
  }
}

class _DashboardParticle {
  late final double x;
  late final double y;
  late final double speed;
  late final double radius;
  late final double opacity;
  late final double phase;
  late final bool isRed;

  _DashboardParticle(int seed) {
    final random = Random(seed * 17 + 100);

    x = random.nextDouble();
    y = random.nextDouble();
    speed = random.nextDouble() * 0.35 + 0.08;
    radius = random.nextDouble() * 1.5 + 0.4;
    opacity = random.nextDouble() * 0.35 + 0.08;
    phase = random.nextDouble() * 2 * pi;
    isRed = random.nextDouble() > 0.55;
  }
}
