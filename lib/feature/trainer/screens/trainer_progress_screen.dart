import 'package:flutter/material.dart';

import 'package:gymora_fitness_management/feature/trainer/screens/trainer_clients_screen.dart';

class TrainerProgressScreen extends StatefulWidget {
  const TrainerProgressScreen({super.key});

  @override
  State<TrainerProgressScreen> createState() => _TrainerProgressScreenState();
}

class _TrainerProgressScreenState extends State<TrainerProgressScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color trainerYellow = Color(0xFFFFC107);
  static const Color trainerYellowLight = Color(0xFFFFD54F);
  static const Color trainerYellowDark = Color(0xFFFFA000);

  static const Color background = Color(0xFF05070C);
  static const Color cardColor = Color(0xFF0C111A);
  static const Color cardColorLight = Color(0xFF121923);
  static const Color borderColor = Color(0xFF202A36);

  // ============================================================
  // STATE
  // ============================================================

  String _selectedPeriod = 'This Week';

  final List<_ChartData> _weeklyData = [
    _ChartData(day: 'MON', value: 0.45, sessions: 4),
    _ChartData(day: 'TUE', value: 0.68, sessions: 6),
    _ChartData(day: 'WED', value: 0.55, sessions: 5),
    _ChartData(day: 'THU', value: 0.82, sessions: 8),
    _ChartData(day: 'FRI', value: 0.72, sessions: 7),
    _ChartData(day: 'SAT', value: 0.94, sessions: 9),
    _ChartData(day: 'SUN', value: 0.50, sessions: 5),
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // TOP GLOW
          Positioned(
            top: -120,
            right: -100,
            child: _buildGlow(size: 280, color: trainerYellow),
          ),

          Positioned(
            top: 280,
            left: -160,
            child: _buildGlow(size: 300, color: trainerYellowDark),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 24),

                  _buildPerformanceHero(),

                  const SizedBox(height: 18),

                  _buildOverviewStats(),

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    title: 'Weekly Performance',
                    actionText: _selectedPeriod,
                    onTap: _showPeriodSelector,
                  ),

                  const SizedBox(height: 14),

                  _buildWeeklyChart(),

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    title: 'Training Insights',
                    actionText: '',
                  ),

                  const SizedBox(height: 14),

                  _buildInsights(),

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    title: 'Client Progress',
                    actionText: 'View All',
                    onTap: _openClients,
                  ),

                  const SizedBox(height: 14),

                  _buildClientProgressCard(
                    name: 'Rahul Sharma',
                    initials: 'RS',
                    goal: 'Muscle Building',
                    progress: 0.84,
                    sessions: '18 sessions',
                    change: '+12%',
                  ),

                  const SizedBox(height: 12),

                  _buildClientProgressCard(
                    name: 'Neha Singh',
                    initials: 'NS',
                    goal: 'Weight Loss',
                    progress: 0.72,
                    sessions: '14 sessions',
                    change: '+9%',
                  ),

                  const SizedBox(height: 12),

                  _buildClientProgressCard(
                    name: 'Arjun Mehta',
                    initials: 'AM',
                    goal: 'Strength Training',
                    progress: 0.91,
                    sessions: '21 sessions',
                    change: '+18%',
                  ),

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    title: 'Achievements',
                    actionText: 'View All',
                    onTap: _showAchievements,
                  ),

                  const SizedBox(height: 14),

                  _buildAchievements(),

                  const SizedBox(height: 28),

                  _buildMonthlyGoal(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GLOW
  // ============================================================

  Widget _buildGlow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0.02),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Track your training performance',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: _showPeriodSelector,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: trainerYellow,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PERFORMANCE HERO
  // ============================================================

  Widget _buildPerformanceHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: LinearGradient(
          colors: [
            trainerYellow.withValues(alpha: 0.18),
            trainerYellow.withValues(alpha: 0.06),
            cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: trainerYellow.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: trainerYellow.withValues(alpha: 0.07),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Performance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Excellent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'You are performing above your monthly average.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              _buildCircularProgress(value: 0.88, label: '88%'),
            ],
          ),

          const SizedBox(height: 22),

          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _heroStat(
                  icon: Icons.trending_up_rounded,
                  value: '+18.4%',
                  label: 'Growth',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _heroStat(
                  icon: Icons.check_circle_outline_rounded,
                  value: '186',
                  label: 'Completed',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _heroStat(
                  icon: Icons.timer_outlined,
                  value: '124h',
                  label: 'Training',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress({
    required double value,
    required String label,
  }) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 7,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),

          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: trainerYellow,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'SCORE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: trainerYellow, size: 18),

        const SizedBox(height: 7),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }

  // ============================================================
  // OVERVIEW STATS
  // ============================================================

  Widget _buildOverviewStats() {
    return Row(
      children: [
        Expanded(
          child: _overviewCard(
            icon: Icons.people_alt_rounded,
            value: '24',
            label: 'Clients',
            change: '+4',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _overviewCard(
            icon: Icons.calendar_month_rounded,
            value: '38',
            label: 'Sessions',
            change: '+8',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _overviewCard(
            icon: Icons.star_rounded,
            value: '4.9',
            label: 'Rating',
            change: '+0.2',
          ),
        ),
      ],
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String value,
    required String label,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: trainerYellow.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: trainerYellow, size: 19),
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
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.40),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            change,
            style: const TextStyle(
              color: trainerYellow,
              fontSize: 9,
              fontWeight: FontWeight.w900,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText,
                  style: const TextStyle(
                    color: trainerYellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: trainerYellow,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // WEEKLY CHART
  // ============================================================

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Training Sessions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sessions completed this week',
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: trainerYellow.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: trainerYellow,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+18.4%',
                      style: TextStyle(
                        color: trainerYellow,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 205,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_weeklyData.length, (index) {
                final data = _weeklyData[index];

                return Expanded(
                  child: _chartBar(data: data, isHighest: data.value == 0.94),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: trainerYellow,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Completed sessions',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartBar({required _ChartData data, required bool isHighest}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(
            height: 25,
            child: isHighest
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: trainerYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'TOP',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : null,
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 1,
                      height: constraints.maxHeight,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: data.value,
                        child: Container(
                          width: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: const LinearGradient(
                              colors: [trainerYellowLight, trainerYellowDark],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: trainerYellow.withValues(alpha: 0.18),
                                blurRadius: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Text(
            data.day,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRAINING INSIGHTS
  // ============================================================

  Widget _buildInsights() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _insightCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Best Streak',
                value: '12 Days',
                subtitle: 'Consistency',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _insightCard(
                icon: Icons.timer_rounded,
                title: 'Avg. Session',
                value: '58 Min',
                subtitle: 'Per session',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _insightCard(
                icon: Icons.fitness_center_rounded,
                title: 'Workouts',
                value: '142',
                subtitle: 'Completed',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _insightCard(
                icon: Icons.emoji_events_rounded,
                title: 'Achievements',
                value: '08',
                subtitle: 'Unlocked',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          const SizedBox(height: 14),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              color: trainerYellow.withValues(alpha: 0.75),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLIENT PROGRESS
  // ============================================================

  Widget _buildClientProgressCard({
    required String name,
    required String initials,
    required String goal,
    required double progress,
    required String sessions,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      trainerYellow.withValues(alpha: 0.20),
                      trainerYellow.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: trainerYellow.withValues(alpha: 0.25),
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: trainerYellow,
                      fontSize: 12,
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
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: trainerYellow.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: trainerYellow,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      trainerYellow,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: trainerYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white.withValues(alpha: 0.28),
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                sessions,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Training Progress',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Widget _buildAchievements() {
    return Row(
      children: [
        Expanded(
          child: _achievementCard(
            icon: Icons.local_fire_department_rounded,
            title: '12 Day',
            subtitle: 'Streak',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _achievementCard(
            icon: Icons.fitness_center_rounded,
            title: '100+',
            subtitle: 'Sessions',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _achievementCard(
            icon: Icons.star_rounded,
            title: '4.9',
            subtitle: 'Rating',
          ),
        ),
      ],
    );
  }

  Widget _achievementCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trainerYellow.withValues(alpha: 0.10),
              border: Border.all(color: trainerYellow.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: trainerYellow, size: 20),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTHLY GOAL
  // ============================================================

  Widget _buildMonthlyGoal() {
    const double progress = 0.76;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          colors: [trainerYellow.withValues(alpha: 0.13), cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: trainerYellow.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: trainerYellow.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: trainerYellow,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complete 50 training sessions',
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
              ),

              const Text(
                '38 / 50',
                style: TextStyle(
                  color: trainerYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: const AlwaysStoppedAnimation<Color>(trainerYellow),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Text(
                '76% completed',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '12 sessions remaining',
                style: TextStyle(
                  color: trainerYellow.withValues(alpha: 0.75),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERIOD SELECTOR
  // ============================================================

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: const BoxDecoration(
            color: cardColorLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Performance Period',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Select the period you want to analyze.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 18),

              _periodOption(
                sheetContext,
                title: 'This Week',
                subtitle: 'Last 7 days',
                icon: Icons.calendar_view_week_rounded,
              ),

              const SizedBox(height: 10),

              _periodOption(
                sheetContext,
                title: 'This Month',
                subtitle: 'Current month',
                icon: Icons.calendar_month_rounded,
              ),

              const SizedBox(height: 10),

              _periodOption(
                sheetContext,
                title: 'Last 3 Months',
                subtitle: 'Long-term performance',
                icon: Icons.insights_rounded,
              ),

              const SizedBox(height: 10),

              _periodOption(
                sheetContext,
                title: 'This Year',
                subtitle: 'Yearly performance',
                icon: Icons.auto_graph_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _periodOption(
    BuildContext sheetContext, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedPeriod == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = title;
        });

        Navigator.pop(sheetContext);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title selected'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? trainerYellow.withValues(alpha: 0.09) : cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? trainerYellow.withValues(alpha: 0.35)
                : borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: trainerYellow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: trainerYellow, size: 21),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: trainerYellow,
                size: 21,
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLIENTS
  // ============================================================

  void _openClients() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerClientsScreen()),
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  void _showAchievements() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: const BoxDecoration(
            color: cardColorLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Your Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              _achievementRow(
                icon: Icons.local_fire_department_rounded,
                title: '12 Day Streak',
                subtitle: 'Trained consistently for 12 days',
              ),

              const SizedBox(height: 10),

              _achievementRow(
                icon: Icons.fitness_center_rounded,
                title: '100+ Sessions',
                subtitle: 'Successfully completed 100 sessions',
              ),

              const SizedBox(height: 10),

              _achievementRow(
                icon: Icons.star_rounded,
                title: 'Top Rated Trainer',
                subtitle: 'Maintained a 4.9 average rating',
              ),

              const SizedBox(height: 10),

              _achievementRow(
                icon: Icons.people_alt_rounded,
                title: 'Client Champion',
                subtitle: 'Helped 20+ clients reach their goals',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _achievementRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trainerYellow.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: trainerYellow, size: 21),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: trainerYellow,
            size: 19,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHART MODEL
// ============================================================

class _ChartData {
  final String day;
  final double value;
  final int sessions;

  const _ChartData({
    required this.day,
    required this.value,
    required this.sessions,
  });
}
