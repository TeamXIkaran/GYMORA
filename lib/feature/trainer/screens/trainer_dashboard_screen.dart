import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';
import 'package:karan_fitness/feature/trainer/screens/trainer_clients_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  int _selectedIndex = 0;

  final List<_TrainerClient> _clients = const [
    _TrainerClient(
      name: 'Aarav Sharma',
      goal: 'Weight Loss',
      progress: 78,
      sessions: '12 sessions',
      avatar: 'AS',
    ),
    _TrainerClient(
      name: 'Neha Singh',
      goal: 'Muscle Gain',
      progress: 65,
      sessions: '09 sessions',
      avatar: 'NS',
    ),
    _TrainerClient(
      name: 'Rahul Verma',
      goal: 'Strength',
      progress: 88,
      sessions: '15 sessions',
      avatar: 'RV',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.darkGradient),
          ),

          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _TrainerParticlePainter(
                  progress: _animationController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC107).withValues(alpha: 0.07),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildDashboard(),
                      _buildClientsScreen(),
                      _buildScheduleScreen(),
                      _buildProgressScreen(),
                      _buildMoreScreen(),
                    ],
                  ),
                ),

                _buildBottomNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD
  // ---------------------------------------------------------------------------

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 24),

          _buildWelcomeCard(),

          const SizedBox(height: 20),

          _buildStats(),

          const SizedBox(height: 24),

          _buildSectionHeader(
            title: 'Today\'s Schedule',
            subtitle: 'Your upcoming training sessions',
            action: 'View All',
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),

          const SizedBox(height: 12),

          _buildTodaySchedule(),

          const SizedBox(height: 24),

          _buildSectionHeader(
            title: 'My Clients',
            subtitle: 'Track your clients progress',
            action: 'View All',
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),

          const SizedBox(height: 12),

          _buildClients(),

          const SizedBox(height: 24),

          _buildSectionHeader(
            title: 'Quick Actions',
            subtitle: 'Manage your training',
          ),

          const SizedBox(height: 12),

          _buildQuickActions(),

          const SizedBox(height: 24),

          _buildPerformanceCard(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC107).withValues(alpha: 0.25),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'AK',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
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
                'Amit Kumar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Trainer • GYMO Fitness',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        _circleButton(
          Icons.notifications_none_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/trainerNotifications');
          },
        ),

        const SizedBox(width: 8),

        _circleButton(
          Icons.settings_outlined,
          onTap: () {
            Navigator.pushNamed(context, '/trainerSettings');
          },
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.045),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WELCOME CARD
  // ---------------------------------------------------------------------------

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC107).withValues(alpha: 0.20),
            const Color(0xFFFF9800).withValues(alpha: 0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'TRAINER',
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'Ready to train?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'You have 5 training sessions scheduled today.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFFFFC107),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Next session • 10:30 AM',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFC107).withValues(alpha: 0.10),
              border: Border.all(
                color: const Color(0xFFFFC107).withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFFFFC107),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATS
  // ---------------------------------------------------------------------------

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_outlined,
            value: '24',
            title: 'My Clients',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.calendar_month_outlined,
            value: '05',
            title: 'Today Sessions',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.trending_up_rounded,
            value: '86%',
            title: 'Attendance',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFFC107), size: 18),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? action,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),

        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'View All',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TODAY SCHEDULE
  // ---------------------------------------------------------------------------

  Widget _buildTodaySchedule() {
    final sessions = [
      {
        'time': '10:30 AM',
        'name': 'Aarav Sharma',
        'type': 'Personal Training',
        'duration': '60 min',
        'status': 'Upcoming',
      },
      {
        'time': '12:00 PM',
        'name': 'Neha Singh',
        'type': 'Strength Training',
        'duration': '45 min',
        'status': 'Upcoming',
      },
      {
        'time': '04:30 PM',
        'name': 'Rahul Verma',
        'type': 'Weight Training',
        'duration': '60 min',
        'status': 'Upcoming',
      },
    ];

    return Column(
      children: sessions.map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFFFFC107),
                      size: 17,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      session['time']!,
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session['type']!,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.white30,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          session['duration']!,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'UPCOMING',
                  style: TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // CLIENTS
  // ---------------------------------------------------------------------------

  Widget _buildClients() {
    return Column(
      children: _clients.map((client) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFC107).withValues(alpha: 0.10),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.20),
                  ),
                ),
                child: Center(
                  child: Text(
                    client.avatar,
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.goal,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: client.progress / 100,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFFC107),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${client.progress}%',
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    client.sessions,
                    style: const TextStyle(color: Colors.white30, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // QUICK ACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(icon: Icons.person_add_alt_1_rounded, title: 'Add Client'),
      _QuickAction(icon: Icons.calendar_month_rounded, title: 'Schedule'),
      _QuickAction(icon: Icons.assignment_outlined, title: 'Workout'),
      _QuickAction(icon: Icons.bar_chart_rounded, title: 'Progress'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.065),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      action.icon,
                      color: const Color(0xFFFFC107),
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      action.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white24,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PERFORMANCE
  // ---------------------------------------------------------------------------

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC107).withValues(alpha: 0.13),
            Colors.white.withValues(alpha: 0.025),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Color(0xFFFFC107), size: 20),
              SizedBox(width: 9),
              Text(
                'Weekly Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _PerformanceItem(value: '28', title: 'Sessions'),
              _PerformanceItem(value: '24', title: 'Completed'),
              _PerformanceItem(value: '92%', title: 'Success Rate'),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.92,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
            ),
          ),

          const SizedBox(height: 9),

          const Text(
            'Great work! Keep helping your clients reach their goals.',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ---------------------------------------------------------------------------

  Widget _buildBottomNavigation() {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: 'Clients',
      ),
      _NavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: 'Schedule',
      ),
      _NavItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights_rounded,
        label: 'Progress',
      ),
      _NavItem(
        icon: Icons.more_horiz_rounded,
        activeIcon: Icons.more_horiz_rounded,
        label: 'More',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D13).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = _selectedIndex == index;
          final item = items[index];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainerClientsScreen(),
                    ),
                  );
                  return;
                }

                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFC107).withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? item.activeIcon : item.icon,
                      color: selected
                          ? const Color(0xFFFFC107)
                          : Colors.white38,
                      size: 21,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFFFFC107)
                            : Colors.white38,
                        fontSize: 9,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OTHER TABS
  // ---------------------------------------------------------------------------

  Widget _buildClientsScreen() {
    return _simpleTabScreen(
      icon: Icons.people_alt_rounded,
      title: 'My Clients',
      subtitle: 'Manage and track your clients',
      child: _buildClients(),
    );
  }

  Widget _buildScheduleScreen() {
    return _simpleTabScreen(
      icon: Icons.calendar_month_rounded,
      title: 'Schedule',
      subtitle: 'Manage your training sessions',
      child: _buildTodaySchedule(),
    );
  }

  Widget _buildProgressScreen() {
    return _simpleTabScreen(
      icon: Icons.insights_rounded,
      title: 'Progress',
      subtitle: 'Track your performance',
      child: _buildPerformanceCard(),
    );
  }

  Widget _buildMoreScreen() {
    return _simpleTabScreen(
      icon: Icons.more_horiz_rounded,
      title: 'More',
      subtitle: 'Trainer tools and settings',
      child: Column(
        children: [
          _moreTile(Icons.notifications_none_rounded, 'Notifications'),
          _moreTile(Icons.settings_outlined, 'Settings'),
          _moreTile(Icons.help_outline_rounded, 'Help & Support'),
          _moreTile(Icons.logout_rounded, 'Logout', danger: true),
        ],
      ),
    );
  }

  Widget _simpleTabScreen({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFFFFC107), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          child,
        ],
      ),
    );
  }

  Widget _moreTile(IconData icon, String title, {bool danger = false}) {
    final iconColor = danger
        ? const Color(0xFFFF5252)
        : const Color(0xFFFFC107);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white24,
            size: 13,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODELS
// =============================================================================

class _TrainerClient {
  final String name;
  final String goal;
  final int progress;
  final String sessions;
  final String avatar;

  const _TrainerClient({
    required this.name,
    required this.goal,
    required this.progress,
    required this.sessions,
    required this.avatar,
  });
}

class _QuickAction {
  final IconData icon;
  final String title;

  const _QuickAction({required this.icon, required this.title});
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _PerformanceItem extends StatelessWidget {
  final String value;
  final String title;

  const _PerformanceItem({required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFC107),
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PARTICLES
// =============================================================================

class _TrainerParticlePainter extends CustomPainter {
  final double progress;

  _TrainerParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(22);

    for (int i = 0; i < 35; i++) {
      final x = random.nextDouble() * size.width;

      final baseY = random.nextDouble() * size.height;

      final y = (baseY - progress * 35) % size.height;

      final radius = 0.5 + random.nextDouble() * 1.3;

      final paint = Paint()
        ..color = const Color(
          0xFFFFC107,
        ).withValues(alpha: 0.025 + random.nextDouble() * 0.035);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrainerParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
