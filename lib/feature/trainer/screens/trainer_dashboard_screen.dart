import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:gymora_fitness_management/feature/trainer/screens/trainer_clients_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_profile_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_progress_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_schedule_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _particleController;

  static const Color trainerYellow = Color(0xFFFFC107);
  static const Color trainerYellowLight = Color(0xFFFFD54F);
  static const Color trainerYellowDark = Color(0xFFFFA000);

  static const Color background = Color(0xFF05070C);
  static const Color cardColor = Color(0xFF0C111A);
  static const Color cardColorLight = Color(0xFF121923);
  static const Color borderColor = Color(0xFF202A36);

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashboard(),
                _buildClientsPlaceholder(),
                _buildScheduleScreen(),
                _buildProgressScreen(),
                _buildMoreScreen(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 26),

          _buildWelcomeSection(),

          const SizedBox(height: 22),

          _buildStatsSection(),

          const SizedBox(height: 26),

          _buildSectionHeader(
            title: 'Today\'s Schedule',
            actionText: 'View All',
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),

          const SizedBox(height: 14),

          _buildScheduleCard(
            time: '06:00 AM',
            title: 'Morning Strength',
            subtitle: 'Personal Training',
            member: 'Rahul Sharma',
            icon: Icons.fitness_center_rounded,
          ),

          const SizedBox(height: 12),

          _buildScheduleCard(
            time: '09:30 AM',
            title: 'Weight Loss Session',
            subtitle: 'Personal Training',
            member: 'Neha Singh',
            icon: Icons.monitor_weight_rounded,
          ),

          const SizedBox(height: 12),

          _buildScheduleCard(
            time: '05:00 PM',
            title: 'Muscle Building',
            subtitle: 'Personal Training',
            member: 'Arjun Mehta',
            icon: Icons.sports_gymnastics_rounded,
          ),

          const SizedBox(height: 28),

          _buildSectionHeader(
            title: 'My Clients',
            actionText: 'View All',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerClientsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _buildClientCard(
            name: 'Rahul Sharma',
            goal: 'Muscle Building',
            progress: 0.78,
            initials: 'RS',
          ),

          const SizedBox(height: 12),

          _buildClientCard(
            name: 'Neha Singh',
            goal: 'Weight Loss',
            progress: 0.62,
            initials: 'NS',
          ),

          const SizedBox(height: 12),

          _buildClientCard(
            name: 'Arjun Mehta',
            goal: 'Strength Training',
            progress: 0.84,
            initials: 'AM',
          ),

          const SizedBox(height: 28),

          _buildSectionHeader(title: 'Quick Actions', actionText: ''),

          const SizedBox(height: 14),

          _buildQuickActions(),

          const SizedBox(height: 28),

          _buildSectionHeader(
            title: 'Weekly Performance',
            actionText: 'Details',
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),

          const SizedBox(height: 14),

          _buildPerformanceCard(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        // PROFILE PHOTO
        GestureDetector(
          onTap: _openTrainerProfile,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [trainerYellowLight, trainerYellowDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: trainerYellow.withValues(alpha: 0.25),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning 👋',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Amit Kumar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Trainer • GYMORA',
                style: TextStyle(
                  color: trainerYellow.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        _headerIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/trainerNotifications');
          },
        ),

        const SizedBox(width: 8),

        _headerIconButton(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.pushNamed(context, '/trainerSettings');
          },
        ),
      ],
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 21),
      ),
    );
  }

  void _openTrainerProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerProfileScreen()),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [trainerYellow.withValues(alpha: 0.14), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: trainerYellow.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Strong.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Keep your clients moving forward.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trainerYellow.withValues(alpha: 0.12),
              border: Border.all(color: trainerYellow.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: trainerYellow,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_rounded,
            value: '24',
            label: 'Clients',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.calendar_today_rounded,
            value: '08',
            label: 'Sessions',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.star_rounded,
            value: '4.9',
            label: 'Rating',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: trainerYellow, size: 21),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionText,
              style: const TextStyle(
                color: trainerYellow,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // SCHEDULE
  // ============================================================

  Widget _buildScheduleCard({
    required String time,
    required String title,
    required String subtitle,
    required String member,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: trainerYellow.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: trainerYellow, size: 23),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: trainerYellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$subtitle • $member',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
        ],
      ),
    );
  }

  // ============================================================
  // CLIENTS
  // ============================================================

  Widget _buildClientsPlaceholder() {
    return const SizedBox.shrink();
  }

  Widget _buildClientCard({
    required String name,
    required String goal,
    required double progress,
    required String initials,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trainerYellow.withValues(alpha: 0.12),
              border: Border.all(color: trainerYellow.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: trainerYellow,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      trainerYellow,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: trainerYellow,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Add Client',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Client clicked')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.add_task_rounded,
            label: 'Add Session',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Session clicked')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.assignment_rounded,
            label: 'Workout',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Workout clicked')));
            },
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: trainerYellow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: trainerYellow, size: 21),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PERFORMANCE
  // ============================================================

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Training Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '+18.4%',
                style: TextStyle(
                  color: trainerYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _chartBar('Mon', 0.45),
                _chartBar('Tue', 0.68),
                _chartBar('Wed', 0.55),
                _chartBar('Thu', 0.82),
                _chartBar('Fri', 0.72),
                _chartBar('Sat', 0.94),
                _chartBar('Sun', 0.50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(String day, double value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: value,
                child: Container(
                  width: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [trainerYellowLight, trainerYellowDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: trainerYellow.withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            day,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHEDULE SCREEN
  // ============================================================

  Widget _buildScheduleScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle(
            title: 'Schedule',
            subtitle: 'Manage your training sessions',
          ),
          const SizedBox(height: 22),
          _buildScheduleCard(
            time: '06:00 AM',
            title: 'Morning Strength',
            subtitle: 'Personal Training',
            member: 'Rahul Sharma',
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            time: '09:30 AM',
            title: 'Weight Loss Session',
            subtitle: 'Personal Training',
            member: 'Neha Singh',
            icon: Icons.monitor_weight_rounded,
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            time: '05:00 PM',
            title: 'Muscle Building',
            subtitle: 'Personal Training',
            member: 'Arjun Mehta',
            icon: Icons.sports_gymnastics_rounded,
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            time: '07:30 PM',
            title: 'Strength Training',
            subtitle: 'Personal Training',
            member: 'Vikas Sharma',
            icon: Icons.fitness_center_rounded,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS SCREEN
  // ============================================================

  Widget _buildProgressScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle(
            title: 'Progress',
            subtitle: 'Track your training performance',
          ),
          const SizedBox(height: 22),
          _buildPerformanceCard(),
          const SizedBox(height: 18),
          _buildProgressStat(
            icon: Icons.people_alt_rounded,
            title: 'Client Retention',
            value: '92%',
          ),
          const SizedBox(height: 12),
          _buildProgressStat(
            icon: Icons.check_circle_rounded,
            title: 'Completed Sessions',
            value: '186',
          ),
          const SizedBox(height: 12),
          _buildProgressStat(
            icon: Icons.star_rounded,
            title: 'Average Rating',
            value: '4.9',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: trainerYellow.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: trainerYellow, size: 22),
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
          Text(
            value,
            style: const TextStyle(
              color: trainerYellow,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MORE SCREEN
  // ============================================================

  Widget _buildMoreScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle(title: 'More', subtitle: 'Manage your account'),

          const SizedBox(height: 24),

          _moreTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Manage your notifications',
            onTap: () {
              Navigator.pushNamed(context, '/trainerNotifications');
            },
          ),

          const SizedBox(height: 12),

          _moreTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Manage application settings',
            onTap: () {
              Navigator.pushNamed(context, '/trainerSettings');
            },
          ),

          const SizedBox(height: 12),

          _moreTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Need help? Contact support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support clicked')),
              );
            },
          ),

          const SizedBox(height: 12),

          _moreTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out from your trainer account',
            iconColor: Colors.redAccent,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _moreTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = trainerYellow,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  Widget _buildPageTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
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
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080C12),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // CLIENTS
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrainerClientsScreen(),
                        ),
                      );
                      return;
                    }

                    if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrainerScheduleScreen(),
                        ),
                      );
                      return;
                    }
                    if (index == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrainerProgressScreen(),
                        ),
                      );
                      return;
                    }
                    // PROFILE
                    if (index == 4) {
                      _openTrainerProfile();
                      return;
                    }

                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: isSelected ? 44 : 38,
                          height: isSelected ? 32 : 30,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? trainerYellow.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? trainerYellow
                                : Colors.white.withValues(alpha: 0.40),
                            size: 21,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? trainerYellow
                                : Colors.white.withValues(alpha: 0.40),
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.60)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: trainerYellow,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                // Add your actual logout logic here.
                // Example:
                // context.read<AuthProvider>().logout();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out')));
              },
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// NAV ITEM MODEL
// ============================================================

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

// ============================================================
// PARTICLE PAINTER
// ============================================================

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;

      final baseY = random.nextDouble() * size.height;

      final movement = math.sin((progress * math.pi * 2) + i) * 10;

      final y = baseY + movement;

      final radius = 0.5 + random.nextDouble() * 1.2;

      paint.color = const Color(
        0xFFFFC107,
      ).withValues(alpha: 0.025 + random.nextDouble() * 0.05);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
